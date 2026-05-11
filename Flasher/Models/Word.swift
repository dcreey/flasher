import Foundation

enum PartOfSpeech: String, Codable {
    case noun, adjective, adverb, preposition, conjunction, pronoun, article, infinitive
}

struct Word: Identifiable, Codable, Hashable {
    // Spanish word is stable and unique — use it as ID so progress survives restarts
    var id: String { spanish }
    let order: Int
    let spanish: String
    let english: String
    let partOfSpeech: PartOfSpeech
    let gender: String?
}

struct VocabSentence: Identifiable, Codable {
    let id: UUID
    let wordID: String   // Spanish word
    let template: String
    let full: String
    let translation: String  // English translation of the full sentence

    init(wordID: String, template: String, full: String, translation: String = "") {
        self.id = UUID()
        self.wordID = wordID
        self.template = template.decodedSentence
        self.full = full.decodedSentence
        self.translation = translation.decodedSentence
    }
}

private extension String {
    var decodedSentence: String {
        var s = self
        // Double-encoded entities first
        let replacements: [(String, String)] = [
            ("&amp;gt;", ">"), ("&amp;lt;", "<"), ("&amp;quot;", "\""),
            ("&amp;", "&"), ("&lt;", "<"), ("&gt;", ">"), ("&quot;", "\""), ("&apos;", "'"), ("&#39;", "'"),
            // RTF smart-quote artifact
            ("\\'97", "'"),
            // HTML tags
        ]
        for (from, to) in replacements {
            s = s.replacingOccurrences(of: from, with: to)
        }
        // Strip any remaining HTML tags like <i>, </i>, <br>
        while let open = s.range(of: "<"), let close = s.range(of: ">", range: open.upperBound..<s.endIndex) {
            s.removeSubrange(open.lowerBound...close.lowerBound)
        }
        return s.trimmingCharacters(in: .whitespaces)
    }
}
