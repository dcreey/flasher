import Foundation
import Observation

@Observable
final class ProgressStore {
    static let shared = ProgressStore()

    private var progress: [String: WordProgress] = [:]
    private(set) var placementCompleted: Bool = false
    private(set) var currentSessionNumber: Int = 0

    private let progressKey            = "word_progress_v3"
    private let placementKey           = "placement_completed_v1"
    private let sessionKey             = "session_number_v1"
    private let achievementsKey        = "unlocked_achievements_v2"
    private let milestoneCyclesKey     = "milestone_cycles_v1"
    private let correctAnswersKey      = "total_correct_v1"
    private let accessoryTokensKey     = "accessory_tokens_v1"
    private let unlockedAccessoriesKey = "unlocked_accessories_raptor_v1"
    private let equippedAccessoriesKey = "equipped_accessories_v1"

    private(set) var unlockedAchievements: Set<String> = []
    // Maps trigger rawValue → last 225-word cycle in which it fired
    private(set) var lastFiredMilestoneCycle: [String: Int] = [:]

    // Accessory / token system
    private(set) var totalCorrectAnswers: Int = 0
    private(set) var accessoryTokens: Int = 0
    private(set) var unlockedAccessoryIDs: Set<String> = []
    private(set) var equippedAccessoryIDs: Set<String> = []

    // How many correct answers until the next token
    var correctsToNextToken: Int { 25 - (totalCorrectAnswers % 25) }

    func canFireMilestone(_ trigger: AchievementTrigger, cycle: Int) -> Bool {
        lastFiredMilestoneCycle[trigger.rawValue] != cycle
    }

    func recordMilestoneFired(_ trigger: AchievementTrigger, cycle: Int) {
        lastFiredMilestoneCycle[trigger.rawValue] = cycle
        if let data = try? JSONEncoder().encode(lastFiredMilestoneCycle) {
            UserDefaults.standard.set(data, forKey: milestoneCyclesKey)
        }
    }

    func unlock(_ name: String) -> Bool {
        guard !unlockedAchievements.contains(name) else { return false }
        unlockedAchievements.insert(name)
        if let data = try? JSONEncoder().encode(Array(unlockedAchievements)) {
            UserDefaults.standard.set(data, forKey: achievementsKey)
        }
        return true
    }

    private init() { load() }

    // MARK: - Read

    func progressFor(_ wordID: String) -> WordProgress {
        progress[wordID] ?? WordProgress(wordID: wordID)
    }

    func isEffectivelyLearned(_ wordID: String) -> Bool {
        progressFor(wordID).effectivelyLearned
    }

    func learnedCount(in words: [Word]) -> Int {
        words.filter { isEffectivelyLearned($0.spanish) }.count
    }

    func inProgressCount(in words: [Word]) -> Int {
        words.filter {
            let p = progressFor($0.spanish)
            return !p.effectivelyLearned && p.sessionCorrectCount > 0
        }.count
    }

    // Returns count of in-progress words at each session level 1…(neededSessions-1)
    func inProgressBreakdown(in words: [Word]) -> [Int: Int] {
        var breakdown: [Int: Int] = [:]
        for word in words {
            let p = progressFor(word.spanish)
            if !p.effectivelyLearned && p.sessionCorrectCount > 0 {
                breakdown[p.sessionCorrectCount, default: 0] += 1
            }
        }
        return breakdown
    }

    /// IDs of every word the user moved to the top of the queue, flashcard set or not.
    func prioritizedWordIDs() -> [String] {
        progress.values.filter { $0.priorityDate != nil }.map(\.wordID)
    }

    /// IDs of every word with any saved progress.
    func trackedWordIDs() -> [String] { Array(progress.keys) }

    // MARK: - Session

    func beginSession() {
        currentSessionNumber += 1
        UserDefaults.standard.set(currentSessionNumber, forKey: sessionKey)
    }

    // MARK: - Study

    func incrementSessionCorrect(wordID: String, sentenceIdx: Int) {
        var p = progressFor(wordID)
        p.sessionCorrectCount = min(p.sessionCorrectCount + 1, SeedData.neededSessions)
        p.lastSentenceIdx = sentenceIdx
        p.lastCorrectSession = currentSessionNumber
        p.priorityDate = nil
        p.lastReviewDate = Date()
        progress[wordID] = p
        save()
    }

    func recordWrong(wordID: String) {
        var p = progressFor(wordID)
        p.totalWrongCount += 1
        p.lastReviewDate = Date()
        progress[wordID] = p
        save()
    }

    func recordLearnWord(wordID: String) {
        var p = progressFor(wordID)
        p.learnWordCount += 1
        p.lastReviewDate = Date()
        progress[wordID] = p
        save()
    }

    // MARK: - Accessory tokens

    func recordCorrectAnswer() {
        let before = totalCorrectAnswers / 25
        totalCorrectAnswers += 1
        if totalCorrectAnswers / 25 > before { accessoryTokens += 1 }
        saveAccessoryState()
    }

    // Returns true if the token was spent and the accessory unlocked
    @discardableResult
    func unlockAccessory(id: String) -> Bool {
        guard accessoryTokens > 0, !unlockedAccessoryIDs.contains(id) else { return false }
        accessoryTokens -= 1
        unlockedAccessoryIDs.insert(id)
        saveAccessoryState()
        return true
    }

    func isAccessoryUnlocked(id: String) -> Bool { unlockedAccessoryIDs.contains(id) }

    func equipAccessory(id: String) {
        guard unlockedAccessoryIDs.contains(id) else { return }
        equippedAccessoryIDs.insert(id)
        saveAccessoryState()
    }

    func unequipAccessory(id: String) {
        equippedAccessoryIDs.remove(id)
        saveAccessoryState()
    }

    private func saveAccessoryState() {
        UserDefaults.standard.set(totalCorrectAnswers, forKey: correctAnswersKey)
        UserDefaults.standard.set(accessoryTokens, forKey: accessoryTokensKey)
        if let d = try? JSONEncoder().encode(Array(unlockedAccessoryIDs)) {
            UserDefaults.standard.set(d, forKey: unlockedAccessoriesKey)
        }
        if let d = try? JSONEncoder().encode(Array(equippedAccessoryIDs)) {
            UserDefaults.standard.set(d, forKey: equippedAccessoriesKey)
        }
    }

    // MARK: - Dictionary actions

    /// Puts a word back into the learning pool, discarding earlier progress.
    func flagForRelearning(wordID: String) {
        var p = progressFor(wordID)
        p.sessionCorrectCount = 0
        p.placementPassed = false
        p.permanentlySkipped = false
        p.lastCorrectSession = -99
        p.flaggedForRelearn = true
        p.lastReviewDate = Date()
        progress[wordID] = p
        save()
    }

    /// Flags the word for relearning and moves it to the front of the next study session.
    func moveToTopOfQueue(wordID: String) {
        flagForRelearning(wordID: wordID)
        var p = progressFor(wordID)
        p.priorityDate = Date()
        progress[wordID] = p
        save()
    }

    func removeFromQueue(wordID: String) {
        var p = progressFor(wordID)
        p.priorityDate = nil
        progress[wordID] = p
        save()
    }

    func permanentlySkip(wordID: String) {
        var p = progressFor(wordID)
        p.permanentlySkipped = true
        progress[wordID] = p
        save()
    }

    func isPermanentlySkipped(_ wordID: String) -> Bool {
        progressFor(wordID).permanentlySkipped
    }

    func skippedCount(in words: [Word]) -> Int {
        words.filter { isPermanentlySkipped($0.spanish) }.count
    }

    func markLearned(wordID: String, sentenceIdx: Int) {
        var p = progressFor(wordID)
        p.sessionCorrectCount = SeedData.neededSessions
        p.lastSentenceIdx = sentenceIdx
        p.lastReviewDate = Date()
        progress[wordID] = p
        save()
    }

    // MARK: - Placement

    func markPlacementPassed(wordIDs: [String]) {
        for id in wordIDs {
            var p = progressFor(id)
            p.placementPassed = true
            progress[id] = p
        }
        placementCompleted = true
        save()
        UserDefaults.standard.set(true, forKey: placementKey)
    }

    func skipPlacement() {
        placementCompleted = true
        UserDefaults.standard.set(true, forKey: placementKey)
    }

    // MARK: - Reset

    func resetAll() {
        progress = [:]
        placementCompleted = false
        currentSessionNumber = 0
        unlockedAchievements = []
        lastFiredMilestoneCycle = [:]
        totalCorrectAnswers = 0
        accessoryTokens = 0
        unlockedAccessoryIDs = []
        equippedAccessoryIDs = []
        RecentWords.shared.clear()
        for key in [progressKey, placementKey, sessionKey, achievementsKey,
                    milestoneCyclesKey, correctAnswersKey, accessoryTokensKey,
                    unlockedAccessoriesKey, equippedAccessoriesKey] {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(progress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
        UserDefaults.standard.set(placementCompleted, forKey: placementKey)
    }

    private func load() {
        placementCompleted = UserDefaults.standard.bool(forKey: placementKey)
        currentSessionNumber = UserDefaults.standard.integer(forKey: sessionKey)
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let names = try? JSONDecoder().decode([String].self, from: data) {
            unlockedAchievements = Set(names)
        }
        if let data = UserDefaults.standard.data(forKey: milestoneCyclesKey),
           let cycles = try? JSONDecoder().decode([String: Int].self, from: data) {
            lastFiredMilestoneCycle = cycles
        }
        totalCorrectAnswers = UserDefaults.standard.integer(forKey: correctAnswersKey)
        accessoryTokens = UserDefaults.standard.integer(forKey: accessoryTokensKey)
        if let d = UserDefaults.standard.data(forKey: unlockedAccessoriesKey),
           let arr = try? JSONDecoder().decode([String].self, from: d) {
            unlockedAccessoryIDs = Set(arr)
        }
        if let d = UserDefaults.standard.data(forKey: equippedAccessoriesKey),
           let arr = try? JSONDecoder().decode([String].self, from: d) {
            equippedAccessoryIDs = Set(arr)
        }
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let decoded = try? JSONDecoder().decode([String: WordProgress].self, from: data)
        else { return }
        progress = decoded
    }
}
