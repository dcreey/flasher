import Foundation

/// Why a drill sentence uses the tense it does, and what went wrong when the learner typed something else.
enum DrillExplainer {
    struct Entry {
        /// The tense in a phrase: "a finished action at a specific moment in the past".
        let short: String
        /// The rule, one sentence.
        let rule: String
        /// Time-word clues in the sentence and what each one tells you, matched in order against the lowercased sentence.
        let markers: [(String, String)]
        /// How the other sentence on the card relates to this one.
        let context: String
    }

    static let entries: [String: Entry] = [
        "simple present": Entry(
            short: "something true now or done regularly",
            rule: "The present is for what is true now, happens now, or happens as a habit.",
            markers: [("todos los días", "“Todos los días” marks a habit."), ("a veces", "“A veces” (sometimes) describes something that happens regularly.")],
            context: "The other sentence looks at a different time, so this one has to say what is true now."),
        "simple preterite": Entry(
            short: "a finished action at a specific moment in the past",
            rule: "The preterite tells an event that happened and finished at one point in the past.",
            markers: [("de repente", "“De repente” (suddenly) is a one-off event, and one-off finished events take the preterite."), ("ayer", "“Ayer” points to one finished moment yesterday.")],
            context: "The scene-setting sentence is in the imperfect (how things were). The preterite is the event that happens inside that scene."),
        "simple imperfect": Entry(
            short: "a past situation or habit with no clear end",
            rule: "The imperfect describes how things were, or what used to happen again and again.",
            markers: [("cada semana", "“Cada semana” means again and again, and repeated past actions take the imperfect."), ("en esa época", "“En esa época” describes how things were over a period."), ("antes", "“Antes” introduces what used to be true."), ("a veces", "“A veces” in the past means it used to happen now and then.")],
            context: "The other sentence says how things are now, which shows the first was how they used to be."),
        "simple future": Entry(
            short: "what will happen",
            rule: "The future says what will happen after now. In everyday Latin American speech ir a + infinitive is more common for plans; the future is used more in writing and for guesses.",
            markers: [("mañana", "“Mañana” is a later time."), ("algún día", "“Algún día” means some day in the future.")],
            context: "The other sentence says how things are now. The future says what comes next."),
        "simple conditional": Entry(
            short: "what would happen under a condition",
            rule: "The conditional says what would happen if something were true, or what is only imagined.",
            markers: [("si hubiera tiempo", "“Si hubiera tiempo” is a condition that isn’t true, so the result is “would”."), ("con ese cambio", "“Con ese cambio” sets up an imagined situation, and its result is conditional.")],
            context: "The other sentence states what is true now. The conditional is what would be different."),
        "simple subjunctivePresent": Entry(
            short: "something wished for or felt about, not yet a fact",
            rule: "After a wish, a feeling or “it’s important that”, the verb goes in the present subjunctive.",
            markers: [("espero que", "“Espero que” (I hope that) is a wish, and the verb after it is subjunctive."), ("es importante que", "“Es importante que” expresses importance, which calls for the subjunctive.")],
            context: "The other sentence reacts to the wish or says what comes of it."),
        "simple subjunctiveImperfect": Entry(
            short: "a wish or request seen from the past",
            rule: "When the main verb is in the past (“quería que”), the subjunctive after it is the imperfect subjunctive.",
            markers: [("quería que", "“Quería que” (I wanted that) is past, so the subjunctive after it is the imperfect one."), ("era importante que", "“Era importante que” is past, so the subjunctive that follows is imperfect.")],
            context: "The other sentence tells how it turned out."),
        "simple imperative": Entry(
            short: "a direct command",
            rule: "The imperative gives a direct command to the person you are talking to.",
            markers: [("¡", "The exclamation marks and the missing subject show a direct command.")],
            context: "The other sentence gives the situation, and the command is what to do about it."),
        "progressive present": Entry(
            short: "an action in progress right now",
            rule: "Estar + gerund (-ando/-iendo) shows an action that is in progress at this moment.",
            markers: [("ahora", "“Ahora” (now) says it is happening at this very moment.")],
            context: "The other sentence says how things were before, and the progressive shows what is going on now."),
        "progressive preterite": Entry(
            short: "an action that went on for a stretch of time that is now over",
            rule: "Estuvo + gerund stresses how long an action went on, within a time that has ended.",
            markers: [("toda la tarde", "“Toda la tarde” is a finished stretch of time: the action went on all afternoon and is over.")],
            context: "The other sentence says what came after."),
        "progressive imperfect": Entry(
            short: "an action that was in progress at a past moment",
            rule: "Estaba + gerund shows what was in the middle of happening when something else happened.",
            markers: [("cuando llamaste", "“Cuando llamaste” is the moment, and the action was already in progress at that point.")],
            context: "The other sentence is what happened next or what followed."),
        "progressive future": Entry(
            short: "an action that will be in progress at a future moment",
            rule: "Estará + gerund pictures you in the middle of an action at a future moment.",
            markers: [("mañana a esta hora", "“Mañana a esta hora” picks one future moment, and you will be in the middle of the action then.")],
            context: "The other sentence describes the present."),
        "progressive conditional": Entry(
            short: "what would be going on under a condition",
            rule: "Estaría + gerund says what would be in progress now if a condition held.",
            markers: [("si hubiera tiempo", "“Si hubiera tiempo” is a condition that isn’t true, so the result is “would be doing”.")],
            context: "The other sentence describes how things really are."),
        "progressive subjunctivePresent": Entry(
            short: "a wish about something in progress",
            rule: "After a wish, the “in progress” verb is subjunctive too: esté + gerund.",
            markers: [("espero que", "“Espero que” is a wish, so estar itself goes in the subjunctive.")],
            context: "The other sentence reacts to the wish."),
        "progressive subjunctiveImperfect": Entry(
            short: "an unreal situation in progress now",
            rule: "After “si” for something unreal, estar goes in the imperfect subjunctive: estuviera + gerund.",
            markers: [(" si ", "“Si” followed by something unreal needs the imperfect subjunctive.")],
            context: "The other sentence describes how things really are."),
        "perfect present": Entry(
            short: "something done in a period that is not over, or that still matters",
            rule: "He/has/ha + participle looks back from now at something already done.",
            markers: [(" hoy ", "“Hoy” is a period that has not ended yet, so the present perfect fits. In Mexico the preterite is actually the more common choice here."),
                      ("todavía no", "“Todavía no” says it has not happened up to now and is still open, so the present perfect fits. In Mexico the preterite is also common: “todavía no lo compró”.")],
            context: "The other sentence is about a finished time (yesterday, last year), which would take the preterite."),
        "perfect imperfect": Entry(
            short: "something already done before another past moment",
            rule: "Había + participle (pluscuamperfecto) is the past of the past: done before another past moment.",
            markers: [(" ya ", "“Cuando llegué” is the past moment, and “ya” (already) says this was done before it."),
                      ("todavía no", "“Todavía no” says that up to that past moment it had not happened yet: había + participle.")],
            context: "The other sentence describes the scene at that moment, in the imperfect."),
        "perfect future": Entry(
            short: "something that will be finished before a future moment",
            rule: "Habrá + participle says something will already be done by a future moment.",
            markers: [("para el viernes", "“Para el viernes” is the deadline, and the action will be done before it.")],
            context: "The other sentence says what is true now."),
        "perfect conditional": Entry(
            short: "what would have happened, but didn’t",
            rule: "Habría + participle says what would have happened under a condition that was not met.",
            markers: [("si hubiera habido tiempo", "“Si hubiera habido tiempo” is an unreal past condition, so the result is “would have”.")],
            context: "The other sentence says why it is not possible now."),
        "perfect subjunctivePresent": Entry(
            short: "a hope about something that should already be done",
            rule: "Haya + participle: a wish or feeling about something that should already have happened.",
            markers: [("espero que", "“Espero que” is a wish, and the thing hoped for should already be done: haya + participle."),
                      ("no creo que", "“No creo que” (I don’t think that) expresses doubt, which calls for the subjunctive, and “todavía” means up to now: haya + participle.")],
            context: "The other sentence reacts to it or says what follows."),
        "perfect subjunctiveImperfect": Entry(
            short: "a wish about the past (“if only it had…”)",
            rule: "Hubiera + participle after “ojalá” is a wish about the past that did not come true.",
            markers: [("ojalá", "“Ojalá” with a past wish means “if only”, which takes hubiera + participle.")],
            context: "The other sentence says where things stand now."),
        "acabarDe present": Entry(
            short: "something that has just happened",
            rule: "Acabar de + infinitive means “has just”: a moment before now.",
            markers: [("acab", "Acabar de says it happened a moment ago, and the present form puts that moment at now.")],
            context: "The other sentence tells what happened, as a finished past event."),
        "acabarDe imperfect": Entry(
            short: "something that had just happened at a past moment",
            rule: "Acababa de + infinitive means “had just”: a moment before another past moment.",
            markers: [("cuando llegué", "“Cuando llegué” is the past moment, and the action had just happened before it.")],
            context: "The other sentence describes the scene at that moment."),
        "irA present": Entry(
            short: "a plan, or what is about to happen",
            rule: "Ir a + infinitive says what is going to happen after now. It is the most common way to say a plan in everyday Latin American speech.",
            markers: [("mañana", "“Mañana” plus ir a is a plan for tomorrow.")],
            context: "The other sentence is about another time, to contrast with the plan."),
        "irA imperfect": Entry(
            short: "a plan that was made in the past",
            rule: "Iba a + infinitive means “was going to”: a plan from a past moment.",
            markers: [("pero no fue posible", "“Pero no fue posible” shows the plan was in the past and did not happen: iba a + infinitive.")],
            context: "The scene-setting sentence is in the imperfect, as is the plan."),
        "estarPor present": Entry(
            short: "something about to happen",
            rule: "Estar por + infinitive means “about to”: it is right at the edge of happening. In several Latin American countries it is used this way; elsewhere it can mean having the intention or the temptation to do it.",
            markers: [("ahora", "“Ahora” (now) with estar por means it is about to happen at this moment.")],
            context: "The other sentence says what comes next."),
        "estarPor imperfect": Entry(
            short: "something that was about to happen at a past moment",
            rule: "Estaba por + infinitive means “was about to”: at that past moment it was about to happen.",
            markers: [("cuando llamaste", "“Cuando llamaste” is the moment, and the action was about to happen then.")],
            context: "The other sentence says what happened or followed."),
        "estarPor preterite": Entry(
            short: "something that almost happened, but didn’t",
            rule: "Estuvo por + infinitive means it came close to happening, once, and did not.",
            markers: [("no pasó nada", "“Y al final no pasó nada” shows it almost happened but didn’t: estuvo por.")],
            context: "The scene-setting sentence is in the imperfect (how things were)."),
    ]

    /// What each pair of easily confused tenses gets wrong, keyed "target|typed".
    static let contrasts: [String: String] = [
        "simple preterite|simple imperfect": "The imperfect describes a background or a habit. This sentence has one finished event, so it takes the preterite.",
        "simple imperfect|simple preterite": "The preterite is for one finished event. This sentence describes a habit or how things were, so it takes the imperfect.",
        "simple preterite|perfect present": "The present perfect looks back from now, and fits best for a time that is not over (hoy, esta semana). In Mexico the preterite is the usual choice for a finished moment like “ayer” (about 80 to 90 percent of past-tense uses in studies), but the present perfect is also used.",
        "perfect present|simple preterite": "The preterite also works with “hoy”, and in Mexico it is the more common choice. This drill asks for the present perfect, which looks back from now.",
        "simple present|simple preterite": "The preterite is a finished past event. This sentence is about now or a habit.",
        "simple preterite|simple present": "The present is for now. This sentence tells something that already happened, so it needs the preterite.",
        "simple imperfect|simple present": "The present is for now. This sentence says what used to happen, so it needs the imperfect.",
        "simple subjunctivePresent|simple present": "The present is the indicative, for facts. After a wish or a feeling, the verb needs the subjunctive.",
        "simple subjunctiveImperfect|simple imperfect": "The imperfect is the indicative, for facts. After a past trigger like “quería que”, the verb needs the subjunctive.",
        "simple subjunctiveImperfect|simple subjunctivePresent": "“Quería que” and “era importante que” are past, so the subjunctive must be the imperfect one. The present subjunctive goes with “espero que”.",
        "simple subjunctivePresent|simple subjunctiveImperfect": "“Espero que” and “es importante que” are in the present, so the subjunctive is the present one. The imperfect subjunctive goes with a past trigger.",
        "simple conditional|simple future": "The future says what will happen. An unreal condition (“si hubiera tiempo”) calls for “would”, the conditional.",
        "simple future|simple conditional": "The conditional says what would happen. “Mañana” is a plain later time, so the future is the one.",
        "simple conditional|simple imperfect": "In everyday speech the imperfect often stands in for the conditional, but the conditional is the standard form for an imagined result.",
        "perfect imperfect|simple imperfect": "The imperfect describes the scene at the moment. “Ya” says this was done before that moment, which takes había + participle.",
        "perfect imperfect|simple preterite": "The preterite is the event itself. “Ya” says this was finished before another past moment, so use había + participle.",
        "perfect imperfect|perfect present": "He/has/ha + participle looks back from now. This sentence looks back from a past moment (“cuando llegué”), so it needs había.",
        "perfect future|simple future": "The simple future says what will happen. “Para el viernes” says it will already be done by then: habrá + participle.",
        "perfect conditional|simple conditional": "The simple conditional is about now or later. This condition was about the past, so it is “would have”: habría + participle.",
        "perfect subjunctiveImperfect|simple subjunctiveImperfect": "“Ojalá” about the past means “if only it had…”, which takes hubiera + participle.",
        "perfect subjunctivePresent|simple subjunctivePresent": "The simple subjunctive is for what you hope will happen. This is a hope about something that should already be done: haya + participle.",
        "irA imperfect|simple imperfect": "The imperfect says what used to happen. “Pero no fue posible” shows a plan that did not happen: iba a + infinitive.",
        "irA present|simple future": "The simple future is a general “will”. A plan close to now takes ir a + infinitive.",
        "simple future|irA present": "Ir a is a plan close to now. “Algún día” is a distant future, so the simple future is the one.",
        "progressive present|simple present": "The simple present is for habits. “Ahora” says it is happening at this moment, which takes estar + gerund.",
        "progressive imperfect|simple imperfect": "The simple imperfect describes a habit or a state. “Cuando llamaste” shows an action in progress at that moment: estaba + gerund.",
        "progressive imperfect|progressive preterite": "Estuvo + gerund is for a stretch of time that is over. At one past moment, the action was in progress: estaba + gerund.",
        "progressive preterite|progressive imperfect": "Estaba + gerund is an action in progress at one moment. “Toda la tarde” is a finished stretch of time: estuvo + gerund.",
        "acabarDe present|simple preterite": "The preterite tells a finished event. Acabar de says it has just happened, a moment before now.",
        "acabarDe imperfect|acabarDe present": "“Cuando llegué” is a past moment, so acabar goes in the imperfect: acababa de.",
        "estarPor imperfect|estarPor present": "“Cuando llamaste” is a past moment, so estar goes in the imperfect: estaba por.",
        "estarPor preterite|estarPor imperfect": "Estaba por is “was about to”. If it almost happened once and did not, use estuvo por.",
        "progressive preterite|simple preterite": "Both say it is over. Estuvo + gerund stresses that the activity went on during that time.",
        "progressive future|simple future": "Both place the action at that future moment. Estaré + gerund stresses that you will be in the middle of it.",
        "progressive conditional|simple conditional": "Both say what would happen. Estaría + gerund stresses that it would be in progress.",
        "perfect conditional|perfect subjunctiveImperfect": "In the result part of an unreal past condition both “habría comprado” and “hubiera comprado” are accepted. “Habría” is the standard form.",
        "perfect subjunctiveImperfect|perfect conditional": "After “ojalá” the wish needs the subjunctive (hubiera + participle). The conditional is for results, not wishes.",
        "simple imperative|irA present": "“Vamos a + infinitive” is the everyday way to say “let’s”, but it can also be a plain “we are going to”. The command form (“comamos”) is only an exhortation.",
        "estarPor imperfect|irA imperfect": "Iba a + infinitive says what was planned or about to happen. Estaba por is closer to “was about to”.",
        "estarPor preterite|irA imperfect": "Iba a + infinitive says what almost happened. Estuvo por stresses that it came close once and did not.",
        "irA present|estarPor present": "Estar por is closer to “about to”. Ir a + infinitive is a plan, which can be further away.",
    ]

    private static let personNames = ["yo", "tú", "él / ella / usted", "nosotros", "vosotros", "ellos / ustedes"]

    /// The line for the moment: where the action sits compared with the anchor time.
    static func momentLine(_ drill: DrillTense) -> String {
        let base = mainMomentLine(drill)
        // Name the other things the tense can say, so "why this tense" is never the whole story
        let others = drill.readings.dropFirst().filter(\.standard).prefix(2).map { "\($0.note) (\($0.example))" }
        return others.isEmpty ? base : base + " It can also say: " + others.joined(separator: " ")
    }

    private static func mainMomentLine(_ drill: DrillTense) -> String {
        if drill.mood == .conditional { return "Imagined: what would happen, not what does." }
        // The perfect looks back from the moment, and covers what is still open up to it ("todavía no")
        if drill.kind == .perfect {
            switch drill.time {
            case .past: return "Before a moment in the past: it was already done by then, or it still had not happened up to then."
            case .present: return "Before now: it is done and still matters, or it has not happened yet up to now (todavía no)."
            case .future: return "Before a moment in the future: it will be done by then."
            }
        }
        switch (drill.moment, drill.time) {
        case (.before, .past): return "Before a moment in the past: it was already done by then."
        case (.before, .present): return "Before now: it is done and still matters."
        case (.before, .future): return "Before a moment in the future: it will be done by then."
        case (.during, .past): return "During a moment or a stretch of time in the past."
        case (.during, .present): return "Right now, or as a habit."
        case (.during, .future): return "At a moment in the future."
        case (.after, .past): return "After a moment in the past: what was about to happen from there."
        case (.after, .present): return "After now: what is about to happen."
        case (.after, .future): return "After a moment in the future."
        }
    }

    struct Explanation {
        /// "Why the preterite?"
        let heading: String
        let rule: String
        /// The clue in this sentence, if one is found.
        let clue: String?
        let moment: String
        let context: String
    }

    static func explain(_ card: DrillSentences.Card) -> Explanation {
        let entry = entries[card.drill.key]
        let lower = " " + card.sentence.lowercased() + " "
        let clue = entry?.markers.first { lower.contains($0.0) }?.1
        return Explanation(heading: "Why the \(card.drill.title.lowercased())?",
                           rule: entry?.rule ?? "",
                           clue: clue,
                           moment: momentLine(card.drill),
                           context: entry?.context ?? "")
    }

    /// Works out what the learner typed: another tense of the verb, the right tense for another person, or neither.
    static func identify(_ typed: String, card: DrillSentences.Card) -> (drill: DrillTense, person: Int)? {
        let given = typed.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !given.isEmpty else { return nil }
        func plain(_ s: String) -> String { s.folding(options: [.diacriticInsensitive], locale: Locale(identifier: "es")) }
        // The tense being drilled first, so "hablé" for an "él" sentence is read as the wrong person, not the wrong tense
        let order = [card.drill] + DrillTense.all.filter { $0 != card.drill }
        for exact in [true, false] {
            for drill in order {
                for person in 0..<6 {
                    guard let form = DrillSentences.verbPhrase(card.infinitive, drill, person: person)?.lowercased() else { continue }
                    if exact ? form == given : plain(form) == plain(given) { return (drill, person) }
                }
            }
        }
        return nil
    }

    private static func distance(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        var row = Array(0...b.count)
        for i in 1...max(a.count, 1) where !a.isEmpty {
            var previous = row[0]
            row[0] = i
            for j in 1...max(b.count, 1) where !b.isEmpty {
                let current = row[j]
                row[j] = min(row[j] + 1, row[j - 1] + 1, previous + (a[i - 1] == b[j - 1] ? 0 : 1))
                previous = current
            }
        }
        return row[b.count]
    }

    /// One or two sentences on what the typed answer was and why it does not fit here.
    static func diagnose(_ typed: String, card: DrillSentences.Card) -> String {
        let given = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !given.isEmpty else { return "Nothing was typed." }
        let subject = card.subject.text.isEmpty ? "this sentence" : "“\(card.subject.text)”"
        if let found = identify(given, card: card) {
            if found.drill == card.drill {
                return "“\(given)” is the right tense, but it is the form for \(personNames[found.person]). \(subject == "this sentence" ? "This sentence" : "With \(subject)") needs “\(card.answer)”."
            }
            let other = found.drill
            let contrast = contrasts["\(card.drill.key)|\(other.key)"]
            let wrote = "“\(given)” is the \(other.title.lowercased()) (\(entries[other.key]?.short ?? other.gloss))."
            return contrast.map { "\(wrote) \($0)" } ?? "\(wrote) This sentence needs the \(card.drill.title.lowercased()) (\(entries[card.drill.key]?.short ?? card.drill.gloss))."
        }
        // A regular participle or gerund on a verb that has an irregular one: "haya volvido" for "haya vuelto"
        let stem = String(card.infinitive.dropLast(2))
        let ar = card.infinitive.hasSuffix("ar")
        let answerWords = card.answer.split(separator: " ").map(String.init)
        if let last = answerWords.last, answerWords.count > 1 || card.drill.kind == .progressive {
            let regular = card.drill.kind == .perfect ? stem + (ar ? "ado" : "ido") : card.drill.kind == .progressive ? stem + (ar ? "ando" : "iendo") : nil
            if let regular, regular != last, given.lowercased() == (answerWords.dropLast() + [regular]).joined(separator: " ") {
                let part = card.drill.kind == .perfect ? "participle" : "gerund"
                return "“\(card.infinitive)” has an irregular \(part): “\(last)”, not “\(regular)”. The answer is “\(card.answer)”."
            }
        }
        if distance(given.lowercased(), card.answer.lowercased()) <= 2 {
            return "Close. Check the spelling: “\(card.answer)”."
        }
        return "“\(given)” is not a form of \(card.infinitive) that the drill knows. The sentence needs the \(card.drill.title.lowercased())."
    }
}
