import Foundation

/// One thing a tense can say: when it is anchored (time), where the action sits compared with that moment, and an example.
/// Most tenses have more than one. The first reading of each is the main one, the one the tense is usually taught for.
/// See docs/conjugation-drill/tense-interchangeability.md for the audit and sources.
struct DrillReading: Equatable {
    let time: DrillTime
    let moment: DrillMoment
    let example: String
    let note: String
    /// False for readings heard in everyday speech but not the standard form.
    var standard = true

    init(_ time: DrillTime, _ moment: DrillMoment, _ example: String, _ note: String, standard: Bool = true) {
        self.time = time
        self.moment = moment
        self.example = example
        self.note = note
        self.standard = standard
    }
}

enum DrillReadings {
    static let all: [String: [DrillReading]] = [
        // Simple tenses
        "simple present": [
            .init(.present, .during, "Como tacos todos los días.", "What is true now, or happens as a habit."),
            .init(.future, .during, "Mañana viajo a Puebla.", "A planned future, with a time word."),
            .init(.present, .during, "Vivo aquí desde 2010.", "Something that began before and is still true (desde, hace… que)."),
            .init(.past, .during, "En 1492 Colón llega a América.", "The historical present: telling the past as if it were now."),
        ],
        "simple preterite": [
            .init(.past, .during, "Ayer comí tacos.", "One finished event at a specific moment."),
        ],
        "simple imperfect": [
            .init(.past, .during, "Antes comía tacos cada semana.", "How things were, or what used to happen."),
            .init(.past, .after, "Dijo que venía mañana.", "Reported speech: what was coming from a past moment.", standard: false),
        ],
        "simple future": [
            .init(.future, .during, "Mañana comerá tacos.", "What will happen."),
            .init(.present, .during, "Estará durmiendo.", "A guess about now (probability)."),
        ],
        "simple conditional": [
            .init(.present, .during, "Compraría el coche si tuviera dinero.", "What would happen under a condition, now or later."),
            .init(.past, .after, "Dijo que vendría mañana.", "The future as seen from a past moment."),
            .init(.past, .during, "Serían las ocho.", "A guess about the past."),
        ],
        "simple subjunctivePresent": [
            .init(.present, .during, "Espero que venga ahora.", "A wish, feeling or doubt about now."),
            .init(.future, .during, "Cuando llegue, te llamo.", "Something still to come, after cuando, hasta que, antes de que."),
        ],
        "simple subjunctiveImperfect": [
            .init(.past, .during, "Quería que viniera.", "A wish or request seen from the past."),
            .init(.present, .during, "Si tuviera dinero, compraría un coche.", "Something unreal now."),
            .init(.future, .during, "Ojalá viniera mañana.", "A future that is unlikely."),
        ],
        "simple imperative": [
            .init(.present, .during, "¡Come ya!", "Do it now."),
            .init(.future, .after, "Mañana llámame.", "Do it later."),
        ],
        // Progressive tenses
        "progressive present": [
            .init(.present, .during, "Estoy comiendo.", "In progress right now."),
            .init(.present, .during, "Estoy viviendo en Madrid este año.", "A temporary situation."),
        ],
        "progressive preterite": [
            .init(.past, .during, "Estuve estudiando toda la tarde.", "In progress for a limited stretch of time that is over."),
        ],
        "progressive imperfect": [
            .init(.past, .during, "Estaba comiendo cuando llamaste.", "In progress at a past moment."),
        ],
        "progressive future": [
            .init(.future, .during, "Mañana a esta hora estaré viajando.", "In progress at a future moment."),
            .init(.present, .during, "Estará durmiendo todavía.", "A guess about what is going on now."),
        ],
        "progressive conditional": [
            .init(.present, .during, "Estaría comiendo ahora si hubiera tiempo.", "Imagined as in progress."),
            .init(.past, .during, "Estaría durmiendo cuando llamaste.", "A guess about the past."),
        ],
        "progressive subjunctivePresent": [
            .init(.present, .during, "Espero que estés comiendo.", "A wish about what is going on now."),
            .init(.future, .during, "Espero que estés trabajando mañana a esta hora.", "A wish about a future moment."),
        ],
        "progressive subjunctiveImperfect": [
            .init(.present, .during, "Si estuviera comiendo ahora, se notaría.", "Something unreal now."),
            .init(.past, .during, "Quería que estuviera trabajando.", "Seen from the past."),
        ],
        // Perfect tenses: done by the moment, and also still open up to it
        "perfect present": [
            .init(.present, .before, "Ya he comido.", "Done by now, and it still matters."),
            .init(.present, .during, "Todavía no he comido.", "Still open up to now (todavía no, desde)."),
        ],
        "perfect imperfect": [
            .init(.past, .before, "Cuando llegué, ya había comido.", "Done before another past moment."),
            .init(.past, .during, "Cuando llegué, todavía no había comido.", "Still open up to that past moment."),
        ],
        "perfect future": [
            .init(.future, .before, "Para el viernes ya habré comido.", "Done by a future moment."),
            .init(.future, .during, "El viernes todavía no habré terminado.", "Still open up to that future moment."),
            .init(.present, .before, "Ya habrá llegado.", "A guess about something that has probably happened already."),
        ],
        "perfect conditional": [
            .init(.past, .before, "Habría comprado el coche si hubiera tenido dinero.", "What would have happened."),
            .init(.past, .before, "Dijo que para el viernes habría terminado.", "Done by a moment that was still to come from a past moment."),
        ],
        "perfect subjunctivePresent": [
            .init(.present, .before, "Espero que hayas comido.", "A wish about something that should already be done."),
            .init(.present, .during, "No creo que haya llegado todavía.", "Doubt about something that is still open up to now."),
            .init(.future, .before, "Cuando hayas terminado, llámame.", "Done before another future moment."),
        ],
        "perfect subjunctiveImperfect": [
            .init(.past, .before, "Ojalá hubiera comido.", "A wish about the past."),
            .init(.past, .before, "Si hubiera sabido, habría venido.", "Something unreal in the past."),
        ],
        // Phrases
        "acabarDe present": [.init(.present, .before, "Acabo de comer.", "Just before now.")],
        "acabarDe imperfect": [.init(.past, .before, "Acababa de comer cuando llegaste.", "Just before a past moment.")],
        "irA present": [
            .init(.present, .after, "Voy a comer.", "A plan, or what is about to happen."),
            .init(.present, .after, "¡Vamos a comer!", "Let’s: a suggestion."),
        ],
        "irA imperfect": [.init(.past, .after, "Iba a comer, pero llamaste.", "A plan from a past moment.")],
        "estarPor present": [.init(.present, .after, "Estoy por comer.", "About to.")],
        "estarPor imperfect": [.init(.past, .after, "Estaba por comer.", "Was about to.")],
        "estarPor preterite": [.init(.past, .after, "Estuve por comer, pero no.", "Came close, once.")],
    ]
}

extension DrillTense {
    /// Everything the tense can say, main reading first.
    var readings: [DrillReading] { DrillReadings.all[key] ?? [] }
    var times: Set<DrillTime> { Set(readings.map(\.time)) }
    var moments: Set<DrillMoment> { Set(readings.map(\.moment)) }

    /// Whether any reading of the tense fits these filters.
    func fits(time: DrillTime?, moment: DrillMoment?) -> Bool {
        readings.contains { (time == nil || $0.time == time) && (moment == nil || $0.moment == moment) }
    }

    /// The first reading that fits the filters, to show why a tense is listed when it is not its main use.
    func reading(time: DrillTime?, moment: DrillMoment?) -> DrillReading? {
        readings.first { (time == nil || $0.time == time) && (moment == nil || $0.moment == moment) }
    }
}
