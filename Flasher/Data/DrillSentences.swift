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
            if usage.valency == "C", let adjective = DrillAdjectives.complement(verb: base, subject: subject, seed: seed, perfect: drill.kind == .perfect), !(people && base == "quedar" && seed % 2 == 0) {
                // ser, estar, resultar, quedar: an adjective tagged for this kind of subject ("quedar" also takes a place, for people)
                complement = adjective
            } else {
                complement = (people || animal) ? usage.complement(for: infinitive, seed: seed, past: toldInPast(drill)) : VerbUsage.thingComplement(pool: profile.pool, seed: seed)
            }
        }
        let cue = usage.cue(drill.tense)
        let weather = usage.valency == "W"
        let sameSubject = subject.person == 0 || subject.text.hasSuffix(" yo")
        // What comes before the subjunctive: wishes, doubt, feelings, necessity, purpose, time words. Only triggers that fit the tense and the subject are offered;
        // with the same subject Spanish uses an infinitive after wishes, purpose and "antes de" ("quiero comer"), so those are left out.
        let progressiveOrPerfect = drill.kind == .progressive || drill.kind == .perfect
        func trigger(past: Bool) -> String {
            let options: [String]
            switch (past, sameSubject, progressiveOrPerfect) {
            case (true, true, _): options = ["Era importante que", "Era posible que", "Dudaba que", "Ojalá", "Era raro que", "Hablaba como si"]
            case (true, false, _): options = ["Quería que", "Esperaba que", "Pedí que", "Dudaba que", "No creía que", "Me alegró que", "Era posible que", "Era necesario que",
                                              "Prefería que", "Temía que", "Te llamé antes de que", "Me fui sin que", "Me sorprendió que", "Me molestó que", "Fue una lástima que",
                                              "Me gustaría que", "Sería mejor que", "Lo dije para que", "Era raro que"]
            case (false, true, true): options = ["Es posible que", "Dudo que", "No creo que", "Quizás", "Puede que", "Es raro que"]
            case (false, true, false): options = ["Es importante que", "Es posible que", "Dudo que", "Ojalá", "Quizás", "Te aviso en cuanto", "Puede que", "Es raro que", "Hace falta que"]
            case (false, false, true): options = drill.kind == .perfect
                ? ["Espero que", "Dudo que", "No creo que", "Me alegra que", "Es posible que", "Es una lástima que", "Temo que", "Ojalá", "Me quedo hasta que",
                   "Puede que", "Me sorprende que", "Es raro que", "No es que"]
                : ["Espero que", "Dudo que", "No creo que", "Me alegra que", "Es posible que", "Quizás", "Ojalá", "Temo que", "Puede que", "Me sorprende que"]
            case (false, false, false): options = ["Espero que", "Quiero que", "Dudo que", "No creo que", "Me alegra que", "Es posible que", "Es necesario que", "Ojalá", "Quizás",
                                                   "Te lo digo para que", "Llámame antes de que", "Te aviso en cuanto", "Me quedo hasta que", "Es una lástima que", "Prefiero que", "Temo que",
                                                   "Puede que", "Llevo el teléfono en caso de que", "Hace falta que", "Más vale que", "Me sorprende que", "Me molesta que", "Es raro que",
                                                   "Te ayudo con tal de que", "No salgo a menos que", "Espera a que", "No es que"]
            }
            // "Llámame", "te lo digo", "espera": a tú command or "te" doesn't go with usted or ustedes in the same sentence
            let formal = ["usted", "ustedes"].contains(subject.text)
            var usable = formal ? options.filter { !$0.hasPrefix("Llámame") && !$0.hasPrefix("Te ") && !$0.hasPrefix("Espera") } : options
            // "Espera a que (tú) salgas": telling you to wait for yourself
            if subject.person == 1 { usable.removeAll { $0.hasPrefix("Espera") } }
            return usable[(seed / 17) % usable.count]
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
        // "No es que" rejects a reason, which reads naturally with "no": "No es que no quiera, es que…"
        case (.simple, .subjunctivePresent): let t = trigger(past: false); parts = [t, shown, t == "No es que" ? "no" : "", verb, complement]
        case (.simple, .subjunctiveImperfect): parts = [trigger(past: true), shown, verb, complement]
        case (.simple, .imperative): parts = ["¡" + verb, complement + "!"]
        case (.progressive, .present): parts = ["Ahora", shown, verb, complement]
        case (.progressive, .preterite): parts = ["Toda la tarde", shown, verb, complement]
        case (.progressive, .imperfect): parts = ["Cuando llamaste,", shown, verb, complement]
        case (.progressive, .future): parts = ["Mañana a esta hora", shown, verb, complement]
        case (.progressive, .conditional): parts = people ? [shown, verb, complement, "ahora", ifClause] : [withChange, shown, verb, complement]
        case (.progressive, .subjunctivePresent): parts = [trigger(past: false), shown, verb, complement]
        case (.perfect, .subjunctivePresent):
            let t = trigger(past: false)
            parts = still && !sameSubject ? ["No creo que", shown, verb, complement, "todavía"] : t == "No es que" ? [t, shown, "no", verb, complement]
                : (seed / 13) % 2 == 0 ? [t, shown, "ya", verb, complement] : [t, shown, verb, complement]
        case (.progressive, .subjunctiveImperfect): parts = ["Si", shown, verb, complement, "ahora, se notaría"]
        // The perfect also says it is still open up to the moment: "Él todavía no ha comprado el paquete"
        case (.perfect, .present): parts = still ? [shown, "todavía no", verb, complement] : ["Hoy", shown, verb, complement]
        case (.perfect, .imperfect): parts = still ? ["Cuando llegué,", shown, "todavía no", verb, complement] : ["Cuando llegué, ya", shown, verb, complement]
        case (.perfect, .future): parts = ["Para el viernes", shown, verb, complement]
        case (.perfect, .conditional): parts = people ? [shown, verb, complement, ifPerfect] : [withChange, shown, verb, complement]
        case (.perfect, .subjunctiveImperfect): parts = [["Ojalá", "Me habría gustado que", "Dudaba que", "Era una lástima que", "Me sorprendió que", "Era como si"][(seed / 17) % 6], shown, verb, complement]
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
        var around = context(drill, seed: seed, category: DrillContexts.category(infinitive, usage: usage, subjectIsPerson: people || animal), subject: subject.text, avoiding: target, related: related, infinitive: infinitive)
        // A feeling is about something taken as real, so "Pronto lo sabremos" after "Me alegra que…" would contradict it: react instead
        if let reaction = reaction(to: target, seed: seed) { around = ("", reaction) }
        let full = [around.before, target, around.after].filter { !$0.isEmpty }.joined(separator: " ")
        return (around.before, target, around.after, verb, full)
    }

    /// Second sentences for feelings and regrets, by what the first sentence says: glad, sorry, annoyed, surprised, a regret about the past.
    private static let reactions: [(triggers: [String], lines: [String])] = [
        (["me alegra que"], ["Es una buena noticia.", "Eso nos pone contentos.", "Así todo es más fácil.", "Todos estamos felices."]),
        (["me alegró que"], ["Fue una buena noticia.", "Eso nos puso contentos.", "Todos lo celebramos.", "Fue un buen día."]),
        (["es una lástima que"], ["Así son las cosas.", "No hay nada que hacer.", "Todos estamos un poco tristes.", "Las cosas no salen como queremos."]),
        (["fue una lástima que", "era una lástima que", "me habría gustado que"], ["Pero ya no hay nada que hacer.", "Ahora ya es tarde.", "Así fueron las cosas.", "Nadie pudo hacer nada."]),
        (["me molesta que"], ["No es la primera vez.", "Siempre pasa lo mismo.", "Así no se puede.", "Ya hablaremos de eso."]),
        (["me molestó que"], ["No fue la primera vez.", "Siempre pasaba lo mismo.", "Después hablamos de eso.", "Nadie dijo nada."]),
        (["me sorprende que"], ["Nadie lo esperaba.", "No es lo normal.", "Antes no era así.", "Es algo nuevo."]),
        (["me sorprendió que"], ["Nadie lo esperaba.", "No era lo normal.", "Fue algo inesperado.", "Antes no era así."]),
        (["es raro que"], ["No es lo normal.", "Antes no era así.", "Nadie lo esperaba.", "Normalmente no pasa."]),
        (["era raro que"], ["No era lo normal.", "Antes no pasaba.", "Nadie lo esperaba.", "Normalmente no pasaba."]),
        (["no es que"], ["Es otra cosa.", "Es que no hay tiempo.", "El problema es otro.", "Es que hay otro problema."]),
        (["me gustaría que", "sería mejor que"], ["Sería lo mejor para todos.", "Eso nos ayudaría mucho.", "Así todo sería más fácil.", "Lo pensaremos."]),
    ]

    private static func reaction(to target: String, seed: Int) -> String? {
        let lower = target.lowercased()
        guard let match = reactions.first(where: { $0.triggers.contains { lower.hasPrefix($0) } }) else { return nil }
        return match.lines[(seed / 5) % match.lines.count]
    }

    private static func capitalized(_ text: String) -> String {
        guard let index = text.firstIndex(where: { $0.isLetter }) else { return text }
        return text[..<index] + text[index].uppercased() + text[text.index(after: index)...]
    }
}
