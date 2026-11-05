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
        case .before: "Already done by that moment"
        case .during: "Happening at that moment"
        case .after: "Still to come from that moment"
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

    /// The drill for the table and tense a word page is showing: the simple table gives the simple tense, the "-ing"
    /// table the progressive one, the perfect table the perfect one. nil when the drill has no such tense.
    static func forWordPage(form: VerbForm, tense: Tense) -> DrillTense? {
        let kind: Kind = switch form {
        case .infinitive: .simple
        case .gerund: .progressive
        case .participle: .perfect
        }
        let drill = DrillTense(kind: kind, tense: tense)
        return all.contains(drill) ? drill : nil
    }

    /// The tenses that match every filter that is set.
    static func matching(mood: DrillMood?, time: DrillTime?, moment: DrillMoment?) -> [DrillTense] {
        all.filter { drill in
            (mood == nil || drill.mood == mood) && (time == nil || drill.time == time) && (moment == nil || drill.moment == moment)
        }
    }
}

/// The message at the top of the selector: what the chosen filters mean and which tenses they leave, with example conjugations.
struct DrillSelectionSummary: Equatable {
    /// "Subjunctive · Present · After" and how many tenses that leaves.
    let headline: String
    /// One line per tense that applies: "Pluscuamperfecto · había comido".
    let lines: [String]
    /// What the chosen mood and moment mean.
    let note: String?
    /// When nothing fits: which values of the other filters would.
    let hint: String?

    /// Examples show the verb "comer" in the third person, as on the tense rows.
    static func make(mood: DrillMood?, time: DrillTime?, moment: DrillMoment?, limit: Int = 8) -> DrillSelectionSummary {
        let chosen = [mood?.title, time?.title, moment?.title].compactMap { $0 }
        let matches = DrillTense.matching(mood: mood, time: time, moment: moment)
        let note = [mood.map { "\($0.title): \($0.blurb.lowercased())" }, moment.map { "\($0.title): \($0.blurb.lowercased())" }]
            .compactMap { $0 }.joined(separator: ". ")

        guard !chosen.isEmpty else {
            return DrillSelectionSummary(headline: "All \(matches.count) tenses", lines: [], note: nil,
                                         hint: "Pick a mood, a time or a moment to narrow them.")
        }
        guard !matches.isEmpty else {
            return DrillSelectionSummary(headline: "\(chosen.joined(separator: " · ")): no tense fits", lines: [],
                                         note: note.isEmpty ? nil : note, hint: emptyHint(mood: mood, time: time, moment: moment))
        }
        var lines = matches.prefix(limit).map { "\($0.title) · \($0.example)" }
        if matches.count > limit { lines.append("and \(matches.count - limit) more below") }
        return DrillSelectionSummary(headline: "\(chosen.joined(separator: " · ")): \(matches.count) \(matches.count == 1 ? "tense" : "tenses")",
                                     lines: lines, note: note.isEmpty ? nil : note, hint: nil)
    }

    /// For an empty selection, what each filter could be if the others stayed as they are.
    private static func emptyHint(mood: DrillMood?, time: DrillTime?, moment: DrillMoment?) -> String? {
        var parts: [String] = []
        if mood != nil {
            let options = Set(DrillTense.matching(mood: nil, time: time, moment: moment).map(\.mood))
            if !options.isEmpty { parts.append("Mood could be " + DrillMood.allCases.filter(options.contains).map(\.title).joined(separator: " or ")) }
        }
        if time != nil {
            let options = Set(DrillTense.matching(mood: mood, time: nil, moment: moment).map(\.time))
            if !options.isEmpty { parts.append("Time could be " + DrillTime.allCases.filter(options.contains).map(\.title).joined(separator: " or ")) }
        }
        if moment != nil {
            let options = Set(DrillTense.matching(mood: mood, time: time, moment: nil).map(\.moment))
            if !options.isEmpty { parts.append("Moment could be " + DrillMoment.allCases.filter(options.contains).map(\.title).joined(separator: " or ")) }
        }
        return parts.isEmpty ? "Clear a filter to see more." : parts.joined(separator: ". ") + "."
    }
}
