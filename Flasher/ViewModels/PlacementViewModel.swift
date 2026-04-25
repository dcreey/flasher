import Foundation
import Observation

@Observable
final class PlacementViewModel {
    private let store: ProgressStore
    private let allWords: [Word]
    private let sentencesByWord: [String: [VocabSentence]]

    // Per-level state
    private var currentLevel: Int = 0
    private var levelCards: [CardItem] = []
    private var cardIndex: Int = 0
    private var levelMisses: Int = 0

    var userInput: String = ""
    var isShowingResult: Bool = false
    var lastCorrect: Bool = false
    var isComplete: Bool = false
    var placedAtLevel: Int = 0   // the level the user starts from (0 = beginning)

    var currentCard: CardItem? {
        levelCards.indices.contains(cardIndex) ? levelCards[cardIndex] : nil
    }

    // Progress within the current 10-card level
    var levelProgress: (current: Int, total: Int) {
        (min(cardIndex + 1, levelCards.count), levelCards.count)
    }

    // Which 10% range we're testing (1-based for display)
    var overallLevel: Int { currentLevel + 1 }

    // How many misses so far this level
    var missesThisLevel: Int { levelMisses }

    init(store: ProgressStore = .shared) {
        self.store = store
        self.allWords = SeedData.words
        let sentences = SeedData.buildSentences()
        self.sentencesByWord = Dictionary(grouping: sentences) { $0.wordID }
        loadLevel(0)
    }

    // MARK: - Level loading

    private func loadLevel(_ level: Int) {
        currentLevel = level
        levelMisses = 0
        cardIndex = 0

        let sample = SeedData.sampleForLevel(level)
        let byWord = sentencesByWord
        levelCards = sample.compactMap { word -> CardItem? in
            guard let sentences = byWord[word.spanish], !sentences.isEmpty else { return nil }
            let idx = sentences.indices.randomElement()!
            return CardItem(word: word, sentence: sentences[idx], sentenceIdx: idx)
        }
    }

    // MARK: - Actions

    func submit() {
        guard let card = currentCard else { return }
        let input  = normalize(userInput)
        let target = normalize(card.word.spanish)
        lastCorrect = input == target
        if !lastCorrect { levelMisses += 1 }
        isShowingResult = true
    }

    func dontKnow() {
        levelMisses += 1
        lastCorrect = false
        isShowingResult = true
    }

    func next() {
        userInput = ""
        isShowingResult = false
        cardIndex += 1
        if cardIndex >= levelCards.count {
            processLevelResult()
        }
    }

    // MARK: - Level result processing

    private func processLevelResult() {
        if levelMisses >= 3 {
            // ≥3 misses: place user at start of this level
            placedAtLevel = currentLevel
            if currentLevel > 0 {
                let passedIDs = allWords
                    .filter { SeedData.level(for: $0) < currentLevel }
                    .map { $0.spanish }
                store.markPlacementPassed(wordIDs: passedIDs)
            } else {
                store.skipPlacement()
            }
            isComplete = true
        } else {
            // < 3 misses: mark this level as placement-passed and advance
            let levelIDs = allWords
                .filter { SeedData.level(for: $0) == currentLevel }
                .map { $0.spanish }
            // Mark passed in the store but don't finalize yet (keep going)
            // We'll finalize at the end or on failure
            currentLevel += 1
            if currentLevel >= 10 {
                // Passed all levels
                let allIDs = allWords.map { $0.spanish }
                store.markPlacementPassed(wordIDs: allIDs)
                placedAtLevel = 10
                isComplete = true
            } else {
                // Batch-pass the finished level and move on
                store.markPlacementPassed(wordIDs: levelIDs)
                loadLevel(currentLevel)
            }
        }
    }

    // MARK: - Helpers

    private func normalize(_ s: String) -> String {
        s.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
