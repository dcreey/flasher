import Foundation

typealias SpanishIssueAdder = (SpanishIssue.Kind, NSRange, String, String?) -> Void

/// The rules that look at whole phrases and verb forms. Each one fires only on evidence in the dictionary or on a fixed
/// pattern that is wrong in every context; ambiguous text is left alone.
extension SpanishChecker {

    // MARK: - Fixed phrases

    private struct PhraseRule {
        let pattern: String
        let kind: SpanishIssue.Kind
        /// The message and suggestion for a match; nil skips it.
        let build: (_ match: NSTextCheckingResult, _ text: NSString) -> (message: String, suggestion: String?)?
    }

    private static func bounded(_ pattern: String) -> String { "(?<![\\p{L}])" + pattern + "(?![\\p{L}])" }

    private static let numberWords = "\\d+|un|una|dos|tres|cuatro|cinco|seis|siete|ocho|nueve|diez|once|doce|trece|catorce|quince|dieciséis|diecisiete|dieciocho|diecinueve|veinte|veinti\\p{L}+|treinta|cuarenta|cincuenta|sesenta|setenta|ochenta|noventa|cien|ciento"

    private static let phraseRules: [PhraseRule] = [
        // "más mejor"
        PhraseRule(pattern: bounded("(m[aá]s)\\s+(mejor|peor)"), kind: .grammar) { m, text in
            let better = text.substring(with: m.range(at: 2)).lowercased()
            return ("“\(text.substring(with: m.range))” says “more” twice: “\(better)” already means “more good” or “more bad”.", better)
        },
        // "soy 25 años": an age is something you have
        PhraseRule(pattern: bounded("(soy|estoy|eres|estás|somos|estamos)\\s+(\(numberWords))\\s+años"), kind: .grammar) { m, text in
            let verb = text.substring(with: m.range(at: 1)).lowercased()
            let have = ["soy": "tengo", "estoy": "tengo", "eres": "tienes", "estás": "tienes", "somos": "tenemos", "estamos": "tenemos"][verb] ?? "tengo"
            let fixed = "\(have) \(text.substring(with: m.range(at: 2))) años"
            return ("To give an age Spanish uses “tener” (to have), not “ser” or “estar”: “\(fixed)”.", fixed)
        },
        // "¿Porque…?"
        PhraseRule(pattern: "¿\\s*(por\\s*que|porque|porqué)(?![\\p{L}])", kind: .spelling) { m, text in
            ("In a question, “why” is two words with an accent: “por qué”.", "¿por qué")
        },
        // dequeísmo: "pienso de que"
        PhraseRule(pattern: bounded("(pienso|piensas|piensa|pensamos|piensan|pensé|pensó|creo|crees|cree|creemos|creen|creí|creyó|opino|opinas|opina|opinamos|opinan|digo|dices|dice|decimos|dicen|dije|dijo|dijeron|supongo|supones|supone|espero|esperas|esperamos|esperan|quiero|quieres|quiere|queremos|quieren|afirmó|asegura|aseguró|comentó|explicó|parece)\\s+de\\s+que"), kind: .grammar) { m, text in
            let verb = text.substring(with: m.range(at: 1))
            return ("With “\(verb)” the “de” isn't needed before “que” (this mistake is called dequeísmo): “\(verb) que”.", "\(verb) que")
        },
        // queísmo: "me alegro que", "me di cuenta que", "estoy seguro que"
        PhraseRule(pattern: bounded("(me|te|nos|os)\\s+(alegro|alegras|alegramos|acuerdo|acuerdas|acordamos|olvido|olvidé|olvidas|olvidamos)\\s+que"), kind: .grammar) { m, text in
            let found = text.substring(with: m.range)
            let fixed = String(found.dropLast(3)) + "de que"
            return ("This verb needs “de” before “que”: “\(fixed)”.", fixed)
        },
        PhraseRule(pattern: bounded("(me|te|se|nos|os)\\s+(di|doy|das|da|damos|dan|dio|dimos|dieron|daba|dabas|daban)\\s+cuenta\\s+que"), kind: .grammar) { m, text in
            let found = text.substring(with: m.range)
            let fixed = String(found.dropLast(3)) + "de que"
            return ("“darse cuenta” needs “de” before “que”: “\(fixed)”.", fixed)
        },
        PhraseRule(pattern: bounded("(estoy|estás|está|estamos|están|estaba|estaban|estuve)\\s+(seguro|segura|seguros|seguras|convencido|convencida|convencidos|convencidas)\\s+que"), kind: .grammar) { m, text in
            let found = text.substring(with: m.range)
            let fixed = String(found.dropLast(3)) + "de que"
            return ("“estar seguro” and “estar convencido” need “de” before “que”: “\(fixed)”.", fixed)
        },
        // redundancies
        PhraseRule(pattern: bounded("(sub(?:o|es|e|imos|en|ir|ió|í|iste|ieron|iendo)|baj(?:o|as|a|amos|an|ar|ó|é|aste|aron|ando))\\s+para\\s+(arriba|abajo)"), kind: .style) { m, text in
            let verb = text.substring(with: m.range(at: 1))
            return ("“\(text.substring(with: m.range))” is redundant: “\(verb)” already means going \(text.substring(with: m.range(at: 2)).lowercased() == "arriba" ? "up" : "down").", verb)
        },
        PhraseRule(pattern: bounded("(entr(?:o|as|a|amos|an|ar|ó|é|aste|aron|ando))\\s+adentro"), kind: .style) { m, text in
            let verb = text.substring(with: m.range(at: 1))
            return ("“\(text.substring(with: m.range))” is redundant: “\(verb)” already means going in.", verb)
        },
        PhraseRule(pattern: bounded("(?:vuelvo|vuelves|vuelve|volvemos|vuelven|volví|volvió|volvieron|volver|volviendo)\\s+a\\s+repetir(?:lo|la|los|las)?"), kind: .style) { m, text in
            ("“volver a repetir” is redundant: “repetir” already means to do it again.", "repetir")
        },
    ]

    static func phraseRules(_ text: String, add: SpanishIssueAdder) {
        let ns = text as NSString
        let whole = NSRange(location: 0, length: ns.length)
        for rule in phraseRules {
            guard let regex = try? NSRegularExpression(pattern: rule.pattern, options: [.caseInsensitive]) else { continue }
            for match in regex.matches(in: text, range: whole) {
                if let note = rule.build(match, ns) { add(rule.kind, match.range, note.message, note.suggestion) }
            }
        }
    }

    // MARK: - Mood after a trigger: "quiero que vienes"

    private static let subjunctiveTriggers: [[String]] = [
        ["quiero", "que"], ["quieres", "que"], ["quiere", "que"], ["queremos", "que"], ["quieren", "que"],
        ["espero", "que"], ["esperas", "que"], ["esperamos", "que"], ["esperan", "que"],
        ["necesito", "que"], ["necesitas", "que"], ["necesita", "que"], ["necesitamos", "que"],
        ["prefiero", "que"], ["prefieres", "que"], ["prefiere", "que"], ["deseo", "que"], ["pido", "que"], ["dudo", "que"],
        ["no", "creo", "que"], ["no", "pienso", "que"], ["no", "cree", "que"], ["no", "crees", "que"],
        ["me", "alegra", "que"], ["me", "gusta", "que"], ["te", "gusta", "que"], ["le", "gusta", "que"], ["nos", "gusta", "que"],
        ["es", "importante", "que"], ["es", "necesario", "que"], ["es", "posible", "que"], ["es", "mejor", "que"], ["es", "bueno", "que"], ["es", "probable", "que"],
        ["antes", "de", "que"], ["a", "menos", "que"], ["con", "tal", "de", "que"], ["sin", "que"], ["para", "que"], ["ojalá", "que"], ["ojalá"],
    ].sorted { $0.count > $1.count }

    /// After these phrases Spanish needs the subjunctive; an indicative-only verb right after one is a mistake.
    static func subjunctiveRules(_ tokens: [Token], text: NSString, adjacent: (Int) -> Bool, span: (Int, Int) -> NSRange, add: SpanishIssueAdder) {
        let subjects = Set(["yo", "tú", "él", "ella", "usted", "nosotros", "nosotras", "vosotros", "vosotras", "ellos", "ellas", "ustedes"])
        for i in tokens.indices {
            guard let trigger = subjunctiveTriggers.first(where: { trigger in
                i + trigger.count <= tokens.count
                    && (0..<trigger.count).allSatisfy { tokens[i + $0].lower == trigger[$0] && ($0 == 0 || adjacent(i + $0 - 1)) }
            }) else { continue }
            // "¿Para que sirve?" is “para qué” written without its accent, not a trigger
            if trigger == ["para", "que"], isInQuestion(at: tokens[i].range.location, in: text) { continue }
            var last = i + trigger.count - 1
            while last + 1 < tokens.count, adjacent(last), subjects.contains(tokens[last + 1].lower) || tokens[last + 1].lower == "no" || pronounWords.contains(tokens[last + 1].lower) { last += 1 }
            guard last + 1 < tokens.count, adjacent(last), !tokens[last + 1].isCapitalized else { continue }
            let verb = tokens[last + 1]
            let options = Clitics.formOptions(verb.lower)
            let tenses = Set(options.map(\.tense))
            guard !tenses.isEmpty, tenses.isDisjoint(with: [.subjunctivePresent, .subjunctiveImperfect]) else { continue }
            let order = Tense.allCases
            let best = options.min { (order.firstIndex(of: $0.tense) ?? 0) < (order.firstIndex(of: $1.tense) ?? 0) }
            let fix = best.flatMap { Clitics.formOf($0.infinitive, .subjunctivePresent, $0.person) }
            let said = trigger.joined(separator: " ")
            add(.verb, span(i, last + 1), "After “\(said)” Spanish uses the subjunctive, but “\(verb.text)” is indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
        }
    }

    private static func isInQuestion(at location: Int, in text: NSString) -> Bool {
        var index = location - 1
        while index >= 0 {
            let c = text.character(at: index)
            if c == 0xBF { return true }
            if c == 46 || c == 63 || c == 33 || c == 10 { return false }
            index -= 1
        }
        return false
    }

    // MARK: - Verb forms that aren't Spanish: "tenió", "sabo", "hací"

    /// Forms you get by conjugating an irregular verb as if it were regular, when that isn't a word.
    private static let regularisedForms: [String: (form: String, infinitive: String)] = {
        var map: [String: (form: String, infinitive: String)] = [:]
        for word in Lexicon.shared.allWords where word.partOfSpeech == .infinitive && !word.spanish.contains(" ") {
            guard let conjugation = Conjugator.conjugate(word.spanish), !conjugation.reflexive else { continue }
            for tense in Tense.allCases where tense != .imperative {
                for person in 0..<6 {
                    // "tenés" is a real form, so the tú present is left alone
                    if tense == .present && person == 1 { continue }
                    guard let actual = conjugation.form(tense, person)?.lowercased(),
                          let regular = conjugation.regularForms[tense]?[person].flatMap({ $0 })?.lowercased(),
                          actual != regular, actual.searchKey != regular.searchKey, !actual.contains(" "), !regular.contains(" "),
                          Lexicon.shared.wordsByID[regular] == nil, VerbForms.index[regular] == nil else { continue }
                    if map[regular] == nil { map[regular] = (actual, word.spanish) }
                }
            }
        }
        return map
    }()

    static func regularisedForm(_ lower: String) -> (form: String, infinitive: String)? { regularisedForms[lower] }

    // MARK: - Pronoun order: "me se cayó" → "se me cayó"

    private static let pronounRank: [String: Int] = ["se": 0, "te": 1, "os": 1, "me": 2, "nos": 2, "le": 3, "les": 3]

    /// Pronouns go in a fixed order: se, te/os, me/nos, then le/les. (lo/la/los/las have their own rule.)
    static func pronounOrderRules(_ tokens: [Token], adjacent: (Int) -> Bool, span: (Int, Int) -> NSRange, add: SpanishIssueAdder) {
        let determiners: Set<String> = ["el", "la", "los", "las", "un", "una", "unos", "unas"]
        for i in tokens.indices.dropLast() where adjacent(i) {
            guard let first = pronounRank[tokens[i].lower], let second = pronounRank[tokens[i + 1].lower], first > second else { continue }
            // "yo me se la lección": "se" is the verb sé written without its accent
            if tokens[i + 1].lower == "se", i + 2 >= tokens.count || determiners.contains(tokens[i + 2].lower) { continue }
            add(.pronouns, span(i, i + 1), "Pronouns go in a fixed order: se, then te/os, then me/nos, then le/les. So “\(tokens[i + 1].lower) \(tokens[i].lower)”, not “\(tokens[i].lower) \(tokens[i + 1].lower)”.", "\(tokens[i + 1].lower) \(tokens[i].lower)")
        }
    }

    // MARK: - Noun and adjective: "casa bonito"

    private struct AdjectiveForm: Hashable { let masculine: Bool?; let plural: Bool; let base: String }

    /// Adjectives that are colors taken from nouns never change: las casas rosa.
    private static let invariableColors: Set<String> = ["rosa", "naranja", "violeta", "café", "turquesa", "lila", "beige", "crema", "oro", "plata", "vino", "limón", "salmón", "granate", "fucsia", "añil"]

    /// Nouns that are often placed after another noun as a label: la cultura pueblo, un tema clave.
    private static let appositions: Set<String> = ["pueblo", "clave", "modelo", "estrella", "bomba", "relámpago", "limón", "estándar", "tipo", "base", "cumbre", "fantasma", "testigo", "piloto", "pareja", "gigante", "puente", "llave", "madre", "padre", "hijo", "hija", "jefe"]

    private static func isAdjective(_ word: String) -> Bool { Lexicon.shared.meanings(for: word).contains { $0.partOfSpeech == .adjective } }

    /// Gender and number of a written adjective, from its ending and the dictionary form. Nil when it can't be told for sure.
    private static func adjectiveForm(_ lower: String) -> AdjectiveForm? {
        guard lower.count >= 3, VerbForms.index[lower] == nil, !invariableColors.contains(lower), !appositions.contains(lower) else { return nil }
        var found: Set<AdjectiveForm> = []
        func consider(_ base: String, _ masculine: Bool?, _ plural: Bool) {
            if base.count >= 2, isAdjective(base) { found.insert(AdjectiveForm(masculine: masculine, plural: plural, base: base)) }
        }
        if lower.hasSuffix("os") { consider(String(lower.dropLast(2)) + "o", true, true) }
        if lower.hasSuffix("as") { consider(String(lower.dropLast(2)) + "o", false, true) }
        if lower.hasSuffix("a") { consider(String(lower.dropLast()) + "o", false, false) }
        if lower.hasSuffix("o") { consider(lower, true, false) }
        if lower.hasSuffix("ores") { consider(String(lower.dropLast(2)), true, true) }
        if lower.hasSuffix("oras") { consider(String(lower.dropLast(2)), false, true) }
        if lower.hasSuffix("ora") { consider(String(lower.dropLast()), false, false) }
        if lower.hasSuffix("es") { consider(String(lower.dropLast(2)), nil, true); consider(String(lower.dropLast()), nil, true) }
        else if lower.hasSuffix("s") { consider(String(lower.dropLast()), nil, true) }
        if !lower.hasSuffix("o") { consider(lower, nil, false) }
        return found.count == 1 ? found.first : nil
    }

    private static func inflected(_ form: AdjectiveForm, masculine: Bool, plural: Bool) -> String {
        let base = form.base
        if base.hasSuffix("o") { return String(base.dropLast()) + (masculine ? "o" : "a") + (plural ? "s" : "") }
        if base.hasSuffix("or") { return base + (masculine ? "" : "a") + (plural ? (masculine ? "es" : "s") : "") }
        guard plural else { return base }
        return base + (base.last.map { "aeiouáéíóú".contains($0) } ?? false ? "s" : "es")
    }

    /// Checks the adjective right after "article + noun" against the noun's gender and number.
    static func adjectiveAgreement(noun: Token, adjective: Token, masculine: Bool, plural: Bool?, span: NSRange, add: SpanishIssueAdder) {
        guard !adjective.isCapitalized, let form = adjectiveForm(adjective.lower) else { return }
        let kind = masculine ? "masculine" : "feminine"
        if let formMasculine = form.masculine, formMasculine != masculine {
            let fixed = inflected(form, masculine: masculine, plural: form.plural)
            add(.agreement, span, "“\(noun.text) \(adjective.text)”: “\(noun.lower)” is \(kind), so the adjective must match: “\(noun.text) \(fixed)”.", "\(noun.text) \(fixed)")
        } else if let plural, plural != form.plural {
            let fixed = inflected(form, masculine: form.masculine ?? masculine, plural: plural)
            let number = plural ? "plural" : "singular"
            add(.agreement, span, "“\(noun.text) \(adjective.text)”: “\(noun.lower)” is \(number), so the adjective must be \(number) too: “\(noun.text) \(fixed)”.", "\(noun.text) \(fixed)")
        }
    }

    // MARK: - Heads-up: words that look like English but mean something else

    private static let falseFriends: [String: String] = [
        "embarazada": "“embarazada” means pregnant, not embarrassed (that is “avergonzada”).",
        "constipado": "“constipado” means having a cold, not constipated (that is “estreñido”).",
        "éxito": "“éxito” means success, not exit (that is “salida”).",
        "actualmente": "“actualmente” means currently, not actually (that is “en realidad”).",
        "carpeta": "“carpeta” means folder, not carpet (that is “alfombra”).",
        "librería": "“librería” means bookstore, not library (that is “biblioteca”).",
        "sensible": "“sensible” means sensitive, not sensible (that is “sensato”).",
        "asistir": "“asistir” means to attend; to assist is “ayudar”.",
        "realizar": "“realizar” means to carry out or accomplish; to realize is “darse cuenta”.",
        "soportar": "“soportar” means to put up with; to support is “apoyar”.",
        "decepción": "“decepción” means disappointment, not deception (that is “engaño”).",
        "disgusto": "“disgusto” means upset or annoyance, not disgust (that is “asco”).",
        "largo": "“largo” means long, not large (that is “grande”).",
        "fábrica": "“fábrica” means factory, not fabric (that is “tela”).",
        "introducir": "“introducir” means to insert; to introduce a person is “presentar”.",
        "pretender": "“pretender” means to intend or try; to pretend is “fingir”.",
        "molestar": "“molestar” means to bother, not to molest.",
        "lectura": "“lectura” means reading, not a lecture (that is “conferencia”).",
        "colegio": "“colegio” means school, not college (that is “universidad”).",
        "campo": "“campo” means field or countryside, not a camp (that is “campamento”).",
        "preservativo": "“preservativo” means condom, not a preservative (that is “conservante”).",
        "arena": "“arena” means sand, not an arena (that is “estadio”).",
    ]

    static func falseFriendNote(_ lower: String) -> String? {
        if let note = falseFriends[lower] { return note }
        for suffix in ["s", "es"] where lower.hasSuffix(suffix) {
            if let note = falseFriends[String(lower.dropLast(suffix.count))] { return note }
        }
        return nil
    }
}
