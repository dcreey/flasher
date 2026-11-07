import Foundation

enum PartOfSpeech: String, Codable {
    case noun, adjective, adverb, preposition, conjunction, pronoun, article, infinitive, interjection, numeral, phrase
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

extension Word {
    /// Feminine nouns that take "el" in the singular because they start with a stressed a.
    private static let elFeminine: Set<String> = ["agua", "águila", "alma", "arma", "hambre", "área", "hacha", "ala", "ancla", "asma", "aula", "aura", "ave", "habla", "hada", "álgebra", "ánima", "ánfora", "arpa", "asa", "aya"]

    /// Nouns that exist only in the plural (the first word counts for phrases like "gafas de sol").
    static let pluralOnly: Set<String> = ["gafas", "pantalones", "tijeras", "vacaciones", "celos", "ganas", "afueras", "alrededores", "añicos", "trizas", "víveres", "enseres",
                                          "modales", "nupcias", "exequias", "ahorros", "comestibles", "cercanías", "andas", "arras", "bártulos", "calzoncillos", "cojones",
                                          "creces", "entrañas", "expensas", "fauces", "ínfulas", "mientes", "parabienes", "pertrechos", "pésames", "preliminares",
                                          "sabiendas", "tinieblas", "vituallas", "binoculares", "prismáticos", "tenazas", "alicates", "leggings", "shorts", "vaqueros",
                                          "tejanos", "cosquillas", "macarrones", "paperas", "termas", "finanzas", "cabales", "atenuantes", "anales", "aspavientos",
                                          "bríos", "dineros", "anteojos", "escombros", "harapos"]

    /// Nouns with the matching "the" and the sex in brackets: "el fantasma (m)", "la casa (f)", "el/la estudiante (m/f)"; nouns that exist only in the plural
    /// say so: "las gafas (f, plural only)". People and animals with a form for each sex show both: "el dueño / la dueña". Other words stay as they are.
    var withArticle: String {
        guard partOfSpeech == .noun else { return spanish }
        let head = spanish.lowercased().split(separator: " ").first.map(String.init) ?? spanish
        // A phrase like "gafas de sol" has no gender of its own, so it takes the one of its first word
        let sex = gender ?? Lexicon.shared.meanings(for: spanish).first { $0.partOfSpeech == .noun }?.gender
            ?? (Word.pluralOnly.contains(head) ? Lexicon.shared.meanings(for: head).first { $0.partOfSpeech == .noun }?.gender : nil)
        if Word.pluralOnly.contains(head) {
            switch sex {
            case "m": return "los \(spanish) (m, plural only)"
            case "f": return "las \(spanish) (f, plural only)"
            default: return "los/las \(spanish) (plural only)"
            }
        }
        // People and animals that change with sex show both: "el dueño / la dueña", "el/la testigo (m/f)"
        if sex == "m" || sex == "mf", let pair = PersonNouns.label(for: self) { return pair.hasPrefix("el/la") ? "\(pair) (m/f)" : pair }
        switch sex {
        case "m": return "el \(spanish) (m)"
        case "f": return "\(Word.elFeminine.contains(spanish.lowercased()) ? "el" : "la") \(spanish) (f)"
        case "mf": return "el/la \(spanish) (m/f)"
        default: return spanish
        }
    }
}
