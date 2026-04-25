import Foundation
import Observation

@Observable
final class ProgressStore {
    static let shared = ProgressStore()

    private var progress: [String: WordProgress] = [:]
    private(set) var placementCompleted: Bool = false
    private(set) var currentSessionNumber: Int = 0

    private let progressKey = "word_progress_v3"
    private let placementKey = "placement_completed_v1"
    private let sessionKey = "session_number_v1"
    private let achievementsKey = "unlocked_achievements_v2"
    private let milestoneCyclesKey = "milestone_cycles_v1"

    private(set) var unlockedAchievements: Set<String> = []
    // Maps trigger rawValue → last 250-word cycle in which it fired
    private(set) var lastFiredMilestoneCycle: [String: Int] = [:]

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
        progress[wordID] = p
        save()
    }

    func markLearned(wordID: String, sentenceIdx: Int) {
        var p = progressFor(wordID)
        p.sessionCorrectCount = SeedData.neededSessions
        p.lastSentenceIdx = sentenceIdx
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
        UserDefaults.standard.removeObject(forKey: progressKey)
        UserDefaults.standard.removeObject(forKey: placementKey)
        UserDefaults.standard.removeObject(forKey: sessionKey)
        UserDefaults.standard.removeObject(forKey: achievementsKey)
        UserDefaults.standard.removeObject(forKey: milestoneCyclesKey)
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
        guard let data = UserDefaults.standard.data(forKey: progressKey),
              let decoded = try? JSONDecoder().decode([String: WordProgress].self, from: data)
        else { return }
        progress = decoded
    }
}
