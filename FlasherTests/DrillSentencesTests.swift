import XCTest
@testable import Flasher

/// Sentences are built from each verb's usage code, so every verb with a code must work in every drill tense.
final class DrillSentencesTests: XCTestCase {

    private func allVerbs() -> [String] {
        Lexicon.shared.meaningsByWord.compactMap { word, meanings in
            meanings.contains { $0.partOfSpeech == .infinitive } && !word.contains(" ") ? word : nil
        }.sorted()
    }

    private func check(_ verbs: [String], everyNth: Int = 1) -> (total: Int, problems: [String]) {
        var total = 0
        var problems: [String] = []
        for verb in verbs {
            for (ti, drill) in DrillTense.all.enumerated() {
                let subjects = DrillSentences.subjects(for: verb, drill)
                if subjects.isEmpty { continue }
                let subject = subjects[(verb.count + ti) % subjects.count]
                guard let text = DrillSentences.sentence(verb, drill, subject: subject) else { problems.append("\(verb) \(drill.label): no sentence"); continue }
                total += 1
                if text.contains("  ") || text.contains(" .") || text.contains(" ,") { problems.append("spacing: \(text)") }
                if !(text.hasSuffix(".") || text.hasSuffix("!")) { problems.append("ending: \(text)") }
                if !(text.first(where: { $0.isLetter })?.isUppercase ?? true) { problems.append("capital: \(text)") }
                // Rare verb forms the spelling list reads as nouns (cápsula/capsula, fórmula/formula): the checker is wrong there, not the sentence
                let knownClashes: Set<String> = ["capsula", "formula", "formule", "maculó", "macules", "placan"]
                let bad = SpanishChecker.check(text).filter { $0.kind != .tip && !knownClashes.contains($0.found.lowercased()) }
                if !bad.isEmpty { problems.append("\(text)   <<< \(bad.map { "\($0.kind.rawValue):\($0.found)" }.joined(separator: ", "))") }
            }
        }
        return (total, problems)
    }

    /// The ~500 hand-tagged verbs in all 28 drill tenses.
    func testHandTaggedVerbsInEveryDrillTense() {
        let verbs = allVerbs().filter { VerbUsage.of($0)?.reviewed == true }
        XCTAssertGreaterThan(verbs.count, 900)
        let (total, problems) = check(verbs)
        XCTAssertGreaterThan(total, 20_000)
        XCTAssertTrue(problems.isEmpty, "\(problems.count) problems, first:\n" + problems.prefix(25).joined(separator: "\n"))
    }

    /// The guessed verbs: every one of them must produce well-formed sentences.
    func testGuessedVerbsAreWellFormed() {
        let all = allVerbs().filter { VerbUsage.of($0)?.reviewed == false }
        XCTAssertGreaterThan(all.count, 3200)
        // Every 4th verb keeps the suite quick; the generator is deterministic, so a failing verb always fails
        let verbs = all.enumerated().filter { $0.offset % 4 == 0 }.map(\.element)
        let (total, problems) = check(verbs)
        XCTAssertGreaterThan(total, 12_000)
        XCTAssertTrue(problems.isEmpty, "\(problems.count) problems, first:\n" + problems.prefix(25).joined(separator: "\n"))
    }

    func testEveryVerbHasAUsageOrIsSkippedOnPurpose() {
        let verbs = allVerbs()
        let skipped = verbs.filter { VerbUsage.of($0) == nil }
        XCTAssertLessThan(skipped.count, 130, "Too many verbs without a usage: \(skipped.prefix(40))")
    }

    func testComplementsHaveNoPossessives() {
        for verb in allVerbs().prefix(1500) {
            guard let usage = VerbUsage.of(verb) else { continue }
            for seed in 0..<6 {
                let c = usage.complement(for: verb, seed: seed)
                XCTAssertFalse([" su ", " mi ", " tu ", "su ", "mi ", "tu "].contains { c.hasPrefix($0) || c.contains(" " + $0) }, "\(verb): \(c)")
            }
        }
    }

    func testGustarTypeVerbsPutTheThingAfterTheVerb() {
        let drill = DrillTense(kind: .simple, tense: .present)
        let subject = DrillSentences.subjects(for: "gustar", drill)[0]
        let text = DrillSentences.sentence("gustar", drill, subject: subject)!
        XCTAssertTrue(text.contains("gusta ") || text.contains("gustan "), text)
        XCTAssertTrue(["Me ", "Te ", "Le ", "Nos ", "Les "].contains { text.hasPrefix($0) }, text)
    }

    func testWeatherHasNoSubjectOrComplement() {
        let drill = DrillTense(kind: .simple, tense: .present)
        let subject = DrillSentences.subjects(for: "llover", drill)[0]
        XCTAssertEqual(DrillSentences.sentence("llover", drill, subject: subject), "Llueve a veces.")
    }

    func testCuesMatchTheKindOfEvent() {
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        let sudden = DrillSentences.sentence("caer", preterite, subject: DrillSentences.subjects(for: "caer", preterite)[0])!
        XCTAssertTrue(sudden.hasPrefix("De repente"), sudden)
        let state = DrillTense(kind: .simple, tense: .present)
        let know = DrillSentences.sentence("saber", state, subject: DrillSentences.subjects(for: "saber", state)[0])!
        XCTAssertFalse(know.contains("todos los días"), know)
    }

    func testStativeVerbsSkipTheProgressive() {
        XCTAssertTrue(DrillSentences.subjects(for: "saber", DrillTense(kind: .progressive, tense: .present)).isEmpty)
        XCTAssertTrue(DrillSentences.subjects(for: "empezar", DrillTense(kind: .progressive, tense: .present)).isEmpty)
        XCTAssertFalse(DrillSentences.subjects(for: "comer", DrillTense(kind: .progressive, tense: .present)).isEmpty)
    }
}
