import Foundation

/// How the drill tenses are organised for choosing: by mood, by the time the sentence is anchored to, and by where the
/// action sits relative to that moment (before it, during it, after it).
enum DrillMood: String, CaseIterable, Identifiable {
    case indicative, subjunctive, conditional, imperative, phrases
    var id: String { rawValue }

    var title: String {
        switch self {
        case .indicative: "Indicative"
        case .subjunctive: "Subjunctive"
        case .conditional: "Conditional"
        case .imperative: "Imperative"
        case .phrases: "Phrases"
        }
    }

    /// One line on what the mood is for.
    var blurb: String {
        switch self {
        case .indicative: "Facts and events"
        case .subjunctive: "Wishes, feelings, doubt"
        case .conditional: "What would happen"
        case .imperative: "Commands"
        case .phrases: "Just did, going to, about to"
        }
    }
}

/// The moment a sentence is anchored to: now, a moment in the past, or a moment in the future.
enum DrillTime: String, CaseIterable, Identifiable {
    case past, present, future
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
}

/// Where the action sits compared with that moment.
enum DrillMoment: String, CaseIterable, Identifiable {
    case before, during, after
    var id: String { rawValue }
    var title: String { rawValue.capitalized }

    var blurb: String {
        switch self {
        case .before: "Already done by then (he comido, había comido, acaba de)"
        case .during: "Happening at that moment (como, comía, estaba comiendo)"
        case .after: "Still to come from there (voy a comer, iba a comer, está por comer)"
        }
    }
}

extension DrillTense {
    var mood: DrillMood {
        switch kind {
        case .acabarDe, .irA, .estarPor: return .phrases
        case .simple, .progressive, .perfect:
            switch tense {
            case .conditional: return .conditional
            case .subjunctivePresent, .subjunctiveImperfect: return .subjunctive
            case .imperative: return .imperative
            default: return .indicative
            }
        }
    }

    /// The moment the sentence is anchored to. For the phrases it is the moment of the helper verb ("acabo de" now, "acababa de" then).
    var time: DrillTime {
        switch tense {
        case .present, .subjunctivePresent, .imperative: return .present
        case .preterite, .imperfect, .subjunctiveImperfect: return .past
        case .future: return .future
        // "I would eat" imagines now or later; "I would have eaten" imagines the past
        case .conditional: return kind == .perfect ? .past : .present
        }
    }

    /// Where the action sits compared with the anchor moment.
    var moment: DrillMoment {
        switch kind {
        case .simple, .progressive: return .during
        case .perfect, .acabarDe: return .before
        case .irA, .estarPor: return .after
        }
    }

    /// The tenses that match every filter that is set.
    static func matching(mood: DrillMood?, time: DrillTime?, moment: DrillMoment?) -> [DrillTense] {
        all.filter { drill in
            (mood == nil || drill.mood == mood) && (time == nil || drill.time == time) && (moment == nil || drill.moment == moment)
        }
    }
}
