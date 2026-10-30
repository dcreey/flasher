import SwiftUI

struct DictionaryView: View {
    @State private var recents = RecentWords.shared
    @State private var searchText: String = ""
    @State private var scope: SearchScope = .all
    @State private var results: [SearchHit] = []
    @State private var resultsKey: SearchKey?
    @State private var displayCount: Int = 100
    @State private var showSettings = false

    private let pageSize = 100

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
            if searchText.isEmpty {
                recentsList
            } else if resultsKey == currentKey, results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else if resultsKey == nil {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                resultsList
            }
        }
        .searchable(text: $searchText, prompt: scope.prompt)
        .searchScopes($scope, activation: .onSearchPresentation) {
            ForEach(SearchScope.allCases) { Text($0.title).tag($0) }
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .navigationTitle("Diccionario")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showSettings = true } label: { Image(systemName: "gearshape") }
                    .accessibilityLabel("Settings")
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .navigationDestination(for: SearchHit.self) { WordDetailView(word: $0.word, diminutive: $0.diminutive) }
        .task(id: currentKey) { await runSearch(for: currentKey) }
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
                Section {
                    ForEach(recentHits) { hit in
                        NavigationLink(value: hit) { DictionaryRow(hit: hit) }
                    }
                } header: {
                    HStack {
                        Text("Recent")
                        Spacer()
                        Button("Clear") { recents.clear() }
                            .font(.footnote)
                            .textCase(nil)
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private var resultsList: some View {
        List {
            ForEach(results.prefix(displayCount)) { hit in
                NavigationLink(value: hit) { DictionaryRow(hit: hit) }
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
                if hit.matchedEnglish {
                    Text("🇺🇸 EN")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Color.purple.opacity(0.15), in: Capsule())
                        .foregroundStyle(.purple)
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
