import Foundation
import Observation

/// Words the user opened from the dictionary, most recent first.
@Observable
final class RecentWords {
    static let shared = RecentWords()

    private static let key = "recent_dictionary_words_v1"
    private static let limit = 20

    private(set) var ids: [String] = []

    private static let wordsByID: [String: Word] = Dictionary(
        SeedData.words.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

    var words: [Word] { ids.compactMap { Self.wordsByID[$0] } }

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
