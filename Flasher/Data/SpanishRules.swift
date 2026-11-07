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
        // "estoy seguro podernos hacer": before an infinitive these adjectives take "de" ("estoy seguro de podernos hacer")
        PhraseRule(pattern: bounded("(estoy|estás|está|estamos|están|estaba|estaban|estuve|estuvo|estaré|estaría)\\s+(seguro|segura|seguros|seguras|convencido|convencida|convencidos|convencidas)\\s+(\\p{L}*(?:ar|er|ir|ír)(?:me|te|se|nos|os|lo|la|los|las|le|les)*)"), kind: .grammar) { m, text in
            let next = text.substring(with: m.range(at: 3))
            // Strip attached pronouns ("podernos" → "poder") and check what is left really is a verb in the infinitive
            var base = next.lowercased()
            var stripped = true
            while stripped {
                stripped = false
                for clitic in ["me", "te", "se", "nos", "os", "lo", "la", "los", "las", "le", "les"] where base.hasSuffix(clitic) && base.count > clitic.count + 2 {
                    let shorter = String(base.dropLast(clitic.count))
                    if Lexicon.shared.meaningsByWord[shorter]?.contains(where: { $0.partOfSpeech == .infinitive }) == true { base = shorter; stripped = false; break }
                    if let last = shorter.last, "aeiouáéíó".contains(last) == false { base = shorter; stripped = true; break }
                }
            }
            let accentless = base.folding(options: .diacriticInsensitive, locale: nil)
            guard Lexicon.shared.meaningsByWord[base]?.contains(where: { $0.partOfSpeech == .infinitive }) == true
                    || Lexicon.shared.meaningsByWord[accentless]?.contains(where: { $0.partOfSpeech == .infinitive }) == true else { return nil }
            let verb = text.substring(with: m.range(at: 1)), adjective = text.substring(with: m.range(at: 2))
            let fixed = "\(verb) \(adjective) de \(next)"
            return ("“estar seguro” and “estar convencido” take “de” before an infinitive: “\(fixed)”.", fixed)
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

    /// A word that starts a noun phrase: the next word is the subject ("que las luces empiecen"), not the verb.
    private static let nounPhraseStarters: Set<String> = ["el", "la", "los", "las", "un", "una", "unos", "unas", "mi", "mis", "tu", "tus", "su", "sus", "nuestro", "nuestra", "nuestros", "nuestras", "este", "esta", "estos", "estas", "ese", "esa", "esos", "esas"]

    private static let subjunctiveTriggers: [[String]] = [
        ["quiero", "que"], ["quieres", "que"], ["quiere", "que"], ["queremos", "que"], ["quieren", "que"],
        ["espero", "que"], ["esperas", "que"], ["esperamos", "que"], ["esperan", "que"],
        ["necesito", "que"], ["necesitas", "que"], ["necesita", "que"], ["necesitamos", "que"],
        ["prefiero", "que"], ["prefieres", "que"], ["prefiere", "que"], ["deseo", "que"], ["pido", "que"], ["dudo", "que"],
        ["no", "creo", "que"], ["no", "pienso", "que"], ["no", "cree", "que"], ["no", "crees", "que"],
        ["me", "alegra", "que"], ["me", "gusta", "que"], ["te", "gusta", "que"], ["le", "gusta", "que"], ["nos", "gusta", "que"],
        ["es", "importante", "que"], ["es", "necesario", "que"], ["es", "posible", "que"], ["es", "mejor", "que"], ["es", "bueno", "que"], ["es", "probable", "que"],
        ["antes", "de", "que"], ["a", "menos", "que"], ["con", "tal", "de", "que"], ["sin", "que"], ["para", "que"], ["ojalá", "que"], ["ojalá", "y"], ["ojalá"],
        // More that always take the subjunctive (NGLE ch. 25, 46, 47; see docs/conjugation-drill/subjunctive-rules.md)
        ["pide", "que"], ["pedimos", "que"], ["piden", "que"], ["exijo", "que"], ["exige", "que"], ["ruego", "que"], ["sugiero", "que"], ["recomiendo", "que"],
        ["aconsejo", "que"], ["prohíbo", "que"], ["permito", "que"], ["deseamos", "que"], ["desea", "que"], ["prefiere", "que"], ["preferimos", "que"],
        ["dudas", "que"], ["duda", "que"], ["dudamos", "que"], ["niego", "que"], ["niega", "que"],
        ["me", "alegro", "de", "que"], ["se", "alegra", "de", "que"], ["me", "molesta", "que"], ["me", "sorprende", "que"], ["me", "encanta", "que"],
        ["me", "preocupa", "que"], ["me", "da", "miedo", "que"], ["me", "da", "pena", "que"], ["temo", "que"],
        ["es", "una", "lástima", "que"], ["es", "una", "pena", "que"], ["qué", "lástima", "que"], ["qué", "pena", "que"], ["es", "raro", "que"],
        ["es", "imposible", "que"], ["es", "preciso", "que"], ["es", "fundamental", "que"], ["es", "urgente", "que"], ["es", "conveniente", "que"],
        ["es", "hora", "de", "que"], ["hace", "falta", "que"], ["más", "vale", "que"], ["puede", "que"], ["puede", "ser", "que"],
        ["no", "es", "que"], ["no", "es", "verdad", "que"], ["no", "es", "cierto", "que"], ["es", "mentira", "que"],
        ["a", "no", "ser", "que"], ["con", "tal", "que"], ["a", "fin", "de", "que"], ["en", "caso", "de", "que"], ["a", "condición", "de", "que"],
        ["no", "sea", "que"], ["no", "vaya", "a", "ser", "que"], ["espera", "a", "que"], ["esperar", "a", "que"],
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
            // "no dudo que es verdad" takes the indicative: the negative flips "dudo que"
            if ["dudo", "duda", "dudas", "dudamos", "niego", "niega"].contains(trigger[0]), trigger.count == 2, i > 0, tokens[i - 1].lower == "no", adjacent(i - 1) { continue }
            // "me temo que perderemos" (I suspect) takes either mood; only plain "temo que" (I fear) asks for the subjunctive
            if trigger == ["temo", "que"], i > 0, tokens[i - 1].lower == "me", adjacent(i - 1) { continue }
            // "no es mentira que" is certainty; "¿No es verdad que viene?" asks for agreement and takes the indicative
            if trigger == ["es", "mentira", "que"], i > 0, tokens[i - 1].lower == "no", adjacent(i - 1) { continue }
            if ["verdad", "cierto"].contains(trigger.dropFirst(2).first ?? ""), isInQuestion(at: tokens[i].range.location, in: text) { continue }
            // "¿No crees que ya es tarde?" asks you to agree and takes the indicative (either mood is fine in a question)
            if trigger.first == "no", ["creo", "cree", "crees", "pienso", "piensas", "piensa"].contains(trigger.dropFirst().first ?? ""), isInQuestion(at: tokens[i].range.location, in: text) { continue }
            // "Quiero que yo vaya": with the same subject a wish takes the infinitive ("quiero ir")
            // "Espero que (yo) pueda ir" is accepted, so esperar isn't on the list
            let wishes: Set<String> = ["quiero", "prefiero", "necesito", "deseo"]
            if wishes.contains(trigger[0]), trigger.count == 2, i + 3 < tokens.count, tokens[i + 2].lower == "yo", adjacent(i + 1), adjacent(i + 2),
               let infinitive = Clitics.formOptions(tokens[i + 3].lower).first(where: { $0.person == 0 && !$0.infinitive.contains(" ") })?.infinitive {
                let fix = "\(tokens[i].text) \(infinitive)"
                add(.verb, span(i, i + 3), "When the person who wants and the person who does are the same, Spanish uses the infinitive: “\(fix)”, not “que yo…”.", fix)
                continue
            }
            var last = i + trigger.count - 1
            while last + 1 < tokens.count, adjacent(last), !nounPhraseStarters.contains(tokens[last + 1].lower), subjects.contains(tokens[last + 1].lower) || tokens[last + 1].lower == "no" || pronounWords.contains(tokens[last + 1].lower) { last += 1 }
            guard last + 1 < tokens.count, adjacent(last), !tokens[last + 1].isCapitalized, !nounPhraseStarters.contains(tokens[last + 1].lower) else { continue }
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

    // MARK: - Indicative after a statement of belief: "creo que tengas"

    private static let indicativeTriggers: [[String]] = [
        ["creo", "que"], ["crees", "que"], ["cree", "que"], ["creemos", "que"], ["creen", "que"],
        ["pienso", "que"], ["piensas", "que"], ["piensa", "que"], ["pensamos", "que"], ["opino", "que"], ["supongo", "que"],
        ["me", "parece", "que"], ["te", "parece", "que"], ["le", "parece", "que"],
        ["es", "verdad", "que"], ["es", "cierto", "que"], ["es", "obvio", "que"], ["es", "evidente", "que"], ["está", "claro", "que"],
        ["sé", "que"], ["sabes", "que"], ["sabe", "que"], ["sabemos", "que"], ["veo", "que"], ["noto", "que"], ["recuerdo", "que"],
        ["no", "cabe", "duda", "de", "que"], ["no", "hay", "duda", "de", "que"], ["es", "indudable", "que"], ["es", "seguro", "que"],
        ["estoy", "seguro", "de", "que"], ["estoy", "segura", "de", "que"], ["estoy", "convencido", "de", "que"], ["estoy", "convencida", "de", "que"],
        ["está", "demostrado", "que"], ["resulta", "que"], ["menos", "mal", "que"], ["si", "bien"],
        // "si" (if) and "por si" (in case) never take the present subjunctive: "si tengo", "por si llueve" (or "si tuviera", "por si lloviera")
        ["si"], ["por", "si"],
        // Not here on purpose: "digo que" / "dice que" (with the subjunctive they give an order: "te digo que vengas"),
        // "no dudo que" / "no niego que" (both moods are correct), "me temo que" (either), bare "es que" (it sits inside "lo importante es que estés")
    ].sorted { $0.count > $1.count }

    /// Saying what you think or know takes the indicative, so a subjunctive right after one is a mistake.
    /// Negated ("no creo que tengas") and in a question ("¿crees que tenga?") the subjunctive is fine, and those are left alone.
    static func indicativeRules(_ tokens: [Token], text: NSString, adjacent: (Int) -> Bool, span: (Int, Int) -> NSRange, add: SpanishIssueAdder) {
        let subjects = Set(["yo", "tú", "él", "ella", "usted", "nosotros", "nosotras", "vosotros", "vosotras", "ellos", "ellas", "ustedes"])
        for i in tokens.indices {
            guard let trigger = indicativeTriggers.first(where: { trigger in
                i + trigger.count <= tokens.count
                    && (0..<trigger.count).allSatisfy { tokens[i + $0].lower == trigger[$0] && ($0 == 0 || adjacent(i + $0 - 1)) }
            }) else { continue }
            // "no creo que", "no me parece que": the negative brings the subjunctive back
            if trigger.first != "no", i > 0, tokens[i - 1].lower == "no", adjacent(i - 1) { continue }
            if isInQuestion(at: tokens[i].range.location, in: text) { continue }
            let ifClause = trigger.last == "si"
            if ifClause, i > 0 {
                let before = tokens[i - 1].lower
                // "como si" has its own card (imperfect subjunctive); "no sé si vaya" is "whether", heard in Mexico
                if before == "como" || ["sé", "sabe", "sabes", "sabemos", "saben", "pregunto", "pregunta", "preguntó", "ver", "saber", "duda", "dudo"].contains(before) { continue }
            }
            var last = i + trigger.count - 1
            while last + 1 < tokens.count, adjacent(last), !nounPhraseStarters.contains(tokens[last + 1].lower), subjects.contains(tokens[last + 1].lower) || pronounWords.contains(tokens[last + 1].lower) || (ifClause && tokens[last + 1].lower == "no") { last += 1 }
            guard last + 1 < tokens.count, adjacent(last), !tokens[last + 1].isCapitalized, !nounPhraseStarters.contains(tokens[last + 1].lower) else { continue }
            let verb = tokens[last + 1]
            let options = Clitics.formOptions(verb.lower).filter { $0.tense == .subjunctivePresent && !$0.infinitive.contains(" ") }
            // "sea" is yo or él: only an explicit "yo" makes it the first person
            let saidYo = last >= i + trigger.count && tokens[(i + trigger.count)...last].contains { $0.lower == "yo" }
            let ordered = saidYo ? options : options.sorted { ($0.person == 0 ? 1 : 0) < ($1.person == 0 ? 1 : 0) }
            // Only a form that can be nothing but a present subjunctive of one verb; "no dudo que" keeps its own wording.
            // A form that is also the indicative of a more common verb ("vives" from vivir, not vivar; "cena" from cenar, not ceñir)
            // is left alone; one whose other reading is rarer ("vengas" from vengar) is still a subjunctive of venir.
            func commonness(_ infinitive: String) -> Int { Lexicon.shared.wordsByID[infinitive]?.order ?? Int.max }
            guard let best = ordered.first, Set(options.map(\.infinitive)).count == 1,
                  Clitics.formOptions(verb.lower).allSatisfy({ $0.tense == .subjunctivePresent || $0.tense == .imperative || ($0.infinitive != best.infinitive && commonness($0.infinitive) > commonness(best.infinitive)) }),
                  let fix = Clitics.formOf(best.infinitive, .present, best.person) else { continue }
            let said = trigger.joined(separator: " ")
            if ifClause {
                let unlikely = Clitics.formOf(best.infinitive, .subjunctiveImperfect, best.person)
                add(.verb, span(i, last + 1), "After “\(said)” Spanish never uses the present subjunctive: “\(fix)”\(unlikely.map { ". For something unlikely or unreal, use the imperfect subjunctive: “\($0)”" } ?? "").", fix)
            } else if trigger.first == "no" || trigger.contains("seguro") || trigger.contains("duda") || trigger == ["si", "bien"] || trigger == ["menos", "mal", "que"] || trigger == ["resulta", "que"] {
                add(.verb, span(i, last + 1), "“\(said)” states something as certain, so the verb is indicative: “\(fix)”.", fix)
            } else {
                add(.verb, span(i, last + 1), "After “\(said)” Spanish uses the indicative: “\(fix)”. The subjunctive comes back when it is negative (*no creo que tengas*) or a question.", fix)
            }
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
