import Foundation
import Observation

enum CardResult {
    case correct, incorrect, revealed
}

struct CardItem: Identifiable {
    let id = UUID()
    let word: Word
    let sentence: VocabSentence
    let sentenceIdx: Int
}

@Observable
final class StudyViewModel {
    static let sessionSize = 20

    private let store: ProgressStore
    private let allWords: [Word]
    private let sentencesByWord: [String: [VocabSentence]]

    private static let footWords: Set<String> = [
        "pie", "zapato", "bota", "calcetín", "calceta", "tobillo", "talón", "torcedura"
    ]
    private static let dungeonWords: Set<String> = [
        "magia", "mago", "mágico", "héroe", "fortaleza", "mito", "leyenda",
        "batallar", "daño", "exorcismo", "pitaya", "pitahaya", "pez espada"
    ]

    private var queue: [CardItem] = []
    private var sessionResolvedIDs: Set<String> = []
    private(set) var sessionIncorrectIDs: Set<String> = []
    private var sessionMissCount: [String: Int] = [:]

    var currentCard: CardItem?
    var userInput: String = ""
    var lastResult: CardResult?
    var isShowingResult: Bool = false
    var sessionComplete: Bool = false
    var synonymHint: Character? = nil  // non-nil while user needs a hint after typing a synonym
    var pendingAchievement: AchievementToast? = nil

    private(set) var sessionWordCount: Int = 0
    private var correctStreak: Int = 0
    private var wrongStreak: Int = 0
    private var sessionCorrectCount: Int = 0
    private var correctSinceLastRandom: Int = 0
    private var nextRandomThreshold: Int = Int.random(in: 2...6)
    private var firedTriggersThisSession: Set<AchievementTrigger> = []

    var sessionProgress: (done: Int, total: Int) {
        (sessionResolvedIDs.count, sessionWordCount)
    }

    var currentCardSessionCorrectCount: Int {
        guard let card = currentCard else { return 0 }
        return store.progressFor(card.word.spanish).sessionCorrectCount
    }

    var currentCardWasIncorrectThisSession: Bool {
        guard let card = currentCard else { return false }
        return sessionIncorrectIDs.contains(card.word.spanish)
    }

    init(store: ProgressStore = .shared) {
        self.store = store
        self.allWords = SeedData.words
        let sentences = SeedData.buildSentences()
        self.sentencesByWord = Dictionary(grouping: sentences) { $0.wordID }
        store.beginSession()
        buildQueue()
        advance()
    }

    // MARK: - Queue building

    private func buildQueue() {
        let selected = selectSessionWords()
        sessionWordCount = selected.count
        queue = selected.compactMap { word -> CardItem? in
            guard let (sentence, idx) = pickSentence(for: word) else { return nil }
            return CardItem(word: word, sentence: sentence, sentenceIdx: idx)
        }.shuffled()
    }

    private func selectSessionWords() -> [Word] {
        let prevSession = store.currentSessionNumber - 1
        let allAvailable = allWords.filter { !store.isEffectivelyLearned($0.spanish) }
        // Prefer words not answered correctly in the immediately preceding session
        let cooledDown = allAvailable.filter {
            store.progressFor($0.spanish).lastCorrectSession != prevSession
        }
        let available = cooledDown.count >= 5 ? cooledDown : allAvailable

        // Priority: in-progress words (sessionCorrectCount 1-4, desc) then new by order
        let sorted = available.sorted { a, b in
            let ca = store.progressFor(a.spanish).sessionCorrectCount
            let cb = store.progressFor(b.spanish).sessionCorrectCount
            if ca > 0 && cb == 0 { return true }
            if ca == 0 && cb > 0 { return false }
            if ca > 0 && cb > 0  { return ca > cb }
            return a.order < b.order
        }

        // Ensure at least one word of each key POS type (if available)
        let targetPOS: [PartOfSpeech] = [.noun, .infinitive, .adjective, .adverb, .preposition, .conjunction]
        var selected: [Word] = []
        var selectedIDs = Set<String>()

        for pos in targetPOS {
            if let rep = sorted.first(where: { $0.partOfSpeech == pos && !selectedIDs.contains($0.spanish) }) {
                selected.append(rep)
                selectedIDs.insert(rep.spanish)
            }
        }

        // Fill remaining slots with highest-priority words regardless of type
        let remaining = sorted.filter { !selectedIDs.contains($0.spanish) }
        let fill = Array(remaining.prefix(max(0, Self.sessionSize - selected.count)))
        return selected + fill
    }

    // Pick a sentence different from the last one used for this word
    private func pickSentence(for word: Word) -> (VocabSentence, Int)? {
        guard let sentences = sentencesByWord[word.spanish], !sentences.isEmpty else { return nil }
        let lastIdx = store.progressFor(word.spanish).lastSentenceIdx
        let candidates = sentences.indices.filter { $0 != lastIdx }
        let idx = candidates.randomElement() ?? sentences.indices.randomElement()!
        return (sentences[idx], idx)
    }

    // MARK: - Advance

    private func advance() {
        userInput = ""
        synonymHint = nil
        lastResult = nil
        isShowingResult = false
        if queue.isEmpty {
            currentCard = nil
            sessionComplete = true
        } else {
            currentCard = queue.removeFirst()
        }
    }

    // MARK: - Actions

    func submit() {
        guard let card = currentCard else { return }
        synonymHint = nil

        let input = normalize(userInput)

        if isCorrectAnswer(input, for: card.word) {
            resolveCorrect(card)
        } else if SeedData.isSynonym(input: input, of: card.word.spanish) {
            synonymHint = card.word.spanish.first
            userInput = ""
        } else {
            correctStreak = 0
            wrongStreak += 1
            sessionIncorrectIDs.insert(card.word.spanish)
            let missCount = (sessionMissCount[card.word.spanish] ?? 0) + 1
            sessionMissCount[card.word.spanish] = missCount
            lastResult = .incorrect
            isShowingResult = true
            checkAchievements(event: .wrong)
            if missCount == 2 { fireAchievement(.repeatedMiss) }
            if missCount == 3 { fireAchievement(.repeatedMiss3) }
            if missCount == 4 { fireAchievement(.repeatedMiss4) }
        }
    }

    private func isCorrectAnswer(_ normalizedInput: String, for word: Word) -> Bool {
        let target = normalize(word.spanish)
        if normalizedInput == target { return true }
        // Accept both gendered forms of adjectives (-o / -a swap)
        if word.partOfSpeech == .adjective {
            if target.hasSuffix("o") {
                let fem = String(target.dropLast()) + "a"
                if normalizedInput == fem { return true }
            } else if target.hasSuffix("a") {
                let masc = String(target.dropLast()) + "o"
                if normalizedInput == masc { return true }
            }
        }
        return false
    }

    func learnWord() {
        guard let card = currentCard else { return }
        sessionIncorrectIDs.insert(card.word.spanish)
        lastResult = .revealed
        isShowingResult = true
        fireAchievement(.learnWord)
    }

    private func resolveCorrect(_ card: CardItem) {
        correctStreak += 1
        wrongStreak = 0
        sessionCorrectCount += 1

        if !sessionResolvedIDs.contains(card.word.spanish) {
            sessionResolvedIDs.insert(card.word.spanish)
            let wasIncorrect = sessionIncorrectIDs.contains(card.word.spanish)
            if wasIncorrect {
                store.incrementSessionCorrect(wordID: card.word.spanish, sentenceIdx: card.sentenceIdx)
                if store.isEffectivelyLearned(card.word.spanish) { fireAchievement(.wordMastered) }
            } else {
                store.markLearned(wordID: card.word.spanish, sentenceIdx: card.sentenceIdx)
            }
            queue.removeAll { $0.word.spanish == card.word.spanish }
            if (sessionMissCount[card.word.spanish] ?? 0) >= 2 { fireAchievement(.redemption) }
            if Self.footWords.contains(card.word.spanish)    { fireAchievement(.footWord) }
            if Self.dungeonWords.contains(card.word.spanish) { fireAchievement(.dungeonWord) }
        }
        lastResult = .correct
        isShowingResult = true
        checkAchievements(event: .correct)
        checkRandomEncouragement()
    }

    func next() {
        guard let card = currentCard else { advance(); return }

        if lastResult == .incorrect || lastResult == .revealed {
            // Re-queue: insert in second half of queue so it comes back, not immediately
            if let (sentence, idx) = pickSentence(for: card.word) {
                let insertAt = Int.random(in: max(1, queue.count / 2)...max(1, queue.count))
                queue.insert(CardItem(word: card.word, sentence: sentence, sentenceIdx: idx),
                             at: min(insertAt, queue.count))
            }
        }
        advance()
    }

    // MARK: - Achievements

    private enum SessionEvent { case correct, wrong }

    private func fireAchievement(_ trigger: AchievementTrigger) {
        guard pendingAchievement == nil else { return }
        guard firedTriggersThisSession.insert(trigger).inserted else { return }
        if let toast = AchievementMessages.pickUnseen(for: trigger, seen: store.unlockedAchievements) {
            store.unlock(toast.name)
            pendingAchievement = toast
        }
    }

    private func fireCycledAchievement(_ trigger: AchievementTrigger, cycle: Int) {
        guard pendingAchievement == nil else { return }
        guard firedTriggersThisSession.insert(trigger).inserted else { return }
        guard store.canFireMilestone(trigger, cycle: cycle) else { return }
        if let toast = AchievementMessages.pickUnseen(for: trigger, seen: store.unlockedAchievements) {
            store.unlock(toast.name)
            store.recordMilestoneFired(trigger, cycle: cycle)
            pendingAchievement = toast
        }
    }

    private func checkAchievements(event: SessionEvent) {
        switch event {
        case .correct:
            fireAchievement(.firstCorrect)
            if correctStreak == 5  { fireAchievement(.streak5) }
            if correctStreak == 10 { fireAchievement(.streak10) }
            if queue.isEmpty && sessionIncorrectIDs.isEmpty && sessionCorrectCount == sessionWordCount {
                fireAchievement(.perfectSession)
            }
            let learned = store.learnedCount(in: allWords)
            let milestones: [(minWords: Int, trigger: AchievementTrigger, cycleSize: Int)] = [
                (10,   .learned10,   101),
                (50,   .learned50,   101),
                (100,  .learned100,  100),
                (250,  .learned250,  250),
                (500,  .learned500,  500),
                (1000, .learned1000, 1000),
            ]
            for (minWords, trigger, cycleSize) in milestones where learned >= minWords {
                fireCycledAchievement(trigger, cycle: learned / cycleSize)
            }
        case .wrong:
            fireAchievement(.firstWrong)
            if wrongStreak == 5 { fireAchievement(.wrongStreak5) }
        }
    }

    private func checkRandomEncouragement() {
        guard pendingAchievement == nil else { return }
        correctSinceLastRandom += 1
        if correctSinceLastRandom >= nextRandomThreshold {
            correctSinceLastRandom = 0
            nextRandomThreshold = Int.random(in: 2...6)
            if let toast = AchievementMessages.pickUnseenRandom(seen: store.unlockedAchievements) {
                store.unlock(toast.name)
                pendingAchievement = toast
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
