import SwiftUI

/// The Learn tab: the subjunctive as a short course. One "up next" card says what to do; below it the lessons
/// run in order (the big rule first, then one lesson per family), each with a few steps: the rule, what to watch out for,
/// and the fine points. A step opens once the one it builds on has been answered right twice.
struct LearnView: View {
    private var progress: MoodMapProgress { .shared }
    @State private var round: MoodRoundSetup?

    private var steps: [MoodNode] { MoodMap.treeOrder }
    private var learned: Int { MoodMap.nodes.filter { progress.mastered($0.id) }.count }
    private var dueCount: Int { MoodMap.nodes.filter { progress.due($0.id) }.count }
    /// The first open step that isn't learned yet, in course order.
    private var next: MoodNode? { steps.first { progress.unlocked($0) && !progress.mastered($0.id) } }
    private var lessons: [MoodNode] { MoodMap.lessons }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Subjunctive").font(.title2.weight(.bold))
                    Text("When to use it, one step at a time").foregroundStyle(.secondary)
                    ProgressView(value: Double(learned), total: Double(MoodMap.nodes.count)).tint(.purple)
                    Text("\(learned) of \(MoodMap.nodes.count) steps learned").font(.footnote).foregroundStyle(.secondary)
                }

                upNext

                if dueCount > 0 {
                    Button { round = MoodRoundSetup(focus: nil) } label: {
                        Label("\(dueCount) to review", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.orange.opacity(0.15), in: Capsule())
                            .foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink { TriggerWordsView() } label: { triggerWordsRow }
                    .buttonStyle(.plain)

                Text("Lessons").font(.headline).padding(.top, 4)
                VStack(alignment: .leading, spacing: 10) {
                    if let root = MoodMap.byID["root"] { lessonLink(root) }
                    // The course in parts: each part is one kind of clause, with the big rule running through it
                    ForEach(Array(MoodMap.chapters.enumerated()), id: \.offset) { index, chapter in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Part \(index + 1): \(chapter.title)").font(.subheadline.weight(.semibold))
                            Text(chapter.note).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.top, 10)
                        ForEach(chapter.lessons.compactMap { MoodMap.byID[$0] }) { lessonLink($0) }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Learn")
        .fullScreenCover(item: $round) { MoodSessionView(setup: $0) }
    }

    private var upNext: some View {
        let step = next
        return VStack(alignment: .leading, spacing: 10) {
            Text(step == nil ? "All learned" : "Up next").font(.caption.weight(.semibold)).foregroundStyle(.purple).textCase(.uppercase)
            Text(step?.title ?? "Keep it fresh with a mixed round").font(.title3.weight(.semibold))
            if let step {
                Text(step.rule).font(.subheadline).foregroundStyle(.secondary).lineLimit(3)
            }
            Button { round = MoodRoundSetup(focus: step?.id) } label: {
                Text(step == nil ? "Practice" : "Start").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(Color.purple, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private func lessonLink(_ lesson: MoodNode) -> some View {
        NavigationLink { LessonView(lesson: lesson) } label: { lessonRow(lesson, number: lessons.firstIndex(of: lesson) ?? 0) }
            .buttonStyle(.plain)
            .disabled(!progress.unlocked(lesson))
    }

    /// The list of words that decide the mood, by what they do.
    private var triggerWordsRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "text.book.closed").font(.title3).foregroundStyle(.purple).frame(width: 36, height: 36)
                .background(Color.purple.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("Trigger words").font(.body.weight(.semibold))
                Text("\(MoodTriggers.all.count) words and phrases: which always take it, which only with no, which change meaning")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func lessonRow(_ lesson: MoodNode, number: Int) -> some View {
        let open = progress.unlocked(lesson)
        let parts = MoodMap.steps(of: lesson)
        let done = parts.filter { progress.mastered($0.id) }.count
        return HStack(spacing: 14) {
            ZStack {
                Circle().fill(done == parts.count ? Color.purple : Color.purple.opacity(open ? 0.15 : 0.06))
                if !open { Image(systemName: "lock.fill").font(.caption).foregroundStyle(.secondary) }
                else if done == parts.count { Image(systemName: "checkmark").font(.subheadline.weight(.bold)).foregroundStyle(.white) }
                else { Text(number == 0 ? "★" : "\(number)").font(.subheadline.weight(.semibold)).foregroundStyle(.purple) }
            }
            .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text(number == 0 ? "Start here: \(lesson.title.lowercased())" : MoodMap.title(of: lesson, progress: progress)).font(.body.weight(.semibold))
                    .foregroundStyle(open ? .primary : .secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(open ? "\(done) of \(parts.count) learned" : progress.waitsForImperfect(lesson) ? "Opens after the imperfect subjunctive" : "Opens after the big rule").font(.caption).foregroundStyle(.secondary)
                if open, parts.count > 1 {
                    HStack(spacing: 4) {
                        ForEach(parts) { part in
                            Capsule().fill(progress.mastered(part.id) ? Color.purple : progress.of(part.id).right > 0 ? Color.purple.opacity(0.45) : Color.secondary.opacity(0.2))
                                .frame(width: 18, height: 5)
                        }
                    }
                }
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .opacity(open ? 1 : 0.6)
        .accessibilityElement(children: .combine)
    }
}

/// One lesson: the rule in plain words, an example, and its steps in order, each with its own rule written out.
private struct LessonView: View {
    let lesson: MoodNode
    private var progress: MoodMapProgress { .shared }
    @State private var round: MoodRoundSetup?

    var body: some View {
        let parts = MoodMap.steps(of: lesson)
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(lesson.title).font(.title2.weight(.bold))
                Text(lesson.rule)
                Text(lesson.example).italic().foregroundStyle(.secondary)
                    .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                Button { round = MoodRoundSetup(focus: lesson.id, lesson: lesson.id) } label: {
                    Text("Practice this lesson").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(Color.purple, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(!progress.unlocked(lesson))
                // Read the rule, examples and what follows again, then practise the lesson's steps
                Button { round = MoodRoundSetup(focus: lesson.id, relearn: true, lesson: lesson.id) } label: {
                    Label("Re-learn this lesson", systemImage: "book").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(Color.purple.opacity(0.12), in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.purple)
                }
                .buttonStyle(.plain)
                .disabled(!progress.unlocked(lesson))

                if parts.count > 1 {
                    Text("Steps").font(.headline).padding(.top, 6)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(parts.enumerated()), id: \.element.id) { index, part in
                            stepRow(part, last: index == parts.count - 1)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $round) { MoodSessionView(setup: $0) }
    }

    /// A step on the lesson's path: a dot and a line down to the next step, then what the step says.
    private func stepRow(_ step: MoodNode, last: Bool) -> some View {
        let open = progress.unlocked(step)
        let stats = progress.of(step.id)
        let learned = progress.mastered(step.id)
        return HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(learned ? Color.purple : Color(.secondarySystemGroupedBackground))
                    Circle().strokeBorder(open ? Color.purple : Color.secondary.opacity(0.3), lineWidth: 2)
                    if learned { Image(systemName: "checkmark").font(.caption2.weight(.bold)).foregroundStyle(.white) }
                    else if !open { Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(.secondary) }
                }
                .frame(width: 24, height: 24)
                if !last { Rectangle().fill(Color.secondary.opacity(0.25)).frame(width: 2).frame(maxHeight: .infinity) }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(step.id == lesson.id ? "The rule" : step.levelName).font(.caption.weight(.semibold)).foregroundStyle(.purple).textCase(.uppercase)
                Text(MoodMap.title(of: step, progress: progress)).font(.body.weight(.semibold)).foregroundStyle(open ? .primary : .secondary)
                if open {
                    // The lesson's own rule is already at the top of the page
                    if step.id != lesson.id {
                        Text(step.rule).font(.subheadline).foregroundStyle(.secondary)
                        Text(step.example).font(.subheadline).italic().foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(learned ? "Learned" : "\(stats.right) of \(MoodMapProgress.needed) right").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        if step.id != lesson.id {
                            Button("Re-learn") { round = MoodRoundSetup(focus: step.id, relearn: true) }.font(.caption.weight(.semibold)).tint(.purple)
                            Button("Practice") { round = MoodRoundSetup(focus: step.id) }.font(.caption.weight(.semibold)).tint(.purple)
                        }
                    }
                } else {
                    Text(progress.waitsForImperfect(step) ? "Opens after “\(MoodMap.byID[MoodMap.imperfectIntro]?.title ?? "the imperfect subjunctive")”"
                         : "Opens after two right answers on “\(MoodMap.byID[step.parent ?? ""]?.title ?? "the step above")”").font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, last ? 0 : 22)
        }
    }
}

struct MoodRoundSetup: Identifiable {
    let id = UUID()
    let focus: String?
    /// Show the reading pages even when the step is already learned.
    var relearn = false
    /// Practise this lesson's steps rather than the focus and its neighbours.
    var lesson: String?
}

/// One round: choose, then say why, then read the rule. A missed card comes back later in the round.
struct MoodSessionView: View {
    let setup: MoodRoundSetup
    @Environment(\.dismiss) private var dismiss
    private var progress: MoodMapProgress { .shared }

    private enum Phase { case choose, why, explain }
    @State private var deck: [MoodItem] = []
    @State private var index = 0
    @State private var phase = Phase.choose
    @State private var picked: Int?
    @State private var reason: String?
    @State private var retried: Set<String> = []
    @State private var rightCount = 0
    /// Tenses introduced on the card on screen: shown with their explanation until the next card.
    @State private var newTenses: [MoodTenseInfo] = []
    /// The reading pages shown before the first card.
    @State private var briefing = false
    /// The cards worked through on the reading pages; the round leaves them out.
    @State private var workedCards: [MoodItem] = []

    private var item: MoodItem? { deck.indices.contains(index) ? deck[index] : nil }
    private var answeredRight: Bool { picked.map { item?.correct.contains($0) ?? false } ?? false }
    private var reasonRight: Bool {
        guard let item else { return false }
        return item.why.isEmpty ? reason == item.node : reason == "why\(item.whyRight)"
    }

    /// The reasons to choose from: the card's own, or the node and two neighbours. Each has an id and a title.
    private func reasonOptions(_ item: MoodItem) -> [(id: String, title: String)] {
        if !item.why.isEmpty { return item.why.enumerated().map { ("why\($0.offset)", $0.element) } }
        return MoodMap.reasons(for: item, hideImperfect: progress.hidesImperfect).map { ($0.id, $0.title) }
    }

    private func isRightReason(_ id: String, _ item: MoodItem) -> Bool {
        item.why.isEmpty ? id == item.node : id == "why\(item.whyRight)"
    }

    var body: some View {
        NavigationStack {
            Group {
                if briefing, let focus = setup.focus.flatMap({ MoodMap.byID[$0] }) {
                    MoodBriefingView(step: focus, progress: progress, cards: workedCards) { briefing = false }
                } else if let item { card(item) } else { finished }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }.accessibilityLabel("Close")
                }
                ToolbarItem(placement: .principal) {
                    Text(briefing ? "Read first" : deck.isEmpty ? "Learn" : "\(min(index + 1, deck.count)) of \(deck.count)").font(.headline)
                }
            }
        }
        .onAppear {
            if deck.isEmpty {
                // A step still being learned (or one chosen to re-learn) starts with its rules, examples and watch-outs
                briefing = setup.relearn || (setup.focus.map { !progress.mastered($0) } ?? false)
                if briefing, let step = setup.focus.flatMap({ MoodMap.byID[$0] }) { workedCards = MoodMap.workedExamples(for: step, progress: progress) }
                deck = MoodRound.make(focus: setup.focus, progress: progress, excluding: Set(workedCards.map(\.id)), lesson: setup.lesson)
            }
        }
        .task { await Task.detached(priority: .utility) { MoodTenseLabels.warmUp() }.value }
    }

    private func card(_ item: MoodItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let node = MoodMap.byID[item.node] {
                    Text(item.heading).font(.footnote.weight(.semibold)).foregroundStyle(.purple)
                    Text(item.context).font(.subheadline).foregroundStyle(.secondary)
                    Text(display(item)).font(.title3.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                    choices(item)
                    if phase != .choose, !newTenses.isEmpty { tenseIntro }
                    if phase != .choose { whyStep(item, node: node) }
                    if phase == .explain { explanation(item, node: node) }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// The sentence with the gap filled in once the learner has chosen.
    private func display(_ item: MoodItem) -> String {
        guard item.kind == .form, let picked, phase != .choose else { return item.prompt }
        let best = item.correct.contains(picked) ? picked : (item.correct.min() ?? picked)
        return item.prompt.replacingOccurrences(of: "___", with: item.choices[best])
    }

    private func choices(_ item: MoodItem) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(item.choices.enumerated()), id: \.offset) { i, choice in
                Button {
                    guard phase == .choose else { return }
                    picked = i
                    phase = .why
                    introduceTenses(item)
                } label: {
                    HStack {
                        // The tense of each choice, named once the learner has answered
                        Group {
                            if phase != .choose, item.kind == .form, let tense = MoodTenseLabels.info(for: choice, in: item) {
                                Text(choice) + Text("  (\(tense.name))").font(.subheadline).foregroundColor(.secondary)
                            } else {
                                Text(choice)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        if phase != .choose {
                            if item.correct.contains(i) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                            else if picked == i { Image(systemName: "xmark.circle.fill").foregroundStyle(.red) }
                        }
                    }
                    .padding(12)
                    .background(background(i, item), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func background(_ i: Int, _ item: MoodItem) -> Color {
        guard phase != .choose else { return Color(.secondarySystemBackground) }
        if item.correct.contains(i) { return Color.green.opacity(0.15) }
        if picked == i { return Color.red.opacity(0.15) }
        return Color(.secondarySystemBackground)
    }

    /// A tense the learner meets for the first time: what it means and where it is used.
    private var tenseIntro: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(newTenses) { tense in
                VStack(alignment: .leading, spacing: 4) {
                    Text("New tense: \(tense.name)").font(.subheadline.weight(.semibold)).foregroundStyle(.purple)
                    Text(tense.meaning).font(.subheadline)
                    Text(tense.uses).font(.footnote).foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func introduceTenses(_ item: MoodItem) {
        guard item.kind == .form else { newTenses = []; return }
        var seen = Set<String>()
        newTenses = item.choices.compactMap { MoodTenseLabels.info(for: $0, in: item) }
            .filter { !progress.seenTenses.contains($0.id) && seen.insert($0.id).inserted }
        progress.markSeen(newTenses.map(\.id))
    }

    private func whyStep(_ item: MoodItem, node: MoodNode) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(answeredRight ? (item.bothWork ? "Right, and more than one works." : "Right.") : "Not this time.")
                .font(.headline).foregroundStyle(answeredRight ? .green : .red)
            Text("Why?").font(.subheadline.weight(.semibold))
            ForEach(reasonOptions(item), id: \.id) { option in
                Button {
                    guard phase == .why else { return }
                    reason = option.id
                    finish(item)
                } label: {
                    HStack {
                        Text(option.title).frame(maxWidth: .infinity, alignment: .leading)
                        if phase == .explain {
                            if isRightReason(option.id, item) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                            else if reason == option.id { Image(systemName: "xmark.circle.fill").foregroundStyle(.red) }
                        }
                    }
                    .padding(10)
                    .background(phase == .explain && isRightReason(option.id, item) ? Color.green.opacity(0.15) : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func explanation(_ item: MoodItem, node: MoodNode) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.note)
            verbBreakdown(display(item), title: "The verbs")
            if let changed = MoodTenseLabels.changed(item) { verbBreakdown(changed, title: "After the change: \(changed)") }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(node.levelName): \(node.title)").font(.footnote.weight(.semibold))
                Text(node.rule).font(.footnote)
                Text(node.example).font(.footnote).italic().foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            Button { next() } label: {
                Text(index + 1 < deck.count ? "Next" : "Finish").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(Color.purple, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
    }

    /// Each verb of the sentence with its tense, and why the subjunctive is in that tense: "dijo is past, so viniera is too".
    @ViewBuilder private func verbBreakdown(_ sentence: String, title: String) -> some View {
        let verbs = MoodTenseLabels.verbs(in: sentence)
        let usage = MoodTenseLabels.usage(in: sentence, pastKnown: !progress.hidesImperfect)
        if !verbs.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.footnote.weight(.semibold))
                ForEach(verbs, id: \.self) { verb in
                    (Text(verb.word).bold().foregroundColor(verb.isSubjunctive ? .purple : .primary)
                     + Text(verb.word == verb.verb ? "" : " · \(verb.verbLabel)")
                     + Text(" · \(verb.tense.name)").foregroundColor(.secondary)
                     + Text(verb.persons.isEmpty ? "" : " (\(verb.personText))").foregroundColor(.secondary))
                        .font(.footnote)
                }
                ForEach(usage, id: \.self) { line in
                    Text(line).font(.footnote).fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func finish(_ item: MoodItem) {
        phase = .explain
        let right = answeredRight && reasonRight
        // Only the first try counts toward the node; a miss comes back later in the round
        if !retried.contains(item.id) {
            progress.record(item.node, right: right)
            if right { rightCount += 1 }
        }
        if !right {
            retried.insert(item.id)
            let at = Int.random(in: min(index + 3, deck.count)...deck.count)
            deck.insert(item, at: at)
        }
    }

    private func next() {
        index += 1
        phase = .choose
        picked = nil
        reason = nil
        newTenses = []
    }

    private var finished: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 48)).foregroundStyle(.purple)
            Text("Round done").font(.title2.weight(.semibold))
            Text("\(rightCount) right on the first try, with the reason.").foregroundStyle(.secondary)
            Button("Done") { dismiss() }.buttonStyle(.borderedProminent).tint(.purple)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


/// What to read before practising a step, one page at a time: the rule with its idea and examples, worked cards, then the
/// rule it qualifies, its watch-outs and fine points, and the rules mixed into the round. Continue unlocks after a short
/// reading time, so the page gets read rather than tapped past.
struct MoodBriefingView: View {
    let step: MoodNode
    let progress: MoodMapProgress
    /// Cards worked through here; the round that follows leaves them out, so the exercises are new sentences.
    let cards: [MoodItem]
    let onDone: () -> Void
    @State private var page = 0
    @State private var ready = false
    @State private var fill: CGFloat = 0
    /// How long the Continue bar takes to fill; the animation is on the bar alone, so nothing else on screen moves with it.
    @State private var fillSeconds: Double = 3

    /// Before the imperfect lesson, nothing with an imperfect subjunctive is shown.
    private var hides: Bool { progress.hidesImperfect && !MoodMap.imperfectSteps.contains(step.id) }
    private func ok(_ text: String) -> Bool { !hides || !MoodMap.mentionsImperfect(text) }

    private struct Section: Identifiable { let id: String; let title: String; let body: String; let example: String?; let note: String? }

    private var examples: [(spanish: String, english: String)] {
        (MoodMap.briefings[step.id]?.examples ?? []).filter { ok($0.spanish) }
    }

    /// Cards from the step with the right answer in place, why it's right, and how the tense is chosen.
    private var worked: [(context: String, sentence: String, english: String?, why: String, tense: String?)] {
        cards.compactMap { item in
            guard let right = item.correct.min() else { return nil }
            let sentence: String
            var english: String?
            switch item.kind {
            case .form: sentence = item.prompt.replacingOccurrences(of: "___", with: item.choices[right])
            case .meaning: sentence = item.prompt; english = item.choices[right]
            case .flip: sentence = MoodTenseLabels.changed(item) ?? item.prompt
            }
            guard ok(sentence), ok(item.note), ok(item.context) else { return nil }
            let tense = MoodTenseLabels.usage(in: sentence, pastKnown: !progress.hidesImperfect).first { ok($0) }
            return (item.context, sentence, english, item.note, tense)
        }
    }

    /// The rule this step qualifies, its own watch-outs and fine points, and the rules practised next to it.
    private var related: [Section] {
        var out: [Section] = []
        if step.level > 2, let parent = step.parent.flatMap({ MoodMap.byID[$0] }) {
            out.append(Section(id: "p" + parent.id, title: "It refines: \(MoodMap.title(of: parent, progress: progress))",
                               body: ok(parent.rule) ? parent.rule : "", example: ok(parent.example) ? parent.example : nil, note: nil))
        }
        let children = MoodMap.children(of: step.id).sorted(by: { $0.level < $1.level })
        for child in children.prefix(5) {
            let open = progress.unlocked(child)
            let waits = progress.waitsForImperfect(child)
            out.append(Section(id: "c" + child.id, title: "\(child.levelName): \(MoodMap.title(of: child, progress: progress))",
                               body: !waits && ok(child.rule) ? child.rule : "", example: !waits && ok(child.example) ? child.example : nil,
                               note: open ? nil : "You'll practise this later, once this step is going well."))
        }
        if children.count > 5 {
            out.append(Section(id: "more", title: "And \(children.count - 5) more lessons", body: "Each one takes this rule to a new kind of sentence.", example: nil, note: nil))
        }
        let siblings = MoodMap.nodes.filter { $0.parent == step.parent && $0.id != step.id && progress.unlocked($0) && !progress.mastered($0.id) }
        for sibling in siblings.prefix(3) where ok(sibling.title) {
            out.append(Section(id: "s" + sibling.id, title: "Also in this round: \(sibling.title)",
                               body: ok(sibling.rule) ? sibling.rule : "", example: ok(sibling.example) ? sibling.example : nil,
                               note: "It's mixed in so you learn to tell the two apart."))
        }
        return out
    }

    private var pages: Int { related.isEmpty ? 2 : 3 }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Step \(page + 1) of \(pages)").font(.caption.weight(.semibold)).foregroundStyle(.purple).textCase(.uppercase)
                    switch page {
                    case 0: rulePage
                    case 1: workedPage
                    default: relatedPage
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            continueButton.padding(.top, 8)
        }
        .onAppear(perform: startReading)
        .onChange(of: page) { startReading() }
    }

    private var rulePage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(step.levelName).font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
            Text(MoodMap.title(of: step, progress: progress)).font(.title2.weight(.bold))
            if ok(step.rule) { Text(step.rule).font(.body) }
            if let why = MoodMap.briefings[step.id]?.why, ok(why) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Why").font(.subheadline.weight(.semibold))
                    Text(why).font(.subheadline)
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.purple.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            }
            Text("Examples").font(.subheadline.weight(.semibold))
            if examples.isEmpty, ok(step.example) {
                Text(step.example).italic()
            }
            ForEach(Array(examples.enumerated()), id: \.offset) { _, example in
                VStack(alignment: .leading, spacing: 2) {
                    Text(example.spanish).font(.body.weight(.medium))
                    Text(example.english).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private var workedPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Worked examples").font(.title3.weight(.bold))
            Text(worked.isEmpty ? "No worked examples here: the exercises start next." : "Each one with the answer in place and why it's right. The exercises that follow use different sentences.").font(.subheadline).foregroundStyle(.secondary)
            ForEach(Array(worked.enumerated()), id: \.offset) { _, card in
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.context).font(.caption).foregroundStyle(.secondary)
                    Text(card.sentence).font(.title3.weight(.medium))
                    if let english = card.english { Text(english).font(.subheadline).foregroundStyle(.secondary) }
                    Text(card.why).font(.subheadline)
                    if let tense = card.tense { Text(tense).font(.footnote).foregroundStyle(.secondary) }
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var relatedPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(step.level <= 2 ? "What this leads to" : "Watch-outs and related rules").font(.title3.weight(.bold))
            Text(step.level <= 2
                 ? "This rule has more nuance than one page can hold: special cases, exceptions and words that bend it. We start with the big picture first, so the main idea sticks before the details pile on. Here's a preview of what builds on it. You don't need any of it yet: each one opens as you go, with its own reading pages like these."
                 : "Rules in Spanish come in layers: a general rule first, then the cases that bend it. Here's the rule this step refines, the finer points that come after it, and any rules mixed into this round so you learn to tell them apart. You don't need the finer points yet: each one opens later with its own reading pages.")
                .font(.subheadline).foregroundStyle(.secondary)
            ForEach(related) { section in
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.title).font(.subheadline.weight(.semibold))
                    if !section.body.isEmpty { Text(section.body).font(.subheadline) }
                    if let example = section.example { Text(example).font(.subheadline).italic().foregroundStyle(.secondary) }
                    if let note = section.note { Text(note).font(.caption).foregroundStyle(.secondary) }
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var continueButton: some View {
        Button {
            guard ready else { return }
            if page + 1 < pages { page += 1 } else { onDone() }
        } label: {
            ZStack(alignment: .leading) {
                GeometryReader { geo in
                    Rectangle().fill(Color.purple).frame(width: geo.size.width * fill)
                        .animation(fill == 0 ? nil : .linear(duration: fillSeconds), value: fill)
                }
                Text(page + 1 < pages ? "Continue" : "Start practice").font(.headline)
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                    .foregroundStyle(.white)
            }
            .frame(height: 46)
            .background(Color.purple.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .accessibilityHint(ready ? "" : "Available after a moment to read")
    }

    /// About four words a second, between three and twelve seconds a page.
    private var readingSeconds: Double {
        var words = 0
        func count(_ text: String) { words += text.split(separator: " ").count }
        switch page {
        case 0:
            count(step.rule); count(MoodMap.briefings[step.id]?.why ?? "")
            examples.forEach { count($0.spanish); count($0.english) }
        case 1: worked.forEach { count($0.sentence); count($0.why) }
        default: related.forEach { count($0.body); count($0.example ?? "") }
        }
        return min(12, max(3, Double(words) / 4))
    }

    private func startReading() {
        ready = false
        fill = 0
        let seconds = readingSeconds
        fillSeconds = seconds
        // Start the fill on the next pass, so the bar animates from empty without animating the page around it
        DispatchQueue.main.async { fill = 1 }
        let shown = page
        Task {
            try? await Task.sleep(for: .seconds(seconds))
            if page == shown { ready = true }
        }
    }
}
