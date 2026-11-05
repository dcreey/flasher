import Foundation

/// Sentences that more than one tense can complete. The card says so and lets the learner pick which tense to answer in.
/// The rules come from the audit in docs/conjugation-drill/tense-interchangeability.md.
enum DrillAlternates {
    struct Option: Equatable {
        let drill: DrillTense
        /// Why this tense works here too.
        let why: String
        /// Heard in everyday speech but not the standard form.
        var colloquial = false
    }

    private static func drill(_ kind: DrillTense.Kind, _ tense: Tense) -> DrillTense { DrillTense(kind: kind, tense: tense) }

    /// The other tenses that fit this card's sentence, not counting the card's own. Empty when only one fits.
    static func options(for card: DrillSentences.Card) -> [Option] {
        let lower = " " + card.sentence.lowercased() + " "
        func has(_ text: String) -> Bool { lower.contains(text) }
        var found: [Option] = []
        switch card.drill.key {
        // Finished past and "ayer": the simple past is the usual choice in Mexico, and the present perfect is heard too
        case "simple preterite" where has(" ayer "):
            found = [Option(drill: drill(.perfect, .present), why: "In Mexico the preterite is the usual choice, about 80 to 90 percent of past-tense uses in studies, but the present perfect is also used, even for a recent past like “ayer”.")]
        case "perfect present" where has(" hoy "):
            found = [Option(drill: drill(.simple, .preterite), why: "“Hoy” is not over yet, so the present perfect fits. In Mexico the preterite is actually the more common choice here.")]
        // Talking about what comes next: ir a, the future and the present overlap
        case "simple future" where has(" mañana "):
            found = [Option(drill: drill(.irA, .present), why: "In everyday Latin American speech, ir a + infinitive is the most common way to say a plan."),
                     Option(drill: drill(.simple, .present), why: "With a time word like “mañana”, the plain present can also say a future plan.")]
        case "simple future" where has(" algún día "):
            found = [Option(drill: drill(.irA, .present), why: "In everyday speech, ir a + infinitive is used for the future too. The simple future sounds more formal.")]
        case "irA present" where has(" mañana "):
            found = [Option(drill: drill(.simple, .future), why: "The future also says what will happen tomorrow. It is more common in writing, and for guesses."),
                     Option(drill: drill(.simple, .present), why: "With “mañana”, the plain present can say a future plan.")]
        // In progress now
        case "progressive present" where has(" ahora "):
            found = [Option(drill: drill(.simple, .present), why: "With “ahora” the simple present can also say what is happening now. The progressive stresses that it is in progress.")]
        // A stretch of time that is over takes the preterite; an interrupted action takes either imperfect
        case "progressive preterite" where has("toda la tarde"):
            found = [Option(drill: drill(.simple, .preterite), why: "A limited stretch of time (“toda la tarde”) takes the preterite either way. Estuvo + gerund stresses the activity, the plain preterite just tells that it happened.")]
        case "progressive imperfect" where has("cuando llamaste"):
            found = [Option(drill: drill(.simple, .imperfect), why: "The simple imperfect also says it was going on at that moment. The progressive stresses that it was in the middle of happening.")]
        case "progressive future" where has("mañana a esta hora"):
            found = [Option(drill: drill(.simple, .future), why: "The simple future also places the action at that moment. The progressive stresses that you will be in the middle of it.")]
        // Imagined results
        case "progressive conditional" where has("si hubiera tiempo"):
            found = [Option(drill: drill(.simple, .conditional), why: "The simple conditional says the same without stressing that it would be in progress.")]
        case "simple conditional" where has("si hubiera tiempo"):
            found = [Option(drill: drill(.simple, .imperfect), why: "In everyday speech the imperfect often stands in for the conditional. The conditional is the standard form.", colloquial: true)]
        case "perfect conditional" where has("si hubiera habido tiempo"):
            found = [Option(drill: drill(.perfect, .subjunctiveImperfect), why: "In the result part of an unreal past condition both are accepted: “habría comprado” and “hubiera comprado”. Only “si habría…” is wrong.")]
        // Before another past moment: the pluperfect, not the preterite (the sources say they are not interchangeable)
        // Nosotros: "vamos a" is the everyday way to say "let's"
        case "simple imperative" where card.subject.text == "nosotros":
            found = [Option(drill: drill(.irA, .present), why: "“Vamos a + infinitive” is the everyday way to say “let’s”. The tone tells whether it is a suggestion or a plain “we are going to”.")]
        // A deadline: the simple future or ir a say it will happen, the future perfect says it will already be done
        case "perfect future" where has("para el viernes"):
            found = [Option(drill: drill(.simple, .future), why: "“Terminaré para el viernes” is very common. The future perfect stresses that it will already be finished by then."),
                     Option(drill: drill(.irA, .present), why: "“Voy a terminar para el viernes” is what most people say in conversation.", colloquial: true)]
        // About to: estar por and ir a overlap, with a different shade
        case "estarPor present" where has(" ahora "):
            found = [Option(drill: drill(.irA, .present), why: "Ir a + infinitive also says it will happen soon. Estar por is closer to “about to”.")]
        case "estarPor imperfect" where has("cuando llamaste"):
            found = [Option(drill: drill(.irA, .imperfect), why: "Iba a + infinitive says what was planned or about to happen. Estaba por is closer to “was about to”.")]
        case "estarPor preterite" where has("no pasó nada"):
            found = [Option(drill: drill(.irA, .imperfect), why: "“Iba a + infinitive” also says what almost happened, and “al final no pasó nada” shows it did not.")]
        default:
            break
        }
        // Only tenses the drill can build for this verb and subject
        return found.filter { option in
            DrillSentences.subjects(for: card.infinitive, option.drill).contains(card.subject)
                && DrillSentences.verbPhrase(card.infinitive, option.drill, person: card.subject.person) != nil
        }
    }

    /// Other spellings of the same tense that are just as right: the imperfect subjunctive in -ra and in -se
    /// (“comiera” and “comiese”). They stay interchangeable when -ra only stands for the conditional, which no drill card does.
    static func equivalentForms(for card: DrillSentences.Card) -> [String] {
        guard card.drill.tense == .subjunctiveImperfect else { return [] }
        let endings = [("éramos", "ésemos"), ("áramos", "ásemos"), ("eran", "esen"), ("aran", "asen"), ("eras", "eses"), ("aras", "ases"), ("era", "ese"), ("ara", "ase")]
        var changed = false
        let words = card.answer.split(separator: " ").map { word -> String in
            let text = String(word)
            for (ra, se) in endings where text.hasSuffix(ra) && text.count > ra.count {
                changed = true
                return String(text.dropLast(ra.count)) + se
            }
            return text
        }
        return changed ? [words.joined(separator: " ")] : []
    }
}
