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

    /// Verbs that have a command form on paper but are never used as one.
    private static let noCommand: Set<String> = ["poder", "deber", "soler", "merecer", "caber", "convenir", "valer", "costar", "ocurrir", "suceder", "pertenecer", "parecer"]

    /// Subjects that fit this verb in this drill. Empty when the drill skips the verb or tense.
    static func subjects(for infinitive: String, _ drill: DrillTense) -> [DrillSubject] {
        guard let usage = VerbUsage.of(infinitive), !VerbProfiles.isRare(infinitive) else { return [] }
        if drill.kind == .progressive, "ks".contains(usage.aspect), usage.valency != "D", usage.valency != "W" { return [] }
        if drill.kind == .acabarDe || drill.kind == .estarPor, usage.aspect == "s" { return [] }
        if drill.kind == .estarPor, usage.valency == "D" { return [] }
        if drill.tense == .imperative, drill.kind == .simple, "DWCS".contains(usage.valency) { return [] }
        // Nobody says "¡Pueda ayudar!" or "¡Deba salir!"
        if drill.tense == .imperative, noCommand.contains(infinitive.hasSuffix("se") ? String(infinitive.dropLast(2)) : infinitive) { return [] }
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
        build(infinitive, drill, subject: subject)?.text
    }

    /// A drill card: the sentence with the verb phrase left blank, and the phrase that fills it.
    struct Card: Hashable {
        let infinitive: String
        let drill: DrillTense
        let subject: DrillSubject
        /// "Ayer ella ______ la cena."
        let prompt: String
        /// The full sentence, shown after answering.
        let sentence: String
        /// What goes in the blank ("comió", "estaba comiendo", "me gusta").
        let answer: String

        /// The same sentence answered in another tense that fits it ("Mañana ellos van a comer" for "comerán").
        func choosing(_ chosen: DrillTense) -> Card {
            guard chosen != drill, let phrase = DrillSentences.verbPhrase(infinitive, chosen, person: subject.person) else { return self }
            // The blank stays where it was; a phrase at the start of a sentence gets its capital
            var text = prompt
            if let blank = text.range(of: "______") {
                let before = text[..<blank.lowerBound].trimmingCharacters(in: CharacterSet(charactersIn: " ¡¿"))
                let atStart = before.isEmpty || before.hasSuffix(".") || before.hasSuffix("!") || before.hasSuffix("?")
                text.replaceSubrange(blank, with: atStart ? phrase.prefix(1).uppercased() + phrase.dropFirst() : phrase)
            }
            return Card(infinitive: infinitive, drill: chosen, subject: subject, prompt: prompt, sentence: text, answer: phrase)
        }
    }

    /// `variant` picks a different object, time word and context sentence for the same verb, tense and subject.
    /// Variant 0 is the fixed one the tests rely on.
    static func card(_ infinitive: String, _ drill: DrillTense, subject: DrillSubject, variant: Int = 0) -> Card? {
        // Only the target sentence is searched, so a verb that also appears in the context sentence ("fue") is not blanked there
        guard let built = build(infinitive, drill, subject: subject, variant: variant),
              let range = built.target.range(of: built.verb, options: [.caseInsensitive, .diacriticInsensitive]) else { return nil }
        var blanked = built.target
        blanked.replaceSubrange(range, with: "______")
        return Card(infinitive: infinitive, drill: drill, subject: subject,
                    prompt: [built.before, blanked, built.after].filter { !$0.isEmpty }.joined(separator: " "),
                    sentence: built.text, answer: built.verb)
    }

    /// A second sentence in a different tense that sets the scene or follows on, so the card reads like a little
    /// piece of talk and the learner has to notice which tense the blank needs. It comes from a pool of 50 chosen for
    /// the tense, and the ones that fit the kind of verb most closely are favoured (`DrillContexts.pick`).
    private static func context(_ drill: DrillTense, seed: Int, category: DrillContexts.Category, subject: String, avoiding target: String, related: DrillRelatedContext.Source?, infinitive: String) -> (before: String, after: String) {
        // A sentence about the object of the first sentence when it has one, otherwise one of the general pools
        func line(_ pool: String) -> String {
            if let related, let text = DrillRelatedContext.sentence(pool: pool, source: related, seed: seed, infinitive: infinitive, target: target) { return text }
            return DrillContexts.pick(pool, for: category, seed: seed, subject: subject, avoiding: target)
        }
        func before(_ pool: String) -> (String, String) { (line(pool), "") }
        func after(_ pool: String) -> (String, String) { ("", line(pool)) }
        switch (drill.kind, drill.tense) {
        case (.simple, .present): return after("timeContrasts")
        case (.simple, .preterite): return before("imperfectScenes")
        case (.simple, .imperfect): return after("nowContrasts")
        case (.simple, .future), (.simple, .conditional), (.simple, .imperative): return before("presentStates")
        case (.simple, .subjunctivePresent): return after("futureCloses")
        case (.simple, .subjunctiveImperfect): return after("pastCloses")
        case (.progressive, .present): return before("imperfectScenes")
        case (.progressive, .preterite), (.progressive, .imperfect): return after("pastCloses")
        case (.progressive, .future), (.progressive, .conditional), (.progressive, .subjunctiveImperfect): return before("presentStates")
        case (.progressive, _): return after("futureCloses")
        case (.perfect, .present): return after("timeContrasts")
        case (.perfect, .imperfect): return after("imperfectCloses")
        case (.perfect, .future): return before("presentStates")
        case (.perfect, .subjunctivePresent): return after("futureCloses")
        case (.perfect, _): return after("nowContrasts")
        case (.acabarDe, .present): return after("pastCloses")
        case (.acabarDe, _): return after("imperfectCloses")
        case (.irA, .present): return after("timeContrasts")
        case (.irA, _): return before("imperfectScenes")
        case (.estarPor, .present): return after("futureCloses")
        case (.estarPor, .imperfect): return after("pastCloses")
        case (.estarPor, _): return before("imperfectScenes")
        }
    }

    /// What the second sentence can be about: the object of the verb, where it goes, who it is done with, the thing that
    /// is its subject, what is said, or what is wanted. nil when the sentence has none of these.
    private static func relatedSource(_ usage: VerbUsage, complement: String, subject: DrillSubject, people: Bool) -> DrillRelatedContext.Source? {
        func thing(_ text: String, _ kind: Character?) -> DrillRelatedContext.Source? {
            guard let kind, let found = DrillRelatedContext.thing(from: text, kind: kind) else { return nil }
            return .thing(found)
        }
        // A thing that is the subject ("La película empieza", "Me gusta el libro"): the second sentence is about it
        func aboutTheSubject() -> DrillRelatedContext.Source? {
            let noun = subject.text.split(separator: " ").last.map(String.init) ?? subject.text
            return thing(subject.text, DrillRelatedContext.kind(forNoun: noun))
        }
        if usage.valency == "D" { return aboutTheSubject() }
        if !people { return aboutTheSubject() }
        switch usage.valency {
        case "T": return thing(complement, usage.object)
        case "M": return thing(complement, "l")
        case "P":
            let key = (usage.preposition ?? "") + (usage.object == "-" ? "-" : String(usage.object))
            return thing(complement, DrillRelatedContext.kind(forPreposition: key))
        case "S": return complement.isEmpty ? nil : .clause(complement)
        case "X": return complement.split(separator: " ").last.map { .action(String($0)) }
        default: return nil
        }
    }

    /// Whether the sentence is told in the past, so clauses after the verb are in the past too.
    private static func toldInPast(_ drill: DrillTense) -> Bool {
        [.preterite, .imperfect, .subjunctiveImperfect].contains(drill.tense)
    }

    private static func build(_ infinitive: String, _ drill: DrillTense, subject: DrillSubject, variant: Int = 0) -> (before: String, target: String, after: String, verb: String, text: String)? {
        guard let usage = VerbUsage.of(infinitive), var verb = verbPhrase(infinitive, drill, person: subject.person), !verb.isEmpty else { return nil }
        let seed = (stableSeed(infinitive, drill, subject.person) &+ variant &* 7919) & Int.max
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
            let base = infinitive.hasSuffix("se") ? String(infinitive.dropLast(2)) : infinitive
            if usage.valency == "C", let adjective = DrillAdjectives.complement(verb: base, subject: subject, seed: seed), !(people && base == "quedar" && seed % 2 == 0) {
                // ser, estar, resultar, quedar: an adjective tagged for this kind of subject ("quedar" also takes a place, for people)
                complement = adjective
            } else {
                complement = (people || animal) ? usage.complement(for: infinitive, seed: seed, past: toldInPast(drill)) : VerbUsage.thingComplement(pool: profile.pool, seed: seed)
            }
        }
        let cue = usage.cue(drill.tense)
        let weather = usage.valency == "W"
        let sameSubject = subject.person == 0 || subject.text.hasSuffix(" yo")
        func trigger(past: Bool) -> String {
            if sameSubject { return past ? "Era importante que" : "Es importante que" }
            return past ? "Quería que" : "Espero que"
        }
        // About a third of the perfect cards are about something that has not happened yet
        let still = (seed / 7) % 3 == 0
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
        case (.progressive, .subjunctivePresent): parts = [trigger(past: false), shown, verb, complement]
        case (.perfect, .subjunctivePresent): parts = still && !sameSubject ? ["No creo que", shown, verb, complement, "todavía"] : [trigger(past: false), shown, verb, complement]
        case (.progressive, .subjunctiveImperfect): parts = ["Si", shown, verb, complement, "ahora, se notaría"]
        // The perfect also says it is still open up to the moment: "Él todavía no ha comprado el paquete"
        case (.perfect, .present): parts = still ? [shown, "todavía no", verb, complement] : ["Hoy", shown, verb, complement]
        case (.perfect, .imperfect): parts = still ? ["Cuando llegué,", shown, "todavía no", verb, complement] : ["Cuando llegué, ya", shown, verb, complement]
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
        let target = drill.tense == .imperative && drill.kind == .simple ? capitalized(text) : capitalized(text) + "."
        let related = relatedSource(usage, complement: complement, subject: subject, people: people || animal)
        let around = context(drill, seed: seed, category: DrillContexts.category(infinitive, usage: usage, subjectIsPerson: people || animal), subject: subject.text, avoiding: target, related: related, infinitive: infinitive)
        let full = [around.before, target, around.after].filter { !$0.isEmpty }.joined(separator: " ")
        return (around.before, target, around.after, verb, full)
    }

    private static func capitalized(_ text: String) -> String {
        guard let index = text.firstIndex(where: { $0.isLetter }) else { return text }
        return text[..<index] + text[index].uppercased() + text[text.index(after: index)...]
    }
}
