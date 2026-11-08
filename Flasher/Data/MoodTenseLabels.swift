import Foundation

/// Names the tense of a choice on a Learn card ("tuviera" → imperfect subjunctive), and explains each tense
/// the first time the learner meets it.
struct MoodTenseInfo: Hashable, Identifiable {
    let id: String
    let name: String
    /// What the tense means.
    let meaning: String
    /// Where it is used, with examples.
    let uses: String
}

enum MoodTenseLabels {
    static let infinitive = MoodTenseInfo(id: "infinitive", name: "infinitive",
        meaning: "The verb's dictionary form (-ar, -er, -ir). It has no person and no tense of its own.",
        uses: "After a verb when the same person does both (quiero ir, not quiero que yo vaya), and after para, sin, antes de: estudio para aprobar.")

    static let byTense: [Tense: MoodTenseInfo] = [
        .present: MoodTenseInfo(id: "present", name: "present indicative",
            meaning: "What is so: now, as a habit, or as a plan for soon.",
            uses: "Facts you claim (sé que viene, creo que tiene razón), habits (cuando llego, ceno), and real conditions after si: si llueve, no salgo."),
        .preterite: MoodTenseInfo(id: "preterite", name: "preterite",
            meaning: "A past event, seen as finished.",
            uses: "Telling what happened: me llamó ayer, después de que llegó, comimos. As a claim, it is indicative."),
        .imperfect: MoodTenseInfo(id: "imperfect", name: "imperfect indicative",
            meaning: "The past as background: how things were, what used to happen, what was going on.",
            uses: "Descriptions and habits (cuando era niño, vivía aquí), and reported news: me dijo que venía (she said she was coming)."),
        .future: MoodTenseInfo(id: "future", name: "future",
            meaning: "What will happen, or a guess about now (¿dónde estará? = where can he be?).",
            uses: "Main clauses and questions: ¿cuándo llegarás? Never after cuando, si or other time and condition words: cuando llegues, not cuando llegarás."),
        .conditional: MoodTenseInfo(id: "conditional", name: "conditional",
            meaning: "“Would”: what would happen if things were different.",
            uses: "What would happen in another situation (yo no lo haría), polite wishes and requests (me gustaría ir, ¿podrías ayudarme?), and the future seen from the past (dijo que vendría). Never right after si (if)."),
        .subjunctivePresent: MoodTenseInfo(id: "subjunctivePresent", name: "present subjunctive",
            meaning: "The subjunctive for now or later: something not claimed, about the present or the future.",
            uses: "After a present main verb (quiero que vengas, no creo que tenga razón), for what is still to come (cuando llegues), and with ojalá for what can still happen. Same forms as usted commands: venga, llame."),
        .subjunctiveImperfect: MoodTenseInfo(id: "subjunctiveImperfect", name: "imperfect subjunctive",
            meaning: "The subjunctive for the past, or for things that are unlikely or unreal.",
            uses: "After a past or conditional main verb (quería que vinieras, me gustaría que vinieras), in unreal conditions (si tuviera tiempo…), after como si, and with ojalá for what is unlikely. Made from the ellos preterite: tuvieron → tuviera."),
        .imperative: MoodTenseInfo(id: "imperative", name: "command",
            meaning: "Telling someone to do something.",
            uses: "Ven, llámame, no digas eso (a no command uses the subjunctive forms)."),
    ]

    /// haber + participle, named by the tense of haber.
    static let perfect: [Tense: MoodTenseInfo] = [
        .present: MoodTenseInfo(id: "perfect.present", name: "present perfect",
            meaning: "“Has done”: a past event that still counts now.",
            uses: "He visto esa película. As a claim, it's indicative: sé que ha llegado."),
        .imperfect: MoodTenseInfo(id: "perfect.imperfect", name: "pluperfect",
            meaning: "“Had done”: earlier than another past moment.",
            uses: "Cuando llegué, ya se había ido."),
        .future: MoodTenseInfo(id: "perfect.future", name: "future perfect",
            meaning: "“Will have done”, or a guess about the past (habrá salido = he must have gone out).",
            uses: "Para mañana lo habré terminado."),
        .conditional: MoodTenseInfo(id: "perfect.conditional", name: "conditional perfect",
            meaning: "“Would have done”: what would have happened, but didn't.",
            uses: "The result of an unreal past condition: si lo hubiera sabido, habría venido."),
        .subjunctivePresent: MoodTenseInfo(id: "perfect.subjunctivePresent", name: "perfect subjunctive",
            meaning: "The subjunctive of “has done”: a finished event, not claimed.",
            uses: "Feelings and doubts about what has happened (me alegra que hayas venido, no creo que lo haya hecho), ojalá haya aprobado, and superlatives: la mejor película que haya visto."),
        .subjunctiveImperfect: MoodTenseInfo(id: "perfect.subjunctiveImperfect", name: "pluperfect subjunctive",
            meaning: "The subjunctive of “had done”: something that didn't happen, or an earlier past not claimed.",
            uses: "Unreal past conditions (si lo hubiera sabido…), regrets (ojalá hubiera venido), and after a past main verb about something earlier: no creía que lo hubiera hecho."),
    ]

    /// Which tense to name when a form belongs to more than one ("venga" is present subjunctive and a usted command).
    private static let order: [Tense] = [.subjunctivePresent, .subjunctiveImperfect, .present, .preterite, .imperfect, .future, .conditional, .imperative]
    private static let clitics: Set<String> = ["me", "te", "se", "nos", "os", "lo", "la", "los", "las", "le", "les", "no", "que"]

    /// Every form of every drill verb, mapped to the tense it belongs to.
    private static let index: [String: Tense] = {
        var map: [String: Tense] = [:]
        let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        // A form shared by two verbs or tenses ("venga": venir subjunctive, vengar present) is named by the earlier tense in the order
        func put(_ form: String?, _ tense: Tense) {
            guard let form = form?.lowercased() else { return }
            if let old = map[form], rank[old]! <= rank[tense]! { return }
            map[form] = tense
        }
        for verb in Set(DrillSentences.verbList + MoodMap.extraVerbs) {
            guard let conjugation = Conjugator.conjugate(verb) else { continue }
            for tense in order {
                for person in 0..<6 {
                    put(conjugation.form(tense, person), tense)
                    if tense == .imperative { put(conjugation.attachedImperativeOrForm(tense, person), tense) }
                }
            }
        }
        return map
    }()
    private static let infinitives: Set<String> = Set(DrillSentences.verbList + MoodMap.extraVerbs)

    /// Builds the index ahead of time, so the first answer doesn't wait for it.
    static func warmUp() { _ = index }

    private static let haberForms: Set<String> = ["he", "has", "ha", "hemos", "han", "haya", "hayas", "hayamos", "hayan", "había", "habías", "habíamos", "habían", "hubiera", "hubieras", "hubiéramos", "hubieran", "habría", "habrías", "habríamos", "habrían", "habré", "habrás", "habrá", "habremos", "habrán"]

    /// Forms that are the same in two tenses, named for the card they are on ("quedamos": present or preterite).
    private static let overrides: [String: [String: Tense]] = [
        "purpose.demodo.2": ["quedamos": .preterite],
    ]

    /// The tense of a choice on a card. Uses the sentence too: "habrías" before a participle (si lo ___ sabido) is the conditional perfect.
    static func info(for choice: String, in item: MoodItem) -> MoodTenseInfo? {
        if let tense = overrides[item.id]?[choice.lowercased()] { return byTense[tense] }
        let word = choice.lowercased()
        if haberForms.contains(word), let range = item.prompt.range(of: "___ ") {
            let next = item.prompt[range.upperBound...].prefix { $0.isLetter }.lowercased()
            if ["ado", "ido", "to", "cho", "so"].contains(where: { next.hasSuffix($0) }), let helper = index[word] { return perfect[helper] }
        }
        return info(for: choice)
    }

    /// The tense of a choice such as "tuviera", "que vaya", "hubiera venido" or "ir"; nil when it isn't a verb form.
    static func info(for choice: String) -> MoodTenseInfo? {
        let words = choice.lowercased().split(separator: " ").map(String.init).filter { !clitics.contains($0) }
        guard let first = words.first else { return nil }
        if words.count >= 2, let helper = index[first], haberForms.contains(first) {
            return perfect[helper]
        }
        // ir a + infinitive: named by the tense of ir ("vamos a llegar", "vayamos a llegar")
        if words.count >= 3, words[1] == "a", infinitives.contains(words[2]) { return index[first].flatMap { byTense[$0] } }
        guard words.count == 1 else { return nil }
        if infinitives.contains(first) { return infinitive }
        // An infinitive with a pronoun on the end: perderme, irse, decírselo
        for clitic in ["me", "te", "se", "nos", "os", "lo", "la", "le", "los", "las", "les"] where first.hasSuffix(clitic) {
            let base = String(first.dropLast(clitic.count)).folding(options: .diacriticInsensitive, locale: Locale(identifier: "es"))
            if infinitives.contains(base) || infinitives.contains(base + "se") { return infinitive }
        }
        return index[first].flatMap { byTense[$0] }
    }

    // MARK: - The verbs of a sentence

    /// One verb in a Learn sentence: "viniera — venir, imperfect subjunctive (yo or él/ella/usted)".
    struct SentenceVerb: Hashable {
        let word: String
        let verb: String
        let tense: MoodTenseInfo
        let persons: [Int]
        /// The simple tense, or the tense of haber for "haya venido".
        let base: Tense?
        let perfect: Bool
        /// Where the verb starts, counted in words.
        var position = 0

        var personText: String {
            let names = ["yo", "tú", "él/ella/usted", "nosotros", "vosotros", "ellos/ustedes"]
            let shown = persons.count > 1 ? persons.filter { $0 != 4 } : persons
            return shown.map { names[$0] }.joined(separator: " or ")
        }
        /// "ser or ir" for the forms they share (fue, fuera).
        var verbLabel: String {
            guard verb == "ser", let ir = Conjugator.conjugate("ir"), let base, !perfect,
                  persons.contains(where: { ir.form(base, $0)?.lowercased() == word }) else { return verb }
            return "ser or ir"
        }
        var isSubjunctive: Bool { base == .subjunctivePresent || base == .subjunctiveImperfect }
    }

    /// Words spelled like a verb form that are almost always something else here (como, para, entre...).
    private static let notVerbs: Set<String> = ["como", "para", "sobre", "entre", "bajo", "nada", "casa", "cara", "solo", "ante", "media", "vino", "río",
        "seguro", "mientras", "bien", "mal", "mi", "agua", "así", "cosa", "frío", "hermana", "hermano", "idea", "mesa", "obvio", "oferta",
        "pena", "piso", "salvo", "tarde", "una", "listo", "abrigo", "enfermo", "enferma", "ganas", "sin", "cuenta", "noticia", "verdad", "mentira", "duda", "miedo"]
    /// After one of these a word is a noun or adjective: "mi trabajo", "la espera", "muy cansado", "sin duda".
    private static let beforeNouns: Set<String> = ["el", "un", "una", "unos", "unas", "mi", "tu", "su", "mis", "tus", "sus",
        "nuestro", "nuestra", "este", "esta", "ese", "esa", "muy", "sin", "del", "al", "de", "en", "con", "por"]
    /// Verbs that win when a form belongs to two: creo is creer (not crear), siento sentir, vengo venir, vivo vivir.
    private static let preferredVerbs = ["ser", "estar", "ir", "venir", "creer", "sentir", "vivir", "decir", "tener", "hacer", "poder", "querer", "saber", "ver", "dar"]

    /// Every form of every Learn verb → the verb, tense and persons it is ("viniera" → venir, imperfect subjunctive, yo and él).
    private static let formIndex: [String: (verb: String, tense: Tense, persons: [Int])] = {
        var map: [String: (verb: String, tense: Tense, persons: [Int])] = [:]
        let rank = Dictionary(uniqueKeysWithValues: order.enumerated().map { ($1, $0) })
        var verbs: [String] = []
        for verb in preferredVerbs + DrillSentences.verbList + MoodMap.extraVerbs + ["parecer", "conocer", "quejarse", "darse"] where !verbs.contains(verb) { verbs.append(verb) }
        // Commands last, so "sé" is saber (I know), not the command of ser
        for commands in [false, true] {
            for verb in verbs {
                guard let conjugation = Conjugator.conjugate(verb) else { continue }
                for tense in order where (tense == .imperative) == commands {
                    for person in 0..<6 {
                        guard let form = conjugation.form(tense, person)?.lowercased(), !form.contains(" ") else { continue }
                        if let old = map[form] {
                            if old.verb == verb, old.tense == tense { map[form]!.persons.append(person); continue }
                            // A more common verb keeps its form (cree is creer, not crear's subjunctive); within a verb the order decides
                            if old.verb != verb || rank[old.tense]! <= rank[tense]! { continue }
                        }
                        map[form] = (verb, tense, [person])
                    }
                }
            }
        }
        map["hay"] = ("haber", .present, [2])
        return map
    }()

    /// Forms that are both present and preterite (llegamos, salimos): nosotros of -ar and -ir verbs.
    private static let presentOrPreterite: Set<String> = {
        var set = Set<String>()
        for verb in Set(DrillSentences.verbList + MoodMap.extraVerbs) {
            guard let c = Conjugator.conjugate(verb), let present = c.form(.present, 3), present == c.form(.preterite, 3) else { continue }
            set.insert(present.lowercased())
        }
        return set
    }()

    /// The verbs of a sentence in order, each with its tense. "haya venido" and "va a llover" count as one verb.
    static func verbs(in sentence: String) -> [SentenceVerb] {
        let words = sentence.lowercased().split { !$0.isLetter }.map(String.init)
        var found: [SentenceVerb] = []
        var i = 0
        func add(_ verb: SentenceVerb) { var verb = verb; verb.position = i; found.append(verb) }
        func infinitiveOf(_ word: String) -> String? {
            if infinitives.contains(word) { return word }
            // With a pronoun on the end: irme, haberlo, decírselo
            for clitic in ["selo", "sela", "melo", "telo", "me", "te", "se", "nos", "os", "lo", "la", "le", "los", "las", "les"] where word.hasSuffix(clitic) {
                let base = String(word.dropLast(clitic.count)).folding(options: .diacriticInsensitive, locale: Locale(identifier: "es"))
                if infinitives.contains(base) || base == "haber" { return base }
            }
            return nil
        }
        while i < words.count {
            let word = words[i]
            defer { i += 1 }
            let next = i + 1 < words.count ? words[i + 1] : ""
            if haberForms.contains(word), ["ado", "ido", "ído", "to", "cho", "so"].contains(where: { next.hasSuffix($0) }),
               let helper = formIndex[word], let info = perfect[helper.tense] {
                let verb = infinitives.first { Conjugator.conjugate($0)?.participle == next } ?? next
                add(SentenceVerb(word: "\(word) \(next)", verb: verb, tense: info, persons: helper.persons, base: helper.tense, perfect: true))
                i += 1
                continue
            }
            if let base = infinitiveOf(word) {
                // haber + participle as an infinitive: "haber venido", "haberlo sabido"
                if base == "haber", ["ado", "ido", "ído", "to", "cho", "so"].contains(where: { next.hasSuffix($0) }) {
                    add(SentenceVerb(word: "\(word) \(next)", verb: infinitives.first { Conjugator.conjugate($0)?.participle == next } ?? next,
                                              tense: perfectInfinitive, persons: [], base: nil, perfect: true))
                    i += 1
                } else {
                    add(SentenceVerb(word: word, verb: base, tense: infinitive, persons: [], base: nil, perfect: false))
                }
                continue
            }
            guard !notVerbs.contains(word), i == 0 || !beforeNouns.contains(words[i - 1]) else { continue }
            if formIndex[word] == nil, let ra = raForm(of: word), let entry = formIndex[ra], entry.tense == .subjunctiveImperfect, let info = byTense[entry.tense] {
                add(SentenceVerb(word: word, verb: entry.verb, tense: MoodTenseInfo(id: info.id, name: "imperfect subjunctive (-se form)", meaning: info.meaning, uses: info.uses),
                                 persons: entry.persons, base: entry.tense, perfect: false))
                continue
            }
            if formIndex[word] == nil, let command = commandWithPronoun(word) {
                add(command)
                continue
            }
            guard let entry = formIndex[word], let info = byTense[entry.tense] else { continue }
            // ir a + infinitive: "va a llover" is the near future
            if entry.verb == "ir", next == "a", i + 2 < words.count, let inf = infinitiveOf(words[i + 2]) {
                let tense = entry.tense == .present ? nearFuture
                    : MoodTenseInfo(id: info.id, name: "\(info.name) of ir a + infinitive", meaning: info.meaning, uses: info.uses)
                add(SentenceVerb(word: "\(word) a \(words[i + 2])", verb: inf, tense: tense, persons: entry.persons, base: entry.tense, perfect: false))
                i += 2
                continue
            }
            var tense = info
            if presentOrPreterite.contains(word), entry.tense == .present || entry.tense == .preterite {
                tense = MoodTenseInfo(id: info.id, name: "present or preterite (same form)", meaning: info.meaning, uses: info.uses)
            }
            add(SentenceVerb(word: word, verb: entry.verb, tense: tense, persons: entry.persons, base: entry.tense, perfect: false))
        }
        return found
    }

    /// "quisiese" → "quisiera", "hablásemos" → "habláramos": the -se imperfect subjunctive as its -ra twin.
    private static func raForm(of word: String) -> String? {
        for (se, ra) in [("semos", "ramos"), ("seis", "rais"), ("ses", "ras"), ("sen", "ran"), ("se", "ra")] where word.hasSuffix(se) && word.count > se.count + 2 {
            return String(word.dropLast(se.count)) + ra
        }
        return nil
    }

    /// A command with a pronoun on the end: siéntese, dímelo, llámame. With se it's usted or ustedes (siéntese is sentarse, not sentir).
    private static func commandWithPronoun(_ word: String) -> SentenceVerb? {
        let fold = { (w: String) in w.folding(options: .diacriticInsensitive, locale: Locale(identifier: "es")) }
        for clitic in ["selo", "sela", "melo", "telo", "noslo", "se", "me", "te", "nos", "lo", "la", "le", "los", "las", "les"] where word.count > clitic.count + 1 && word.hasSuffix(clitic) {
            guard let candidates = commandIndex[fold(String(word.dropLast(clitic.count)))], let info = byTense[.imperative] else { continue }
            let pick = clitic.hasPrefix("se") ? candidates.first { [2, 5].contains($0.1) } ?? candidates[0] : candidates[0]
            return SentenceVerb(word: word, verb: pick.0, tense: info, persons: [pick.1], base: .imperative, perfect: false)
        }
        return nil
    }

    /// Accent-free command forms → every verb and person they belong to, for commands with a pronoun attached.
    private static let commandIndex: [String: [(String, Int)]] = {
        var map: [String: [(String, Int)]] = [:]
        let fold = { (w: String) in w.folding(options: .diacriticInsensitive, locale: Locale(identifier: "es")) }
        for verb in preferredVerbs + DrillSentences.verbList + MoodMap.extraVerbs {
            guard let c = Conjugator.conjugate(verb) else { continue }
            for person in 0..<6 {
                guard let form = c.form(.imperative, person)?.lowercased(), !form.contains(" ") else { continue }
                map[fold(form), default: []].append((verb.hasSuffix("se") ? String(verb.dropLast(2)) : verb, person))
            }
        }
        return map
    }()

    static let nearFuture = MoodTenseInfo(id: "nearFuture", name: "near future (ir a + infinitive)",
        meaning: "What is going to happen.", uses: "Vamos a llegar tarde, va a llover. As a claim, it's indicative.")
    static let perfectInfinitive = MoodTenseInfo(id: "perfectInfinitive", name: "perfect infinitive (haber + participle)",
        meaning: "The infinitive of “have done”: something finished before.", uses: "Me alegro de haber venido, siento no haber llamado.")

    /// How each subjunctive verb's tense is chosen in the sentence: from the main verb before it, or from si, como si, ojalá.
    /// `pastKnown` false: no rewrite into the imperfect subjunctive ("Told about the past: …") before the learner has met it.
    static func usage(in sentence: String, pastKnown: Bool = true) -> [String] {
        let verbs = verbs(in: sentence)
        let words = sentence.lowercased().split { !$0.isLetter }.map(String.init)
        var lines: [String] = []
        for (k, verb) in verbs.enumerated() {
            guard verb.isSubjunctive else {
                if let line = plainLine(verbs, k, words) { lines.append(line) }
                continue
            }
            let word = verb.word, name = verb.tense.name
            let first = word.split(separator: " ").first.map(String.init) ?? word
            let at = verb.position
            let before = Array(words[..<at])
            let past = verb.base == .subjunctiveImperfect
            if before.suffix(2) == ["como", "si"] {
                lines.append("Como si (as if) always takes a past subjunctive, whatever the main verb: \(word).")
                continue
            }
            if before.last == "si", past {
                lines.append("After si (if), the \(name) makes the condition unreal or unlikely: it isn't so, or probably won't be.")
                continue
            }
            let mainBefore = verbs[..<k].last { !$0.isSubjunctive && $0.base != nil }
            let lead = before.filter { !["me", "te", "se", "nos", "os", "lo", "la", "le", "les", "yo", "tú"].contains($0) }
            if mainBefore == nil, before.contains("ojalá") {
                lines.append(past
                    ? "With ojalá, the \(name) wishes for something unlikely or that can't happen now."
                    : "With ojalá, the \(name) wishes for something that can still happen.")
                continue
            }
            if mainBefore == nil, lead == ["no"], verb.base == .subjunctivePresent, k == 0 {
                lines.append("No + the present subjunctive is a negative command (no \(first)). Negative commands use the subjunctive forms, not the command ones.")
                continue
            }
            if mainBefore == nil, lead == ["que"], verb.base == .subjunctivePresent {
                lines.append("Que + the present subjunctive on its own is a wish or an order, with “I hope” or “let” left out: que \(word)…")
                continue
            }
            if mainBefore == nil, past, lead.isEmpty, ["querer", "poder", "deber"].contains(verb.verb) {
                lines.append("\(word.capitalizedFirst) on its own is a polite request, softer than \(Conjugator.conjugate(verb.verb)?.form(.present, verb.persons.first ?? 0) ?? "the present").")
                continue
            }
            // With the subjunctive clause first (cuando llegues, te llamo), the main verb comes after it
            let main = mainBefore ?? verbs[(k + 1)...].first { !$0.isSubjunctive && $0.base != nil }
            guard let main, let mainBase = main.base else {
                lines.append(verb.isSubjunctive ? "\(word.capitalizedFirst) is the \(name). \(verb.tense.meaning)" : "\(word.capitalizedFirst) is \(indicative(verb)): a plain statement.")
                continue
            }
            let mainName = main.tense.name
            let mainPast = [.preterite, .imperfect].contains(mainBase) || (main.perfect && mainBase == .imperfect)
            // Rewritten only for "main que sub" at the end of the sentence, so the other tense is sure to read right
            let mainAt: Int? = main.position
            let plain = mainBefore != nil && main.verb != "poder" && !verb.perfect && !main.perfect && k == verbs.count - 1 && mainAt.map { $0 + 1 < words.count && words[$0 + 1] == "que" && ($0 == 0 || words[$0 - 1] != "hace") } == true
                && words.filter { $0 == main.word }.count == 1
            if mainBase == .conditional {
                lines.append("The main verb, \(main.word), is in the conditional, which takes a past subjunctive just like a past verb: \(word).")
            } else if past {
                if mainPast {
                    var line = "\(word.capitalizedFirst) is the \(name) because the main verb, \(main.word), is in the past (\(mainName)): the subjunctive moves back in time with it."
                    if plain, let swap = swapped(sentence, main: main, to: .present, sub: verb, to: .subjunctivePresent) {
                        line += " With a present main verb: \(swap)."
                    }
                    lines.append(line)
                } else {
                    lines.append("The main verb, \(main.word), is \(mainName), but \(word) is the \(name): it looks back at the past, or at something unlikely.")
                }
            } else if mainPast {
                lines.append("The main verb, \(main.word), is in the past, but the \(name) \(word) says it is still to come, or still true now.")
            } else {
                let what = mainBase == .imperative ? "a command" : mainName
                var line = "\(word.capitalizedFirst) is the \(name) because the main verb, \(main.word), is \(what): \(verb.perfect ? "a finished event judged from now." : "now or later.")"
                let pastTense: Tense = telling.contains(main.verb) ? .preterite : .imperfect
                if plain, pastKnown, mainBase != .imperative, let swap = swapped(sentence, main: main, to: pastTense, sub: verb, to: .subjunctiveImperfect) {
                    line += " Told about the past: \(swap)."
                }
                lines.append(line)
            }
        }
        // Every sentence gets at least one line: the main verb's tense and what it does
        if lines.isEmpty, let verb = verbs.first(where: { $0.base != nil }) ?? verbs.first {
            lines.append("\(verb.word.capitalizedFirst) is the \(verb.tense.name). \(verb.tense.meaning)")
        }
        return lines
    }

    private static let clauseWords: Set<String> = ["que", "si", "cuando", "cuándo", "aunque", "mientras", "porque", "quizás", "quizá", "tal", "mejor", "como", "desde", "después", "siempre", "salvo", "pesar", "más", "capaz"]

    /// Why a verb that isn't subjunctive is in its form: an infinitive with no new subject, or an indicative after que, si, cuando...
    private static func plainLine(_ verbs: [SentenceVerb], _ k: Int, _ words: [String]) -> String? {
        let verb = verbs[k], word = verb.word, name = verb.tense.name
        let at = verb.position
        let main = verbs[..<k].last { $0.base != nil }
        let mainAt = main?.position
        let between = Array(words[min((mainAt ?? -1) + 1, at)..<at])
        if verb.base == nil {
            let prev = at > 0 ? words[at - 1] : "", prev2 = at > 1 ? words[at - 2] : ""
            let kind = verb.perfect ? "a perfect infinitive" : "an infinitive"
            if verb.perfect, prev == "de", at == 1 {
                return "De + \(word) at the start is a short unreal condition: de haberlo sabido = si lo hubiera sabido (if I had known)."
            }
            if ["para", "sin"].contains(prev) || (prev == "de" && ["antes", "después"].contains(prev2)) {
                let link = prev == "de" ? "\(prev2) de" : prev
                return "\(word.capitalizedFirst) is \(kind): after \(link) with the same subject, Spanish uses the infinitive, not que + subjunctive."
            }
            if ["de", "en", "a", "al", "por"].contains(prev) {
                return "\(word.capitalizedFirst) is \(kind): after a preposition (\(prev)), Spanish uses the infinitive."
            }
            guard let main, between.allSatisfy({ ["me", "te", "se", "nos", "lo", "la", "no", "de", "en", "a"].contains($0) || $0 == "importante" || $0 == "mejor" || $0 == "bueno" || $0 == "necesario" }) else { return nil }
            if main.verb == "ser" {
                return "\(word.capitalizedFirst) is \(kind): said in general, about no one in particular, so there's no que + subjunctive."
            }
            if ["dejar", "permitir", "prohibir", "mandar", "hacer", "impedir"].contains(main.verb) {
                return "\(word.capitalizedFirst) is \(kind): with \(main.verb) the infinitive can follow even for another person (me dejan salir = they let me go out)."
            }
            if ["querer", "esperar", "preferir", "necesitar", "desear", "sentir", "creer"].contains(main.verb) {
                return "\(word.capitalizedFirst) is \(kind): the same person does both, so there's no que + subjunctive (quiero ir, not quiero que yo vaya)."
            }
            return "\(word.capitalizedFirst) is \(kind): \(main.word) takes the infinitive directly."
        }
        // The word that opens this verb's clause, after the main verb
        let scope = main == nil ? Array(words[..<at]) : between
        if words.starts(with: ["yo", "que", "tú"]) {
            return "Yo que tú (if I were you): in speech the imperfect (\(word)) often stands in for the conditional."
        }
        if scope.isEmpty || main == nil, words.contains("quizás") || words.contains("quizá"), !scope.contains("que") {
            return "With quizás, the indicative (\(word)) is a likelier guess; the subjunctive makes it more doubtful."
        }
        // A specific word (cuando, aunque, después de que) wins over the que that follows it
        guard let trigger = scope.last(where: { clauseWords.contains($0) && $0 != "que" }) ?? (scope.contains("que") ? "que" : nil) else { return nil }
        let present = verb.base == .present
        switch trigger {
        case "si":
            return present ? "Si with the present indicative is a real condition that can happen. Si never takes the present subjunctive."
                           : "Si with the \(name) is a real condition or a question (whether), so it's indicative."
        case "cuando", "mientras", "desde", "después", "siempre":
            let link = trigger == "siempre" ? "siempre que" : trigger == "desde" ? "desde que" : trigger == "después" ? "después de que" : trigger
            return "\(link.capitalizedFirst) with the indicative (\(word)) is for what happens as a rule or already happened. For something still to come it takes the subjunctive."
        case "aunque":
            return "Aunque with the indicative (\(word)) grants it as a fact: even though. With the subjunctive it would mean even if."
        case "cuándo":
            return "In a question, cuándo takes the indicative: here the \(name)."
        case "salvo":
            return "Salvo que with the indicative adds a known fact as an exception: except that."
        case "pesar":
            return "A pesar de que with the indicative grants a known fact: despite the fact that."
        case "más":
            return "Por más que with the indicative is about real effort: however hard I tried. With the subjunctive it would be however hard I try."
        case "capaz":
            return "Capaz que (maybe, Latin America) usually takes the indicative: \(word)."
        case "porque":
            return "Porque gives the reason as a fact, so \(word) is indicative."
        case "mejor":
            return "A lo mejor (maybe) takes the indicative: \(word)."
        case "quizás", "quizá", "tal":
            return "After quizás or tal vez, the indicative (\(word)) is a likelier guess; the subjunctive makes it more doubtful."
        case "como":
            return "Como (since) at the start gives the reason as a fact: indicative."
        default:
            guard let main else { return "\(word.capitalizedFirst) is \(indicative(verb)): it states a fact." }
            if let q = scope.lastIndex(of: "que"), scope[..<q].contains(where: { ["el", "la", "los", "las", "un", "una", "unos", "unas", "alguien", "algo", "lo"].contains($0) }) {
                return "\(word.capitalizedFirst) is \(indicative(verb)): the person or thing it describes is real and known."
            }
            return "\(word.capitalizedFirst) is \(indicative(verb)): the clause after \(main.word) is put forward as true."
        }
    }

    /// The sentence a change card asks for: "Dudo que sea verdad." with "Dudo → No dudo" becomes "No dudo que es verdad."
    static func changed(_ item: MoodItem) -> String? {
        guard item.kind == .flip, let right = item.correct.min(), item.choices.indices.contains(right) else { return nil }
        let parts = item.choices[right].components(separatedBy: " → ")
        guard parts.count == 2 else { return nil }
        var sentence = item.prompt
        guard let range = sentence.range(of: parts[0], options: .caseInsensitive) else { return nil }
        sentence.replaceSubrange(range, with: parts[1])
        // "Right now it takes the subjunctive (sea). Make the indicative (es) right."
        let marked = item.context.matches(of: /\(([^)]+)\)/).map { String($0.1) }
        if marked.count == 2, !parts[1].contains(marked[1]),
           let verb = sentence.range(of: "\\b\(marked[0])\\b", options: .regularExpression) {
            sentence.replaceSubrange(verb, with: marked[1])
        }
        return sentence.capitalizedFirst
    }

    /// The mood first, then the tense in plain words, so "imperfect" isn't read as the imperfect subjunctive:
    /// "in the indicative (the imperfect: the past as background, was or used to)".
    private static func indicative(_ verb: SentenceVerb) -> String {
        let time: String
        if verb.tense.name.contains(" or ") { time = verb.tense.name }
        else {
            switch verb.tense.id {
            case "present": time = "the present: now, or as a habit"
            case "preterite": time = "the preterite: a finished past event"
            case "imperfect": time = "the imperfect: the past as background, was or used to"
            case "future": time = "the future: will"
            case "conditional": time = "the conditional: would"
            case "nearFuture": time = "ir a + infinitive: going to"
            default: time = verb.tense.name
            }
        }
        return "in the indicative (\(time))"
    }

    /// Verbs whose subject is the thing liked, not the person: me gusta que, me sorprende que.
    private static let likeVerbs: Set<String> = ["gustar", "encantar", "importar", "molestar", "sorprender", "preocupar", "alegrar", "doler", "faltar", "parecer"]

    private static let telling: Set<String> = ["decir", "pedir", "rogar", "mandar", "ordenar", "exigir", "recomendar", "aconsejar", "sugerir", "prohibir", "permitir", "insistir"]

    /// The sentence with the main verb and the subjunctive put in other tenses, same persons: "Me dijo que viniera." → "me dice que venga".
    private static func swapped(_ sentence: String, main: SentenceVerb, to mainTense: Tense, sub: SentenceVerb, to subTense: Tense) -> String? {
        let mainPerson = likeVerbs.contains(main.verb) && main.persons.contains(2) ? 2 : main.persons.first
        guard let mainPerson, let subPerson = sub.persons.first,
              let newMain = Conjugator.conjugate(main.verb)?.form(mainTense, mainPerson),
              let newSub = Conjugator.conjugate(sub.verb)?.form(subTense, subPerson) else { return nil }
        var result = sentence.trimmingCharacters(in: CharacterSet(charactersIn: " .!?¿¡"))
        for (from, to) in [(main.word, newMain), (sub.word, newSub)] {
            if let range = result.range(of: "\\b\(from)\\b", options: [.regularExpression, .caseInsensitive]) { result.replaceSubrange(range, with: to) }
        }
        return result.capitalizedFirst
    }
}

private extension String {
    var capitalizedFirst: String { prefix(1).uppercased() + dropFirst() }
    var lowercasedFirst: String { prefix(1).lowercased() + dropFirst() }
}
