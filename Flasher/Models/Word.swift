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
        self.template = template
        self.full = full
        self.translation = translation
    }
}
