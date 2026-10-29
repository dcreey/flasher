import SwiftUI

/// A search result. `diminutive` is set when the query (or the word itself) is a -ito/-ita form.
struct SearchHit: Identifiable, Hashable {
    let word: Word
    let diminutive: Diminutive?
    var id: String { word.id }
}

struct DictionaryView: View {
    @State private var recents = RecentWords.shared
    @State private var searchText: String = ""
    @State private var displayCount: Int = 100

    private let pageSize = 100

    private var results: [SearchHit] {
        DictionaryIndex.search(searchText)
    }

    /// Recently opened words, shown above the full list until the user starts typing.
    private var recentHits: [SearchHit] {
        guard searchText.isEmpty else { return [] }
        return recents.words.map { SearchHit(word: $0, diminutive: DiminutiveResolver.resolve($0.spanish)) }
    }

    private var displayed: ArraySlice<SearchHit> {
        results.prefix(displayCount)
    }

    private var allRows: some View {
        ForEach(displayed) { hit in
            NavigationLink(value: hit) {
                DictionaryRow(hit: hit)
            }
        }
    }

    var body: some View {
        Group {
            if results.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                List {
                    if !recentHits.isEmpty {
                        Section {
                            ForEach(recentHits) { hit in
                                NavigationLink(value: hit) {
                                    DictionaryRow(hit: hit)
                                }
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
                    if recentHits.isEmpty {
                        allRows
                    } else {
                        Section("All words") { allRows }
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
        .searchable(text: $searchText, prompt: "Search Spanish or English")
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .navigationTitle("Diccionario")
        .navigationDestination(for: SearchHit.self) { WordDetailView(word: $0.word, diminutive: $0.diminutive) }
        .onChange(of: searchText) { displayCount = pageSize }
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
}

private extension DictionaryRow {
    var diminutiveNote: String? {
        guard let d = hit.diminutive else { return nil }
        if d.inDictionary { return "diminutive of \(d.base.spanish)" }   // the entry is itself the -ito/-ita word
        return [d.form, d.meaning].compactMap { $0 }.joined(separator: " = ")  // searched form → base word
    }
}

/// Precomputed lowercase/diacritic-free strings so each keystroke is a cheap scan of ~6k words.
private enum DictionaryIndex {
    private struct Entry {
        let word: Word
        let spanish: String
        let english: String
        let fuzzyTerms: [[Character]]  // Spanish headword plus each English gloss/word, for typo matching
        let diminutive: Diminutive?    // set when the entry itself is an -ito/-ita word
    }

    private static let entries: [Entry] = SeedData.words.map {
        let spanish = normalize($0.spanish)
        let english = normalize($0.english)
        let englishTerms = english
            .split(whereSeparator: { ", ".contains($0) })
            .map { Array($0) }
        return Entry(word: $0, spanish: spanish, english: english,
                     fuzzyTerms: [Array(spanish)] + englishTerms,
                     diminutive: DiminutiveResolver.resolve($0.spanish))
    }

    static func normalize(_ s: String) -> String { s.searchKey }

    /// Empty query lists everything by frequency. Otherwise ranks exact > prefix > contains,
    /// Spanish matches ahead of English ones, and keeps frequency order within each rank.
    /// Queries of 4+ characters also match near-misses (typos) after the direct matches.
    static func search(_ query: String) -> [SearchHit] {
        let q = normalize(query)
        guard !q.isEmpty else { return entries.map { SearchHit(word: $0.word, diminutive: $0.diminutive) } }

        let query = Array(q)
        let maxTypos = query.count >= 7 ? 2 : (query.count >= 4 ? 1 : 0)
        var ranked: [(rank: Int, hit: SearchHit)] = []

        // "casita" → casa. Goes first unless "casita" has its own entry; that entry (rank 0) then stays on top.
        let diminutive = DiminutiveResolver.resolve(q)
        if let diminutive {
            ranked.append((diminutive.inDictionary ? 1 : -1, SearchHit(word: diminutive.base, diminutive: diminutive)))
        }

        for e in entries where e.word.id != diminutive?.base.id {
            if let rank = rank(for: q, in: e) {
                ranked.append((rank * 2, SearchHit(word: e.word, diminutive: e.diminutive)))
            } else if maxTypos > 0,
                      let distance = e.fuzzyTerms.compactMap({ editDistance(query, $0, limit: maxTypos) }).min() {
                // below every direct match; closer typos first
                ranked.append(((4 + distance) * 2, SearchHit(word: e.word, diminutive: e.diminutive)))
            }
        }
        return ranked
            .sorted { $0.rank != $1.rank ? $0.rank < $1.rank : $0.hit.word.order < $1.hit.word.order }
            .map(\.hit)
    }

    private static func rank(for q: String, in e: Entry) -> Int? {
        if e.spanish == q { return 0 }
        if e.spanish.hasPrefix(q) { return 1 }
        if matchesEnglishTerm(q, in: e.english) { return 2 }
        if e.spanish.contains(q) { return 3 }
        if e.english.contains(q) { return 4 }
        return nil
    }

    /// English glosses are comma separated ("of, from"), so match whole terms.
    private static func matchesEnglishTerm(_ q: String, in english: String) -> Bool {
        english.split(separator: ",").contains { $0.trimmingCharacters(in: .whitespaces) == q }
    }

    /// Damerau-Levenshtein (adjacent swaps count as one edit). Returns nil once the
    /// distance is certain to exceed `limit`, so most comparisons bail out immediately.
    private static func editDistance(_ a: [Character], _ b: [Character], limit: Int) -> Int? {
        if abs(a.count - b.count) > limit { return nil }
        if a.isEmpty || b.isEmpty { return max(a.count, b.count) <= limit ? max(a.count, b.count) : nil }

        var twoAgo = [Int](repeating: 0, count: b.count + 1)
        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)

        for i in 1...a.count {
            current[0] = i
            var rowMin = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                var d = min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    d = min(d, twoAgo[j - 2] + 1)
                }
                current[j] = d
                rowMin = min(rowMin, d)
            }
            if rowMin > limit { return nil }
            (twoAgo, previous, current) = (previous, current, twoAgo)
        }
        return previous[b.count] <= limit ? previous[b.count] : nil
    }
}
