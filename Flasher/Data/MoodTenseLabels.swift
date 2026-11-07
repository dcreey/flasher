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
            uses: "The result of an unreal condition (si tuviera tiempo, te llamaría), polite requests (¿podrías ayudarme?), and the future seen from the past (dijo que vendría). Never in the si part itself."),
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
}
