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
        case .during: "Happening at that moment, or still open up to it (todavía no ha llegado)"
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

    /// The moment the tense is mainly about: its first reading. The phrases are anchored at the helper verb ("acabo de" now,
    /// "acababa de" then).
    var time: DrillTime { readings.first?.time ?? .present }

    /// Where the action sits compared with that moment, in the tense's main reading.
    var moment: DrillMoment { readings.first?.moment ?? .during }

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

    /// The tenses the learner has switched on in Settings: all of them, or all but the progressive ones.
    static var available: [DrillTense] {
        let progressive = UserDefaults.standard.object(forKey: AppSettings.drillProgressiveKey) as? Bool ?? true
        return progressive ? all : all.filter { $0.kind != .progressive }
    }

    /// The tenses that match every filter that is set.
    static func matching(mood: DrillMood?, time: DrillTime?, moment: DrillMoment?) -> [DrillTense] {
        available.filter { drill in
            (mood == nil || drill.mood == mood) && drill.fits(time: time, moment: moment)
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
        var lines = matches.prefix(limit).map { drill -> String in
            // A tense listed for a reading that is not its main one says which: "Presente · come (also: Mañana viajo.)"
            var line = "\(drill.title) · \(drill.example)"
            if (time != nil && drill.time != time) || (moment != nil && drill.moment != moment),
               let other = drill.reading(time: time, moment: moment) { line += " (also: \(other.example))" }
            return line
        }
        if matches.count > limit { lines.append("and \(matches.count - limit) more below") }
        return DrillSelectionSummary(headline: "\(chosen.joined(separator: " · ")): \(matches.count) \(matches.count == 1 ? "tense" : "tenses")",
                                     lines: lines, note: note.isEmpty ? nil : note, hint: hiddenHint(mood: mood, time: time, moment: moment, shown: matches))
    }

    /// The tenses the Moment filter is hiding: they fit the mood and the time but sit at another moment. "Clear Moment to
    /// add: Presente de subjuntivo (During)", so a tense is never missing without saying why.
    private static func hiddenHint(mood: DrillMood?, time: DrillTime?, moment: DrillMoment?, shown: [DrillTense]) -> String? {
        var parts: [String] = []
        func add(_ label: String, _ others: [DrillTense], _ value: (DrillTense) -> String) {
            let hidden = others.filter { !shown.contains($0) }
            guard !hidden.isEmpty else { return }
            let names = hidden.prefix(4).map { "\($0.title) (\(value($0)))" }.joined(separator: ", ")
            parts.append("Clear \(label) to add: \(names)\(hidden.count > 4 ? " and \(hidden.count - 4) more" : "")")
        }
        // Only the moment is worth explaining: a tense that fits the mood and the time but sits at another moment
        // (the perfect under Before, the simple tenses under During) is the one people look for and don't find
        if moment != nil, mood != nil || time != nil { add("Moment", DrillTense.matching(mood: mood, time: time, moment: nil)) { drill in DrillMoment.allCases.filter { drill.fits(time: time, moment: $0) }.map(\.title).joined(separator: ", ") } }
        return parts.isEmpty ? nil : parts.joined(separator: ". ") + "."
    }

    /// For an empty selection, what each filter could be if the others stayed as they are.
    private static func emptyHint(mood: DrillMood?, time: DrillTime?, moment: DrillMoment?) -> String? {
        var parts: [String] = []
        if mood != nil {
            let options = Set(DrillTense.matching(mood: nil, time: time, moment: moment).map(\.mood))
            if !options.isEmpty { parts.append("Mood could be " + DrillMood.allCases.filter(options.contains).map(\.title).joined(separator: " or ")) }
        }
        if time != nil {
            let options = Set(DrillTense.matching(mood: mood, time: nil, moment: moment).flatMap(\.times))
            if !options.isEmpty { parts.append("Time could be " + DrillTime.allCases.filter(options.contains).map(\.title).joined(separator: " or ")) }
        }
        if moment != nil {
            let options = Set(DrillTense.matching(mood: mood, time: time, moment: nil).flatMap(\.moments))
            if !options.isEmpty { parts.append("Moment could be " + DrillMoment.allCases.filter(options.contains).map(\.title).joined(separator: " or ")) }
        }
        return parts.isEmpty ? "Clear a filter to see more." : parts.joined(separator: ". ") + "."
    }
}

/// The tenses the learner has toggled on to study. Saved as text so it survives launches.
struct DrillSelection: Equatable {
    private(set) var keys: Set<String>

    init(raw: String) {
        keys = Set(raw.split(separator: ",").map(String.init).filter { key in DrillTense.all.contains { $0.key == key } })
    }

    var raw: String { keys.sorted().joined(separator: ",") }
    var isEmpty: Bool { keys.isEmpty }
    func contains(_ drill: DrillTense) -> Bool { keys.contains(drill.key) }

    /// The selected tenses in the order the drill lists them.
    var tenses: [DrillTense] { DrillTense.available.filter(contains) }

    mutating func toggle(_ drill: DrillTense) {
        if keys.contains(drill.key) { keys.remove(drill.key) } else { keys.insert(drill.key) }
    }

    mutating func add(_ drills: [DrillTense]) { drills.forEach { keys.insert($0.key) } }
    mutating func remove(_ drills: [DrillTense]) { drills.forEach { keys.remove($0.key) } }
    mutating func clear() { keys.removeAll() }

    /// What "Practice" practises: the selected tenses, or whatever the filters show when nothing is selected.
    func practiceSet(shown: [DrillTense]) -> [DrillTense] { isEmpty ? shown : tenses }

    /// How many selected tenses the filters are hiding right now.
    func hiddenCount(shown: [DrillTense]) -> Int { tenses.filter { !shown.contains($0) }.count }
}
