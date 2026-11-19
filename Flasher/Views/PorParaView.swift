import SwiftUI

/// The Learn tab's first page: pick a guide.
struct LearnHomeView: View {
    private var mood: MoodMapProgress { .shared }
    private var porPara: PorParaProgress { .shared }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Pick a guide. Each one starts with one big idea, then takes it apart one step at a time.")
                    .foregroundStyle(.secondary)
                NavigationLink { LearnView() } label: {
                    guideRow(title: "Subjunctive", subtitle: "When to use it: is anyone claiming it's true?", icon: "quote.bubble",
                             tint: .purple, learned: MoodMap.nodes.filter { mood.mastered($0.id) }.count, total: MoodMap.nodes.count)
                }
                .buttonStyle(.plain)
                NavigationLink { PorParaView() } label: {
                    guideRow(title: "Por vs para", subtitle: "Para: where it ends up. Por: what drives it, or what it passes through.", icon: "arrow.triangle.branch",
                             tint: .teal, learned: PorParaCourse.steps.filter { porPara.mastered($0.id) }.count, total: PorParaCourse.steps.count)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Learn")
    }

    private func guideRow(title: String, subtitle: String, icon: String, tint: Color, learned: Int, total: Int) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).font(.title2).foregroundStyle(tint).frame(width: 48, height: 48)
                .background(tint.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(title).font(.title3.weight(.semibold))
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                ProgressView(value: Double(learned), total: Double(max(total, 1))).tint(tint)
                Text("\(learned) of \(total) steps learned").font(.caption).foregroundStyle(.secondary)
            }
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
        .accessibilityElement(children: .combine)
    }
}

/// Progress on the por/para course: the same rules as the subjunctive course (three right with the reason masters a step,
/// two open what builds on it, reviews after 1, 3, 7 and 14 days), stored separately.
@Observable
final class PorParaProgress {
    static let shared = PorParaProgress(defaults: .standard)
    static let needed = 3
    static let opensChildren = 2
    private static let reviewDays = [1, 3, 7, 14]

    private let defaults: UserDefaults
    private let key = "porParaProgress"
    private(set) var stats: [String: MoodMapProgress.Stats] = [:]

    init(defaults: UserDefaults) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key), let saved = try? JSONDecoder().decode([String: MoodMapProgress.Stats].self, from: data) { stats = saved }
    }

    func of(_ step: String) -> MoodMapProgress.Stats { stats[step] ?? .init() }
    func mastered(_ step: String) -> Bool { of(step).right >= Self.needed }
    func unlocked(_ step: PorParaStep) -> Bool {
        guard let parent = step.parent else { return true }
        return of(parent).right >= Self.opensChildren
    }

    func due(_ step: String, now: Date = .now) -> Bool {
        let s = of(step)
        guard s.right >= Self.needed, let last = s.last else { return false }
        let days = Self.reviewDays[min(s.reviews, Self.reviewDays.count - 1)]
        return now.timeIntervalSince(last) >= Double(days) * 86_400
    }

    func record(_ step: String, right: Bool, now: Date = .now) {
        var s = of(step)
        if right {
            if s.right >= Self.needed { s.reviews += 1 }
            s.right += 1
        } else {
            s.wrong += 1
            s.reviews = max(0, s.reviews - 1)
        }
        s.last = now
        stats[step] = s
        if let data = try? JSONEncoder().encode(stats) { defaults.set(data, forKey: key) }
    }
}

/// A round of up to ten cards: the step or lesson in focus (at least six), then review of steps already practised.
enum PorParaRound {
    static let size = 10

    static func make(focus: String?, lesson: String? = nil, progress: PorParaProgress) -> [PorParaCard] {
        let related: [String]
        if let lesson, let node = PorParaCourse.byID[lesson] {
            related = PorParaCourse.steps(of: node).filter { progress.unlocked($0) }.map(\.id)
        } else if let focus {
            related = [focus]
        } else {
            let open = PorParaCourse.steps.filter { progress.unlocked($0) }
            let learning = open.filter { !progress.mastered($0.id) || progress.due($0.id) }
            related = (learning.isEmpty ? open : learning).map(\.id)
        }
        var perStep = related.map { PorParaCourse.cards(for: $0).shuffled() }
        var mine: [PorParaCard] = []
        let target = focus == nil && lesson == nil ? size : 6
        while mine.count < target, perStep.contains(where: { !$0.isEmpty }) {
            for i in perStep.indices where mine.count < target && !perStep[i].isEmpty { mine.append(perStep[i].removeFirst()) }
        }
        let reviewSteps = PorParaCourse.steps.filter { !related.contains($0.id) && progress.of($0.id).right > 0 && progress.unlocked($0) }
            .sorted { (progress.due($0.id) ? 0 : 1) < (progress.due($1.id) ? 0 : 1) }
        var review: [PorParaCard] = []
        for step in reviewSteps where review.count < min(size - mine.count, mine.count) {
            if let card = PorParaCourse.cards(for: step.id).randomElement() { review.append(card) }
        }
        var deck = interleave((mine + review).shuffled())
        if let first = deck.firstIndex(where: { related.contains($0.step) }), first > 0 { deck.insert(deck.remove(at: first), at: 0) }
        return deck
    }

    static func interleave(_ cards: [PorParaCard]) -> [PorParaCard] {
        var pool = cards
        var out: [PorParaCard] = []
        while !pool.isEmpty {
            let index = pool.firstIndex { $0.step != out.last?.step } ?? 0
            out.append(pool.remove(at: index))
        }
        return out
    }
}

private let teal = Color.teal

struct PorParaRoundSetup: Identifiable {
    let id = UUID()
    let focus: String?
    var relearn = false
    var lesson: String?
}

/// The por/para guide: the simple rules, where they come from, then the lessons in four parts.
struct PorParaView: View {
    private var progress: PorParaProgress { .shared }
    @State private var round: PorParaRoundSetup?

    private var steps: [PorParaStep] { PorParaCourse.lessons.flatMap { PorParaCourse.steps(of: $0) } }
    private var learned: Int { PorParaCourse.steps.filter { progress.mastered($0.id) }.count }
    private var dueCount: Int { PorParaCourse.steps.filter { progress.due($0.id) }.count }
    private var next: PorParaStep? { steps.first { progress.unlocked($0) && !progress.mastered($0.id) } }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Por vs para").font(.title2.weight(.bold))
                    Text("Two simple rules, a few phrases to memorise").foregroundStyle(.secondary)
                    ProgressView(value: Double(learned), total: Double(PorParaCourse.steps.count)).tint(teal)
                    Text("\(learned) of \(PorParaCourse.steps.count) steps learned").font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("The simple rules").font(.caption.weight(.semibold)).foregroundStyle(teal).textCase(.uppercase)
                    Text("**Para → where it ends up.** The five P's: the Place it's headed, the Person who gets it, the Point in time it's due, the Purpose, the Perspective it's judged from.")
                        .font(.subheadline)
                    Text("**Por → what drives it, or what it passes through.** The reason, the thing you're after, someone you do it for, the route, the means, the price, the time.")
                        .font(.subheadline)
                    Text("**Reason or purpose?** Already there and pushing: por. Not yet, what you're aiming to produce: para.")
                        .font(.subheadline)
                    Text("**Memorise:** para siempre, para nada, no es para tanto.").font(.subheadline)
                }
                .padding(16).frame(maxWidth: .infinity, alignment: .leading)
                .background(teal.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))

                upNext

                if dueCount > 0 {
                    Button { round = PorParaRoundSetup(focus: nil) } label: {
                        Label("\(dueCount) to review", systemImage: "arrow.clockwise")
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .background(Color.orange.opacity(0.15), in: Capsule()).foregroundStyle(.orange)
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink { PorParaCheckView() } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "text.magnifyingglass").font(.title3).foregroundStyle(teal).frame(width: 36, height: 36)
                            .background(teal.opacity(0.12), in: Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Check a sentence").font(.body.weight(.semibold))
                            Text("Type your Spanish and see which one the rules pick, and why").font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
                    }
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    .accessibilityElement(children: .combine)
                }
                .buttonStyle(.plain)
                NavigationLink { PorParaSourcesView() } label: { sourcesRow }.buttonStyle(.plain)

                Text("Lessons").font(.headline).padding(.top, 4)
                VStack(alignment: .leading, spacing: 10) {
                    if let root = PorParaCourse.byID["root"] { lessonLink(root, number: 0) }
                    ForEach(Array(PorParaCourse.chapters.enumerated()), id: \.offset) { index, chapter in
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Part \(index + 1): \(chapter.title)").font(.subheadline.weight(.semibold))
                            Text(chapter.note).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.top, 10)
                        ForEach(chapter.lessons.compactMap { PorParaCourse.byID[$0] }) { lesson in
                            lessonLink(lesson, number: PorParaCourse.lessons.firstIndex(of: lesson) ?? 0)
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Por vs para")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $round) { PorParaSessionView(setup: $0) }
    }

    private var upNext: some View {
        let step = next
        return VStack(alignment: .leading, spacing: 10) {
            Text(step == nil ? "All learned" : "Up next").font(.caption.weight(.semibold)).foregroundStyle(teal).textCase(.uppercase)
            Text(step?.title ?? "Keep it fresh with a mixed round").font(.title3.weight(.semibold))
            if let step, step.level > 1 { Text(step.rule).font(.subheadline).foregroundStyle(.secondary).lineLimit(3) }
            Button { round = PorParaRoundSetup(focus: step?.id) } label: {
                Text(step == nil ? "Practice" : "Start").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(teal, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
            }
            .buttonStyle(.plain).padding(.top, 4)
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 18))
    }

    private var sourcesRow: some View {
        HStack(spacing: 14) {
            Image(systemName: "books.vertical").font(.title3).foregroundStyle(teal).frame(width: 36, height: 36)
                .background(teal.opacity(0.12), in: Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("Where the idea comes from").font(.body.weight(.semibold))
                Text("The history of por and para, and the grammars behind the rules").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }

    private func lessonLink(_ lesson: PorParaStep, number: Int) -> some View {
        let open = progress.unlocked(lesson)
        let parts = PorParaCourse.steps(of: lesson)
        let done = parts.filter { progress.mastered($0.id) }.count
        return NavigationLink { PorParaLessonView(lesson: lesson) } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(done == parts.count ? teal : teal.opacity(open ? 0.15 : 0.06))
                    if !open { Image(systemName: "lock.fill").font(.caption).foregroundStyle(.secondary) }
                    else if done == parts.count { Image(systemName: "checkmark").font(.subheadline.weight(.bold)).foregroundStyle(.white) }
                    else { Text(number == 0 ? "★" : "\(number)").font(.subheadline.weight(.semibold)).foregroundStyle(teal) }
                }
                .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text(number == 0 ? "Start here: the simple rules" : lesson.title).font(.body.weight(.semibold))
                        .foregroundStyle(open ? .primary : .secondary).frame(maxWidth: .infinity, alignment: .leading)
                    Text(open ? "\(done) of \(parts.count) learned" : "Opens after the simple rules").font(.caption).foregroundStyle(.secondary)
                    if open, parts.count > 1 {
                        HStack(spacing: 4) {
                            ForEach(parts) { part in
                                Capsule().fill(progress.mastered(part.id) ? teal : progress.of(part.id).right > 0 ? teal.opacity(0.45) : Color.secondary.opacity(0.2))
                                    .frame(width: 18, height: 5)
                            }
                        }
                    }
                }
                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .opacity(open ? 1 : 0.6)
            .accessibilityElement(children: .combine)
        }
        .buttonStyle(.plain)
        .disabled(!open)
    }
}

/// One lesson: its rule, why, examples and source, then its steps in order.
private struct PorParaLessonView: View {
    let lesson: PorParaStep
    private var progress: PorParaProgress { .shared }
    @State private var round: PorParaRoundSetup?

    var body: some View {
        let parts = PorParaCourse.steps(of: lesson)
        let started = parts.contains { progress.of($0.id).right + progress.of($0.id).wrong > 0 }
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(lesson.title).font(.title2.weight(.bold))
                Text(lesson.rule)
                if let example = lesson.examples.first {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(example.spanish).italic()
                        Text(example.english).font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                    .background(teal.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                }
                Text("Source: \(lesson.source)").font(.caption).foregroundStyle(.secondary)
                Button { round = PorParaRoundSetup(focus: lesson.id, lesson: lesson.id) } label: {
                    Text(started ? "Practice this lesson" : "Learn this lesson").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                        .background(teal, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                if started {
                    Button { round = PorParaRoundSetup(focus: lesson.id, relearn: true, lesson: lesson.id) } label: {
                        Label("Re-learn this lesson", systemImage: "book").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(teal.opacity(0.12), in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(teal)
                    }
                    .buttonStyle(.plain)
                }
                if parts.count > 1 {
                    Text("Steps").font(.headline).padding(.top, 6)
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(parts.enumerated()), id: \.element.id) { index, part in stepRow(part, last: index == parts.count - 1) }
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $round) { PorParaSessionView(setup: $0) }
    }

    private func stepRow(_ step: PorParaStep, last: Bool) -> some View {
        let open = progress.unlocked(step)
        let stats = progress.of(step.id)
        let learned = progress.mastered(step.id)
        return HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(learned ? teal : Color(.secondarySystemGroupedBackground))
                    Circle().strokeBorder(open ? teal : Color.secondary.opacity(0.3), lineWidth: 2)
                    if learned { Image(systemName: "checkmark").font(.caption2.weight(.bold)).foregroundStyle(.white) }
                    else if !open { Image(systemName: "lock.fill").font(.system(size: 9)).foregroundStyle(.secondary) }
                }
                .frame(width: 24, height: 24)
                if !last { Rectangle().fill(Color.secondary.opacity(0.25)).frame(width: 2).frame(maxHeight: .infinity) }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(step.id == lesson.id ? "The rule" : step.levelName).font(.caption.weight(.semibold)).foregroundStyle(teal).textCase(.uppercase)
                Text(step.title).font(.body.weight(.semibold)).foregroundStyle(open ? .primary : .secondary)
                if open {
                    if step.id != lesson.id {
                        Text(step.rule).font(.subheadline).foregroundStyle(.secondary)
                        if let example = step.examples.first { Text(example.spanish).font(.subheadline).italic().foregroundStyle(.secondary) }
                    }
                    HStack {
                        Text(learned ? "Learned" : "\(stats.right) of \(PorParaProgress.needed) right").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        if step.id != lesson.id {
                            if stats.right + stats.wrong > 0 {
                                Button("Re-learn") { round = PorParaRoundSetup(focus: step.id, relearn: true) }.font(.caption.weight(.semibold)).tint(teal)
                                Button("Practice") { round = PorParaRoundSetup(focus: step.id) }.font(.caption.weight(.semibold)).tint(teal)
                            } else {
                                Button("Learn") { round = PorParaRoundSetup(focus: step.id) }.font(.caption.weight(.semibold)).tint(teal)
                            }
                        }
                    }
                } else {
                    Text("Opens after two right answers on “\(PorParaCourse.byID[step.parent ?? ""]?.title ?? "the step above")”").font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, last ? 0 : 22)
        }
    }
}

/// One round: read the step first if it's new, then choose, then say why, then read the explanation.
struct PorParaSessionView: View {
    let setup: PorParaRoundSetup
    @Environment(\.dismiss) private var dismiss
    private var progress: PorParaProgress { .shared }

    private enum Phase { case choose, why, explain }
    @State private var deck: [PorParaCard] = []
    @State private var index = 0
    @State private var phase = Phase.choose
    @State private var picked: Int?
    @State private var reason: String?
    @State private var retried: Set<String> = []
    @State private var rightCount = 0
    @State private var briefing = false

    private var card: PorParaCard? { deck.indices.contains(index) ? deck[index] : nil }
    private var answeredRight: Bool { picked.map { card?.correct.contains($0) ?? false } ?? false }
    private func isRightReason(_ id: String, _ card: PorParaCard) -> Bool { card.why.isEmpty ? id == card.step : id == "why\(card.whyRight)" }

    var body: some View {
        NavigationStack {
            Group {
                if briefing, let step = setup.focus.flatMap({ PorParaCourse.byID[$0] }) {
                    PorParaBriefingView(step: step) { briefing = false }
                } else if let card { cardView(card) } else { finished }
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
            guard deck.isEmpty else { return }
            briefing = setup.relearn || (setup.focus.map { !progress.mastered($0) && progress.of($0).right + progress.of($0).wrong == 0 } ?? false)
            deck = PorParaRound.make(focus: setup.focus, lesson: setup.lesson, progress: progress)
        }
    }

    private func cardView(_ card: PorParaCard) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {
                    Text(card.bothWork ? "Fill the gap (more than one can work)" : "Fill the gap").font(.footnote.weight(.semibold)).foregroundStyle(teal)
                    if let focus = setup.focus, card.step != focus, !(PorParaCourse.byID[setup.lesson ?? ""].map { PorParaCourse.steps(of: $0).map(\.id).contains(card.step) } ?? false) {
                        Text("Review").font(.caption2.weight(.bold)).textCase(.uppercase)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.orange.opacity(0.18), in: Capsule()).foregroundStyle(.orange)
                    }
                }
                Text(card.context).font(.subheadline).foregroundStyle(.secondary)
                Text(display(card)).font(.title3.weight(.medium)).fixedSize(horizontal: false, vertical: true)
                choices(card)
                if phase != .choose { whyStep(card) }
                if phase == .explain { explanation(card) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func display(_ card: PorParaCard) -> String {
        guard let picked, phase != .choose else { return card.sentence }
        return card.filled(card.correct.contains(picked) ? picked : (card.correct.min() ?? picked))
    }

    private func choices(_ card: PorParaCard) -> some View {
        HStack(spacing: 10) {
            ForEach(Array(card.choices.enumerated()), id: \.offset) { i, choice in
                Button {
                    guard phase == .choose else { return }
                    picked = i
                    phase = .why
                } label: {
                    HStack(spacing: 6) {
                        Text(choice == PorParaCourse.nothing ? "nothing" : choice).font(.headline)
                        if phase != .choose {
                            if card.correct.contains(i) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                            else if picked == i { Image(systemName: "xmark.circle.fill").foregroundStyle(.red) }
                        }
                    }
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(background(i, card), in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func background(_ i: Int, _ card: PorParaCard) -> Color {
        guard phase != .choose else { return Color(.secondarySystemBackground) }
        if card.correct.contains(i) { return Color.green.opacity(0.15) }
        if picked == i { return Color.red.opacity(0.15) }
        return Color(.secondarySystemBackground)
    }

    private func whyStep(_ card: PorParaCard) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(answeredRight ? (card.bothWork ? "Right, and more than one works." : "Right.") : "Not this time.")
                .font(.headline).foregroundStyle(answeredRight ? .green : .red)
            Text("Why?").font(.subheadline.weight(.semibold))
            ForEach(PorParaCourse.reasons(for: card), id: \.id) { option in
                Button {
                    guard phase == .why else { return }
                    reason = option.id
                    finish(card)
                } label: {
                    HStack {
                        Text(option.title).frame(maxWidth: .infinity, alignment: .leading)
                        if phase == .explain {
                            if isRightReason(option.id, card) { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                            else if reason == option.id { Image(systemName: "xmark.circle.fill").foregroundStyle(.red) }
                        }
                    }
                    .padding(10)
                    .background(phase == .explain && isRightReason(option.id, card) ? Color.green.opacity(0.15) : Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func explanation(_ card: PorParaCard) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(card.note)
            if let step = PorParaCourse.byID[card.step] {
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.level == 1 ? step.title : "\(step.levelName): \(step.title)").font(.footnote.weight(.semibold))
                    Text(step.rule).font(.footnote)
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(teal.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            }
            Button { next() } label: {
                Text(index + 1 < deck.count ? "Next" : "Finish").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(teal, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
    }

    private func finish(_ card: PorParaCard) {
        phase = .explain
        let right = answeredRight && reason.map { isRightReason($0, card) } == true
        if !retried.contains(card.id) {
            progress.record(card.step, right: right)
            if right { rightCount += 1 }
        }
        if !right {
            retried.insert(card.id)
            deck.insert(card, at: Int.random(in: min(index + 3, deck.count)...deck.count))
        }
    }

    private func next() {
        index += 1
        phase = .choose
        picked = nil
        reason = nil
    }

    private var finished: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill").font(.system(size: 48)).foregroundStyle(teal)
            Text("Round done").font(.title2.weight(.semibold))
            Text("\(rightCount) right on the first try, with the reason.").foregroundStyle(.secondary)
            Button("Done") { dismiss() }.buttonStyle(.borderedProminent).tint(teal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// What to read before practising a step: the rule, why, examples and source; then where it sits (the rule it
/// refines, or for a lesson, its watch-outs).
private struct PorParaBriefingView: View {
    let step: PorParaStep
    let onDone: () -> Void
    @State private var page = 0

    private var related: [PorParaStep] {
        var out: [PorParaStep] = []
        if step.level > 2, let parent = step.parent.flatMap({ PorParaCourse.byID[$0] }) { out.append(parent) }
        out += step.id == "root" ? PorParaCourse.lessons.filter { $0.id != "root" } : PorParaCourse.children(of: step.id)
        return out
    }
    private var pages: Int { related.isEmpty ? 1 : 2 }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Step \(page + 1) of \(pages)").font(.caption.weight(.semibold)).foregroundStyle(teal).textCase(.uppercase)
                    if page == 0 { rulePage } else { relatedPage }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button { if page + 1 < pages { page += 1 } else { onDone() } } label: {
                Text(page + 1 < pages ? "Continue" : "Start practice").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                    .background(teal, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
            }
            .buttonStyle(.plain).padding(.top, 8)
        }
    }

    private var rulePage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(step.levelName).font(.footnote.weight(.semibold)).foregroundStyle(.secondary)
            Text(step.title).font(.title2.weight(.bold))
            Text(step.rule)
            VStack(alignment: .leading, spacing: 6) {
                Text("Why").font(.subheadline.weight(.semibold))
                Text(step.why).font(.subheadline)
            }
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(teal.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            Text("Examples").font(.subheadline.weight(.semibold))
            ForEach(step.examples, id: \.self) { example in
                VStack(alignment: .leading, spacing: 2) {
                    Text(example.spanish).font(.body.weight(.medium))
                    Text(example.english).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
            }
            Text("Source: \(step.source)").font(.caption).foregroundStyle(.secondary)
        }
    }

    private var relatedPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(step.id == "root" ? "What comes next" : step.level <= 2 ? "Watch-outs" : "Where this fits").font(.title3.weight(.bold))
            Text(step.id == "root"
                 ? "The lessons take each line of the rules in turn: the five P's for para, then what drives it and what it passes through for por, then the few things the rules don't cover. Each opens once the rules are going well."
                 : step.level <= 2 ? "The cases that bend this rule. Each opens later with its own reading pages." : "The rule this step refines.")
                .font(.subheadline).foregroundStyle(.secondary)
            ForEach(related) { other in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(other.levelName): \(other.title)").font(.subheadline.weight(.semibold))
                    Text(other.rule).font(.subheadline)
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

/// The history of por and para, and where each idea in the guide comes from.
struct PorParaSourcesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Where the idea comes from").font(.title2.weight(.bold))

                section("The simple rules", """
                No grammar puts por and para in two lines. The rules this guide uses (para: where it ends up; por: what drives it, or what it passes through) \
                is this app's summary of three ideas that agree with each other, and of the history below. In a blind test on 500 real \
                sentences, a reader using only these rules got about 95% right. The lessons teach the few cases they miss.
                """)

                section("A short history", """
                Latin had two words: per ("through, by means of") and pro ("in front of, on behalf of, in exchange for"). In Old \
                Spanish they merged into one word, por, which carried all of those meanings, and also purpose.

                In the 1200s Spanish made a new word by joining that preposition with a ("to"): pora, which became para. It started \
                out marking destinations: where a trip was headed, who something was going to.

                Para then took over more of por's ground. Purpose before a verb (para comer, "in order to eat") was mostly por in \
                medieval Spanish; para took it over gradually, above all from the 1700s on.

                That history explains the exceptions. Por's older senses never left: going after something (voy por pan), for \
                someone's sake (lo hice por ti), in exchange for (por 200 pesos), and purpose before a verb, where por still \
                works (lo hice por ayudarte).
                """)

                section("Other languages", """
                Portuguese made the same split (por and para), and moved purpose over to para too, apparently a little earlier. Catalan has per \
                and per a, but in most of Catalonia people now say per for both. Italian and French never split: Italian per and \
                French pour cover destination, purpose, price and cause alike. So the split is Spanish and Portuguese, and it's \
                still settling.
                """)

                section("The three ideas behind the rules", """
                • Nicole Delbecque (cognitive grammar, 1996): por is in contact with the action, the conditions it rests on; para is \
                projected beyond it.
                • Francisco Matte Bon: "por presents something as prior; para as new". Causes come before; purposes come after.
                • Chantal Melis (1992) and Concepción Company & Rodrigo Flores (2014): the por of luchar por and ir por is \
                "goal and motive at once". The thing you go after is the reason you set off. That's why it isn't para.
                """)

                section("Sources", """
                • Real Academia Española: Nueva gramática (2009) and Diccionario panhispánico de dudas, entries estar, ir, esperar, \
                pedir, agradecer, porque, hora
                • Diccionario del español de México (El Colegio de México): por, para, estar por
                • Torres Cacoullos & Bauman (2018), on purpose moving from por to para
                • Cadiñanos & Enrique-Arias (2022), on where para comes from
                • D'Antonio, Albiol-Martín & Priego-Casanova (2025), "Por y para: enfoques y su didáctica"
                • Matte Bon, "Cómo construimos las relaciones en la interacción", in Geométrica explosión (Ca' Foscari)
                • Frago (2020), "Un esquema, cuatro preposiciones", marcoELE 31
                • Lam (2009) and Kissling & Arnold (2022): learners taught with connected meanings did better than with lists
                • Lafford & Ryan (1995) and Patin (2016): which uses English and French speakers get wrong
                """)

                Text("Some of these were read only through other texts that quote them. The full research, with what was checked and what wasn't, is in the app's docs (por-para-rules.md).")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            Text(body).font(.subheadline).fixedSize(horizontal: false, vertical: true)
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
