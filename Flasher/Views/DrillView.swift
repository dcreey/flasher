import SwiftUI
import Translation

/// The Drill tab: pick a tense, then fill in the blank in ten short sentences built from the rules engine.
/// Tenses are grouped by mood and can be narrowed by the time the sentence is anchored to and by where the action sits
/// compared with that moment (before it, during it, after it).
struct DrillView: View {
    private var progress: DrillProgress { .shared }
    @State private var started: DrillSetup?
    @State private var mood: DrillMood?
    @State private var time: DrillTime?
    @State private var moment: DrillMoment?

    private var shown: [DrillTense] { DrillTense.matching(mood: mood, time: time, moment: moment) }

    var body: some View {
        List {
            if !progress.queued.isEmpty {
                Section {
                    Button { started = DrillSetup(mode: .queue) } label: {
                        row("Queue", detail: "\(progress.queued.count) \(progress.queued.count == 1 ? "verb" : "verbs") you added, each until it is right \(DrillProgress.queuePractices) times", systemImage: "arrow.up.to.line")
                    }
                }
            }

            Section {
                chips("Mood", DrillMood.allCases, $mood, \.title)
                chips("Time", DrillTime.allCases, $time, \.title)
                chips("Moment", DrillMoment.allCases, $moment, \.title)
                summaryView
                // Always there: with nothing selected it practises every tense, mixed
                Button { started = DrillSetup(mode: .set(shown)) } label: {
                    row("Practice these", detail: shown.isEmpty ? "No tenses to practice" : shown.count == DrillTense.all.count ? "All \(shown.count) tenses" : "\(shown.count) \(shown.count == 1 ? "tense" : "tenses")", systemImage: "play.fill")
                }
                .disabled(shown.isEmpty)
            }

            ForEach(DrillMood.allCases) { group in
                let items = shown.filter { $0.mood == group }
                if !items.isEmpty {
                    Section {
                        ForEach(items, id: \.self) { drill in
                            Button { started = DrillSetup(mode: .tense(drill)) } label: {
                                row(drill.title, detail: "Example: \(drill.example)", trailing: mastered(drill))
                            }
                        }
                    } header: {
                        Text("\(group.title) · \(group.blurb)")
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .navigationTitle("Drill")
        .fullScreenCover(item: $started) { DrillSessionView(setup: $0) }
    }

    /// What the chosen filters mean and which tenses they leave, with example conjugations that change as the filters do.
    private var summaryView: some View {
        let summary = DrillSelectionSummary.make(mood: mood, time: time, moment: moment)
        return VStack(alignment: .leading, spacing: 6) {
            Text(summary.headline).font(.footnote.weight(.semibold))
            ForEach(summary.lines, id: \.self) { line in
                Text(line).font(.footnote).foregroundStyle(.secondary)
            }
            if let note = summary.note { Text(note).font(.footnote).foregroundStyle(.tertiary) }
            if let hint = summary.hint { Text(hint).font(.footnote).foregroundStyle(.secondary) }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// One row of filter chips. Tapping the chosen one clears it.
    private func chips<Option: Identifiable & Equatable>(_ label: String, _ options: [Option], _ selection: Binding<Option?>, _ title: KeyPath<Option, String>) -> some View {
        HStack(spacing: 8) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(.secondary).frame(width: 52, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(options) { option in
                        let selected = selection.wrappedValue == option
                        Button { selection.wrappedValue = selected ? nil : option } label: {
                            Text(option[keyPath: title])
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selected ? Color.accentColor : Color(.secondarySystemFill), in: Capsule())
                                .foregroundStyle(selected ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listRowSeparator(.hidden)
    }

    private func mastered(_ drill: DrillTense) -> String? {
        guard let set = progress.currentSet(drill) else { return nil }
        return "\(set.mastered) of \(set.size)"
    }

    private func row(_ title: String, detail: String, systemImage: String? = nil, trailing: String? = nil) -> some View {
        HStack(spacing: 12) {
            if let systemImage {
                Image(systemName: systemImage).foregroundStyle(Color.accentColor).frame(width: 24)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            if let trailing {
                Text(trailing).font(.footnote).foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

/// What a round is made of.
struct DrillSetup: Identifiable {
    enum Mode { case tense(DrillTense), queue, set([DrillTense]) }
    let id = UUID()
    let mode: Mode

    var title: String {
        switch mode {
        case .tense(let drill): drill.title
        case .queue: "Queue"
        case .set(let drills): drills.count == DrillTense.all.count ? "Mixed practice" : "Selected tenses"
        }
    }
}

struct DrillSessionView: View {
    let setup: DrillSetup
    @Environment(\.dismiss) private var dismiss

    @State private var deck: [DrillSentences.Card] = []
    @State private var index = 0
    @State private var typed = ""
    @State private var grade: DrillGrade?
    @State private var firstTry: [DrillSentences.Card] = []
    @State private var rightCount = 0
    @State private var missedCards: [DrillSentences.Card] = []
    /// Cards already asked a second time after a miss.
    @State private var retried: Set<DrillSentences.Card> = []
    @State private var finished = false
    /// The tense picked on a card that more than one tense fits (nil: the one the drill asked for).
    @State private var chosen: DrillTense?
    /// Set when the answer was another spelling of the same tense (-se for -ra).
    @State private var spellingNote: String?
    @FocusState private var focused: Bool

    private static let roundSize = 10

    var body: some View {
        NavigationStack {
            Group {
                if finished {
                    summary
                } else if deck.indices.contains(index) {
                    cardView(deck[index])
                } else {
                    ContentUnavailableView("Nothing to practice", systemImage: "checkmark.circle", description: Text("No sentences are ready for this."))
                }
            }
            .navigationTitle(setup.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if !finished, !deck.isEmpty {
                    ProgressView(value: Double(index), total: Double(deck.count))
                        .padding(.horizontal, 16)
                }
            }
        }
        .onAppear(perform: start)
    }

    private func start() {
        DrillProgress.shared.beginRound()
        switch setup.mode {
        case .tense(let drill): deck = DrillDeck.make(drill, count: Self.roundSize)
        case .queue: deck = DrillDeck.makeQueued(count: Self.roundSize)
        case .set(let drills): deck = drills.count == 1 ? DrillDeck.make(drills[0], count: Self.roundSize) : DrillDeck.makeMixed(count: Self.roundSize, drills: drills)
        }
        index = 0
        rightCount = 0
        firstTry = []
        missedCards = []
        retried = []
        finished = false
        chosen = nil
        spellingNote = nil
        typed = ""
        grade = nil
        focused = true
    }

    private func cardView(_ original: DrillSentences.Card) -> some View {
        // Some sentences fit more than one tense. The learner picks, and the card follows the pick.
        let options = DrillAlternates.options(for: original)
        let card = chosen.map { original.choosing($0) } ?? original
        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(card.drill.title) · \(card.drill.gloss)")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.teal)
                    Text(card.infinitive).font(.title.bold())
                    if let meaning = Self.meaning(of: card.infinitive) {
                        Text(meaning).font(.subheadline).foregroundStyle(.secondary)
                    }
                    // Who the verb is about: the blank hides the ending, and Spanish drops "yo", "tú" and "nosotros"
                    Text(subjectLine(card))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.indigo)
                        .padding(.top, 4)
                }

                if grade == nil, !options.isEmpty { tensePicker(original, options) }

                Text(grade == nil ? card.prompt : card.sentence)
                    .font(.title3)
                    .fixedSize(horizontal: false, vertical: true)

                // After answering, the whole sentence in English
                if grade != nil, #available(iOS 18.0, *) {
                    DrillEnglishView(spanish: card.sentence).id(card.sentence)
                }

                if let grade {
                    feedback(grade, card)
                    if !options.isEmpty { alsoFits(original, card, options) }
                    Button { next() } label: {
                        Text(index + 1 < deck.count ? "Next" : "Finish").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    TextField("Missing verb", text: $typed)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focused)
                        .submitLabel(.done)
                        .onSubmit { check(card, original: original, options: options) }
                    Button { check(card, original: original, options: options) } label: {
                        Text("Check").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(typed.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func subjectLine(_ card: DrillSentences.Card) -> String {
        card.drill.kind == .simple && card.drill.tense == .imperative ? "Command to: \(card.subject.label)" : "Subject: \(card.subject.label)"
    }

    /// Choose which tense to answer in when the sentence works with more than one.
    private func tensePicker(_ original: DrillSentences.Card, _ options: [DrillAlternates.Option]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("More than one tense fits this sentence. Pick the one you will answer in:")
                .font(.footnote)
                .foregroundStyle(.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach([original.drill] + options.map(\.drill), id: \.self) { drill in
                        let colloquial = options.first { $0.drill == drill }?.colloquial == true
                        let selected = (chosen ?? original.drill) == drill
                        Button { chosen = drill == original.drill ? nil : drill } label: {
                            Text(colloquial ? "\(drill.title) · colloquial" : drill.title)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selected ? Color.teal : Color(.secondarySystemFill), in: Capsule())
                                .foregroundStyle(selected ? Color.white : Color.primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    /// After answering: the other tenses that would have fit, and what the answer counted for.
    private func alsoFits(_ original: DrillSentences.Card, _ answered: DrillSentences.Card, _ options: [DrillAlternates.Option]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if answered.drill != original.drill {
                Text("This round asked for the \(original.drill.title.lowercased()). You answered in the \(answered.drill.title.lowercased()), which fits too, so it counted for that tense.")
            }
            ForEach(options.filter { $0.drill != answered.drill }, id: \.drill) { option in
                Text("Also fits: the \(option.drill.title.lowercased()) (\(option.drill.example)). \(option.why)\(option.colloquial ? " Heard in everyday speech, not the standard form." : "")")
            }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func feedback(_ grade: DrillGrade, _ card: DrillSentences.Card) -> some View {
        switch grade {
        case .correct:
            Label("Correct", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
            if let spellingNote { Text(spellingNote).font(.footnote).foregroundStyle(.secondary) }
        case .accent:
            Label("Right. Mind the accent: \(card.answer)", systemImage: "checkmark.circle").foregroundStyle(.green)
        case .wrong:
            VStack(alignment: .leading, spacing: 4) {
                Label(card.answer, systemImage: "xmark.circle.fill").foregroundStyle(.red).font(.title3.weight(.semibold))
                Text("You wrote \(typed)").font(.footnote).foregroundStyle(.secondary)
            }
            Text(DrillExplainer.diagnose(typed, card: card))
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
        }
        // Why this tense, always open: right answers learn the reason too
        VStack(alignment: .leading, spacing: 8) {
            Text("Why the \(card.drill.title.lowercased())?").font(.subheadline.weight(.semibold))
            explanation(card)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    /// The rule, the clue in this sentence, where the action sits in time, and how the other sentence relates.
    private func explanation(_ card: DrillSentences.Card) -> some View {
        let why = DrillExplainer.explain(card)
        return VStack(alignment: .leading, spacing: 8) {
            Text(why.rule)
            if let clue = why.clue { Label(clue, systemImage: "lightbulb") }
            Label(why.moment, systemImage: "clock")
            if !why.context.isEmpty { Label(why.context, systemImage: "text.bubble") }
        }
        .font(.footnote)
        .foregroundStyle(.secondary)
        .fixedSize(horizontal: false, vertical: true)
    }

    private var summary: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("\(rightCount) of \(firstTry.count)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .padding(.top, 32)
                if !missedCards.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("To practice again").font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
                        ForEach(missedCards, id: \.self) { card in
                            Text(card.sentence).font(.callout)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button { start() } label: { Text("Another round").frame(maxWidth: .infinity) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
            }
            .padding(16)
        }
    }

    private func check(_ shown: DrillSentences.Card, original: DrillSentences.Card, options: [DrillAlternates.Option]) {
        guard grade == nil else { return }
        // Typing the form of another tense that fits the sentence counts as picking it
        var card = shown
        if DrillChecker.grade(typed, answer: card.answer, infinitive: card.infinitive) == .wrong,
           let option = options.first(where: { DrillChecker.grade(typed, answer: original.choosing($0.drill).answer, infinitive: original.infinitive) != .wrong }) {
            card = original.choosing(option.drill)
            chosen = option.drill
        }
        var result = DrillChecker.grade(typed, answer: card.answer, infinitive: card.infinitive)
        // The -se form of the imperfect subjunctive is as right as the -ra form
        if result == .wrong, let other = DrillAlternates.equivalentForms(for: card).first(where: { DrillChecker.grade(typed, answer: $0, infinitive: card.infinitive) != .wrong }) {
            result = .correct
            spellingNote = "“\(card.answer)” and “\(other)” are the same tense: the -ra and -se forms are interchangeable here."
        }
        grade = result
        focused = false
        let right = result != .wrong
        let firstTime = !retried.contains(card)
        DrillProgress.shared.record(card, correct: right, countsTowardMastery: firstTime)
        guard firstTime else { return }
        firstTry.append(card)
        if right { rightCount += 1 } else {
            missedCards.append(card)
            // A missed card comes back later in the round, as in the flashcards
            retried.insert(card)
            let spot = Int.random(in: min(index + 3, deck.count)...deck.count)
            deck.insert(card, at: spot)
        }
    }

    private func next() {
        if index + 1 < deck.count {
            index += 1
            chosen = nil
            spellingNote = nil
            typed = ""
            grade = nil
            focused = true
        } else {
            finished = true
        }
    }

    /// The verb's first everyday English meaning: no slang from one country, nothing crude, no regional label.
    private static func meaning(of infinitive: String) -> String? {
        guard let block = Lexicon.shared.meaningsByWord[infinitive]?.first(where: { $0.partOfSpeech == .infinitive }) else { return nil }
        let plain = block.senses.first { !$0.isCrude && !$0.fromMexico && !$0.text.hasPrefix("(") } ?? block.senses.first { !$0.isCrude }
        guard var text = plain?.text else { return nil }
        if text.hasPrefix("("), let close = text.firstIndex(of: ")") { text = String(text[text.index(after: close)...]) }
        return text.trimmingCharacters(in: .whitespaces)
    }
}


/// What the translator already said, so a sentence that comes up again (a missed card asked a second time) shows at once.
enum DrillEnglishCache {
    static var sentences: [String: String] = [:]
}

/// The English for a Spanish drill sentence, from the same offline translator as the Translate tab. It stays empty
/// when the translator or its language packs aren't available, so the card works without it.
@available(iOS 18.0, *)
private struct DrillEnglishView: View {
    let spanish: String
    @State private var english: String?
    @State private var configuration: TranslationSession.Configuration?

    var body: some View {
        Group {
            if let english {
                Text(english)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .translationTask(configuration) { session in
            guard let response = try? await session.translate(spanish) else { return }
            let text = TranslationTraps.fixingEnglish(response.targetText, spanish: spanish)
            DrillEnglishCache.sentences[spanish] = text
            english = text
        }
        .onAppear {
            if let cached = DrillEnglishCache.sentences[spanish] {
                english = cached
            } else {
                configuration = TranslationSession.Configuration(source: Locale.Language(identifier: "es"), target: Locale.Language(identifier: "en"))
            }
        }
    }
}
