import SwiftUI

/// Every conjugated form of every verb in the dictionary, so a form like "manches" leads back to manchar.
enum VerbForms {
    struct Slot { let infinitive: String; let tense: Tense; let person: Int }

    private static let built: (forms: [String: [Slot]], gerunds: [String: String], participles: Set<String>) = {
        var map: [String: [Slot]] = [:]
        var gerunds: [String: String] = [:]
        var participles: Set<String> = []
        for word in Lexicon.shared.allWords where word.partOfSpeech == .infinitive {
            guard let conjugation = Conjugator.conjugate(word.spanish) else { continue }
            participles.insert(conjugation.participle.lowercased())
            participles.insert(conjugation.gerund.lowercased())
            // First single-word verb wins: "dando" is dar's, not darse cuenta's
            if !word.spanish.contains(" ") { gerunds[conjugation.gerund.searchKey] = gerunds[conjugation.gerund.searchKey] ?? word.spanish }
            for (tense, forms) in conjugation.forms {
                for (person, form) in forms.enumerated() {
                    guard let form, !form.contains(" ") else { continue }
                    map[form.lowercased(), default: []].append(Slot(infinitive: word.spanish, tense: tense, person: person))
                }
            }
        }
        return (map, gerunds, participles)
    }()

    static var index: [String: [Slot]] { built.forms }
    /// Every participle and gerund as written ("tenido", "viendo"), which the form index doesn't hold.
    static var nonFiniteForms: Set<String> { built.participles }
    /// Accent-free gerund → infinitive ("viendo" → ver).
    static var gerunds: [String: String] { built.gerunds }
}

/// Syllables and stress, so pronouns can be attached with the accent in the right place: ver + nos = vernos, di + me + lo = dímelo.
enum SpanishStress {
    private static let vowels = Set("aeiouáéíóúü")
    private static let strong = Set("aeoáéó")
    private static let marked: [Character: Character] = ["a": "á", "e": "é", "i": "í", "o": "ó", "u": "ú"]
    private static let plain: [Character: Character] = ["á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u"]
    private static let clusters: Set<String> = ["pr", "pl", "br", "bl", "fr", "fl", "tr", "dr", "cr", "cl", "gr", "gl", "kr", "kl"]

    private static func isVowel(_ c: [Character], _ i: Int) -> Bool {
        guard vowels.contains(c[i]) else { return false }
        // the u of que, qui, gue, gui is silent
        if c[i] == "u", i > 0, c[i - 1] == "q" || c[i - 1] == "g", i + 1 < c.count, "eiéí".contains(c[i + 1]) { return false }
        return true
    }

    static func syllables(_ c: [Character]) -> [Range<Int>] {
        var nuclei: [Range<Int>] = []
        var i = 0
        while i < c.count {
            guard isVowel(c, i) else { i += 1; continue }
            var start = i
            var j = i + 1
            while j < c.count, isVowel(c, j) {
                let a = c[j - 1], b = c[j]
                // two strong vowels, or an accented i/u, are separate syllables (hiatus)
                if (strong.contains(a) && strong.contains(b)) || "íú".contains(a) || "íú".contains(b) { nuclei.append(start..<j); start = j }
                j += 1
            }
            nuclei.append(start..<j)
            i = j
        }
        guard nuclei.count > 1 else { return [0..<c.count] }
        var starts = [0]
        for k in 1..<nuclei.count {
            let gap = Array(c[nuclei[k - 1].upperBound..<nuclei[k].lowerBound])
            var units: [String] = []
            var x = 0
            while x < gap.count {
                if x + 1 < gap.count, ["ch", "ll", "rr"].contains(String([gap[x], gap[x + 1]])) { units.append(String(gap[x...x + 1])); x += 2 }
                else { units.append(String(gap[x])); x += 1 }
            }
            let toNext: Int
            switch units.count {
            case 0: toNext = 0
            case 1: toNext = 1
            case 2: toNext = clusters.contains(units.joined()) ? 2 : 1
            case 3: toNext = clusters.contains(units[1] + units[2]) ? 2 : 1
            default: toNext = 2
            }
            let moved = units.suffix(toNext).reduce(0) { $0 + $1.count }
            starts.append(nuclei[k].lowerBound - moved)
        }
        return starts.enumerated().map { $0.element..<($0.offset + 1 < starts.count ? starts[$0.offset + 1] : c.count) }
    }

    /// The stressed syllable: the one with a written accent, else by the usual rule.
    static func stress(_ c: [Character], _ syllables: [Range<Int>]) -> Int {
        if let marked = syllables.firstIndex(where: { $0.contains { "áéíóú".contains(c[$0]) } }) { return marked }
        guard syllables.count > 1, let last = c.last else { return 0 }
        return vowels.contains(last) || "ns".contains(last) ? syllables.count - 2 : syllables.count - 1
    }

    /// The vowel that carries the stress inside a syllable.
    static func stressedVowel(_ c: [Character], _ syllable: Range<Int>) -> Int {
        let inside = syllable.filter { isVowel(c, $0) }
        if let accented = inside.first(where: { "áéíóú".contains(c[$0]) }) { return accented }
        return inside.first(where: { strong.contains(c[$0]) }) ?? inside.last ?? syllable.lowerBound
    }

    /// "ver" + "nos" → "vernos", "di" + "me" + "lo" → "dímelo", "viendo" + "le" → "viéndole".
    /// `person` 3 (nosotros command) drops its final s before nos/se, and 4 (vosotros) drops its d before os.
    static func attach(_ form: String, pronouns: [String], person: Int?) -> String {
        let original = Array(form.lowercased())
        var base = original
        if person == 3, let first = pronouns.first, ["nos", "se"].contains(first), base.last == "s" { base.removeLast() }
        if person == 4, pronouns.first == "os", base.last == "d" { base.removeLast() }
        let originalSyllables = syllables(original)
        let stressedAt = stressedVowel(original, originalSyllables[stress(original, originalSyllables)])
        let keepsAccent = "íú".contains(original[stressedAt])
        var word = base.map { plain[$0] ?? $0 } + Array(pronouns.joined())
        let wordSyllables = syllables(word)
        let natural = stressedVowel(word, wordSyllables[stress(word, wordSyllables)])
        if stressedAt < word.count, natural != stressedAt || keepsAccent { word[stressedAt] = marked[word[stressedAt]] ?? word[stressedAt] }
        return String(word)
    }
}

/// A verb with pronouns attached to its end: "vernos", "dámelo", "diciéndole", "hacerlo".
enum Clitics {
    enum Kind: Hashable {
        case infinitive, gerund
        /// The command's person: 1 tú, 2 usted, 3 nosotros, 4 vosotros, 5 ustedes.
        case command(person: Int)
        /// A conjugated verb with the pronouns in front of it ("nos veo"): the tense and person it is written in.
        case finite(tense: Tense, person: Int)
    }

    struct Match: Hashable {
        let verb: Word
        /// What was typed, as typed ("dímelo").
        let typed: String
        /// The verb form before the pronouns ("ver", "dime", "diciendo").
        let form: String
        let pronouns: [String]
        let kind: Kind
        /// Set when the query used "le lo" / "les la": the pair as typed, now corrected to "se lo".
        var correction: String?
        /// A note about how pronouns and commands combine, shown when the query put them the wrong way round.
        var warning: String?
        /// Set when the query was a slip of a vowel in an attached form ("vamanos" → "vámonos").
        var didYouMean: String?

        var correctionNote: String? {
            warning ?? correction.map { "“\($0)” isn't used in Spanish. When le or les comes right before lo, la, los or las, it changes to se, so it reads “\(pronouns.joined(separator: " "))”." }
        }

        /// "to see, to watch — ver + nos (us)"
        var note: String {
            "\(verb.english) — \(title) (\(pronouns.map { Clitics.gloss(of: $0, verb: verb.spanish) }.joined(separator: " + ")))" + (correction.map { " · corrected from “\($0)”" } ?? "") + (didYouMean.map { " · did you mean “\($0)”?" } ?? "")
        }

        /// The tense and person the conjugation chart should show, when the verb part is a command or a conjugated form.
        var selection: (tense: Tense, person: Int)? {
            switch kind {
            case .command(let person): return (.imperative, person)
            case .finite(let tense, let person): return (tense, person)
            default: return nil
            }
        }

        /// "ver + nos" when the pronouns follow the verb, "nos + veo" when they come first.
        var title: String {
            if case .finite = kind { return "\(pronouns.joined(separator: " + ")) + \(form)" }
            return "\(form) + \(pronouns.joined(separator: " + "))"
        }

        struct Reading: Hashable { let english: String; let label: String }

        /// Every sensible meaning, most likely first: "to see each other" (reciprocal) before "to see us".
        var readings: [Reading] {
            guard let (base, rest) = EnglishVerb.parse(verb.english) else { return [] }
            func phrase(_ object: String) -> String {
                let core = { (verb: String) in [verb, object, rest].filter { !$0.isEmpty }.joined(separator: " ") }
                switch kind {
                case .infinitive: return "to " + core(base)
                case .gerund: return core(EnglishVerb.gerund(base))
                case .command(let person): return person == 3 ? "let's " + core(base) : core(base) + "!"
                case .finite(let tense, let person):
                    let verbPart = TenseExamples.phraseEnglish(gloss: "to " + base, tense: tense, person: person) ?? base
                    return [verbPart, object, rest].filter { !$0.isEmpty }.joined(separator: " ")
                }
            }
            if pronouns.count == 2 { return [Reading(english: phrase(Clitics.objects(pronouns)), label: "pronouns combined")] }
            let reciprocal = Clitics.reciprocal.contains(verb.spanish)
            let options: [(String, String)]
            switch pronouns[0] {
            case "nos": options = reciprocal ? [("each other", "reciprocal"), ("us", "object")] : [("us", "object"), ("ourselves", "reflexive")]
            case "os": options = reciprocal ? [("each other", "reciprocal"), ("you all", "object")] : [("you all", "object"), ("yourselves", "reflexive")]
            case "se": options = reciprocal ? [("each other", "reciprocal"), ("himself/herself/themselves", "reflexive")] : [("himself/herself/themselves", "reflexive")]
            case "me": options = [("me", "object"), ("myself", "reflexive")]
            case "te": options = [("you", "object"), ("yourself", "reflexive")]
            case "le": options = [("him/her/you", "object")]
            case "les": options = [("them/you all", "object")]
            case "lo": options = [("it/him/you", "object")]
            case "la": options = [("it/her/you", "object")]
            default: options = [("them", "object")]
            }
            var chosen = options
            if case .finite(_, let person) = kind {
                // "nos vemos" (we + nos) is reflexive or reciprocal; "nos veo" (I + nos) is an object
                let matchesSubject = pronouns[0] == Conjugation.reflexivePronouns[person]
                var fitting = options.filter { matchesSubject ? $0.1 != "object" : $0.1 == "object" }
                if person < 3 { fitting = fitting.filter { $0.1 != "reciprocal" } }
                if !fitting.isEmpty { chosen = fitting }
            }
            // "say to me", not "say me": these verbs take the person as an indirect object
            let indirect = Clitics.indirectVerbs.contains(verb.spanish) && ["me", "te", "nos", "os", "le", "les"].contains(pronouns[0])
            return chosen.map { Reading(english: phrase(indirect && $0.1 == "object" ? "to " + $0.0 : $0.0), label: $0.1) }
        }

        /// What the form means in everyday speech, when that differs from the literal reading.
        var idiom: String? {
            // "nos veo" (I see us) isn't the get-together idiom; "nos vemos" and "vernos" are
            if case .finite(_, let person) = kind, pronouns.first != Conjugation.reflexivePronouns[person] { return nil }
            return Clitics.idioms["\(verb.spanish)+\(pronouns.joined(separator: "+"))"]
        }

        /// How the written word is put together, in plain words: "diciendo (saying) + le (to him/her/you) → diciéndole".
        var built: String {
            let parsed = EnglishVerb.parse(verb.english)
            if case .finite = kind {
                let list = pronouns.map { "\($0) (\(Clitics.gloss(of: $0, verb: verb.spanish)))" }.joined(separator: " + ")
                return "\(list) goes in front of the conjugated verb \(form), as a separate word: \(pronouns.joined(separator: " ")) \(form)."
            }
            let formMeaning: String? = parsed.map { base, rest in
                let tail = rest.isEmpty ? "" : " " + rest
                switch kind {
                case .infinitive: return "to " + base + tail
                case .gerund: return EnglishVerb.gerund(base) + tail
                case .command, .finite: return base + tail + "!"
                }
            }
            let parts = pronouns.map { "\($0) (\(Clitics.gloss(of: $0, verb: verb.spanish)))" }.joined(separator: " + ")
            let joined = SpanishStress.attach(form, pronouns: pronouns, person: selection?.person)
            let plain = form.lowercased() + pronouns.joined()
            var text = "\(form)\(formMeaning.map { " (\($0))" } ?? "") + \(parts) are written as one word: \(joined)."
            if joined != plain {
                text += joined.searchKey == plain.searchKey ? " The accent mark only keeps the stress on the same syllable; it doesn't change the meaning." : " The ending changes slightly so it is easy to say."
            }
            return text
        }

        /// The rule behind it, in one sentence.
        var rule: String {
            switch kind {
            case .infinitive: "Pronouns can go on the end of an infinitive (like \(form))."
            case .gerund: "Pronouns can go on the end of a gerund, the -ing form (like \(form))."
            case .command: "Pronouns go on the end of a command you give. In a negative command they go before the verb instead (“no me lo digas”)."
            case .finite: "With a conjugated verb, pronouns always go in front, as separate words. They are only attached to infinitives, gerunds and commands."
            }
        }

        /// "me", "te", "se", "nos" and "os" can also be reflexive.
        var mayBeReflexive: Bool { pronouns.count == 1 && ["me", "te", "se", "nos", "os"].contains(pronouns[0]) }
    }

    /// Verbs whose person ("me", "le"...) is an indirect object: say TO me, give TO him.
    static let indirectVerbs: Set<String> = [
        "decir", "dar", "escribir", "mandar", "enviar", "contar", "explicar", "pedir", "preguntar", "responder", "hablar", "prestar",
        "regalar", "mostrar", "enseñar", "ofrecer", "traer", "devolver", "prometer", "recomendar", "sugerir", "vender", "comprar",
        "cantar", "leer", "servir", "pagar",
    ]

    /// Verbs whose "nos / os / se" usually means "each other".
    static let reciprocal: Set<String> = [
        "ver", "encontrar", "llamar", "escribir", "hablar", "abrazar", "besar", "saludar", "conocer", "entender", "ayudar", "querer",
        "amar", "odiar", "pelear", "reunir", "juntar", "mirar", "perdonar", "visitar", "apoyar", "respetar", "extrañar", "mandar",
        "enviar", "contar", "cuidar", "acompañar", "esperar", "buscar", "avisar", "abandonar", "lastimar", "insultar", "criticar",
    ]

    static let idioms: [String: String] = [
        "ver+nos": "In everyday speech this means getting together: “Quiero vernos pronto” = I want us to see each other (meet up) soon. The goodbye “nos vemos” = see you (later).",
        "ver+te": "“Verte” = to see you (informal): “Qué gusto verte” = so good to see you. “Nos vemos” is the goodbye.",
        "ver+lo": "“Verlo” = to see it, him, or you (formal): “Qué gusto verlo” = good to see you (to a man, formal).",
        "ver+la": "“Verla” = to see it, her, or you (formal): “Qué gusto verla” = good to see you (to a woman, formal).",
        "ver+me": "“Verme” = to see me: “Ven a verme” = come see me.",
        "conocer+te": "“Conocerte” = to meet you (the first time) or get to know you: “Mucho gusto en conocerte” = nice to meet you.",
        "conocer+lo": "“Conocerlo” = to meet you (formal, a man) or him: “Mucho gusto en conocerlo” = nice to meet you.",
        "conocer+la": "“Conocerla” = to meet you (formal, a woman) or her: “Mucho gusto en conocerla” = nice to meet you.",
        "conocer+nos": "“Conocernos” = to get to know each other: “Quiero conocernos mejor.”",
        "encontrar+nos": "“Encontrarnos” = to meet up: “¿Dónde nos encontramos?” = where shall we meet?",
        "reunir+nos": "“Reunirnos” = to get together, to meet as a group.",
        "juntar+nos": "“Juntarnos” = to get together (very common in Mexico): “Vamos a juntarnos el sábado.”",
        "llamar+te": "“Llamarte” = to call you: “Te llamo luego” = I'll call you later.",
        "ir+nos": "“Irnos” = to leave, to go away: “Vámonos” = let's go.",
        "ir+te": "“Irte” = to leave, to go away: “Vete” = go away; “Ya me voy” = I'm leaving.",
    ]

    fileprivate static let meaning: [String: String] = [
        "me": "me", "te": "you", "se": "him/her/them", "nos": "us", "os": "you all",
        "le": "him/her/formal you", "les": "them/you all", "lo": "it/him/formal you", "la": "it/her/formal you", "los": "them", "las": "them",
    ]

    /// What a pronoun means with this verb: "to him/her/you" for verbs that take the person as an indirect object (decir, dar).
    static func gloss(of pronoun: String, verb: String) -> String {
        let base = meaning[pronoun] ?? pronoun
        return indirectVerbs.contains(verb) && ["me", "te", "nos", "os", "le", "les"].contains(pronoun) ? "to " + base : base
    }

    /// The English object for a sentence: "us", "each other", "it to me".
    static func englishObject(_ pronouns: [String], verb: String, person: Int) -> String {
        if pronouns.count == 2 { return objects(pronouns) }
        let p = pronouns[0]
        if reciprocal.contains(verb), (p == "nos" && person == 3) || (p == "os" && person == 4) || (p == "se" && person == 5) { return "each other" }
        let plain = single[p] ?? p
        return indirectVerbs.contains(verb) && ["me", "te", "nos", "os", "le", "les"].contains(p) ? "to " + plain : plain
    }
    private static let single: [String: String] = [
        "me": "me", "te": "you", "nos": "us", "os": "you all", "le": "him/her/you", "les": "them/you all",
        "se": "himself/herself/themselves", "lo": "it/him/you", "la": "it/her/you", "los": "them", "las": "them",
    ]
    private static let directOnly: [String: String] = ["lo": "it", "la": "it", "los": "them", "las": "them"]
    private static let indirectOnly: [String: String] = [
        "me": "me", "te": "you", "nos": "us", "os": "you all", "le": "him/her/you", "se": "him/her/them", "les": "them/you all",
    ]

    static func meaning(of pronoun: String) -> String { meaning[pronoun] ?? pronoun }
    static func reflexiveMeaning(of pronoun: String) -> String {
        ["me": "myself", "te": "yourself", "se": "himself/herself/themselves", "nos": "ourselves / each other", "os": "yourselves / each other"][pronoun] ?? pronoun
    }

    /// "nos" → "us"; "me" + "lo" → "it to me".
    fileprivate static func objects(_ pronouns: [String]) -> String {
        if pronouns.count == 2 { return "\(directOnly[pronouns[1]] ?? pronouns[1]) to \(indirectOnly[pronouns[0]] ?? pronouns[0])" }
        return single[pronouns[0]] ?? pronouns[0]
    }

    private static let direct: Set<String> = ["lo", "la", "los", "las"]
    private static let suffixes = ["nos", "les", "los", "las", "me", "te", "se", "os", "le", "lo", "la"]

    /// Accent-free infinitive → word, for single-word verbs.
    private static let infinitives: [String: Word] = {
        var map: [String: Word] = [:]
        for word in Lexicon.shared.allWords where word.partOfSpeech == .infinitive && !word.spanish.contains(" ") {
            map[word.spanish.searchKey] = map[word.spanish.searchKey] ?? word
        }
        return map
    }()

    /// Accent-free command forms → the verbs and persons they are commands of ("dame" → dar, tú).
    private static let imperatives: [String: [(infinitive: String, person: Int)]] = {
        var map: [String: [(infinitive: String, person: Int)]] = [:]
        for (form, slots) in VerbForms.index {
            for slot in slots where slot.tense == .imperative { map[form.searchKey, default: []].append((slot.infinitive, slot.person)) }
            // "vayámonos": the nosotros command is also the present subjunctive (vayamos + nos)
            for slot in slots where slot.tense == .subjunctivePresent && slot.person == 3 { map[form.searchKey, default: []].append((slot.infinitive, 3)) }
        }
        return map
    }()

    /// Accent-free conjugated form → every verb, tense and person it can be (commands left out).
    private static let finiteForms: [String: [(infinitive: String, tense: Tense, person: Int, shown: String)]] = {
        var map: [String: [(infinitive: String, tense: Tense, person: Int, shown: String)]] = [:]
        for (form, slots) in VerbForms.index {
            for slot in slots where slot.tense != .imperative { map[form.searchKey, default: []].append((slot.infinitive, slot.tense, slot.person, form)) }
        }
        return map
    }()

    /// A plain-words explanation when the pronouns in a query are in a combination Spanish doesn't use: "le lo", "lo me".
    static func correction(forQuery query: String) -> String? {
        let tokens = query.searchKey.split(separator: " ").map(String.init)
        for pair in zip(tokens, tokens.dropFirst()) {
            if ["le", "les"].contains(pair.0), direct.contains(pair.1) {
                return "“\(pair.0) \(pair.1)” isn't used in Spanish. When le or les comes right before lo, la, los or las, it changes to se (it is easier to say): “se \(pair.1)”."
            }
            // "lo sé" (I know it) is fine, so "se" isn't in this list
            if direct.contains(pair.0), ["me", "te", "nos", "os", "le", "les"].contains(pair.1) {
                return "“\(pair.0) \(pair.1)” has the order backwards. The person comes first, then lo, la, los or las: “\(pair.1) \(pair.0)”."
            }
        }
        return resolvePhrase(query)?.warning
    }

    /// Which persons (0–5) a written verb form can be, ignoring accents; empty when it isn't a known verb form.
    static func persons(ofVerbForm form: String) -> Set<Int> {
        let key = form.searchKey
        var result = Set((finiteForms[key] ?? []).map(\.person))
        for option in imperatives[key] ?? [] { result.insert(option.person) }
        return result
    }

    /// Every verb, tense and person a written form can be, ignoring accents (commands included). Empty when it isn't a verb form.
    static func formOptions(_ form: String) -> [(infinitive: String, tense: Tense, person: Int)] {
        let key = form.searchKey
        var result = (finiteForms[key] ?? []).map { (infinitive: $0.infinitive, tense: $0.tense, person: $0.person) }
        for option in imperatives[key] ?? [] { result.append((option.infinitive, .imperative, option.person)) }
        return result
    }

    /// "digome": a pronoun stuck on a conjugated verb, which Spanish doesn't do. Nil for real words and valid attached forms.
    static func attachedToFinite(_ token: String) -> (form: String, pronouns: [String])? {
        let key = token.searchKey
        guard key.count >= 5, key.allSatisfy({ $0.isLetter }), WordLinks.resolve(token) == nil, !(token.first?.isUppercase ?? true),
              token.allSatisfy({ $0 != "ſ" && ($0.unicodeScalars.first?.value ?? 0) < 0x2000 }),
              // "buscábanle", "dijéronle": literary Spanish keeps the accent of the verb and attaches the pronoun
              !token.lowercased().contains(where: { "áéíóú".contains($0) }) else { return nil }
        func plainFinite(_ base: String) -> Bool { base.count >= 3 && finiteForms[base] != nil && imperatives[base] == nil }
        // "se" is left out: -se imperfect subjunctives ("trajese") look like a verb plus "se"
        for last in suffixes where key.hasSuffix(last) && last != "se" {
            let rest = String(key.dropLast(last.count))
            if plainFinite(rest) { return (rest, [last]) }
            guard direct.contains(last) else { continue }
            for first in suffixes where !direct.contains(first) && rest.hasSuffix(first) {
                let base = String(rest.dropLast(first.count))
                if plainFinite(base) { return (base, [first, last]) }
            }
        }
        return nil
    }

    /// "vamanos" → vámonos: an attached form typed with one vowel wrong.
    static func resolveApproximately(_ token: String) -> Match? {
        let key = token.searchKey
        guard key.count >= 6, key.allSatisfy({ $0.isLetter }), resolve(token) == nil else { return nil }
        let letters = Array(key)
        for (i, c) in letters.enumerated() where "aeiou".contains(c) {
            for vowel in "aeiou" where vowel != c {
                var changed = letters
                changed[i] = vowel
                guard let found = resolve(String(changed)), found.form.count >= 3, let spelled = expectedSpelling(found) else { continue }
                var match = Match(verb: found.verb, typed: token, form: found.form, pronouns: found.pronouns, kind: found.kind)
                match.didYouMean = spelled
                match.warning = "“\(token)” isn't a word. Did you mean “\(spelled)”?"
                return match
            }
        }
        return nil
    }

    /// The correctly accented spelling of an attached form ("hablame" → "háblame"), or nil when it can't be worked out.
    static func expectedSpelling(_ match: Match) -> String? {
        let base: String?
        switch match.kind {
        case .infinitive: base = match.verb.spanish
        case .gerund: base = Conjugator.conjugate(match.verb.spanish)?.gerund
        case .command(let person): base = formOf(match.verb.spanish, .imperative, person)
        case .finite: base = nil
        }
        return base.map { SpanishStress.attach($0, pronouns: match.pronouns, person: match.selection?.person) }
    }

    /// The written command or subjunctive form of a verb for a person ("decir", .imperative, 1 → "di").
    static func formOf(_ infinitive: String, _ tense: Tense, _ person: Int) -> String? {
        Conjugator.conjugate(infinitive)?.forms[tense]?[person].flatMap { $0 }
    }

    /// Both ways to say a command with pronouns: attached when affirmative, in front (with the subjunctive) when negative.
    private static func commandAdvice(_ infinitive: String, person: Int, pronouns: [String]) -> String? {
        guard let command = formOf(infinitive, .imperative, person), let negative = formOf(infinitive, .subjunctivePresent, person) else { return nil }
        let attached = SpanishStress.attach(command, pronouns: pronouns, person: person)
        return "“\(attached)” (pronouns on the end) is how you give the command; the negative command puts them in front instead: “no \(pronouns.joined(separator: " ")) \(negative)”."
    }

    /// "nos veo", "me lo dice", "no te vayas": pronouns in front of a conjugated verb.
    static func resolvePhrase(_ query: String) -> Match? {
        var tokens = query.searchKey.split(separator: " ").map(String.init)
        // "yo me veo": the subject is dropped, and it picks the person when a form fits several ("ve")
        let subjects = ["yo": 0, "tu": 1, "el": 2, "ella": 2, "usted": 2, "nosotros": 3, "nosotras": 3, "vosotros": 4, "vosotras": 4, "ellos": 5, "ellas": 5, "ustedes": 5]
        let subjectPerson = tokens.first.flatMap { subjects[$0] }
        if subjectPerson != nil { tokens.removeFirst() }
        let negated = tokens.first == "no"
        if negated { tokens.removeFirst() }
        // "no dímelo": a negative command can't take its pronouns on the end
        if negated, tokens.count == 1, let attached = resolve(tokens[0]), case .command(let person) = attached.kind,
           let advice = commandAdvice(attached.verb.spanish, person: person, pronouns: attached.pronouns) {
            var match = attached
            match.warning = "In a negative command the pronouns can't be attached to the end. " + advice
            return match
        }
        guard (2...3).contains(tokens.count) else { return nil }
        var pronouns = Array(tokens.dropLast())
        guard pronouns.allSatisfy({ suffixes.contains($0) }) else { return nil }
        var correction: String?
        if pronouns.count == 2 {
            // le/les + lo/la/los/las is not Spanish: it becomes se
            if ["le", "les"].contains(pronouns[0]), direct.contains(pronouns[1]) { correction = pronouns.joined(separator: " "); pronouns[0] = "se" }
            else if direct.contains(pronouns[0]) || !direct.contains(pronouns[1]) { return nil }
        }
        // "me haz": an affirmative command takes its pronouns on the end, so this order isn't used
        if finiteForms[tokens.last!] == nil, !direct.contains(pronouns[0]), let commands = imperatives[tokens.last!] {
            for command in commands {
                guard let word = Lexicon.shared.wordsByID[command.infinitive], !command.infinitive.contains(" "),
                      let advice = commandAdvice(command.infinitive, person: command.person, pronouns: pronouns) else { continue }
                var match = Match(verb: word, typed: query, form: formOf(command.infinitive, .imperative, command.person) ?? tokens.last!, pronouns: pronouns,
                                  kind: .command(person: command.person), correction: correction)
                match.warning = "In an affirmative command the pronouns can't go in front of the verb. " + advice
                return match
            }
        }
        // "la casa": la/lo/los/las are articles too, so a noun or adjective after them is a noun phrase, not "it" + a verb
        if direct.contains(pronouns[0]), Lexicon.shared.meanings(for: tokens.last!).contains(where: { $0.partOfSpeech == .noun || $0.partOfSpeech == .adjective }) { return nil }
        guard let options = finiteForms[tokens.last!] else { return nil }
        // Prefer a plain one-word verb, the earlier tense, and the more common verb
        let order = Tense.allCases
        let ranked = options.compactMap { option -> (option: (infinitive: String, tense: Tense, person: Int, shown: String), word: Word)? in
            guard let word = Lexicon.shared.wordsByID[option.infinitive], !option.infinitive.contains(" ") else { return nil }
            return (option, word)
        }.sorted {
            let a = order.firstIndex(of: $0.option.tense) ?? 0, b = order.firstIndex(of: $1.option.tense) ?? 0
            return a != b ? a < b : $0.word.order < $1.word.order
        }
        guard let best = ranked.first(where: { $0.option.person == subjectPerson }) ?? ranked.first else { return nil }
        return Match(verb: best.word, typed: query, form: best.option.shown, pronouns: pronouns, kind: .finite(tense: best.option.tense, person: best.option.person), correction: correction)
    }

    /// Splits off one or two pronouns ("dámelo" → dá + me + lo) when what is left is an infinitive, a gerund or a command.
    static func resolve(_ token: String) -> Match? {
        let key = token.searchKey
        guard key.count >= 4, !key.contains(" "), key.allSatisfy({ $0.isLetter }) else { return nil }
        for last in suffixes where key.hasSuffix(last) {
            let rest = String(key.dropLast(last.count))
            if let found = verb(rest) ?? droppedLetter(rest, pronouns: [last]) { return Match(verb: found.word, typed: token, form: found.shown, pronouns: [last], kind: found.kind) }
            // indirect + direct: "dámelo", "diciéndoselo"
            guard direct.contains(last) else { continue }
            for first in suffixes where !direct.contains(first) && rest.hasSuffix(first) {
                let base = String(rest.dropLast(first.count))
                if let found = verb(base) ?? droppedLetter(base, pronouns: [first, last]) { return Match(verb: found.word, typed: token, form: found.shown, pronouns: [first, last], kind: found.kind) }
            }
        }
        return nil
    }

    private struct Found { let word: Word; let shown: String; let kind: Kind }

    /// "vamonos" → vamos + nos, "sentaos" → sentad + os: a command drops its last letter before the pronoun.
    private static func droppedLetter(_ base: String, pronouns: [String]) -> Found? {
        let (letter, person) = pronouns[0] == "os" ? ("d", 4) : (["nos", "se"].contains(pronouns[0]) ? "s" : "", 3)
        guard !letter.isEmpty, let options = imperatives[base + letter] else { return nil }
        for option in options where option.person == person {
            if let word = Lexicon.shared.wordsByID[option.infinitive] { return Found(word: word, shown: base + letter, kind: .command(person: person)) }
        }
        return nil
    }

    private static func verb(_ base: String) -> Found? {
        guard base.count >= 2 else { return nil }
        if let word = infinitives[base] { return Found(word: word, shown: word.spanish, kind: .infinitive) }
        if let name = VerbForms.gerunds[base], let word = Lexicon.shared.wordsByID[name] { return Found(word: word, shown: base, kind: .gerund) }
        if let options = imperatives[base] {
            for option in options.sorted(by: { !$0.infinitive.contains(" ") && $1.infinitive.contains(" ") }) { if let word = Lexicon.shared.wordsByID[option.infinitive] { return Found(word: word, shown: base, kind: .command(person: option.person)) } }
        }
        return nil
    }
}

extension EnglishVerb {
    /// "see" → "seeing", "take" → "taking", "stop" → "stopping", "lie" → "lying".
    static func gerund(_ b: String) -> String {
        if b == "be" { return "being" }
        if b.hasSuffix("ie") { return String(b.dropLast(2)) + "ying" }
        if b.count > 2, b.hasSuffix("e"), !["ee", "oe", "ye"].contains(where: b.hasSuffix) { return String(b.dropLast()) + "ing" }
        let v = Array(b)
        if v.count >= 3, v.count <= 4, !noDouble.contains(b), !"aeiouwxy".contains(v[v.count - 1]),
           "aeiou".contains(v[v.count - 2]), !"aeiou".contains(v[v.count - 3]) {
            return b + String(v[v.count - 1]) + "ing"
        }
        return b + "ing"
    }
}

/// A phrase built around a verb ("acabar de", "no manches"): the verb can be conjugated and the rest of the phrase follows along.
struct PhraseVerb {
    let conjugation: Conjugation
    let before: String
    let after: String
    /// The tense and person the phrase is written in (the infinitive's phrases start at "yo, present").
    let start: (tense: Tense, person: Int)
    /// "to have just" when the phrase's meaning is a verb phrase that can be inflected.
    let gloss: String
    let baseMeaning: String

    private static let conjugatedPatterns: Set<String> = ["no manches", "no mames", "no jodas", "no fastidies", "no friegues"]
    private static let leading: Set<String> = ["no", "ni", "ya", "me", "te", "se", "nos", "le", "les", "lo", "la"]

    static func find(for word: Word) -> PhraseVerb? {
        guard word.spanish.contains(" ") else { return nil }
        let tokens = word.spanish.split(separator: " ").map(String.init)
        guard (2...6).contains(tokens.count), isConjugable(tokens) else { return nil }
        let meaning = baseMeaning(of: word)
        // An infinitive up front ("acabar de", "darse cuenta de"), optionally after "no"
        for position in 0..<min(2, tokens.count) where position == 0 || tokens[0] == "no" {
            let verb = tokens[position].lowercased()
            guard let known = Lexicon.shared.wordsByID[verb] ?? Lexicon.shared.wordsByID[String(verb.dropLast(2))],
                  known.partOfSpeech == .infinitive,
                  let conjugation = Conjugator.conjugate(verb) else { continue }
            let plus = tokens.suffix(from: position + 1).filter { $0 != "+" && $0 != "gerundio" }
            return PhraseVerb(conjugation: conjugation, before: tokens.prefix(position).joined(separator: " "),
                              after: plus.joined(separator: " "), start: (.present, 0), gloss: meaning, baseMeaning: meaning)
        }
        // A conjugated verb up front, only for fixed phrases that really are said in other persons ("no manches" → "no manchen").
        // Anything else that merely starts with a verb form (nouns, greetings, proverbs, "me cago en...") stays as written.
        guard conjugatedPatterns.contains(word.spanish.lowercased()) else { return nil }
        for position in 0..<min(3, tokens.count) {
            let form = tokens[position].lowercased()
            if position > 0, !leading.contains(tokens[position - 1].lowercased()) { break }
            if leading.contains(form) { continue }
            guard let slots = VerbForms.index[form], Set(slots.map(\.infinitive)).count == 1,
                  let conjugation = Conjugator.conjugate(slots[0].infinitive) else { break }
            let order = Tense.allCases
            let slot = slots.min { (order.firstIndex(of: $0.tense) ?? 0) < (order.firstIndex(of: $1.tense) ?? 0) }!
            return PhraseVerb(conjugation: conjugation, before: tokens.prefix(position).joined(separator: " "),
                              after: tokens.suffix(from: position + 1).joined(separator: " "),
                              start: (slot.tense, slot.person), gloss: "", baseMeaning: meaning)
        }
        return nil
    }

    /// Fixed sayings, proverbs and signs ("errar es humano", "coser y cantar", "no fumar") never change their verb.
    private static let fixedWords: Set<String> = ["y", "o", "es", "son", "era", "fue", "sea", "ni", "si", "cuando", "donde", "quien"]
    private static let neverConjugated: Set<String> = ["hay", "es", "son"]

    private static func isConjugable(_ tokens: [String]) -> Bool {
        let lower = tokens.map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
        // Anything with a comma, a clause or a coordinated pair is a saying, not a pattern
        if tokens.contains(where: { $0.hasSuffix(",") || $0.hasSuffix("?") || $0.hasSuffix("!") || $0.hasSuffix(".") }) { return false }
        if lower.dropFirst().contains(where: { fixedWords.contains($0) }) { return false }
        // "no" + infinitive is an instruction on a sign ("no fumar"), not a verb that moves
        if lower[0] == "no", lower.count == 2, lower[1].hasSuffix("ar") || lower[1].hasSuffix("er") || lower[1].hasSuffix("ir") { return false }
        // Impersonal haber and "es" stay as written (hay que, es lo que hay)
        if neverConjugated.contains(lower[0]) || (lower[0] == "no" && lower.count > 1 && neverConjugated.contains(lower[1])) { return false }
        return true
    }

    private static func baseMeaning(of word: Word) -> String {
        var text = word.english
        if let cut = text.range(of: " — ") { text = String(text[..<cut.lowerBound]) }
        return text.trimmingCharacters(in: .whitespaces)
    }

    /// The whole phrase with the verb in the chosen tense and person.
    func spanish(core: String) -> String { [before, core, after].filter { !$0.isEmpty }.joined(separator: " ") }

    func english(tense: Tense, person: Int) -> String? {
        TenseExamples.phraseEnglish(gloss: gloss, tense: tense, person: person)
    }
}

/// Makes the Spanish words in a sentence tappable: each one that is in the dictionary (or is a form of a verb that is) links to its page.
enum WordLinks {
    static func resolve(_ token: String) -> Word? { resolvePlain(token) ?? Clitics.resolve(token)?.verb }

    static func resolvePlain(_ token: String) -> Word? {
        let lower = token.lowercased()
        let words = Lexicon.shared.wordsByID
        // A plural of a common noun beats a rarer word spelled the same (bocas → boca, not Spain's "bocas")
        let exact = words[lower]
        if let base = DictionaryIndex.nounsWithForm(lower).first, exact == nil || base.order < exact!.order { return base }
        if let exact { return exact }
        if let slot = VerbForms.index[lower]?.first, let word = words[slot.infinitive] { return word }
        for candidate in [String(lower.dropLast(2)), String(lower.dropLast()), String(lower.dropLast(2)) + "o"] where candidate.count >= 3 {
            if lower.hasSuffix("es"), candidate == String(lower.dropLast(2)), let word = words[candidate] { return word }
            if lower.hasSuffix("s"), candidate == String(lower.dropLast()), let word = words[candidate] { return word }
            if lower.hasSuffix("as"), candidate.hasSuffix("o"), let word = words[candidate] { return word }
        }
        if lower.hasSuffix("a"), let word = words[String(lower.dropLast()) + "o"] { return word }
        return nil
    }

    /// `form` is what was written when it is a verb with pronouns attached, so the page can explain it.
    static func url(for word: Word, form: String? = nil) -> URL? {
        var parts = URLComponents()
        parts.scheme = "elpie"
        parts.host = "word"
        parts.queryItems = [URLQueryItem(name: "id", value: word.id)] + (form.map { [URLQueryItem(name: "form", value: $0)] } ?? [])
        return parts.url
    }

    static func linked(_ text: String) -> AttributedString { linked(AttributedString(text)) }

    static func linked(_ attributed: AttributedString) -> AttributedString {
        var result = attributed
        let plain = String(attributed.characters)
        guard let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return result }
        for match in regex.matches(in: plain, range: NSRange(plain.startIndex..., in: plain)) {
            guard let range = Range(match.range, in: plain) else { continue }
            let token = String(plain[range])
            let url: URL?
            if let word = resolvePlain(token) { url = WordLinks.url(for: word) }
            else if let attached = Clitics.resolve(token) { url = WordLinks.url(for: attached.verb, form: token) }
            else { continue }
            guard let url,
                  let lower = AttributedString.Index(range.lowerBound, within: result),
                  let upper = AttributedString.Index(range.upperBound, within: result) else { continue }
            result[lower..<upper].link = url
            result[lower..<upper].underlineStyle = Text.LineStyle(pattern: .dot, color: .secondary)
        }
        return result
    }
}

/// Opens a tapped Spanish word in its own dictionary page, pushed onto the current stack.
private struct WordLinkNavigation: ViewModifier {
    /// Sends the word to the Dictionary tab instead of pushing it onto the current stack.
    let opensInDictionary: Bool
    @Environment(AppRouter.self) private var router: AppRouter?
    @State private var target: SearchHit?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
                guard url.scheme == "elpie",
                      let id = items?.first(where: { $0.name == "id" })?.value,
                      let word = Lexicon.shared.wordsByID[id] else { return .systemAction }
                let attached = items?.first(where: { $0.name == "form" })?.value.flatMap(Clitics.resolve)
                if opensInDictionary, let router { router.showWord(word, attached: attached) }
                else { target = SearchHit(word: word, diminutive: nil, attached: attached) }
                return .handled
            })
            .navigationDestination(item: $target) { WordDetailView(word: $0.word, diminutive: $0.diminutive, attached: $0.attached) }
    }
}

extension View {
    /// `inDictionary` sends tapped words to the Dictionary tab; otherwise their page is pushed onto the current stack.
    func opensWordLinks(inDictionary: Bool = false) -> some View { modifier(WordLinkNavigation(opensInDictionary: inDictionary)) }
}
