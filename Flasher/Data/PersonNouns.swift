import Foundation

/// Nouns for people and animals that change with sex: el dueño / la dueña, el actor / la actriz, el caballo / la yegua.
/// The pairs come from Wiktionary's noun forms (extras.tsv), which list a feminine only for people and animals,
/// plus a few common ones it leaves out. One entry stands for both: the feminine is shown with the masculine and
/// finds it in search. A feminine with meanings of its own (la música = music) keeps its own entry as well.
enum PersonNouns {
    /// Common pairs the bundled data misses.
    static let supplements: [String: [String]] = [
        "presidente": ["presidenta"], "físico": ["física"], "hombre": ["mujer"], "toro": ["vaca"],
        "príncipe": ["princesa"], "alcalde": ["alcaldesa"], "héroe": ["heroína"], "emperador": ["emperatriz"],
        "sirviente": ["sirvienta"], "dependiente": ["dependienta"], "carnero": ["oveja"], "yerno": ["nuera"],
        "padrastro": ["madrastra"], "padrino": ["madrina"], "papá": ["mamá"], "tigre": ["tigresa"],
    ]

    /// Masculine headword → its feminine forms. A list that includes the headword means one form for both (el/la testigo).
    static let feminine: [String: [String]] = {
        var map: [String: [String]] = [:]
        for (headword, forms) in Extras.shared.nounForms where !forms.feminine.isEmpty {
            guard Lexicon.shared.meanings(for: headword).contains(where: { $0.partOfSpeech == .noun && ($0.gender == "m" || $0.gender == "mf") }) else { continue }
            map[headword] = forms.feminine
        }
        for (headword, forms) in supplements where map[headword] == nil { map[headword] = forms }
        return map
    }()

    /// Feminine form → its masculine headword (dueña → dueño).
    static let masculine: [String: String] = {
        var map: [String: String] = [:]
        for (headword, forms) in feminine { for form in forms where form != headword && map[form] == nil { map[form] = headword } }
        return map
    }()

    /// Senses that only say "the woman version" or give an old "X's wife" reading; they add nothing to the pair.
    private static let femaleOnly = try! NSRegularExpression(pattern: "\\b(female|woman|women|wife|girl|lady|ladies|mistress|queen|daughter|sister|mother|widow|bride|fiancée|niece|aunt|nun|hen|mare|madam|heroine|feminine|mum|mom|mommy|mama|hag|landlady|girlfriend|gal|chick|dowager|maid|nanny|granny|grandma|matron|maiden|nursemaid|wetnurse)\\b|ess\\b", options: [.caseInsensitive])

    private static func isFemaleOnly(_ text: String) -> Bool {
        femaleOnly.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) != nil
    }

    /// The senses of a feminine form that are its own (la música: music), leaving out "female musician" and "musician's wife".
    static func ownSenses(of form: String) -> [Sense] {
        Lexicon.shared.meanings(for: form).flatMap { $0.senses }.filter { !isFemaleOnly($0.text) }
    }

    /// A feminine form that is only the woman version of its masculine (dueña, doctora): search shows the pair instead.
    static func isMergedFeminine(_ word: Word) -> Bool {
        guard masculine[word.spanish] != nil, Lexicon.shared.wordsByID[masculine[word.spanish]!] != nil else { return false }
        let meanings = Lexicon.shared.meanings(for: word.spanish)
        return meanings.allSatisfy { $0.partOfSpeech == .noun } && ownSenses(of: word.spanish).isEmpty
    }

    /// "el dueño / la dueña", "el/la testigo", "el/la juez, la jueza"; nil when the noun has one sex only.
    static func label(for word: Word) -> String? {
        guard word.partOfSpeech == .noun, let forms = feminine[word.spanish] else { return nil }
        let others = forms.filter { $0 != word.spanish }
        if forms.contains(word.spanish) {
            return "el/la \(word.spanish)" + (others.isEmpty ? "" : ", " + others.map { "la \($0)" }.joined(separator: ", "))
        }
        return "el \(word.spanish) / " + others.map { "la \($0)" }.joined(separator: ", ")
    }
}
