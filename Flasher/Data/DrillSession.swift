import Foundation

extension DrillTense {
    /// The name a learner knows the tense by.
    var title: String {
        switch kind {
        case .simple:
            switch tense {
            case .present: "Presente"
            case .preterite: "Pretérito"
            case .imperfect: "Imperfecto"
            case .future: "Futuro"
            case .conditional: "Condicional"
            case .subjunctivePresent: "Presente de subjuntivo"
            case .subjunctiveImperfect: "Imperfecto de subjuntivo"
            case .imperative: "Imperativo"
            }
        case .progressive:
            switch tense {
            case .present: "Presente progresivo"
            case .preterite: "Pretérito progresivo"
            case .imperfect: "Imperfecto progresivo"
            case .future: "Futuro progresivo"
            case .conditional: "Condicional progresivo"
            case .subjunctivePresent: "Subjuntivo presente progresivo"
            default: "Subjuntivo imperfecto progresivo"
            }
        case .perfect:
            switch tense {
            case .present: "Pretérito perfecto"
            case .preterite: "Pretérito anterior"
            case .imperfect: "Pluscuamperfecto"
            case .future: "Futuro perfecto"
            case .conditional: "Condicional perfecto"
            case .subjunctivePresent: "Pretérito perfecto de subjuntivo"
            default: "Pluscuamperfecto de subjuntivo"
            }
        case .acabarDe: tense == .present ? "Acabar de (ahora)" : "Acabar de (antes)"
        case .irA: tense == .present ? "Ir a (ahora)" : "Ir a (antes)"
        case .estarPor:
            switch tense {
            case .present: "Estar por (ahora)"
            case .imperfect: "Estar por (antes)"
            default: "Estar por (pretérito)"
            }
        }
    }

    /// What the tense says, in a few English words.
    var gloss: String {
        switch kind {
        case .simple: tense.gloss
        case .progressive: "was / is -ing"
        case .perfect: "has / had done"
        case .acabarDe: "just did"
        case .irA: "going to"
        case .estarPor: "about to"
        }
    }

    /// The tense shown on a sample verb ("comió"), so the list reads as a menu of forms.
    var example: String {
        DrillSentences.verbPhrase("comer", self, person: tense == .imperative ? 1 : 2) ?? ""
    }

    /// Which group of the menu the tense belongs to.
    var group: String {
        switch kind {
        case .simple: "Simple"
        case .progressive: "Progressive"
        case .perfect: "Perfect"
        case .acabarDe, .irA, .estarPor: "Near past and future"
        }
    }

    /// A stable name for saving progress.
    var key: String { label }
}

/// What the learner has done with one verb in one tense. Works like a flashcard's progress: a verb is mastered
/// after being answered right in `needed` different rounds, and a miss keeps it in rotation.
struct DrillItem: Codable {
    var correct = 0
    var wrong = 0
    var lastCorrectRound = -99
    var lastReview = Date.distantPast
    /// Non-nil means the learner queued it: it comes first in every round that includes its tense until it has been
    /// answered right `DrillProgress.queuePractices` times since it was queued.
    var priorityDate: Date?
    /// Right answers since it was queued (nil for items saved before the queue counted them).
    var queuedCorrect: Int?
    /// The last sentence shown for it, so the next one is different.
    var lastSentence: String?
    var learned: Bool { correct >= DrillProgress.needed }
    var inProgress: Bool { !learned && (correct > 0 || wrong > 0) }
}

@Observable
final class DrillProgress {
    static let shared = DrillProgress(defaults: .standard)

    /// Right answers, in different rounds, before a verb counts as mastered in a tense.
    static let needed = 3
    /// Right answers, in different rounds, before a queued verb leaves the queue.
    static let queuePractices = 3

    private let defaults: UserDefaults
    private(set) var items: [String: DrillItem] = [:]
    private(set) var round = 0
    private(set) var total = 0
    private(set) var correct = 0

    init(defaults: UserDefaults) {
        self.defaults = defaults
        round = defaults.integer(forKey: "drillRound")
        total = defaults.integer(forKey: "drillTotal")
        correct = defaults.integer(forKey: "drillCorrect")
        if let data = defaults.data(forKey: "drillItems"), let saved = try? JSONDecoder().decode([String: DrillItem].self, from: data) {
            items = saved
        }
    }

    static func key(_ infinitive: String, _ drill: DrillTense) -> String { "\(infinitive)|\(drill.key)" }

    static func split(_ key: String) -> (infinitive: String, drill: DrillTense)? {
        let parts = key.split(separator: "|", maxSplits: 1).map(String.init)
        guard parts.count == 2, let drill = DrillTense.all.first(where: { $0.key == parts[1] }) else { return nil }
        return (parts[0], drill)
    }

    func item(_ infinitive: String, _ drill: DrillTense) -> DrillItem { items[Self.key(infinitive, drill)] ?? DrillItem() }

    func beginRound() {
        round += 1
        defaults.set(round, forKey: "drillRound")
    }

    /// The first time a card comes up in a round counts toward mastery; a card asked again after a miss does not.
    func record(_ card: DrillSentences.Card, correct isCorrect: Bool, countsTowardMastery: Bool = true) {
        var entry = item(card.infinitive, card.drill)
        entry.lastReview = Date()
        entry.lastSentence = card.sentence
        if countsTowardMastery {
            total += 1
            if isCorrect {
                correct += 1
                entry.correct = min(entry.correct + 1, Self.needed)
                entry.lastCorrectRound = round
                // A queued verb stays queued until it has been practised right three times
                if entry.priorityDate != nil {
                    let done = (entry.queuedCorrect ?? 0) + 1
                    if done >= Self.queuePractices { entry.priorityDate = nil; entry.queuedCorrect = nil } else { entry.queuedCorrect = done }
                }
            } else { entry.wrong += 1 }
        }
        items[Self.key(card.infinitive, card.drill)] = entry
        save()
    }

    // MARK: Queue

    func isQueued(_ infinitive: String, _ drill: DrillTense) -> Bool { item(infinitive, drill).priorityDate != nil }

    /// Puts the verb in this tense at the front of the line, and starts it over if it was already mastered.
    func queue(_ infinitive: String, _ drill: DrillTense) {
        var entry = item(infinitive, drill)
        if entry.learned { entry.correct = 0; entry.lastCorrectRound = -99 }
        entry.priorityDate = Date()
        entry.queuedCorrect = 0
        items[Self.key(infinitive, drill)] = entry
        save()
    }

    func unqueue(_ infinitive: String, _ drill: DrillTense) {
        var entry = item(infinitive, drill)
        entry.priorityDate = nil
        entry.queuedCorrect = nil
        items[Self.key(infinitive, drill)] = entry
        save()
    }

    /// Queued verb and tense pairs, newest request first.
    var queued: [(infinitive: String, drill: DrillTense)] {
        items.compactMap { key, value -> (Date, String, DrillTense)? in
            guard let date = value.priorityDate, let parts = Self.split(key) else { return nil }
            return (date, parts.infinitive, parts.drill)
        }
        .sorted { $0.0 > $1.0 }
        .map { ($0.1, $0.2) }
    }

    /// Verbs go in sets of this many, most common first.
    static let setSize = 100

    /// Where the learner is in a tense: the first set of verbs that isn't all mastered, and how many of it are.
    /// nil until the learner has answered something in the tense.
    func currentSet(_ drill: DrillTense) -> (mastered: Int, size: Int)? {
        guard items.contains(where: { $0.key.hasSuffix("|" + drill.key) }) else { return nil }
        let verbs = DrillDeck.eligible(drill)
        var start = 0
        while start < verbs.count {
            let chunk = verbs[start..<min(start + Self.setSize, verbs.count)]
            let mastered = chunk.filter { item($0, drill).learned }.count
            if mastered < chunk.count || start + Self.setSize >= verbs.count { return (mastered, chunk.count) }
            start += Self.setSize
        }
        return nil
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) { defaults.set(data, forKey: "drillItems") }
        defaults.set(total, forKey: "drillTotal")
        defaults.set(correct, forKey: "drillCorrect")
    }
}

enum DrillDeck {
    /// Whether the verb is irregular in the thing this drill asks for: its own forms in a simple tense, the gerund
    /// for the progressive, the participle for the perfect. The near-future phrases use the infinitive, so any
    /// irregular verb counts.
    static func isIrregular(_ infinitive: String, in drill: DrillTense) -> Bool {
        guard let c = Conjugator.conjugate(infinitive) else { return false }
        let stem = String(c.infinitive.dropLast(2))
        let ar = c.infinitive.hasSuffix("ar")
        switch drill.kind {
        case .simple: return c.forms[drill.tense] != c.regularForms[drill.tense]
        case .progressive: return c.gerund != stem + (ar ? "ando" : "iendo")
        case .perfect: return c.participle != stem + (ar ? "ado" : "ido")
        case .acabarDe, .irA, .estarPor: return c.forms != c.regularForms
        }
    }

    private static var eligibleCache: [String: [String]] = [:]

    /// The verbs the drill can build sentences for in this tense, most common first.
    static func eligible(_ drill: DrillTense) -> [String] {
        if let cached = eligibleCache[drill.key] { return cached }
        let list = DrillSentences.verbList.filter { !DrillSentences.subjects(for: $0, drill).isEmpty }
        eligibleCache[drill.key] = list
        return list
    }

    /// A card for the verb in the tense with a random subject and a random variant of the sentence, never the one it
    /// had last time, so a verb practised again comes with different objects, time words and context.
    private static func card(_ infinitive: String, _ drill: DrillTense, progress: DrillProgress) -> DrillSentences.Card? {
        let subjects = DrillSentences.subjects(for: infinitive, drill)
        guard !subjects.isEmpty else { return nil }
        let last = progress.item(infinitive, drill).lastSentence
        var fallback: DrillSentences.Card?
        for _ in 0..<12 {
            guard let made = DrillSentences.card(infinitive, drill, subject: subjects.randomElement()!, variant: Int.random(in: 1..<1_000_000)) else { continue }
            if made.sentence != last { return made }
            fallback = made
        }
        return fallback
    }

    /// A round in one tense, built like the flashcard queue:
    /// 1. verbs the learner queued come first;
    /// 2. then verbs already in progress (right some rounds, missed some), the furthest along first;
    /// 3. then new verbs in order of how common they are, skipping every mastered one, so a learner who knows
    ///    the common verbs moves on to rarer ones.
    /// Past the queue, the round is an even mix of verbs that are irregular and regular in this tense.
    static func make(_ drill: DrillTense, count: Int = 10, progress: DrillProgress = .shared) -> [DrillSentences.Card] {
        var deck: [DrillSentences.Card] = []
        var used = Set<String>()

        for entry in progress.queued where entry.drill == drill && deck.count < count {
            if let made = card(entry.infinitive, drill, progress: progress) { deck.append(made); used.insert(entry.infinitive) }
        }

        // Candidates by kind. A verb answered right last round rests a round, as in the flashcards.
        var inProgress: [Bool: [String]] = [true: [], false: []]
        var fresh: [Bool: [String]] = [true: [], false: []]
        let resting = progress.round - 1
        let started = progress.items.compactMap { key, value -> (String, DrillItem)? in
            guard value.inProgress, key.hasSuffix("|" + drill.key), let parts = DrillProgress.split(key) else { return nil }
            return (parts.infinitive, value)
        }
        .filter { !used.contains($0.0) }
        .sorted { $0.1.correct != $1.1.correct ? $0.1.correct > $1.1.correct : $0.0 < $1.0 }
        let rested = started.filter { $0.1.lastCorrectRound != resting }
        for (infinitive, _) in (rested.count >= 4 ? rested : started) where !DrillSentences.subjects(for: infinitive, drill).isEmpty {
            inProgress[isIrregular(infinitive, in: drill), default: []].append(infinitive)
        }
        let want = count
        for infinitive in DrillSentences.verbList where !used.contains(infinitive) {
            if fresh[true]!.count >= want, fresh[false]!.count >= want { break }
            guard !progress.item(infinitive, drill).learned, !progress.item(infinitive, drill).inProgress,
                  !DrillSentences.subjects(for: infinitive, drill).isEmpty else { continue }
            let irregular = isIrregular(infinitive, in: drill)
            if fresh[irregular]!.count < want { fresh[irregular]!.append(infinitive) }
        }
        var lists: [Bool: [String]] = [true: inProgress[true]! + fresh[true]!, false: inProgress[false]! + fresh[false]!]

        var wantIrregular = Bool.random()
        var misses = 0
        while deck.count < count, misses < 4 {
            if let infinitive = lists[wantIrregular]?.first {
                lists[wantIrregular]!.removeFirst()
                if let made = card(infinitive, drill, progress: progress), !used.contains(infinitive) { deck.append(made); used.insert(infinitive); misses = 0 }
            } else { misses += 1 }
            wantIrregular.toggle()
        }
        // The queued verbs lead; the rest are shuffled
        let leading = deck.prefix { progress.isQueued($0.infinitive, $0.drill) }
        return Array(leading) + deck.dropFirst(leading.count).shuffled()
    }

    /// A round from the verbs the learner queued, whatever the tense.
    static func makeQueued(count: Int = 10, progress: DrillProgress = .shared) -> [DrillSentences.Card] {
        progress.queued.prefix(count).compactMap { card($0.infinitive, $0.drill, progress: progress) }
    }

    /// Mixed practice: queued verbs, then ones in progress, then one new verb from each of several tenses.
    /// `drills` limits the tenses (the ones left showing after the selector's filters); queued and in-progress verbs
    /// only come up in those tenses too.
    static func makeMixed(count: Int = 10, drills: [DrillTense] = DrillTense.available, progress: DrillProgress = .shared) -> [DrillSentences.Card] {
        var deck = makeQueued(count: count, progress: progress).filter { drills.contains($0.drill) }
        var used = Set(deck.map(\.infinitive))
        let started = progress.items.compactMap { key, value -> (String, DrillTense, Date)? in
            guard value.inProgress, let parts = DrillProgress.split(key), drills.contains(parts.drill) else { return nil }
            return (parts.infinitive, parts.drill, value.lastReview)
        }.sorted { $0.2 < $1.2 }
        for (infinitive, drill, _) in started where deck.count < count / 2 && !used.contains(infinitive) {
            if let made = card(infinitive, drill, progress: progress) { deck.append(made); used.insert(infinitive) }
        }
        // Each tense lines up its own next verbs; the round takes one at a time from random tenses. (Asking a tense for
        // just one verb always gave its top verb, so a round could never be longer than the number of tenses.)
        var pools: [DrillTense: [DrillSentences.Card]] = [:]
        var open = drills
        while deck.count < count, !open.isEmpty {
            let drill = open.randomElement()!
            if pools[drill] == nil { pools[drill] = make(drill, count: count, progress: progress).shuffled() }
            while let made = pools[drill]?.popLast() {
                if used.contains(made.infinitive) { continue }
                deck.append(made)
                used.insert(made.infinitive)
                break
            }
            if pools[drill]?.isEmpty ?? true { open.removeAll { $0 == drill } }
        }
        return deck.shuffled()
    }
}

enum DrillGrade: Equatable {
    case correct
    /// Right letters, wrong or missing accent.
    case accent
    case wrong
}

enum DrillChecker {
    private static func plain(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "es"))
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ").joined(separator: " ")
    }

    private static func tidy(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased().split(separator: " ").joined(separator: " ")
    }

    private static func isOtherForm(_ word: String, of infinitive: String?) -> Bool {
        guard let infinitive, let conjugation = Conjugator.conjugate(infinitive) else { return false }
        for tense in Tense.allCases {
            for person in 0..<6 where conjugation.form(tense, person)?.lowercased() == word { return true }
        }
        return false
    }

    /// Accents are forgiven but pointed out. A "me gusta" blank also accepts "gusta".
    static func grade(_ typed: String, answer: String, infinitive: String? = nil) -> DrillGrade {
        let given = tidy(typed)
        let wanted = tidy(answer)
        guard !given.isEmpty else { return .wrong }
        if given == wanted { return .correct }
        // Without the accent it may be a different form of the verb ("habló" and "hablo"): that is a wrong answer, not a typo
        if plain(given) == plain(wanted) { return isOtherForm(given, of: infinitive) ? .wrong : .accent }
        // The pronoun in front of a gustar-type verb is part of the sentence, not the verb being drilled
        let clitics = ["me ", "te ", "le ", "nos ", "les "]
        if let clitic = clitics.first(where: { wanted.hasPrefix($0) }) {
            let rest = String(wanted.dropFirst(clitic.count))
            if given == rest { return .correct }
            if plain(given) == plain(rest) { return isOtherForm(given, of: infinitive) ? .wrong : .accent }
        }
        return .wrong
    }
}
