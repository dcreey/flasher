import Foundation

enum SeedData {
    /// Number of sessions a word must be answered correctly to be "learned"
    static let neededSessions = 5

    // MARK: - Level helpers (10 levels, each = 10% of vocabulary)

    static func level(for word: Word) -> Int {
        guard !words.isEmpty else { return 0 }
        return min(word.order * 10 / words.count, 9)
    }

    static func wordsInLevel(_ level: Int) -> [Word] {
        words.filter { self.level(for: $0) == level }
    }

    // MARK: - Percentile (0–99)

    static func percentile(for word: Word) -> Int {
        guard !words.isEmpty else { return 0 }
        return min(word.order * 100 / words.count, 99)
    }

    // MARK: - Placement sampling

    /// Returns 10 words for the given level (0–9), one from each 1% sub-bucket within it.
    static func sampleForLevel(_ level: Int) -> [Word] {
        let total = words.count
        return (0..<10).compactMap { i -> Word? in
            let pct = level * 10 + i          // e.g. level 0 → percentiles 0–9
            let start = pct * total / 100
            let end   = min((pct + 1) * total / 100, total)
            guard start < end else { return nil }
            return Array(words[start..<end]).randomElement()
        }
    }

    // MARK: - Sentence lookup

    static func buildSentences() -> [VocabSentence] {
        var result: [VocabSentence] = []
        let crafted = handcraftedSentenceMap  // from SeedData+Sentences
        for word in words {
            if let sentences = crafted[word.spanish], !sentences.isEmpty {
                result.append(contentsOf: sentences.map {
                    VocabSentence(wordID: word.spanish, template: $0.0, full: $0.1, translation: $0.2)
                })
            } else {
                result.append(contentsOf: templateSentences(for: word))
            }
        }
        return result
    }
}
