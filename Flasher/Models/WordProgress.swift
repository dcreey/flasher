import Foundation

struct WordProgress: Codable {
    let wordID: String
    var sessionCorrectCount: Int  // 0–5; reaches 5 = learned
    var placementPassed: Bool
    var lastSentenceIdx: Int      // index into per-word sentence array; avoids repeating same sentence
    var lastCorrectSession: Int   // session number when last answered correctly; -99 = never

    var learned: Bool { sessionCorrectCount >= SeedData.neededSessions }
    var effectivelyLearned: Bool { learned || placementPassed }

    init(wordID: String) {
        self.wordID = wordID
        self.sessionCorrectCount = 0
        self.placementPassed = false
        self.lastSentenceIdx = -1
        self.lastCorrectSession = -99
    }
}
