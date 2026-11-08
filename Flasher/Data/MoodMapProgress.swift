import Foundation

/// How far the learner is on each node of the mood map. A node counts a right answer only when both the verb and the
/// reason ("why?") were right on the first try. Three of those master it; two open its children. Mastered nodes come
/// back for review after 1, 3, 7 and 14 days.
@Observable
final class MoodMapProgress {
    static let shared = MoodMapProgress(defaults: .standard)
    static let needed = 3
    static let opensChildren = 2
    private static let reviewDays = [1, 3, 7, 14]

    struct Stats: Codable, Equatable {
        var right = 0
        var wrong = 0
        var reviews = 0
        var last: Date?
    }

    private let defaults: UserDefaults
    private let key = "moodMapProgress"
    private(set) var stats: [String: Stats] = [:]
    /// Tenses already explained on a card, so each is introduced once.
    private(set) var seenTenses: Set<String> = []
    private let tensesKey = "moodMapSeenTenses"

    init(defaults: UserDefaults) {
        self.defaults = defaults
        if let data = defaults.data(forKey: key), let saved = try? JSONDecoder().decode([String: Stats].self, from: data) { stats = saved }
        seenTenses = Set(defaults.stringArray(forKey: tensesKey) ?? [])
    }

    func markSeen(_ tenses: [String]) {
        let new = Set(tenses).subtracting(seenTenses)
        guard !new.isEmpty else { return }
        seenTenses.formUnion(new)
        defaults.set(Array(seenTenses).sorted(), forKey: tensesKey)
    }

    func of(_ node: String) -> Stats { stats[node] ?? Stats() }
    func mastered(_ node: String) -> Bool { of(node).right >= Self.needed }

    /// The top rule is always open; any other node opens once its parent has been answered right twice.
    func unlocked(_ node: MoodNode) -> Bool {
        if waitsForImperfect(node) { return false }
        guard let parent = node.parent else { return true }
        return of(parent).right >= Self.opensChildren
    }

    /// A step whose cards use the imperfect subjunctive (viniera, hubiera) waits until the imperfect lesson has introduced it.
    func waitsForImperfect(_ node: MoodNode) -> Bool {
        MoodMap.usesImperfect.contains(node.id) && of(MoodMap.imperfectIntro).right < Self.opensChildren
    }

    func due(_ node: String, now: Date = .now) -> Bool {
        let s = of(node)
        guard s.right >= Self.needed, let last = s.last else { return false }
        let days = Self.reviewDays[min(s.reviews, Self.reviewDays.count - 1)]
        return now.timeIntervalSince(last) >= Double(days) * 86_400
    }

    func record(_ node: String, right: Bool, now: Date = .now) {
        var s = of(node)
        if right {
            if s.right >= Self.needed { s.reviews += 1 }
            s.right += 1
        } else {
            s.wrong += 1
            // A slip on a mastered node brings it back sooner
            s.reviews = max(0, s.reviews - 1)
        }
        s.last = now
        stats[node] = s
        save()
    }

    func reset() { stats = [:]; seenTenses = []; defaults.removeObject(forKey: tensesKey); save() }

    private func save() {
        if let data = try? JSONEncoder().encode(stats) { defaults.set(data, forKey: key) }
    }
}

/// A round of up to ten mood cards. With a focus node it mixes that node with its siblings and open children, so each rule is
/// practised next to the ones it gets confused with. Without one it takes open nodes that aren't mastered yet, plus any that are due.
enum MoodRound {
    static let size = 10

    static func make(focus: String? = nil, progress: MoodMapProgress) -> [MoodItem] {
        let open = MoodMap.nodes.filter { progress.unlocked($0) }
        let nodes: [MoodNode]
        if let focus, let node = MoodMap.byID[focus] {
            let siblings = MoodMap.nodes.filter { $0.parent == node.parent && $0.id != node.id && progress.unlocked($0) }
            let children = MoodMap.children(of: node.id).filter { progress.unlocked($0) }
            nodes = [node] + siblings + children
        } else {
            let learning = open.filter { !progress.mastered($0.id) }
            let due = open.filter { progress.due($0.id) }
            nodes = learning + due.filter { !learning.contains($0) }
        }
        // The focus (or the newest open nodes) first, then the rest; at most three cards a node so a round covers several rules
        // With few open nodes each one gives more cards, so a round is always close to ten
        let perNode = max(3, Int((Double(size) / Double(max(nodes.count, 1))).rounded(.up)))
        var picked: [MoodItem] = []
        for node in nodes {
            picked += MoodMap.items(for: node.id, progress: progress).shuffled().prefix(focus == node.id ? perNode + 1 : perNode)
            if picked.count >= size * 2 { break }
        }
        if picked.isEmpty { picked = MoodMap.items(for: "root", progress: progress) }
        // The focus node's cards always make it in; the neighbours fill the rest of the round
        let mine = picked.filter { $0.node == focus }
        let rest = picked.filter { $0.node != focus }.shuffled()
        return interleave(Array((mine + rest).prefix(size)).shuffled())
    }

    /// Puts cards from the same node apart where it can, so two cards in a row test different rules.
    static func interleave(_ items: [MoodItem]) -> [MoodItem] {
        var pool = items
        var out: [MoodItem] = []
        while !pool.isEmpty {
            let index = pool.firstIndex { $0.node != out.last?.node } ?? 0
            out.append(pool.remove(at: index))
        }
        return out
    }
}
