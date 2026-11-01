import SwiftUI

/// Every conjugated form of every verb in the dictionary, so a form like "manches" leads back to manchar.
enum VerbForms {
    struct Slot { let infinitive: String; let tense: Tense; let person: Int }

    private static let built: (forms: [String: [Slot]], gerunds: [String: String]) = {
        var map: [String: [Slot]] = [:]
        var gerunds: [String: String] = [:]
        for word in Lexicon.shared.allWords where word.partOfSpeech == .infinitive {
            guard let conjugation = Conjugator.conjugate(word.spanish) else { continue }
            // First single-word verb wins: "dando" is dar's, not darse cuenta's
            if !word.spanish.contains(" ") { gerunds[conjugation.gerund.searchKey] = gerunds[conjugation.gerund.searchKey] ?? word.spanish }
            for (tense, forms) in conjugation.forms {
                for (person, form) in forms.enumerated() {
                    guard let form, !form.contains(" ") else { continue }
                    map[form.lowercased(), default: []].append(Slot(infinitive: word.spanish, tense: tense, person: person))
                }
            }
        }
        return (map, gerunds)
    }()

    static var index: [String: [Slot]] { built.forms }
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
    }

    struct Match: Hashable {
        let verb: Word
        /// What was typed, as typed ("dímelo").
        let typed: String
        /// The verb form before the pronouns ("ver", "dime", "diciendo").
        let form: String
        let pronouns: [String]
        let kind: Kind

        /// "to see, to watch — ver + nos (us)"
        var note: String {
            "\(verb.english) — \(form) + \(pronouns.joined(separator: " + ")) (\(pronouns.map { Clitics.gloss(of: $0, verb: verb.spanish) }.joined(separator: " + ")))"
        }

        /// The tense and person the conjugation chart should show, when the verb part is a command.
        var selection: (tense: Tense, person: Int)? {
            if case .command(let person) = kind { return (.imperative, person) }
            return nil
        }

        /// "to see us", "seeing us", "tell it to me!"; nil when the verb's gloss isn't a plain verb.
        var english: String? {
            guard let (base, rest) = EnglishVerb.parse(verb.english) else { return nil }
            func phrase(_ verb: String) -> String { [verb, Clitics.objects(pronouns), rest].filter { !$0.isEmpty }.joined(separator: " ") }
            switch kind {
            case .infinitive: return "to " + phrase(base)
            case .gerund: return phrase(EnglishVerb.gerund(base))
            case .command(let person): return person == 3 ? "let's " + phrase(base) : phrase(base) + "!"
            }
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
            // "say to me", not "say me": these verbs take the person as an indirect object
            let indirect = Clitics.indirectVerbs.contains(verb.spanish) && ["me", "te", "nos", "os", "le", "les"].contains(pronouns[0])
            return options.map { Reading(english: phrase(indirect && $0.1 == "object" ? "to " + $0.0 : $0.0), label: $0.1) }
        }

        /// What the form means in everyday speech, when that differs from the literal reading.
        var idiom: String? { Clitics.idioms["\(verb.spanish)+\(pronouns.joined(separator: "+"))"] }

        /// How the written word is put together, in plain words: "diciendo (saying) + le (to him/her/you) → diciéndole".
        var built: String {
            let parsed = EnglishVerb.parse(verb.english)
            let formMeaning: String? = parsed.map { base, rest in
                let tail = rest.isEmpty ? "" : " " + rest
                switch kind {
                case .infinitive: return "to " + base + tail
                case .gerund: return EnglishVerb.gerund(base) + tail
                case .command: return base + tail + "!"
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
        }
        return map
    }()

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

    private static func resolvePlain(_ token: String) -> Word? {
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
