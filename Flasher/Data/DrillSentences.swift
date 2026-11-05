import Foundation

/// Everything a conjugation drill can ask for: the simple tenses, the progressive and perfect tables, and three
/// "near future / near past" phrases (acabar de, ir a, estar por) followed by an infinitive.
struct DrillTense: Hashable {
    enum Kind: String, Hashable { case simple, progressive, perfect, acabarDe, irA, estarPor }
    let kind: Kind
    /// The tense of the main verb for simple tenses, of the helper (estar, haber, acabar, ir) for the others.
    let tense: Tense

    static let all: [DrillTense] =
        Tense.allCases.map { DrillTense(kind: .simple, tense: $0) }
        + VerbForm.gerund.tenses.map { DrillTense(kind: .progressive, tense: $0) }
        + VerbForm.participle.tenses.map { DrillTense(kind: .perfect, tense: $0) }
        + [Tense.present, .imperfect].map { DrillTense(kind: .acabarDe, tense: $0) }
        + [Tense.present, .imperfect].map { DrillTense(kind: .irA, tense: $0) }
        + [Tense.present, .imperfect, .preterite].map { DrillTense(kind: .estarPor, tense: $0) }

    var label: String { "\(kind.rawValue) \(tense.rawValue)" }
}

enum DrillSentences {
    /// The conjugated verb as it is written: "come", "estaba comiendo", "había comido", "acaba de comer", "va a comer".
    static func verbPhrase(_ infinitive: String, _ drill: DrillTense, person: Int) -> String? {
        guard let conjugation = Conjugator.conjugate(infinitive) else { return nil }
        let tense = drill.tense
        switch drill.kind {
        case .simple: return conjugation.attachedImperativeOrForm(tense, person)
        case .progressive: return CompoundForms.form(of: conjugation, .gerund, tense, person)
        case .perfect: return CompoundForms.form(of: conjugation, .participle, tense, person)
        case .acabarDe: return Conjugator.conjugate("acabar")?.form(tense, person).map { "\($0) de \(infinitive)" }
        case .irA: return Conjugator.conjugate("ir")?.form(tense, person).map { "\($0) a \(infinitive)" }
        case .estarPor: return Conjugator.conjugate("estar")?.form(tense, person).map { "\($0) por \(infinitive)" }
        }
    }

    /// Subjects that fit this verb in this drill. Empty when the drill skips the verb or tense.
    static func subjects(for infinitive: String, _ drill: DrillTense) -> [DrillSubject] {
        guard let usage = VerbUsage.of(infinitive), !VerbProfiles.isRare(infinitive) else { return [] }
        if drill.kind == .progressive, "ks".contains(usage.aspect), usage.valency != "D", usage.valency != "W" { return [] }
        if drill.kind == .acabarDe || drill.kind == .estarPor, usage.aspect == "s" { return [] }
        if drill.kind == .estarPor, usage.valency == "D" { return [] }
        if drill.tense == .imperative, drill.kind == .simple, "DWCS".contains(usage.valency) { return [] }
        if drill.kind != .simple, drill.tense == .imperative { return [] }
        return DrillSubjects.subjects(for: infinitive, tense: drill.tense)
    }

    /// Pronouns Spanish drops unless they are needed; "él/ella/usted/ellos/ustedes" and noun subjects stay.
    private static let dropped: Set<String> = ["yo", "tú", "nosotros", "vosotros"]

    private static func stableSeed(_ infinitive: String, _ drill: DrillTense, _ person: Int) -> Int {
        infinitive.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) % 1_000_003 } + person + (DrillTense.all.firstIndex(of: drill) ?? 0)
    }

    /// A full sentence for any verb the drill supports. The complement and cue words come from the verb's usage.
    static func sentence(_ infinitive: String, _ drill: DrillTense, subject: DrillSubject) -> String? {
        guard let usage = VerbUsage.of(infinitive), var verb = verbPhrase(infinitive, drill, person: subject.person), !verb.isEmpty else { return nil }
        let seed = stableSeed(infinitive, drill, subject.person)
        let profile = VerbProfiles.profile(infinitive)
        let people = subject.isPerson
        var shown = dropped.contains(subject.text) ? "" : subject.text
        var complement: String
        let animal = !people && VerbProfiles.profile(infinitive).kind == .living && !subject.text.isEmpty
        switch usage.valency {
        case "W": complement = ""
        case "D":
            // me gusta la película: the thing comes after the verb and a pronoun for the person goes before it
            let io = ["me", "te", "le", "nos", "les"][seed % 5]
            verb = io + " " + verb
            complement = subject.text
            shown = ""
        default:
            complement = (people || animal) ? usage.complement(for: infinitive, seed: seed) : VerbUsage.thingComplement(pool: profile.pool, seed: seed)
        }
        let cue = usage.cue(drill.tense)
        let weather = usage.valency == "W"
        let sameSubject = subject.person == 0 || subject.text.hasSuffix(" yo")
        func trigger(past: Bool) -> String {
            if sameSubject { return past ? "Era importante que" : "Es importante que" }
            return past ? "Quería que" : "Espero que"
        }
        let withChange = weather ? "Si hubiera nubes," : "Con ese cambio,"
        let ifClause = weather ? "" : "si hubiera tiempo"
        let ifPerfect = weather ? "" : "si hubiera habido tiempo"
        var parts: [String]
        switch (drill.kind, drill.tense) {
        case (.simple, .present): parts = [shown, verb, complement, cue.trail]
        case (.simple, .preterite): parts = [cue.lead, shown, verb, complement]
        case (.simple, .imperfect): parts = [cue.lead, shown, verb, complement, cue.trail]
        case (.simple, .future): parts = [cue.lead, shown, verb, complement]
        case (.simple, .conditional): parts = people ? [shown, verb, complement, ifClause] : [withChange, shown, verb, complement]
        case (.simple, .subjunctivePresent): parts = [trigger(past: false), shown, verb, complement]
        case (.simple, .subjunctiveImperfect): parts = [trigger(past: true), shown, verb, complement]
        case (.simple, .imperative): parts = ["¡" + verb, complement + "!"]
        case (.progressive, .present): parts = ["Ahora", shown, verb, complement]
        case (.progressive, .preterite): parts = ["Toda la tarde", shown, verb, complement]
        case (.progressive, .imperfect): parts = ["Cuando llamaste,", shown, verb, complement]
        case (.progressive, .future): parts = ["Mañana a esta hora", shown, verb, complement]
        case (.progressive, .conditional): parts = people ? [shown, verb, complement, "ahora", ifClause] : [withChange, shown, verb, complement]
        case (.progressive, .subjunctivePresent), (.perfect, .subjunctivePresent): parts = [trigger(past: false), shown, verb, complement]
        case (.progressive, .subjunctiveImperfect): parts = ["Si", shown, verb, complement, "ahora, se notaría"]
        case (.perfect, .present): parts = ["Hoy", shown, verb, complement]
        case (.perfect, .imperfect): parts = ["Cuando llegué, ya", shown, verb, complement]
        case (.perfect, .future): parts = ["Para el viernes", shown, verb, complement]
        case (.perfect, .conditional): parts = people ? [shown, verb, complement, ifPerfect] : [withChange, shown, verb, complement]
        case (.perfect, .subjunctiveImperfect): parts = ["Ojalá", shown, verb, complement]
        case (.acabarDe, .present): parts = [shown, verb, complement]
        case (.acabarDe, _): parts = ["Cuando llegué,", shown, verb, complement]
        case (.irA, .present): parts = ["Mañana", shown, verb, complement]
        case (.irA, _): parts = ["Ayer", shown, verb, complement + ", pero no fue posible"]
        case (.estarPor, .present): parts = ["Ahora", shown, verb, complement]
        case (.estarPor, .imperfect): parts = ["Cuando llamaste,", shown, verb, complement]
        case (.estarPor, _): parts = ["Una vez", shown, verb, complement + ", y al final no pasó nada"]
        default: return nil
        }
        var text = parts.filter { !$0.isEmpty && $0 != "," }.joined(separator: " ")
        text = text.replacingOccurrences(of: "  ", with: " ").replacingOccurrences(of: " ,", with: ",").replacingOccurrences(of: ", ,", with: ",")
        if text.hasSuffix(",") { text.removeLast() }
        if drill.tense == .imperative, drill.kind == .simple { return capitalized(text) }
        return capitalized(text) + "."
    }

    private static func capitalized(_ text: String) -> String {
        guard let index = text.firstIndex(where: { $0.isLetter }) else { return text }
        return text[..<index] + text[index].uppercased() + text[text.index(after: index)...]
    }
}
