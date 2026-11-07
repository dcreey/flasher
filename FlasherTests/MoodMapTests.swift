import XCTest
@testable import Flasher

final class MoodMapTests: XCTestCase {
    func testEveryItemIsWellFormed() {
        let ids = Set(MoodMap.nodes.map(\.id))
        XCTAssertEqual(ids.count, MoodMap.nodes.count, "node ids are unique")
        XCTAssertEqual(Set(MoodMap.items.map(\.id)).count, MoodMap.items.count, "item ids are unique")
        for item in MoodMap.items {
            XCTAssertTrue(ids.contains(item.node), item.id)
            XCTAssertFalse(item.correct.isEmpty, item.id)
            XCTAssertTrue(item.correct.allSatisfy { item.choices.indices.contains($0) }, item.id)
            XCTAssertEqual(Set(item.choices).count, item.choices.count, "\(item.id): choices differ")
            if item.kind == .form { XCTAssertTrue(item.prompt.contains("___"), item.id) }
            XCTAssertFalse(item.note.isEmpty, item.id)
            if !item.why.isEmpty { XCTAssertTrue(item.why.indices.contains(item.whyRight), item.id) }
        }
    }

    /// Every rule can be practised, and every node hangs off the top rule.
    func testTreeIsCompleteAndReachable() {
        for node in MoodMap.nodes {
            XCTAssertFalse(MoodMap.items(for: node.id).isEmpty, "\(node.id) has cards")
            if let parent = node.parent { XCTAssertNotNil(MoodMap.byID[parent], node.id) }
        }
        XCTAssertEqual(MoodMap.treeOrder.count, MoodMap.nodes.count)
    }

    func testReasonsIncludeTheAnswerAndTwoOthers() {
        for item in MoodMap.items {
            let reasons = MoodMap.reasons(for: item)
            XCTAssertEqual(reasons.count, 3, item.id)
            XCTAssertEqual(Set(reasons.map(\.id)).count, 3, item.id)
            XCTAssertTrue(reasons.contains { $0.id == item.node }, item.id)
            XCTAssertEqual(reasons, MoodMap.reasons(for: item), "\(item.id): same order every time")
        }
    }

    /// The right answers, filled in, must not be flagged by the app's own Spanish checker.
    func testRightAnswersPassTheChecker() {
        for item in MoodMap.items where item.kind == .form {
            for i in item.correct {
                let text = item.prompt.replacingOccurrences(of: "___", with: item.choices[i])
                let bad = SpanishChecker.check(text).filter { $0.kind != .tip }
                XCTAssertTrue(bad.isEmpty, "\(item.id): \(text) <<< \(bad.map(\.message))")
            }
        }
    }

    /// Every trigger points at a Learn step, and every dictionary key it tags is a real entry, or the tag would never show.
    func testTriggerWordsResolve() {
        XCTAssertEqual(Set(MoodTriggers.all.map(\.id)).count, MoodTriggers.all.count, "phrases are unique")
        for trigger in MoodTriggers.all {
            XCTAssertNotNil(MoodMap.byID[trigger.node], "\(trigger.phrase): step \(trigger.node)")
            XCTAssertTrue(trigger.indicative != nil || trigger.subjunctive != nil, trigger.phrase)
            for key in trigger.keys {
                XCTAssertTrue(!Lexicon.shared.meanings(for: key).isEmpty || SeedData.words.contains { $0.spanish == key }, "\(trigger.phrase): \(key) is not in the dictionary")
            }
        }
        XCTAssertEqual(MoodTriggers.triggers(for: "creer").first?.behavior, .subjunctiveWithNo)
        XCTAssertEqual(MoodTriggers.triggers(for: "dudar").first?.behavior, .indicativeWithNo)
        XCTAssertEqual(MoodTriggers.triggers(for: "a lo mejor").first?.behavior, .indicative)
    }

    /// The trigger list and the app's Spanish checker must agree: no example the list teaches is flagged as wrong.
    func testTriggerExamplesPassTheChecker() {
        for trigger in MoodTriggers.all {
            for text in [trigger.indicative, trigger.subjunctive].compactMap({ $0 }) {
                let bad = SpanishChecker.check(text).filter { $0.kind != .tip }
                XCTAssertTrue(bad.isEmpty, "\(trigger.phrase): \(text) <<< \(bad.map(\.message))")
            }
        }
    }

    func testUnlockingAndMastery() {
        let defaults = UserDefaults(suiteName: "MoodMapTests")!
        defaults.removePersistentDomain(forName: "MoodMapTests")
        let progress = MoodMapProgress(defaults: defaults)
        let want = MoodMap.byID["want"]!
        XCTAssertTrue(progress.unlocked(MoodMap.byID["root"]!))
        XCTAssertFalse(progress.unlocked(want))
        progress.record("root", right: true)
        progress.record("root", right: true)
        XCTAssertTrue(progress.unlocked(want))
        XCTAssertFalse(progress.mastered("root"))
        progress.record("root", right: true)
        XCTAssertTrue(progress.mastered("root"))
        XCTAssertFalse(progress.due("root"))
        XCTAssertTrue(progress.due("root", now: Date().addingTimeInterval(2 * 86_400)))
        // Saved between launches
        XCTAssertEqual(MoodMapProgress(defaults: defaults).of("root").right, 3)
    }

    func testRoundsMixRulesAndStayInTheOpenPart() {
        let defaults = UserDefaults(suiteName: "MoodMapRounds")!
        defaults.removePersistentDomain(forName: "MoodMapRounds")
        let progress = MoodMapProgress(defaults: defaults)
        // A new learner only sees the top rule
        let first = MoodRound.make(progress: progress)
        XCTAssertTrue(first.allSatisfy { $0.node == "root" })
        XCTAssertGreaterThanOrEqual(first.count, 8, "a first round is still close to ten cards")
        for _ in 0..<3 { progress.record("root", right: true) }
        let round = MoodRound.make(progress: progress)
        XCTAssertLessThanOrEqual(round.count, MoodRound.size)
        XCTAssertGreaterThan(Set(round.map(\.node)).count, 2, "a round covers several rules")
        XCTAssertTrue(round.allSatisfy { progress.unlocked(MoodMap.byID[$0.node]!) })
        // A focused round puts the rule next to its siblings
        let focused = MoodRound.make(focus: "want", progress: progress)
        XCTAssertTrue(focused.contains { $0.node == "want" })
        XCTAssertTrue(focused.contains { $0.node != "want" })
    }
}
