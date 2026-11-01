import Foundation
import SwiftUI

/// One thing wrong (or very likely wrong) in a piece of Spanish.
struct SpanishIssue: Identifiable, Hashable {
    enum Kind: String {
        case pronouns = "Pronouns"
        case agreement = "Agreement"
        case spelling = "Spelling"
        case grammar = "Grammar"
        case verb = "Verb"
        case style = "Style"
        case tip = "Heads-up"

        var icon: String {
            switch self {
            case .pronouns: "person.2"
            case .agreement: "arrow.left.arrow.right"
            case .spelling: "textformat.abc"
            case .grammar: "text.badge.checkmark"
            case .verb: "textformat.alt"
            case .style: "scissors"
            case .tip: "lightbulb"
            }
        }
    }

    let kind: Kind
    /// Where it is in the text that was checked.
    let range: NSRange
    let found: String
    let message: String
    let suggestion: String?

    var id: String { "\(kind.rawValue)-\(range.location)-\(range.length)-\(found)" }
}

/// A small rules engine for Spanish. Every rule is deliberately narrow: a wrong flag costs more trust than a missed one,
/// so a rule only fires when the dictionary data says the text is wrong, never merely unusual.
enum SpanishChecker {
    struct Token {
        let text: String
        let range: NSRange
        let lower: String
        let key: String
        var isCapitalized: Bool { text.first?.isUppercase ?? false }
    }

    static let pronounWords: Set<String> = ["me", "te", "se", "nos", "os", "le", "les", "lo", "la", "los", "las"]

    static func check(_ text: String) -> [SpanishIssue] {
        let ns = text as NSString
        guard ns.length > 0, let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return [] }
        let tokens: [Token] = regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map { match in
            let word = ns.substring(with: match.range)
            return Token(text: word, range: match.range, lower: word.lowercased(), key: word.searchKey)
        }

        /// True when only spaces separate token i from the next one (no comma, dash or period between).
        func adjacent(_ i: Int) -> Bool {
            guard i + 1 < tokens.count else { return false }
            let start = tokens[i].range.location + tokens[i].range.length
            let gap = ns.substring(with: NSRange(location: start, length: tokens[i + 1].range.location - start))
            return !gap.isEmpty && gap.allSatisfy { $0 == " " || $0 == "\t" }
        }
        func span(_ from: Int, _ to: Int) -> NSRange { NSUnionRange(tokens[from].range, tokens[to].range) }
        /// True when the token opens a sentence, where a capital letter says nothing about names.
        func atSentenceStart(_ i: Int) -> Bool {
            var index = tokens[i].range.location - 1
            while index >= 0 {
                let c = ns.character(at: index)
                if c == 32 || c == 9 || c == 34 || c == 0x201C || c == 0xBF || c == 0xA1 { index -= 1; continue }
                return [46, 33, 63, 10, 58].contains(c)   // . ! ? newline :
            }
            return true
        }

        var issues: [SpanishIssue] = []
        let add: (SpanishIssue.Kind, NSRange, String, String?) -> Void = { kind, range, message, suggestion in
            // Two pronoun notes can share a word ("le lo haz": "le lo" and "lo haz"), so those may overlap each other
            guard !issues.contains(where: { NSIntersectionRange($0.range, range).length > 0 && !($0.kind == .pronouns && kind == .pronouns && $0.range != range) }) else { return }
            issues.append(SpanishIssue(kind: kind, range: range, found: ns.substring(with: range), message: message, suggestion: suggestion))
        }

        pronounRules(tokens.map { ($0.lower, $0.text) }, adjacent: adjacent, span: span, add: add)

        for i in tokens.indices {
            let token = tokens[i]

            // "hablame" → "háblame", "dimelo" → "dímelo"
            if !token.isCapitalized || atSentenceStart(i), WordLinks.resolvePlain(token.text) == nil, !token.text.contains("ſ"),
               let attached = Clitics.resolve(token.text), attached.pronouns != ["se"], attached.pronouns != ["os"], let expected = SpanishStress.expectedSpellingIfWrong(attached, typed: token.lower) {
                add(.spelling, token.range, "“\(token.text)” needs an accent mark so the stress stays on the same syllable: “\(expected)”.", expected)
                continue
            }

            // "digome": a pronoun stuck on a conjugated verb
            if let stuck = Clitics.attachedToFinite(token.text) {
                let fixed = (stuck.pronouns + [stuck.form]).joined(separator: " ")
                add(.pronouns, token.range, "“\(token.text)” has a pronoun attached to a conjugated verb. Pronouns only attach to infinitives, gerunds and affirmative commands. Here they go in front: “\(fixed)”.", fixed)
                continue
            }

            // "tenió": an irregular verb conjugated as if it were regular
            if !token.isCapitalized, token.lower.count >= 3, let wrong = regularisedForm(token.lower), !isKnownWord(token.text) {
                add(.verb, token.range, "“\(token.text)” isn't a Spanish form. “\(wrong.infinitive)” is irregular here: “\(wrong.form)”.", wrong.form)
                continue
            }

            // "vamanos": an attached form with a vowel slip
            if !token.isCapitalized || atSentenceStart(i), token.lower.count >= 6, !isKnownWord(token.text), let guess = Clitics.resolveApproximately(token.text), let spelled = guess.didYouMean {
                add(.spelling, token.range, "“\(token.text)” isn't a word. Did you mean “\(spelled)”?", spelled)
                continue
            }

            // Missing accent or tilde on a word that isn't a word without it: "telefono" → "teléfono"
            if token.lower == token.key, token.lower.count >= 3, !token.isCapitalized, let fixed = accentFix(for: token.lower) {
                add(.spelling, token.range, "“\(token.text)” is missing an accent mark or tilde: “\(fixed)”.", fixed)
            }
        }

        // Words that look like English but mean something else
        for token in tokens {
            if let note = falseFriendNote(token.lower) { add(.tip, token.range, note, nil) }
        }

        agreementRules(tokens, adjacent: adjacent, span: span, add: add)
        subjectVerbRules(tokens, adjacent: adjacent, span: span, add: add)
        pronounOrderRules(tokens, adjacent: adjacent, span: span, add: add)
        subjunctiveRules(tokens, text: ns, adjacent: adjacent, span: span, add: add)
        phraseRules(text, add: add)

        // "de el" → "del", "a el" → "al" (not before a name: "de El Salvador")
        for i in tokens.indices.dropLast(2) where adjacent(i) && adjacent(i + 1) {
            let a = tokens[i], b = tokens[i + 1], c = tokens[i + 2]
            if (a.lower == "de" || a.lower == "a"), b.text == "el", let first = c.text.first, first.isLowercase {
                let fixed = a.lower == "de" ? "del" : "al"
                add(.grammar, span(i, i + 1), "“\(a.lower) el” contracts to “\(fixed)”.", fixed)
            }
        }

        // "la la casa": a repeated article, preposition or possessive
        let repeatable: Set<String> = ["el", "la", "los", "las", "un", "una", "unos", "unas", "de", "en", "y", "o", "con", "por", "para", "su", "sus", "mi", "mis", "tu", "tus"]
        for i in tokens.indices.dropLast() where adjacent(i) && tokens[i].lower == tokens[i + 1].lower && repeatable.contains(tokens[i].lower) {
            add(.grammar, span(i, i + 1), "“\(tokens[i].lower)” is repeated.", tokens[i].lower)
        }


        return issues.sorted { $0.range.location < $1.range.location }
    }

    // MARK: - Pronouns

    /// Wrong pronoun orders and pronoun/command combinations, reusing what the dictionary search already knows.
    private static func pronounRules(_ words: [(lower: String, text: String)], adjacent: (Int) -> Bool, span: (Int, Int) -> NSRange,
                                     add: (SpanishIssue.Kind, NSRange, String, String?) -> Void) {
        var covered: [NSRange] = []
        for size in [2, 3] {
            for i in 0..<max(0, words.count - size + 1) where (pronounWords.contains(words[i].lower) || words[i].lower == "no") {
                guard (i..<(i + size - 1)).allSatisfy({ adjacent($0) }) else { continue }
                let range = span(i, i + size - 1)
                // A wider window that already holds a flagged pair adds nothing, but a pair that only shares a word does
                guard !covered.contains(where: { NSIntersectionRange($0, range).length == min($0.length, range.length) }) else { continue }
                let query = words[i..<(i + size)].map(\.text).joined(separator: " ")
                var note = Clitics.correction(forQuery: query)
                // "le lo haz": after another pronoun, "lo" can't be an article, so check the command as "se lo haz"
                if note == nil, size == 2, i > 0, ["lo", "la", "los", "las"].contains(words[i].lower), pronounWords.contains(words[i - 1].lower), adjacent(i - 1) {
                    note = Clitics.correction(forQuery: "se " + query)
                }
                if let note {
                    covered.append(range)
                    add(.pronouns, range, note, nil)
                }
            }
        }
    }

    // MARK: - Spelling

    /// Words that exist only with an accent or tilde, keyed by their plain spelling.
    private static let accentVariants: [String: [String]] = {
        var map: [String: [String]] = [:]
        func record(_ form: String) {
            let lower = form.lowercased()
            let key = lower.searchKey
            guard key != lower, !lower.contains(" ") else { return }
            if !(map[key]?.contains(lower) ?? false) { map[key, default: []].append(lower) }
        }
        for word in Lexicon.shared.allWords { record(word.spanish) }
        for form in VerbForms.index.keys { record(form) }
        return map
    }()

    /// True when the dictionary knows the word in any way: an entry, a verb form, a plural, a diminutive, or a verb with pronouns.
    static func isKnownWord(_ word: String) -> Bool {
        let lower = word.lowercased()
        if VerbForms.nonFiniteForms.contains(lower) { return true }
        // tenida, tenidos, tenidas: the participle used as an adjective
        var participle = lower
        if participle.hasSuffix("s") { participle.removeLast() }
        if participle.hasSuffix("a") { participle = String(participle.dropLast()) + "o" }
        if VerbForms.nonFiniteForms.contains(participle) { return true }
        return Lexicon.shared.wordsByID[lower] != nil || VerbForms.index[lower] != nil
            || WordLinks.resolve(lower) != nil || DiminutiveResolver.resolve(lower.searchKey) != nil
    }

    /// The accented spelling when the plain one isn't a word on its own ("telefono" → "teléfono").
    private static func accentFix(for plain: String) -> String? {
        guard let candidates = accentVariants[plain] else { return nil }
        return isKnownWord(plain) ? nil : candidates.first
    }

    // MARK: - Agreement

    private struct Determiner { let masculine: Bool; let plural: Bool; let indefinite: Bool }

    private static let determiners: [String: Determiner] = [
        "el": Determiner(masculine: true, plural: false, indefinite: false), "la": Determiner(masculine: false, plural: false, indefinite: false),
        "los": Determiner(masculine: true, plural: true, indefinite: false), "las": Determiner(masculine: false, plural: true, indefinite: false),
        "un": Determiner(masculine: true, plural: false, indefinite: true), "una": Determiner(masculine: false, plural: false, indefinite: true),
        "unos": Determiner(masculine: true, plural: true, indefinite: true), "unas": Determiner(masculine: false, plural: true, indefinite: true),
    ]

    private static func determiner(_ masculine: Bool, _ plural: Bool, indefinite: Bool) -> String {
        determiners.first { $0.value.masculine == masculine && $0.value.plural == plural && $0.value.indefinite == indefinite }?.key ?? ""
    }

    private struct NounReading: Hashable { let masculine: Bool; let plural: Bool? }

    /// Nouns that are masculine in one sense and feminine in another (el capital / la capital). The dictionary lists only one
    /// gender for several of them, so they are never checked.
    private static let bothGenders: Set<String> = [
        "capital", "cura", "policía", "orden", "frente", "cometa", "corte", "guía", "radio", "editorial", "cólera", "pendiente",
        "margen", "mar", "azúcar", "tilde", "vocal", "moral", "coma", "pez", "parte", "papa", "clave", "final", "lente", "puente",
        "hincha", "colega", "atleta", "turista", "gerente", "canguro", "cualquiera", "fiera", "chorra", "pro", "cámara", "trompeta", "pie", "cuarto", "doblaje", "modo", "tapa", "rostro", "terminal", "canal", "arte", "armazón",
    ]

    /// What the dictionary says a written noun is. Empty when it is unknown, ambiguous, or also another part of speech.
    private static let numerals: Set<String> = ["cero", "uno", "dos", "tres", "cuatro", "cinco", "seis", "siete", "ocho", "nueve", "diez", "once", "doce", "trece", "catorce", "quince", "veinte", "treinta", "cuarenta", "cincuenta", "sesenta", "setenta", "ochenta", "noventa", "cien", "ciento", "mil", "millón"]

    /// Nouns whose gender doesn't follow their ending. The dictionary is trusted for these.
    private static let irregularGender: [String: Bool] = {
        var map: [String: Bool] = [:]
        for word in ["problema", "día", "mapa", "tema", "idioma", "sistema", "programa", "clima", "planeta", "poema", "teorema", "diploma", "drama", "dilema", "esquema", "fantasma", "pijama", "aroma", "síntoma", "tranvía", "lápiz", "país", "mes", "avión", "camión", "corazón", "árbol", "pan", "papel", "color", "amor", "dolor", "sol", "café", "té", "sofá", "menú", "champú", "pie", "cuerpo", "lunes", "martes", "viernes"] { map[word] = true }
        for word in ["mano", "foto", "moto", "tarde", "noche", "leche", "sal", "calle", "carne", "gente", "sangre", "clase", "madre", "imagen", "ley", "flor", "luz", "voz", "paz", "cruz", "nariz", "raíz", "vez", "red", "pared", "sed", "miel", "piel", "señal", "especie", "serie", "fuente", "nube", "torre", "llave", "mente", "muerte", "suerte", "cumbre", "fiebre", "gripe", "tos", "crisis", "tesis", "dosis", "base", "nieve", "lluvia", "playa"] { map[word] = false }
        return map
    }()

    /// The gender an ending suggests: -o, -or, -aje, -án are masculine; -a, -ción, -sión, -dad, -tad, -tud, -umbre are feminine.
    private static func typicalGender(_ word: String) -> Bool? {
        if ["ción", "sión", "dad", "tad", "tud", "umbre"].contains(where: word.hasSuffix) { return false }
        if ["aje", "or", "án"].contains(where: word.hasSuffix) { return true }
        if word.hasSuffix("o") { return true }
        if word.hasSuffix("a") && !["ista", "ita"].contains(where: word.hasSuffix) { return false }
        return nil
    }

    /// Words whose dictionary gender is only believed when the ending (or a known exception) says the same thing.
    private static func trustedGender(_ word: String, dictionary masculine: Bool) -> Bool {
        if let known = irregularGender[word] { return known == masculine }
        return typicalGender(word) == masculine
    }

    private static func nounReadings(_ lower: String) -> Set<NounReading> {
        if numerals.contains(lower) || lower.count <= 2 { return [] }
        if bothGenders.contains(lower) || bothGenders.contains(String(lower.dropLast())) || bothGenders.contains(String(lower.dropLast(2))) { return [] }
        func gender(of word: String) -> Bool? {
            // Every noun sense must state one gender: "el cura" (priest) and "la cura" (cure) share a spelling
            let nouns = Lexicon.shared.meanings(for: word).filter { $0.partOfSpeech == .noun }
            guard !nouns.isEmpty, nouns.allSatisfy({ $0.gender == "m" || $0.gender == "f" }) else { return nil }
            let genders = Set(nouns.compactMap(\.gender))
            guard genders.count == 1, let only = genders.first, trustedGender(word, dictionary: only == "m") else { return nil }
            return only == "m"
        }
        if Lexicon.shared.wordsByID[lower] != nil {
            guard let masculine = gender(of: lower) else { return [] }
            // "lunes", "crisis": the same word is singular and plural
            return [NounReading(masculine: masculine, plural: lower.hasSuffix("s") ? nil : false)]
        }
        var readings: Set<NounReading> = []
        for base in DictionaryIndex.nounsWithForm(lower) where base.partOfSpeech == .noun {
            guard let forms = Extras.shared.nounForms[base.spanish], let baseMasculine = gender(of: base.spanish) else { continue }
            func has(_ list: [String]) -> Bool { list.contains { $0.lowercased() == lower } }
            if has(forms.plural) { readings.insert(NounReading(masculine: baseMasculine, plural: true)) }
            else if has(forms.feminine) { readings.insert(NounReading(masculine: false, plural: false)) }
            else if has(forms.femininePlural) { readings.insert(NounReading(masculine: false, plural: true)) }
            else if has(forms.masculine) { readings.insert(NounReading(masculine: true, plural: false)) }
            else if has(forms.masculinePlural) { readings.insert(NounReading(masculine: true, plural: true)) }
            else { continue }
        }
        return readings.count == 1 ? readings : []
    }

    /// Feminine nouns that start with a stressed "a" take el/un in the singular: el agua, un alma.
    private static func takesMasculineArticle(_ lower: String) -> Bool {
        guard lower.hasPrefix("a") || lower.hasPrefix("á") || lower.hasPrefix("ha") || lower.hasPrefix("há") else { return false }
        let letters = Array(lower)
        let syllables = SpanishStress.syllables(letters)
        return SpanishStress.stress(letters, syllables) == 0
    }

    private static func agreementRules(_ tokens: [Token], adjacent: (Int) -> Bool, span: (Int, Int) -> NSRange,
                                       add: (SpanishIssue.Kind, NSRange, String, String?) -> Void) {
        for i in tokens.indices.dropLast() where adjacent(i) {
            guard let article = determiners[tokens[i].lower], !tokens[i + 1].isCapitalized else { continue }
            let noun = tokens[i + 1]
            let readings = nounReadings(noun.lower)
            guard let reading = readings.first, readings.count == 1 else { continue }
            // la / las / los are also pronouns: "la canto" is "I sing it", not a mismatched article. When the pair
            // doesn't match and the noun is also a verb form, give the benefit of the doubt.
            let couldBePronoun = !article.indefinite && !(article.masculine && !article.plural) && VerbForms.index[noun.lower] != nil
            let matches = reading.masculine == article.masculine && (reading.plural == nil || reading.plural == article.plural)
            if couldBePronoun && !matches { continue }
            let written = "\(tokens[i].lower) \(noun.text)"
            defer {
                // The adjective after the noun has to match the noun, not the article
                if i + 2 < tokens.count, adjacent(i + 1) {
                    adjectiveAgreement(noun: noun, adjective: tokens[i + 2], masculine: reading.masculine, plural: reading.plural, span: span(i + 1, i + 2), add: add)
                }
            }
            if reading.masculine != article.masculine {
                if !reading.masculine, article.masculine, !article.plural, takesMasculineArticle(noun.lower) { continue }
                let fixed = determiner(reading.masculine, article.plural, indefinite: article.indefinite)
                let kind = reading.masculine ? "masculine" : "feminine"
                add(.agreement, span(i, i + 1), "“\(written)”: “\(noun.lower)” is \(kind), so it takes “\(fixed)”: “\(fixed) \(noun.text)”.", "\(fixed) \(noun.text)")
            } else if let plural = reading.plural, plural != article.plural {
                let fixed = determiner(reading.masculine, plural, indefinite: article.indefinite)
                let number = plural ? "plural" : "singular"
                add(.agreement, span(i, i + 1), "“\(written)”: the article and the noun must both be singular or both plural. “\(noun.lower)” is \(number), so “\(fixed) \(noun.text)”.", "\(fixed) \(noun.text)")
            }
        }
    }

    // MARK: - Subject and verb

    private static let subjects: [String: Int] = [
        "yo": 0, "tú": 1, "él": 2, "ella": 2, "usted": 2, "nosotros": 3, "nosotras": 3, "vosotros": 4, "vosotras": 4, "ellos": 5, "ellas": 5, "ustedes": 5,
    ]
    private static let personNames = ["yo", "tú", "él / ella / usted", "nosotros", "vosotros", "ellos / ustedes"]
    private static let beforeSubjectSkip: Set<String> = ["y", "e", "o", "u", "ni", "con", "entre", "según", "como", "que", "para", "por", "sin", "de", "excepto", "salvo", "incluso"]

    /// "yo tiene", "ellos va": a written subject that doesn't match the verb right after it.
    private static func subjectVerbRules(_ tokens: [Token], adjacent: (Int) -> Bool, span: (Int, Int) -> NSRange,
                                         add: (SpanishIssue.Kind, NSRange, String, String?) -> Void) {
        for i in tokens.indices {
            guard let person = subjects[tokens[i].lower] else { continue }
            // "tú y yo somos", "entre tú y yo", "según yo": the verb belongs to a bigger subject, or there is none
            if i > 0, beforeSubjectSkip.contains(tokens[i - 1].lower) { continue }
            var j = i
            while j + 1 < tokens.count, adjacent(j), tokens[j + 1].lower == "no" || pronounWords.contains(tokens[j + 1].lower) { j += 1 }
            guard j + 1 < tokens.count, adjacent(j) else { continue }
            let verb = tokens[j + 1]
            let persons = Clitics.persons(ofVerbForm: verb.key)
            guard !persons.isEmpty, !persons.contains(person) else { continue }
            // "él solo", "usted como": the word is also an adjective, adverb or conjunction here
            let otherUses = Lexicon.shared.meanings(for: verb.lower).contains { [.adjective, .adverb, .conjunction, .preposition].contains($0.partOfSpeech) }
            if otherUses { continue }
            let who = persons.sorted().map { personNames[$0] }.joined(separator: " or ")
            add(.agreement, span(i, j + 1), "“\(tokens[i].text)” doesn't match “\(verb.text)”: that form goes with \(who), not \(personNames[person]).", nil)
        }
    }

    // MARK: - Showing issues

    /// Marks the flagged words in an attributed string built from `text`.
    static func highlighted(_ attributed: AttributedString, text: String, issues: [SpanishIssue]) -> AttributedString {
        var result = attributed
        for issue in issues {
            guard let range = Range(issue.range, in: text),
                  let lower = AttributedString.Index(range.lowerBound, within: result),
                  let upper = AttributedString.Index(range.upperBound, within: result) else { continue }
            result[lower..<upper].backgroundColor = issue.kind == .tip ? Color.yellow.opacity(0.3) : Color.orange.opacity(0.25)
        }
        return result
    }
}

extension SpanishStress {
    /// The right spelling of an attached form when what was typed has the wrong accent, else nil.
    static func expectedSpellingIfWrong(_ match: Clitics.Match, typed: String) -> String? {
        guard let expected = Clitics.expectedSpelling(match), expected != typed, expected.searchKey == typed.searchKey else { return nil }
        return expected
    }
}
