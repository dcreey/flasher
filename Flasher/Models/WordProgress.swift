import Foundation

struct WordProgress: Codable {
    let wordID: String
    var sessionCorrectCount: Int  // 0–5; reaches 5 = learned
    var placementPassed: Bool
    var lastSentenceIdx: Int      // index into per-word sentence array; avoids repeating same sentence
    var lastCorrectSession: Int   // session number when last answered correctly; -99 = never
    var totalWrongCount: Int
    var learnWordCount: Int
    var lastReviewDate: Date      // updated whenever word is answered wrong or learn word is clicked

    var learned: Bool { sessionCorrectCount >= SeedData.neededSessions }
    var effectivelyLearned: Bool { learned || placementPassed }

    init(wordID: String) {
        self.wordID = wordID
        self.sessionCorrectCount = 0
        self.placementPassed = false
        self.lastSentenceIdx = -1
        self.lastCorrectSession = -99
        self.totalWrongCount = 0
        self.learnWordCount = 0
        self.lastReviewDate = .distantPast
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        wordID = try c.decode(String.self, forKey: .wordID)
        sessionCorrectCount = try c.decode(Int.self, forKey: .sessionCorrectCount)
        placementPassed = try c.decode(Bool.self, forKey: .placementPassed)
        lastSentenceIdx = try c.decode(Int.self, forKey: .lastSentenceIdx)
        lastCorrectSession = try c.decode(Int.self, forKey: .lastCorrectSession)
        totalWrongCount = try c.decodeIfPresent(Int.self, forKey: .totalWrongCount) ?? 0
        learnWordCount = try c.decodeIfPresent(Int.self, forKey: .learnWordCount) ?? 0
        lastReviewDate = try c.decodeIfPresent(Date.self, forKey: .lastReviewDate) ?? .distantPast
    }
}
