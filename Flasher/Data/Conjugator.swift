import Foundation

enum Mood: String, CaseIterable, Identifiable {
    case indicative, subjunctive, imperative
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

enum Tense: String, CaseIterable, Identifiable {
    case present, preterite, imperfect, future, conditional
    case subjunctivePresent, subjunctiveImperfect
    case imperative

    var id: String { rawValue }

    var title: String {
        switch self {
        case .present, .subjunctivePresent: "Presente"
        case .preterite: "Pretérito"
        case .imperfect, .subjunctiveImperfect: "Imperfecto"
        case .future: "Futuro"
        case .conditional: "Condicional"
        case .imperative: "Imperativo"
        }
    }

    /// One or two English words that capture what the tense is for.
    var gloss: String {
        switch self {
        case .present: "now"
        case .preterite: "did"
        case .imperfect: "used to"
        case .future: "will"
        case .conditional: "would"
        case .subjunctivePresent: "may"
        case .subjunctiveImperfect: "if / wish"
        case .imperative: "command"
        }
    }

    var mood: Mood {
        switch self {
        case .present, .preterite, .imperfect, .future, .conditional: .indicative
        case .subjunctivePresent, .subjunctiveImperfect: .subjunctive
        case .imperative: .imperative
        }
    }

    static func tenses(in mood: Mood) -> [Tense] { allCases.filter { $0.mood == mood } }
}

struct Conjugation {
    /// Column order of every tense: yo, tú, él/ella/usted, nosotros, vosotros, ellos/ustedes.
    static let pronouns = ["yo", "tú", "él", "nosotros", "vosotros", "ellos"]
    static let imperativePronouns = ["", "tú", "usted", "nosotros", "vosotros", "ustedes"]
    static let reflexivePronouns = ["me", "te", "se", "nos", "os", "se"]

    let infinitive: String
    let gerund: String
    let participle: String
    let reflexive: Bool
    /// Words that follow the verb in a multi-word entry ("echar ganas").
    let tail: String
    let forms: [Tense: [String?]]
    let regularForms: [Tense: [String?]]
    let regularEndings: [Tense: [String?]]
    /// Imperative with the reflexive pronoun attached ("lávate"); nil for non-reflexive verbs.
    let attachedImperative: [String?]?

    func form(_ tense: Tense, _ person: Int) -> String? { forms[tense]?[person] ?? nil }

    /// Splits a form into its stem and its (regular) ending. When the form doesn't end the regular way
    /// the whole form is returned as the ending and `regularEnding` is false.
    func parts(_ tense: Tense, _ person: Int) -> (stem: String, ending: String, regularEnding: Bool)? {
        guard let form = form(tense, person), let ending = regularEndings[tense]?[person] ?? nil else { return nil }
        if form.hasSuffix(ending) { return (String(form.dropLast(ending.count)), ending, true) }
        return ("", form, false)
    }

    /// The stem shared by the row, read off the nosotros/vosotros cells which rarely change.
    func rowStem(_ tense: Tense) -> String {
        for person in [3, 4, 5, 2, 1, 0] {
            if let parts = parts(tense, person), parts.regularEnding { return parts.stem }
        }
        return ""
    }

    func regularRowStem(_ tense: Tense) -> String {
        for person in [3, 4, 5, 2, 1, 0] {
            if let form = regularForms[tense]?[person] ?? nil, let ending = regularEndings[tense]?[person] ?? nil {
                return String(form.dropLast(ending.count))
            }
        }
        return ""
    }

    /// Persons whose stem differs from the rest of the row.
    func stemChangedPersons(_ tense: Tense) -> Set<Int> {
        let stem = rowStem(tense)
        return Set((0..<6).filter { person in
            guard let parts = parts(tense, person) else { return false }
            return !parts.regularEnding || parts.stem != stem
        })
    }
}

enum Conjugator {
    private static var cache: [String: Conjugation?] = [:]

    static func conjugate(_ entry: String) -> Conjugation? {
        if let hit = cache[entry] { return hit }
        let result = build(entry)
        cache[entry] = .some(result)
        return result
    }

    private static func build(_ entry: String) -> Conjugation? {
        let words = entry.split(separator: " ").map(String.init)
        guard var verb = words.first else { return nil }
        let tail = words.dropFirst().joined(separator: " ")
        var reflexive = false
        if verb.count > 3, verb.hasSuffix("se") {
            verb = String(verb.dropLast(2))
            reflexive = true
        }
        guard let engine = Engine(infinitive: verb) else { return nil }

        let present = engine.presentForms()
        let preterite = engine.preteriteForms()
        let subjunctive = engine.subjunctivePresentForms()
        let imperative = engine.imperativeForms(present: present, subjunctive: subjunctive)

        var forms: [Tense: [String?]] = [:]
        forms[.present] = present
        forms[.preterite] = preterite
        forms[.imperfect] = engine.imperfectForms()
        forms[.future] = engine.futureForms()
        forms[.conditional] = engine.conditionalForms()
        forms[.subjunctivePresent] = subjunctive
        forms[.subjunctiveImperfect] = engine.subjunctiveImperfectForms(preterite: preterite)
        forms[.imperative] = imperative

        let regular = engine.regularForms()
        return Conjugation(
            infinitive: engine.inf,
            gerund: engine.gerund,
            participle: engine.participle,
            reflexive: reflexive,
            tail: tail,
            forms: forms,
            regularForms: regular.forms,
            regularEndings: regular.endings,
            attachedImperative: reflexive ? engine.attachedImperative(imperative) : nil
        )
    }

    // MARK: - Irregularity data

    private enum Kind { case ar, er, ir }

    private enum Boot {
        case none
        case eie      // pensar, perder, tener
        case ue       // contar, volver
        case ei       // pedir, seguir
        case eieIr    // sentir, venir: e→ie, and e→i in -ir spots
        case ueIr     // dormir: o→ue, and o→u in -ir spots
        case uue      // jugar
        case hue      // oler
        case uediaeresis  // avergonzar
    }

    private struct Irr {
        var yoStem: String?
        var pretStem: String?
        var futStem: String?
        var participle: String?
        var gerund: String?
        var tu: String?
        var present: [String]?
        var preterite: [String]?
        var imperfect: [String]?
        var subjunctive: [String]?
        var imperative: [String?]?

        func prefixed(_ p: String) -> Irr {
            guard !p.isEmpty else { return self }
            func one(_ s: String?) -> String? { s.map { p + $0 } }
            func many(_ a: [String]?) -> [String]? { a?.map { p + $0 } }
            var r = self
            r.yoStem = one(yoStem); r.pretStem = one(pretStem); r.futStem = one(futStem)
            r.participle = one(participle); r.gerund = one(gerund)
            r.present = many(present); r.preterite = many(preterite)
            r.imperfect = many(imperfect); r.subjunctive = many(subjunctive)
            r.imperative = imperative?.map { $0.map { p + $0 } }
            return r
        }
    }

    private struct Entry<T> {
        let key: String
        let compound: Bool   // also matches verbs that end with `key` (detener ← tener)
        let value: T
        init(_ key: String, _ compound: Bool, _ value: T) { self.key = key; self.compound = compound; self.value = value }
    }

    /// Verbs that merely look like compounds of an irregular verb but are regular.
    private static let regularLookalikes: Set<String> = ["pretender", "compensar", "recompensar", "dispensar"]

    private static let sixes = ["o", "as", "a", "amos", "áis", "an"]

    private static let irregulars: [Entry<Irr>] = [
        Entry("ser", false, Irr(
            participle: "sido", gerund: "siendo",
            present: ["soy", "eres", "es", "somos", "sois", "son"],
            preterite: ["fui", "fuiste", "fue", "fuimos", "fuisteis", "fueron"],
            imperfect: ["era", "eras", "era", "éramos", "erais", "eran"],
            subjunctive: ["sea", "seas", "sea", "seamos", "seáis", "sean"],
            imperative: [nil, "sé", "sea", "seamos", "sed", "sean"])),
        Entry("ir", false, Irr(
            participle: "ido", gerund: "yendo",
            present: ["voy", "vas", "va", "vamos", "vais", "van"],
            preterite: ["fui", "fuiste", "fue", "fuimos", "fuisteis", "fueron"],
            imperfect: ["iba", "ibas", "iba", "íbamos", "ibais", "iban"],
            subjunctive: ["vaya", "vayas", "vaya", "vayamos", "vayáis", "vayan"],
            imperative: [nil, "ve", "vaya", "vamos", "id", "vayan"])),
        Entry("estar", false, Irr(
            pretStem: "estuv", tu: "está",
            present: ["estoy", "estás", "está", "estamos", "estáis", "están"],
            subjunctive: ["esté", "estés", "esté", "estemos", "estéis", "estén"])),
        Entry("dar", false, Irr(
            present: ["doy", "das", "da", "damos", "dais", "dan"],
            preterite: ["di", "diste", "dio", "dimos", "disteis", "dieron"],
            subjunctive: ["dé", "des", "dé", "demos", "deis", "den"])),
        Entry("haber", false, Irr(
            pretStem: "hub", futStem: "habr",
            present: ["he", "has", "ha", "hemos", "habéis", "han"],
            subjunctive: ["haya", "hayas", "haya", "hayamos", "hayáis", "hayan"])),
        Entry("ver", false, Irr(
            yoStem: "ve", participle: "visto",
            present: ["veo", "ves", "ve", "vemos", "veis", "ven"],
            preterite: ["vi", "viste", "vio", "vimos", "visteis", "vieron"],
            imperfect: ["veía", "veías", "veía", "veíamos", "veíais", "veían"])),
        Entry("saber", false, Irr(
            pretStem: "sup", futStem: "sabr",
            present: ["sé", "sabes", "sabe", "sabemos", "sabéis", "saben"],
            subjunctive: ["sepa", "sepas", "sepa", "sepamos", "sepáis", "sepan"])),
        Entry("caber", false, Irr(yoStem: "quep", pretStem: "cup", futStem: "cabr")),
        Entry("andar", false, Irr(pretStem: "anduv")),
        Entry("poder", false, Irr(pretStem: "pud", futStem: "podr", gerund: "pudiendo")),
        Entry("querer", false, Irr(pretStem: "quis", futStem: "querr")),
        Entry("satisfacer", false, Irr(
            yoStem: "satisfag", pretStem: "satisfic", futStem: "satisfar", participle: "satisfecho", tu: "satisface")),
        Entry("tener", true, Irr(yoStem: "teng", pretStem: "tuv", futStem: "tendr", tu: "ten")),
        Entry("venir", true, Irr(yoStem: "veng", pretStem: "vin", futStem: "vendr", tu: "ven")),
        Entry("poner", true, Irr(yoStem: "pong", pretStem: "pus", futStem: "pondr", participle: "puesto", tu: "pon")),
        Entry("hacer", true, Irr(yoStem: "hag", pretStem: "hic", futStem: "har", participle: "hecho", tu: "haz")),
        Entry("decir", true, Irr(yoStem: "dig", pretStem: "dij", participle: "dicho", tu: "di")),
        Entry("traer", true, Irr(yoStem: "traig", pretStem: "traj")),
        Entry("salir", true, Irr(yoStem: "salg", futStem: "saldr", tu: "sal")),
        Entry("valer", true, Irr(yoStem: "valg", futStem: "valdr")),
        Entry("caer", true, Irr(yoStem: "caig")),
        Entry("oír", true, Irr(
            yoStem: "oig", present: ["oigo", "oyes", "oye", "oímos", "oís", "oyen"])),
        Entry("reír", true, Irr(
            participle: "reído", gerund: "riendo",
            present: ["río", "ríes", "ríe", "reímos", "reís", "ríen"],
            preterite: ["reí", "reíste", "rió", "reímos", "reísteis", "rieron"],
            subjunctive: ["ría", "rías", "ría", "riamos", "riáis", "rían"],
            imperative: [nil, "ríe", "ría", "riamos", "reíd", "rían"])),
    ]

    private static let boots: [Entry<Boot>] = [
        // e → ie
        Entry("tener", true, .eie), Entry("querer", false, .eie), Entry("cerrar", true, .eie),
        Entry("pensar", true, .eie), Entry("perder", true, .eie), Entry("tender", true, .eie),
        Entry("scender", true, .eie), Entry("encender", true, .eie), Entry("defender", true, .eie),
        Entry("acertar", true, .eie), Entry("calentar", true, .eie), Entry("comenzar", true, .eie),
        Entry("negar", true, .eie), Entry("alentar", false, .eie), Entry("apretar", false, .eie),
        Entry("arrendar", false, .eie), Entry("asentar", false, .eie), Entry("atravesar", false, .eie),
        Entry("confesar", false, .eie), Entry("despertar", false, .eie), Entry("empezar", false, .eie),
        Entry("encomendar", false, .eie), Entry("recomendar", false, .eie), Entry("enmendar", false, .eie),
        Entry("fregar", false, .eie), Entry("gobernar", false, .eie), Entry("nevar", false, .eie),
        Entry("regar", false, .eie), Entry("sembrar", false, .eie), Entry("sentar", false, .eie),
        Entry("temblar", false, .eie), Entry("tropezar", false, .eie), Entry("aventar", false, .eie), Entry("cimentar", false, .eie),
        // o → ue
        Entry("cordar", true, .ue), Entry("contar", true, .ue), Entry("encontrar", true, .ue),
        Entry("costar", true, .ue), Entry("mostrar", true, .ue), Entry("probar", true, .ue),
        Entry("mover", true, .ue), Entry("volver", true, .ue), Entry("solver", true, .ue),
        Entry("soltar", true, .ue), Entry("sonar", true, .ue), Entry("soñar", true, .ue),
        Entry("volar", true, .ue), Entry("forzar", true, .ue), Entry("colgar", true, .ue),
        Entry("doler", true, .ue), Entry("morder", true, .ue), Entry("torcer", true, .ue),
        Entry("poder", false, .ue), Entry("almorzar", false, .ue), Entry("apostar", false, .ue),
        Entry("colar", false, .ue), Entry("consolar", false, .ue), Entry("demoler", false, .ue),
        Entry("llover", false, .ue), Entry("rodar", false, .ue), Entry("soldar", false, .ue),
        Entry("tronar", false, .ue), Entry("renovar", false, .ue),
        Entry("jugar", false, .uue), Entry("oler", false, .hue), Entry("avergonzar", false, .uediaeresis),
        // e → i
        Entry("pedir", true, .ei), Entry("seguir", true, .ei), Entry("servir", true, .ei),
        Entry("vestir", true, .ei), Entry("medir", true, .ei), Entry("petir", true, .ei),
        Entry("elegir", true, .ei), Entry("regir", true, .ei), Entry("decir", true, .ei),
        Entry("derretir", false, .ei),
        // e → ie / i, o → ue / u
        Entry("sentir", true, .eieIr), Entry("mentir", true, .eieIr), Entry("ferir", true, .eieIr),
        Entry("herir", true, .eieIr), Entry("gerir", true, .eieIr), Entry("vertir", true, .eieIr),
        Entry("hervir", true, .eieIr), Entry("requerir", true, .eieIr), Entry("venir", true, .eieIr),
        Entry("arrepentir", false, .eieIr),
        Entry("dormir", true, .ueIr), Entry("morir", true, .ueIr),
    ]

    private static let participles: [Entry<String>] = [
        Entry("abrir", true, "abierto"), Entry("cubrir", true, "cubierto"), Entry("scribir", true, "scrito"),
        Entry("romper", true, "roto"), Entry("solver", true, "suelto"), Entry("volver", true, "vuelto"),
        Entry("morir", true, "muerto"), Entry("freír", false, "frito"), Entry("imprimir", false, "impreso"),
        Entry("prever", false, "previsto"),
    ]

    /// -iar / -uar / -unir / -ibir verbs that stress the stem vowel in the "boot" forms (envío, reúno).
    private static let stressedStemVowel: [String: Character] = [
        "enviar": "i", "confiar": "i", "desafiar": "i", "enfriar": "i", "fotografiar": "i", "vaciar": "i",
        "ampliar": "i", "criar": "i", "desviar": "i", "guiar": "i", "fiar": "i", "esquiar": "i", "variar": "i",
        "espiar": "i", "liar": "i", "aliar": "i", "rociar": "i", "resfriar": "i", "reunir": "u", "prohibir": "i",
        "cohibir": "i", "aislar": "i", "ahumar": "u", "aunar": "u", "rehusar": "u",
    ]

    private static func lookup<T>(_ table: [Entry<T>], _ inf: String) -> (value: T, prefix: String)? {
        if let exact = table.first(where: { $0.key == inf }) { return (exact.value, "") }
        guard !regularLookalikes.contains(inf) else { return nil }
        let match = table
            .filter { $0.compound && inf.count > $0.key.count && inf.hasSuffix($0.key) }
            .max { $0.key.count < $1.key.count }
        guard let match else { return nil }
        return (match.value, String(inf.dropLast(match.key.count)))
    }

    // MARK: - Engine

    private struct Engine {
        let inf: String
        let kind: Kind
        let stem: String
        let prefix: String
        var irr: Irr
        let boot: Boot
        let stressed: Character?
        let participleOverride: String?
        let isUir: Bool
        let softC: Bool   // cocer/mecer/hacer use c→z rather than c→zc

        private static let bootPersons = [0, 1, 2, 5]

        init?(infinitive: String) {
            let lower = infinitive.lowercased()
            if lower.hasSuffix("ar") { kind = .ar }
            else if lower.hasSuffix("er") { kind = .er }
            else if lower.hasSuffix("ir") || lower.hasSuffix("ír") { kind = .ir }
            else { return nil }
            inf = lower
            stem = String(lower.dropLast(2))

            var irr = Irr()
            var prefix = ""
            if let found = Conjugator.lookup(Conjugator.irregulars, lower) {
                irr = found.value.prefixed(found.prefix)
                irr.tu = found.value.tu
                prefix = found.prefix
            } else if lower.hasSuffix("ducir") {
                irr.pretStem = String(lower.dropLast(3)) + "j"
            }
            self.irr = irr
            self.prefix = prefix
            boot = Conjugator.lookup(Conjugator.boots, lower)?.value ?? .none
            participleOverride = Conjugator.lookup(Conjugator.participles, lower).map { $0.prefix + $0.value }
            if ["bendecir", "maldecir"].contains(lower) { self.irr.participle = nil }
            let s = stem
            let uarStressed = lower.hasSuffix("uar") && !s.hasSuffix("gu") && !s.hasSuffix("qu")
            stressed = Conjugator.stressedStemVowel[lower] ?? (uarStressed ? "u" : nil)
            isUir = kind == .ir && !lower.hasSuffix("ír")
                && ((s.hasSuffix("u") && !s.hasSuffix("gu") && !s.hasSuffix("qu")) || s.hasSuffix("ü"))
            softC = ["cocer", "mecer", "hacer"].contains { lower.hasSuffix($0) }
        }

        // MARK: Stems

        private var uirStem: String {
            stem.hasSuffix("ü") ? String(stem.dropLast()) + "uy" : stem + "y"
        }

        private var yoStem: String? { irr.yoStem ?? (isUir ? uirStem : nil) }

        /// Stem used in the "boot" persons (yo, tú, él, ellos) of the present.
        private var bootStem: String {
            var s = stem
            switch boot {
            case .none: break
            case .eie, .eieIr: s = Conjugator.replacingLast("e", with: "ie", in: s)
            case .ue, .ueIr: s = Conjugator.replacingLast("o", with: "ue", in: s)
            case .ei: s = Conjugator.replacingLast("e", with: "i", in: s)
            case .uue: s = Conjugator.replacingLast("u", with: "ue", in: s)
            case .hue: s = Conjugator.replacingLast("o", with: "hue", in: s)
            case .uediaeresis: s = Conjugator.replacingLast("o", with: "üe", in: s)
            }
            if let stressed {
                let accented: Character = ["i": "í", "u": "ú"][stressed] ?? stressed
                s = Conjugator.replacingLast(stressed, with: String(accented), in: s)
            }
            if isUir { s = uirStem }
            return s
        }

        /// Stem used where -ir verbs weaken the vowel (sintió, durmiendo, sintamos).
        private var irStem: String {
            guard kind == .ir else { return stem }
            switch boot {
            case .eieIr, .ei: return Conjugator.replacingLast("e", with: "i", in: stem)
            case .ueIr: return Conjugator.replacingLast("o", with: "u", in: stem)
            default: return stem
            }
        }

        // MARK: Spelling

        /// Attaches an ending to a stem and applies Spanish spelling rules at the seam.
        private func join(_ stem: String, _ ending: String) -> String {
            guard let first = ending.first else { return stem }
            var s = stem
            let e = Conjugator.unaccented(first)
            let plainStart = first == e

            if kind == .ar, e == "e" {
                if s.hasSuffix("gu") { s = String(s.dropLast(2)) + "gü" }
                else if s.hasSuffix("c") { s = String(s.dropLast()) + "qu" }
                else if s.hasSuffix("g") { s += "u" }
                else if s.hasSuffix("z") { s = String(s.dropLast()) + "c" }
            }
            if kind != .ar, e == "a" || e == "o" {
                if s.hasSuffix("gu") || s.hasSuffix("qu") { s = String(s.dropLast()) }
                else if s.hasSuffix("g") { s = String(s.dropLast()) + "j" }
                else if s.hasSuffix("c") {
                    let before = s.dropLast().last
                    let afterVowel = before.map { "aeiou".contains($0) } ?? false
                    s = String(s.dropLast()) + (afterVowel && !softC ? "zc" : "z")
                }
            }
            if kind != .ar, plainStart, e == "i", ending.count >= 2 {
                let next = ending[ending.index(after: ending.startIndex)]
                if "aeiouáéíóú".contains(next) {
                    // i between vowels becomes y (leyó); after ñ/ll it disappears (tañó)
                    if s.hasSuffix("ñ") || s.hasSuffix("ll") { return s + ending.dropFirst() }
                    if s.hasSuffix("ü") { return String(s.dropLast()) + "uy" + ending.dropFirst() }
                    if let last = s.last, "aeo".contains(last) || isUir && last == "u" {
                        return s + "y" + ending.dropFirst()
                    }
                } else if let last = s.last, "aeo".contains(last) {
                    return s + "í" + ending.dropFirst()   // leíste, caímos, traído
                }
            }
            return s + ending
        }

        // MARK: Tenses

        func presentForms() -> [String?] {
            if let p = irr.present { return p }
            let endings = Conjugator.presentEndings(kind)
            return (0..<6).map { i in
                if i == 0, let ys = irr.yoStem { return ys + "o" }
                return join(Self.bootPersons.contains(i) ? bootStem : stem, endings[i])
            }
        }

        func preteriteForms() -> [String] {
            if let p = irr.preterite { return p }
            if let ps = irr.pretStem {
                let third = ps.hasSuffix("j") ? "eron" : "ieron"
                let o = ps.hasSuffix("c") ? String(ps.dropLast()) + "zo" : ps + "o"
                return [ps + "e", ps + "iste", o, ps + "imos", ps + "isteis", ps + third]
            }
            let endings = Conjugator.preteriteEndings(kind)
            return (0..<6).map { i in join(i == 2 || i == 5 ? irStem : stem, endings[i]) }
        }

        func imperfectForms() -> [String] {
            if let p = irr.imperfect { return p }
            return Conjugator.imperfectEndings(kind).map { join(stem, $0) }
        }

        private var futureBase: String {
            if let fs = irr.futStem { return fs }
            return inf.hasSuffix("ír") ? String(inf.dropLast(2)) + "ir" : inf
        }

        func futureForms() -> [String] { Conjugator.futureEndings.map { futureBase + $0 } }
        func conditionalForms() -> [String] { Conjugator.conditionalEndings.map { futureBase + $0 } }

        func subjunctivePresentForms() -> [String] {
            if let s = irr.subjunctive { return s }
            let endings = Conjugator.subjunctiveEndings(kind)
            return (0..<6).map { i in
                if let ys = yoStem { return ys + endings[i] }
                return join(Self.bootPersons.contains(i) ? bootStem : irStem, endings[i])
            }
        }

        func subjunctiveImperfectForms(preterite: [String]) -> [String] {
            let base = String(preterite[5].dropLast(3))
            let stressedBase = Conjugator.accentingLast(base)
            return [base + "ra", base + "ras", base + "ra", stressedBase + "ramos", base + "rais", base + "ran"]
        }

        private var tuImperative: String? {
            guard let tu = irr.tu else { return nil }
            if prefix.isEmpty { return tu }
            switch tu {
            case "di": return nil
            case "pon", "ten", "ven": return prefix + Conjugator.accentingLast(tu)
            default: return prefix + tu
            }
        }

        func imperativeForms(present: [String?], subjunctive: [String]) -> [String?] {
            if let imperative = irr.imperative { return imperative }
            return [nil, tuImperative ?? present[2], subjunctive[2], subjunctive[3], String(inf.dropLast()) + "d", subjunctive[5]]
        }

        var gerund: String { irr.gerund ?? join(irStem, kind == .ar ? "ando" : "iendo") }

        var participle: String {
            participleOverride ?? irr.participle ?? join(stem, kind == .ar ? "ado" : "ido")
        }

        /// "lávate", "levántense", "vámonos", "vestíos"
        func attachedImperative(_ imperative: [String?]) -> [String?] {
            func clitic(_ word: String?, _ pronoun: String, dropLast drop: Int = 0) -> String? {
                guard let word else { return nil }
                return Conjugator.accentingForClitic(String(word.dropLast(drop))) + pronoun
            }
            var vos: String? = nil
            if let v = imperative[4] {
                if inf == "ir" { vos = "idos" }
                else {
                    var base = String(v.dropLast())
                    if base.hasSuffix("i") { base = String(base.dropLast()) + "í" }
                    vos = base + "os"
                }
            }
            return [nil, clitic(imperative[1], "te"), clitic(imperative[2], "se"),
                    clitic(imperative[3], "nos", dropLast: 1), vos, clitic(imperative[5], "se")]
        }

        // MARK: Regular baseline

        func regularForms() -> (forms: [Tense: [String?]], endings: [Tense: [String?]]) {
            let present = Conjugator.presentEndings(kind)
            let subjunctive = Conjugator.subjunctiveEndings(kind)
            let imperative: [String?] = [nil, present[2], subjunctive[2], subjunctive[3],
                                         kind == .ar ? "ad" : kind == .er ? "ed" : "id", subjunctive[5]]
            let endings: [Tense: [String?]] = [
                .present: present,
                .preterite: Conjugator.preteriteEndings(kind),
                .imperfect: Conjugator.imperfectEndings(kind),
                .future: Conjugator.futureEndings,
                .conditional: Conjugator.conditionalEndings,
                .subjunctivePresent: subjunctive,
                .subjunctiveImperfect: kind == .ar
                    ? ["ara", "aras", "ara", "áramos", "arais", "aran"]
                    : ["iera", "ieras", "iera", "iéramos", "ierais", "ieran"],
                .imperative: imperative,
            ]
            let futureBase = inf.hasSuffix("ír") ? String(inf.dropLast(2)) + "ir" : inf
            var forms: [Tense: [String?]] = [:]
            for (tense, list) in endings {
                let base = tense == .future || tense == .conditional ? futureBase : stem
                forms[tense] = list.map { $0.map { base + $0 } }
            }
            return (forms, endings)
        }
    }

    // MARK: - Endings

    private static func presentEndings(_ kind: Kind) -> [String] {
        switch kind {
        case .ar: ["o", "as", "a", "amos", "áis", "an"]
        case .er: ["o", "es", "e", "emos", "éis", "en"]
        case .ir: ["o", "es", "e", "imos", "ís", "en"]
        }
    }

    private static func preteriteEndings(_ kind: Kind) -> [String] {
        kind == .ar ? ["é", "aste", "ó", "amos", "asteis", "aron"] : ["í", "iste", "ió", "imos", "isteis", "ieron"]
    }

    private static func imperfectEndings(_ kind: Kind) -> [String] {
        kind == .ar ? ["aba", "abas", "aba", "ábamos", "abais", "aban"] : ["ía", "ías", "ía", "íamos", "íais", "ían"]
    }

    private static func subjunctiveEndings(_ kind: Kind) -> [String] {
        kind == .ar ? ["e", "es", "e", "emos", "éis", "en"] : ["a", "as", "a", "amos", "áis", "an"]
    }

    private static let futureEndings = ["é", "ás", "á", "emos", "éis", "án"]
    private static let conditionalEndings = ["ía", "ías", "ía", "íamos", "íais", "ían"]

    // MARK: - String helpers

    private static func replacingLast(_ vowel: Character, with replacement: String, in s: String) -> String {
        guard let index = s.lastIndex(of: vowel) else { return s }
        var result = s
        result.replaceSubrange(index...index, with: replacement)
        return result
    }

    private static func unaccented(_ c: Character) -> Character {
        ["á": "a", "é": "e", "í": "i", "ó": "o", "ú": "u"][c] ?? c
    }

    private static let accentOf: [Character: Character] = ["a": "á", "e": "é", "i": "í", "o": "ó", "u": "ú"]

    /// Accents the last vowel ("pon" → "pón", "habla" → "hablá").
    private static func accentingLast(_ s: String) -> String {
        guard let index = s.lastIndex(where: { accentOf[$0] != nil }) else { return s }
        var result = s
        result.replaceSubrange(index...index, with: String(accentOf[s[index]]!))
        return result
    }

    /// Adds the written accent a word needs before a pronoun is attached ("lava" → "lávate").
    /// One-syllable words and words that already carry an accent are left alone.
    private static func accentingForClitic(_ word: String) -> String {
        if word.contains(where: { "áéíóú".contains($0) }) { return word }
        let chars = Array(word)
        let strong: Set<Character> = ["a", "e", "o"]
        func isVowel(_ i: Int) -> Bool {
            let c = chars[i]
            guard strong.contains(c) || c == "i" || c == "u" || c == "ü" else { return false }
            if c == "u", i > 0, i + 1 < chars.count, "gq".contains(chars[i - 1]), "ei".contains(chars[i + 1]) { return false }
            return true
        }
        var groups: [[Int]] = []
        var i = 0
        while i < chars.count {
            guard isVowel(i) else { i += 1; continue }
            var group = [i]
            var j = i + 1
            while j < chars.count, isVowel(j), !(strong.contains(chars[j]) && strong.contains(chars[j - 1])) {
                group.append(j)
                j += 1
            }
            groups.append(group)
            i = j
        }
        guard groups.count >= 2 else { return word }
        let nucleus = groups[groups.count - 2]
        let target = nucleus.first { strong.contains(chars[$0]) } ?? nucleus.last!
        var result = chars
        result[target] = accentOf[chars[target]] ?? chars[target]
        return String(result)
    }
}
