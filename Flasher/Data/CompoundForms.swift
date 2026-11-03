import Foundation

/// The three non-conjugated forms of a verb. Each opens its own table in the conjugation chart:
/// the infinitive shows the simple tenses, the gerund the "-ing" tenses (estar + gerund), the participle the perfect tenses (haber + participle).
enum VerbForm: String, CaseIterable, Identifiable, Hashable {
    case infinitive, gerund, participle

    var id: String { rawValue }

    var title: String {
        switch self {
        case .infinitive: "Infinitive"
        case .gerund: "Gerund"
        case .participle: "Participle"
        }
    }

    /// The helper verb the table is built with.
    var auxiliary: String? {
        switch self {
        case .infinitive: nil
        case .gerund: "estar"
        case .participle: "haber"
        }
    }

    /// The tenses the table has: not every simple tense has an "-ing" or perfect version.
    var tenses: [Tense] {
        switch self {
        case .infinitive: Tense.allCases
        case .gerund: [.present, .preterite, .imperfect, .future, .conditional, .subjunctivePresent, .subjunctiveImperfect]
        case .participle: [.present, .imperfect, .future, .conditional, .subjunctivePresent, .subjunctiveImperfect]
        }
    }

    func supports(_ tense: Tense) -> Bool { tenses.contains(tense) }

    /// The Spanish name of the tense in this table ("Pluscuamperfecto").
    func title(of tense: Tense) -> String {
        switch self {
        case .infinitive: return tense.title
        case .gerund:
            switch tense {
            case .present, .subjunctivePresent: return "Presente progresivo"
            case .preterite: return "Pretérito progresivo"
            case .imperfect, .subjunctiveImperfect: return "Imperfecto progresivo"
            case .future: return "Futuro progresivo"
            default: return "Condicional progresivo"
            }
        case .participle:
            switch tense {
            case .present: return "Pretérito perfecto"
            case .imperfect, .subjunctiveImperfect: return "Pluscuamperfecto"
            case .future: return "Futuro perfecto"
            case .conditional: return "Condicional perfecto"
            default: return "Perfecto"
            }
        }
    }

    /// One or two English words for the tense in this table.
    func gloss(of tense: Tense) -> String {
        switch self {
        case .infinitive: return tense.gloss
        case .gerund:
            switch tense {
            case .present: return "is doing"
            case .preterite: return "was doing, finished"
            case .imperfect: return "was doing"
            case .future: return "will be doing"
            case .conditional: return "would be doing"
            case .subjunctivePresent: return "may be doing"
            default: return "if … were doing"
            }
        case .participle:
            switch tense {
            case .present: return "has done"
            case .imperfect: return "had done"
            case .future: return "will have done"
            case .conditional: return "would have done"
            case .subjunctivePresent: return "may have done"
            default: return "if … had done"
            }
        }
    }

    /// What the tense is for, in a sentence.
    func usage(of tense: Tense) -> String {
        switch self {
        case .infinitive: return ""
        case .gerund:
            switch tense {
            case .present: return "Something happening right now: *estoy comiendo*. Also used for an action in progress around now."
            case .preterite: return "A progressive action that is over and had a clear end: *estuve estudiando toda la tarde*."
            case .imperfect: return "What was going on in the past, often interrupted by something else: *estaba comiendo cuando llamaste*."
            case .future: return "What will be going on at a later moment, or a guess about now: *estaré trabajando a esa hora*."
            case .conditional: return "What would be going on: *estaría durmiendo si no fuera por el ruido*."
            case .subjunctivePresent: return "After a trigger, for something that may be going on: *espero que estés descansando*."
            default: return "After *si* or a wish, for something that isn't happening: *si estuviera viviendo aquí…*"
            }
        case .participle:
            switch tense {
            case .present: return "Something completed that still matters now: *he terminado* (and I'm free now). In Mexico and Colombia the simple past (*terminé*) is often used instead."
            case .imperfect: return "Something already done before another moment in the past: *ya había comido cuando llegaste*."
            case .future: return "Something that will be done by a later moment, or a guess about the past: *habré terminado para las cinco*."
            case .conditional: return "What would have been done by a later point in the past, or a polite guess: *habría llegado antes*."
            case .subjunctivePresent: return "After a trigger, for something completed: *espero que hayas comido*."
            default: return "After *si* or a wish, for something that did not happen: *si hubiera sabido…*, *ojalá hubieras venido*."
            }
        }
    }
}

/// Where a link into a word's page should land in the conjugation chart.
struct ConjugationFocus: Hashable {
    var form: VerbForm = .infinitive
    var tense: Tense = .present
    var person: Int = 0

    var queryItems: [URLQueryItem] {
        [URLQueryItem(name: "kind", value: form.rawValue), URLQueryItem(name: "tense", value: tense.rawValue), URLQueryItem(name: "person", value: String(person))]
    }

    init(form: VerbForm = .infinitive, tense: Tense = .present, person: Int = 0) {
        self.form = form
        self.tense = tense
        self.person = person
    }

    init?(queryItems: [URLQueryItem]?) {
        func value(_ name: String) -> String? { queryItems?.first(where: { $0.name == name })?.value }
        guard let kind = value("kind").flatMap(VerbForm.init(rawValue:)) else { return nil }
        let tense = value("tense").flatMap(Tense.init(rawValue:)) ?? .present
        self.init(form: kind, tense: kind.supports(tense) ? tense : .present, person: min(max(value("person").flatMap(Int.init) ?? 0, 0), 5))
    }
}

/// Conjugations built from a helper verb and the gerund or participle: "estoy comiendo", "he comido", "había comido".
enum CompoundForms {
    /// The helper verb's own forms ("he", "has", "ha"…), nil when the tense has none.
    static func auxiliary(_ form: VerbForm, _ tense: Tense, _ person: Int) -> String? {
        guard let name = form.auxiliary, form.supports(tense) else { return nil }
        return Conjugator.conjugate(name)?.form(tense, person)
    }

    /// The whole form without pronouns: "he comido", "estaba comiendo".
    static func form(of conjugation: Conjugation, _ form: VerbForm, _ tense: Tense, _ person: Int) -> String? {
        guard let helper = auxiliary(form, tense, person) else { return nil }
        return helper + " " + (form == .gerund ? conjugation.gerund : conjugation.participle)
    }
}
