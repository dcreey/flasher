import Foundation
import Observation

/// Words the user opened from the dictionary, most recent first.
@Observable
final class RecentWords {
    static let shared = RecentWords()

    private static let key = "recent_dictionary_words_v1"
    private static let limit = 20

    private(set) var ids: [String] = []

    var words: [Word] { ids.compactMap { Lexicon.shared.wordsByID[$0] } }

    private init() {
        ids = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
    }

    func record(_ word: Word) {
        ids.removeAll { $0 == word.id }
        ids.insert(word.id, at: 0)
        if ids.count > Self.limit { ids.removeLast(ids.count - Self.limit) }
        save()
    }

    func clear() {
        ids = []
        save()
    }

    private func save() {
        UserDefaults.standard.set(ids, forKey: Self.key)
    }
}

/// Queries the user typed in the dictionary, most recent first. A query is saved when it looks finished
/// (a result was tapped, Search was pressed, the text sat still, or the search was closed on it), never per keystroke.
@Observable
final class RecentSearches {
    static let shared = RecentSearches()

    private static let key = "recent_dictionary_searches_v1"
    private static let limit = 1000
    private static let minimumLength = 3

    private(set) var queries: [String] = []

    private init() {
        queries = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
    }

    func record(_ query: String) {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = text.searchKey
        guard key.count >= Self.minimumLength else { return }
        // Typing "prof" → "profesor" is one search: a query that extends or trims the latest one replaces it
        if let latest = queries.first?.searchKey, key.hasPrefix(latest) || latest.hasPrefix(key) { queries.removeFirst() }
        queries.removeAll { $0.searchKey == key }
        queries.insert(text, at: 0)
        if queries.count > Self.limit { queries.removeLast(queries.count - Self.limit) }
        save()
    }

    func remove(_ query: String) {
        queries.removeAll { $0 == query }
        save()
    }

    func clear() {
        queries = []
        save()
    }

    private func save() {
        UserDefaults.standard.set(queries, forKey: Self.key)
    }
}
