import SwiftUI

struct DictionaryView: View {
    @State private var recents = RecentWords.shared
    @State private var searchText: String = ""
    @State private var scope: SearchScope = .all
    @State private var results: [SearchHit] = []
    @State private var resultsKey: SearchKey?
    @State private var displayCount: Int = 100
    @State private var showSettings = false
    @State private var showHistory = false
    @State private var searches = RecentSearches.shared
    @State private var isSearching = false
    /// The latest non-empty query; saved whenever the search is closed or the app leaves the screen.
    @State private var lastQuery = ""
    @Environment(\.scenePhase) private var scenePhase

    private let pageSize = 100
    /// Only what fits above the keyboard shows here; the rest lives in the searchable history.
    private static let inlineSearches = 5

    private struct SearchKey: Equatable {
        let text: String
        let scope: SearchScope
    }

    private var currentKey: SearchKey { SearchKey(text: searchText, scope: scope) }

    private var recentHits: [SearchHit] {
        recents.words.map { SearchHit(word: $0, diminutive: DiminutiveResolver.resolve($0.spanish)) }
    }

    var body: some View {
        Group {
            if searchText.isEmpty, isSearching {
                recentSearchesList
            } else if searchText.isEmpty {
                recentsList
            } else if resultsKey == currentKey, results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else if resultsKey == nil {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                resultsList
            }
        }
        .background { SearchStateReader(isSearching: $isSearching) }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: scope.prompt)
        .searchScopes($scope, activation: .onSearchPresentation) {
            ForEach(SearchScope.allCases) { Text($0.title).tag($0) }
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .navigationTitle("El Pie")
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSettings = true } label: { Image(systemName: "gearshape") }
                    .accessibilityLabel("Settings")
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showHistory) {
            SearchHistoryView { query in
                showHistory = false
                searchText = query
            }
        }
        .navigationDestination(for: SearchHit.self) { WordDetailView(word: $0.word, diminutive: $0.diminutive) }
        .task(id: currentKey) { await runSearch(for: currentKey) }
        .onSubmit(of: .search) { searches.record(searchText) }
        .onChange(of: isSearching) { _, searching in
            // Any close is the strongest sign the query was what they wanted
            if !searching { saveLastQuery() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { saveLastQuery() }
        }
        .onChange(of: searchText) { _, text in
            if !text.isEmpty { lastQuery = text }
        }
        .task(id: searchText) {
            // Text that sits still with results on screen counts as a finished search
            if searchText.isEmpty {
                // Text emptied while the field stays active means they erased it; closing empties it too, so give that a beat
                try? await Task.sleep(for: .milliseconds(400))
                if !Task.isCancelled, isSearching { lastQuery = "" }
                return
            }
            guard searchText.count >= 3 else { return }
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled, resultsKey == currentKey, !results.isEmpty else { return }
            searches.record(searchText)
        }
    }

    private func saveLastQuery() {
        guard !lastQuery.isEmpty else { return }
        searches.record(lastQuery)
        lastQuery = ""
    }

    private func runSearch(for key: SearchKey) async {
        guard !key.text.isEmpty else {
            results = []
            resultsKey = nil
            return
        }
        try? await Task.sleep(for: .milliseconds(120))
        guard !Task.isCancelled else { return }
        let hits = await Task.detached(priority: .userInitiated) {
            DictionaryIndex.search(key.text, scope: key.scope)
        }.value
        guard !Task.isCancelled else { return }
        results = hits
        resultsKey = key
        displayCount = pageSize
    }

    @ViewBuilder
    private var recentsList: some View {
        if recentHits.isEmpty {
            ContentUnavailableView(
                "No recent searches",
                systemImage: "clock",
                description: Text("Recent searches show up here.")
            )
        } else {
            List {
                listHeader("Recent") { recents.clear() }
                ForEach(recentHits) { hit in
                    NavigationLink(value: hit) { DictionaryRow(hit: hit) }
                }
            }
            .listStyle(.plain)
        }
    }

    /// A title row that scrolls with the list; a pinned section header is see-through and lets rows show behind it.
    private func listHeader(_ title: String, clear: @escaping () -> Void) -> some View {
        HStack {
            Text(title).font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
            Spacer()
            Button("Clear", action: clear).font(.footnote)
        }
        .buttonStyle(.borderless)
        .listRowSeparator(.hidden)
    }

    @ViewBuilder
    private var recentSearchesList: some View {
        if searches.queries.isEmpty {
            ContentUnavailableView(
                "No recent searches",
                systemImage: "magnifyingglass",
                description: Text("Searches you finish show up here.")
            )
        } else {
            List {
                listHeader("Recent searches") { searches.clear() }
                ForEach(searches.queries.prefix(Self.inlineSearches), id: \.self) { query in
                    Button { searchText = query } label: {
                        Label(query, systemImage: "magnifyingglass").foregroundStyle(.primary)
                    }
                    .swipeActions { Button("Delete", role: .destructive) { searches.remove(query) } }
                }
                if searches.queries.count > Self.inlineSearches {
                    Button { showHistory = true } label: {
                        Label("See all searches", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .listStyle(.plain)
            .scrollDisabled(true)
        }
    }

    private var resultsList: some View {
        List {
            ForEach(results.prefix(displayCount)) { hit in
                NavigationLink(value: hit) { DictionaryRow(hit: hit) }
                    .simultaneousGesture(TapGesture().onEnded { searches.record(searchText) })
            }
            if displayCount < results.count {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .onAppear { displayCount += pageSize }
            }
        }
        .listStyle(.plain)
    }
}

/// Every saved search, filtered by what the user types.
private struct SearchHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searches = RecentSearches.shared
    @State private var filter = ""
    let pick: (String) -> Void

    private var shown: [String] {
        let key = filter.searchKey
        return key.isEmpty ? searches.queries : searches.queries.filter { $0.searchKey.contains(key) }
    }

    var body: some View {
        NavigationStack {
            List(shown, id: \.self) { query in
                Button { pick(query) } label: {
                    Label(query, systemImage: "magnifyingglass").foregroundStyle(.primary)
                }
                .swipeActions { Button("Delete", role: .destructive) { searches.remove(query) } }
            }
            .listStyle(.plain)
            .overlay { if shown.isEmpty { ContentUnavailableView.search(text: filter) } }
            .searchable(text: $filter, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search your history")
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .navigationTitle("Search history")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}

/// Reports whether the search field is active; the environment value is only readable from inside the searchable view.
private struct SearchStateReader: View {
    @Environment(\.isSearching) private var environmentIsSearching
    @Binding var isSearching: Bool

    var body: some View {
        Color.clear.onChange(of: environmentIsSearching, initial: true) { _, value in isSearching = value }
    }
}

private struct DictionaryRow: View {
    @Environment(ProgressStore.self) private var store
    let hit: SearchHit

    var body: some View {
        let word = hit.word
        let p = store.progressFor(word.spanish)
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(word.spanish)
                    .font(.headline)
                if Lexicon.shared.hasMexicanMeaning(word) {
                    Text("🇲🇽 MX")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color.green.opacity(0.18), in: Capsule())
                        .foregroundStyle(Color.green)
                }
                if p.priorityDate != nil {
                    Image(systemName: "arrow.up.to.line")
                        .font(.caption)
                        .foregroundStyle(.blue)
                } else if p.flaggedForRelearn && !p.effectivelyLearned {
                    Image(systemName: "flag.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            Text(word.english)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if let note = diminutiveNote {
                Text(note)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.vertical, 2)
    }

    private var diminutiveNote: String? {
        guard let d = hit.diminutive else { return nil }
        if hit.word.spanish.searchKey == d.form.searchKey { return "\(d.kind.label) of \(d.base.spanish)" }  // the entry is the derived word
        return [d.form, d.meaning].compactMap { $0 }.joined(separator: " = ")   // searched form → base word
    }
}
