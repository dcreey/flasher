import XCTest
@testable import Flasher

final class PorParaCourseTests: XCTestCase {

    func testEveryStepHasCardsAndAParentThatExists() {
        for step in PorParaCourse.steps {
            XCTAssertGreaterThanOrEqual(PorParaCourse.cards(for: step.id).count, 3, "\(step.id) needs at least three cards")
            if let parent = step.parent { XCTAssertNotNil(PorParaCourse.byID[parent], "\(step.id): parent \(parent)") }
            XCTAssertFalse(step.examples.isEmpty, step.id)
            XCTAssertFalse(step.source.isEmpty, step.id)
        }
        XCTAssertEqual(Set(PorParaCourse.steps.map(\.id)).count, PorParaCourse.steps.count, "step ids are unique")
        XCTAssertEqual(Set(PorParaCourse.steps.map(\.reason)).count, PorParaCourse.steps.count, "each step has its own reason")
    }

    func testEveryLessonIsInAChapterOnce() {
        let inChapters = PorParaCourse.chapters.flatMap(\.lessons)
        XCTAssertEqual(Set(inChapters).count, inChapters.count)
        let lessons = PorParaCourse.steps.filter { $0.level == 2 }.map(\.id)
        XCTAssertEqual(Set(lessons), Set(inChapters))
    }

    func testCardsAreWellFormed() {
        XCTAssertEqual(Set(PorParaCourse.cards.map(\.id)).count, PorParaCourse.cards.count, "card ids are unique")
        for card in PorParaCourse.cards {
            XCTAssertNotNil(PorParaCourse.byID[card.step], card.id)
            XCTAssertTrue(card.sentence.contains("___"), card.id)
            XCTAssertFalse(card.correct.isEmpty, card.id)
            XCTAssertTrue(card.correct.allSatisfy { card.choices.indices.contains($0) }, card.id)
            for i in card.choices.indices {
                let filled = card.filled(i)
                XCTAssertFalse(filled.contains("  ") || filled.contains("___"), "\(card.id): \(filled)")
            }
        }
    }

    func testTheRightReasonIsAlwaysOffered() {
        for card in PorParaCourse.cards {
            let options = PorParaCourse.reasons(for: card)
            XCTAssertEqual(Set(options.map(\.id)).count, options.count, card.id)
            if card.why.isEmpty {
                XCTAssertEqual(options.count, 3, card.id)
                XCTAssertTrue(options.contains { $0.id == card.step }, card.id)
            } else {
                XCTAssertTrue(card.why.indices.contains(card.whyRight), card.id)
            }
        }
    }

    func testReasonsKeepTheSameOrder() {
        let card = PorParaCourse.cards(for: "dest")[0]
        XCTAssertEqual(PorParaCourse.reasons(for: card).map(\.id), PorParaCourse.reasons(for: card).map(\.id))
    }

    func testFilledLeavesOutNothing() {
        let card = PorParaCourse.cards(for: "none")[0]
        let nothing = card.choices.firstIndex(of: PorParaCourse.nothing)!
        XCTAssertEqual(card.filled(nothing), "Busco mis llaves.")
    }

    func testProgressOpensStepsAfterTwoRight() {
        let defaults = UserDefaults(suiteName: "PorParaCourseTests")!
        defaults.removePersistentDomain(forName: "PorParaCourseTests")
        let progress = PorParaProgress(defaults: defaults)
        let dest = PorParaCourse.byID["dest"]!
        XCTAssertTrue(progress.unlocked(PorParaCourse.byID["root"]!))
        XCTAssertFalse(progress.unlocked(dest))
        progress.record("root", right: true)
        progress.record("root", right: true)
        XCTAssertTrue(progress.unlocked(dest))
        let deck = PorParaRound.make(focus: "dest", progress: progress)
        XCTAssertEqual(deck.first?.step, "dest")
        XCTAssertGreaterThanOrEqual(deck.count, 5)
    }
}
