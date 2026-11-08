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
        XCTAssertEqual(Set(MoodMap.treeOrder.map(\.id)).count, MoodMap.nodes.count, "every step is on exactly one lesson page")
        XCTAssertEqual(Set(MoodMap.lessons.map(\.id)), Set(MoodMap.nodes.filter { $0.level <= 2 }.map(\.id)), "every lesson is in the order")
        // A caveat never opens before the rule it qualifies
        for node in MoodMap.nodes where node.level > 2 {
            XCTAssertLessThan(MoodMap.byID[node.parent!]!.level, node.level, node.id)
        }
    }

    /// Every section of the subjunctive README is taught by a step, and every step is in some section.
    func testEveryReadmeSectionIsTaught() throws {
        let readme = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .appendingPathComponent("docs/conjugation-drill/subjunctive-rules.md")
        let text = try String(contentsOf: readme, encoding: .utf8)
        let listed = Set(MoodMap.coverage.map(\.section))
        for line in text.split(separator: "\n") where line.hasPrefix("## ") || line.hasPrefix("### ") {
            guard let number = line.split(separator: " ").dropFirst().first.map({ String($0).trimmingCharacters(in: CharacterSet(charactersIn: ".")) }),
                  number.first?.isNumber == true, number != "11", number != "12", number != "13" else { continue }
            // A section with subsections is covered by them
            if !line.hasPrefix("### "), text.contains("### \(number).") { continue }
            XCTAssertTrue(listed.contains(number), "README section \(number) has no Learn step")
        }
        for (section, nodes) in MoodMap.coverage {
            for id in nodes { XCTAssertNotNil(MoodMap.byID[id], "\(section): \(id)") }
        }
        let taught = Set(MoodMap.coverage.flatMap(\.nodes))
        let unlisted = MoodMap.nodes.filter { $0.id != "root" && !taught.contains($0.id) }.map(\.id)
        XCTAssertEqual(unlisted, [], "steps that no README section points to")
    }

    /// A step needs three right answers, so it needs at least three cards to avoid repeating one.
    func testEveryStepHasThreeCards() {
        let thin = MoodMap.nodes.filter { MoodMap.items(for: $0.id).count < 3 }.map { "\($0.id): \(MoodMap.items(for: $0.id).count)" }
        XCTAssertEqual(thin, [])
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
            let matrix = MoodTriggers.matrices[trigger.phrase]?.map(\.spanish) ?? []
            for text in [trigger.indicative, trigger.subjunctive].compactMap({ $0 }) + matrix {
                let bad = SpanishChecker.check(text).filter { $0.kind != .tip }
                XCTAssertTrue(bad.isEmpty, "\(trigger.phrase): \(text) <<< \(bad.map(\.message))")
            }
        }
    }

    /// Every choice on a form card names its tense once the card is answered.
    func testEveryFormChoiceHasATense() {
        var missing: [String] = []
        for item in MoodMap.items where item.kind == .form {
            for choice in item.choices where MoodTenseLabels.info(for: choice, in: item) == nil { missing.append("\(item.id): \(choice)") }
        }
        XCTAssertEqual(missing, [])
        XCTAssertEqual(MoodTenseLabels.info(for: "tendría")?.name, "conditional")
        XCTAssertEqual(MoodTenseLabels.info(for: "tuviera")?.name, "imperfect subjunctive")
        XCTAssertEqual(MoodTenseLabels.info(for: "venga")?.name, "present subjunctive")
        XCTAssertEqual(MoodTenseLabels.info(for: "viene")?.name, "present indicative")
        XCTAssertEqual(MoodTenseLabels.info(for: "que vaya")?.name, "present subjunctive")
        XCTAssertEqual(MoodTenseLabels.info(for: "ir")?.name, "infinitive")
        XCTAssertEqual(MoodTenseLabels.info(for: "hubiera venido")?.name, "pluperfect subjunctive")
        XCTAssertEqual(MoodTenseLabels.info(for: "he visto")?.name, "present perfect")
    }

    func testTensesAreIntroducedOnce() {
        let defaults = UserDefaults(suiteName: "MoodTenses")!
        defaults.removePersistentDomain(forName: "MoodTenses")
        let progress = MoodMapProgress(defaults: defaults)
        progress.markSeen(["conditional"])
        XCTAssertTrue(MoodMapProgress(defaults: defaults).seenTenses.contains("conditional"))
    }

    /// Curve balls: an indicative trigger, the indicative answer, and never "me dijeron que" about the speaker.
    func testCurveBallsAreIndicativeAndSensible() {
        let drill = DrillTense(kind: .simple, tense: .subjunctivePresent)
        var made = 0
        for (i, verb) in DrillSentences.verbList.prefix(60).enumerated() {
            for subject in DrillSentences.subjects(for: verb, drill) {
                guard let card = DrillSentences.curveCard(verb, for: drill, subject: subject, variant: i * 31 + 7) else { continue }
                made += 1
                XCTAssertEqual(card.drill, DrillTense(kind: .simple, tense: .present), card.sentence)
                XCTAssertNotNil(card.curve)
                XCTAssertTrue(card.prompt.contains("______"), card.prompt)
                if subject.person == 0 || subject.person == 3 { XCTAssertFalse(card.sentence.hasPrefix("Me dijeron"), card.sentence) }
                let bad = SpanishChecker.check(card.sentence).filter { $0.kind != .tip }
                XCTAssertTrue(bad.isEmpty, "\(card.sentence) <<< \(bad.map(\.message))")
            }
        }
        XCTAssertGreaterThan(made, 50)
        // A subjunctive round gets about two in ten
        let round = DrillDeck.withCurveBalls((0..<10).compactMap { i in
            let verb = DrillSentences.verbList[i]
            return DrillSentences.subjects(for: verb, drill).first.flatMap { DrillSentences.card(verb, drill, subject: $0) }
        })
        XCTAssertGreaterThanOrEqual(round.filter { $0.curve != nil }.count, 1)
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

    /// The imperfect subjunctive is taught before cards use it: until "Past main verb" opens, rounds leave those cards out.
    func testImperfectWaitsForItsLesson() {
        let defaults = UserDefaults(suiteName: "MoodMapImperfect")!
        defaults.removePersistentDomain(forName: "MoodMapImperfect")
        let progress = MoodMapProgress(defaults: defaults)
        XCTAssertFalse(MoodMap.usesImperfect.contains("root"))
        XCTAssertFalse(MoodMap.usesImperfect.contains("want"))
        XCTAssertTrue(MoodMap.imperfectItems.contains("want.decir.1") || MoodMap.items(for: "want.decir").contains { MoodMap.imperfectItems.contains($0.id) })
        for _ in 0..<3 { progress.record("root", right: true) }
        for _ in 0..<3 { progress.record("want", right: true) }
        for _ in 0..<5 {
            XCTAssertFalse(MoodRound.make(progress: progress).contains { MoodMap.imperfectItems.contains($0.id) })
        }
        XCTAssertEqual(MoodMap.lessonOrder.prefix(2), ["want", "imperfect"])
        for _ in 0..<2 { progress.record("imperfect", right: true) }
        for _ in 0..<2 { progress.record(MoodMap.imperfectIntro, right: true) }
        XCTAssertFalse(MoodMap.nodes.contains { progress.waitsForImperfect($0) })
    }

    /// Before the imperfect lesson, nothing a new learner can open shows an imperfect subjunctive form.
    func testNoImperfectBeforeItsLesson() {
        let defaults = UserDefaults(suiteName: "MoodMapNoImperfect")!
        defaults.removePersistentDomain(forName: "MoodMapNoImperfect")
        let progress = MoodMapProgress(defaults: defaults)
        // Everything open except the imperfect lesson itself
        for node in MoodMap.nodes where !MoodMap.imperfectSteps.contains(node.id) { for _ in 0..<3 { progress.record(node.id, right: true) } }
        XCTAssertTrue(progress.hidesImperfect)
        for node in MoodMap.nodes where progress.unlocked(node) && !MoodMap.imperfectSteps.contains(node.id) {
            for text in [MoodMap.title(of: node, progress: progress), node.rule, node.example] {
                XCTAssertFalse(MoodMap.mentionsImperfect(text), "\(node.id): \(text)")
            }
        }
        for _ in 0..<20 {
            for item in MoodRound.make(progress: progress) where !MoodMap.imperfectSteps.contains(item.node) {
                let filled = item.kind == .form ? item.choices.map { item.prompt.replacingOccurrences(of: "___", with: $0) } : [item.prompt] + item.choices
                for text in filled + [item.note, item.context] + item.why + MoodTenseLabels.usage(in: filled.first ?? "", pastKnown: false) {
                    XCTAssertFalse(MoodMap.mentionsImperfect(text), "\(item.id): \(text)")
                }
                for reason in MoodMap.reasons(for: item, hideImperfect: true) { XCTAssertFalse(MoodMap.mentionsImperfect(reason.title), "\(item.id): \(reason.title)") }
            }
        }
        for tense in MoodTenseLabels.byTense.values where tense.id != "subjunctiveImperfect" { XCTAssertFalse(MoodMap.mentionsImperfect(tense.uses), tense.name) }
        // A haber tense whose note uses the imperfect is only met on a card that waits for it
        let plainTenses = Set(MoodMap.items.filter { !MoodMap.imperfectItems.contains($0.id) && !MoodMap.imperfectSteps.contains($0.node) && $0.kind == .form }
            .flatMap { item in item.choices.compactMap { MoodTenseLabels.info(for: $0, in: item)?.id } })
        for tense in MoodTenseLabels.perfect.values where plainTenses.contains(tense.id) { XCTAssertFalse(MoodMap.mentionsImperfect(tense.uses), tense.name) }
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

    /// After answering, the card names each verb's tense and why the subjunctive is in it.
    func testVerbBreakdownExplainsTheSubjunctiveTense() {
        let verbs = MoodTenseLabels.verbs(in: "Me dijo que viniera.")
        XCTAssertEqual(verbs.map(\.word), ["dijo", "viniera"])
        XCTAssertEqual(verbs.map(\.verb), ["decir", "venir"])
        XCTAssertEqual(verbs.map(\.tense.name), ["preterite", "imperfect subjunctive"])
        let usage = MoodTenseLabels.usage(in: "Me dijo que viniera.").joined()
        XCTAssertTrue(usage.contains("dijo, is in the past (preterite)"), usage)
        XCTAssertTrue(usage.contains("Me dice que venga"), usage)
        XCTAssertTrue(MoodTenseLabels.usage(in: "Quiero que vengas.").joined().contains("Quería que vinieras"))
        XCTAssertTrue(MoodTenseLabels.usage(in: "Si tuviera tiempo, iría.").joined().contains("unreal"))
        XCTAssertEqual(MoodTenseLabels.verbs(in: "Me alegra que hayas venido.").last?.tense.name, "perfect subjunctive")
        // Words spelled like verbs aren't listed
        XCTAssertFalse(MoodTenseLabels.verbs(in: "Lo hice como me dijiste, para que vinieras.").contains { ["como", "para"].contains($0.word) })
        XCTAssertEqual(MoodTenseLabels.verbs(in: "Creo que tiene razón.").first?.verb, "creer")
        XCTAssertEqual(MoodTenseLabels.verbs(in: "¿Crees que viene?").first?.tense.name, "present indicative")
        XCTAssertFalse(MoodTenseLabels.usage(in: "Me gustaría que vinieras.").joined().contains("Me gusto"))
        XCTAssertFalse(MoodTenseLabels.usage(in: "Hace falta que llenes el formulario.").joined().contains("faltaba"))
        XCTAssertEqual(MoodTenseLabels.verbs(in: "Mi trabajo es difícil.").map(\.word), ["es"])
        XCTAssertEqual(MoodTenseLabels.verbs(in: "Sé que viene.").first?.verb, "saber")
        XCTAssertEqual(MoodTenseLabels.verbs(in: "Parece que va a llover.").map(\.word), ["parece", "va a llover"])
        XCTAssertTrue(MoodTenseLabels.usage(in: "Sé que viene.").joined().contains("in the indicative (the present: now, or as a habit): the clause after sé is put forward as true"))
        XCTAssertTrue(MoodTenseLabels.usage(in: "Quiero ir al cine.").joined().contains("same person does both"))
        let flip = MoodMap.items.first { $0.id == "belief.claim.6" }!
        XCTAssertEqual(MoodTenseLabels.changed(flip), "No dudo que es verdad.")
        XCTAssertEqual(MoodTenseLabels.verbs(in: "Siéntese, por favor.").first?.verb, "sentar")
        XCTAssertEqual(MoodTenseLabels.verbs(in: "No creo que vaya a llover.").last?.word, "vaya a llover")
        XCTAssertFalse(MoodTenseLabels.usage(in: "Es cierto que es caro.").joined().contains("describes"))
        // An indicative imperfect leads with the mood, so it isn't taken for the imperfect subjunctive
        XCTAssertTrue(MoodTenseLabels.usage(in: "Lo convencí de que era verdad.").joined().hasPrefix("Era is in the indicative (the imperfect"))
        // Every Learn sentence names at least one verb
        for item in MoodMap.items where item.id != "alone.mexico.5" {  // voseo (digás) isn't conjugated
            var sentence = item.prompt
            if item.kind == .form, let best = item.correct.min() { sentence = sentence.replacingOccurrences(of: "___", with: item.choices[best]) }
            XCTAssertFalse(MoodTenseLabels.verbs(in: sentence).isEmpty, "\(item.id): \(sentence)")
            XCTAssertFalse(MoodTenseLabels.usage(in: sentence).isEmpty, "\(item.id): \(sentence)")
        }
        // Dump every Learn sentence for review
        var out = ""
        for item in MoodMap.items {
            var sentence = item.prompt
            if item.kind == .form, let best = item.correct.min() { sentence = sentence.replacingOccurrences(of: "___", with: item.choices[best]) }
            if let changed = MoodTenseLabels.changed(item) { sentence = changed }
            let v = MoodTenseLabels.verbs(in: sentence).map { "\($0.word)=\($0.verb):\($0.tense.name)" }.joined(separator: ", ")
            out += "\(item.id)\t\(sentence)\n  \(v)\n" + MoodTenseLabels.usage(in: sentence).map { "  > " + $0 + "\n" }.joined()
        }
        out += "USES IMPERFECT: " + MoodMap.usesImperfect.sorted().joined(separator: ", ") + "\n"
        out += "IMPERFECT CARDS: \(MoodMap.imperfectItems.count)\n"
        let own = Set(MoodMap.steps(of: MoodMap.byID["imperfect"]!).map(\.id))
        func past(_ t: String) -> Bool { MoodTenseLabels.verbs(in: t).contains { $0.base == .subjunctiveImperfect } }
        for node in MoodMap.nodes where !own.contains(node.id) {
            for (label, t) in [("TITLE", node.title), ("RULE", node.rule), ("EX", node.example)] where past(t) { out += "NODE \(node.id) \(label): \(t)\n" }
        }
        for item in MoodMap.items where !own.contains(item.node) && !MoodMap.imperfectItems.contains(item.id) {
            for (label, t) in [("NOTE", item.note), ("CTX", item.context)] + item.why.map { ("WHY", $0) } where past(t) { out += "ITEM \(item.id) \(label): \(t)\n" }
        }
        for t in MoodTenseLabels.byTense.values where past(t.uses) || past(t.meaning) { out += "TENSE \(t.name): \(t.uses)\n" }
        for trig in MoodTriggers.all { for t in [trig.indicative, trig.subjunctive].compactMap({ $0 }) + [trig.rule] + (MoodTriggers.matrices[trig.phrase]?.map(\.spanish) ?? []) where past(t) { out += "TRIGGER \(trig.phrase): \(t)\n" } }
        try? out.write(toFile: NSTemporaryDirectory() + "verb_breakdown.txt", atomically: true, encoding: .utf8)
        print("DUMP:" + NSTemporaryDirectory() + "verb_breakdown.txt")
    }

    /// Every step still learnable before the imperfect lesson reads clean, and every briefing example is good Spanish.
    func testBriefingsAreSoundAndHideTheImperfect() {
        for (id, briefing) in MoodMap.briefings {
            XCTAssertNotNil(MoodMap.byID[id], id)
            XCTAssertFalse(briefing.examples.isEmpty, id)
            for example in briefing.examples {
                let bad = SpanishChecker.check(example.spanish).filter { $0.kind != .tip }
                XCTAssertTrue(bad.isEmpty, "\(id): \(example.spanish) <<< \(bad.map(\.message))")
            }
            // A step that opens before the imperfect lesson can't explain itself with it
            if !MoodMap.usesImperfect.contains(id), !MoodMap.imperfectSteps.contains(id) {
                XCTAssertFalse(MoodMap.mentionsImperfect(briefing.why), "\(id): \(briefing.why)")
            }
        }
        // Every step with a one-line rule gets a fuller explanation
        let thin = MoodMap.nodes.filter { $0.rule.count < 160 && MoodMap.briefings[$0.id] == nil }.map(\.id)
        XCTAssertEqual(thin, [])
    }

    /// What the learner reads first is never the exact sentence of an exercise that follows.
    func testBriefingExamplesDifferFromExercises() {
        func key(_ t: String) -> String { t.lowercased().filter { $0.isLetter || $0 == " " }.trimmingCharacters(in: .whitespaces) }
        var exercises = Set<String>()
        for item in MoodMap.items {
            switch item.kind {
            case .form: item.correct.forEach { exercises.insert(key(item.prompt.replacingOccurrences(of: "___", with: item.choices[$0]))) }
            case .meaning: exercises.insert(key(item.prompt))
            case .flip: exercises.insert(key(item.prompt)); MoodTenseLabels.changed(item).map { exercises.insert(key($0)) }
            }
        }
        var same: [String] = []
        for (id, briefing) in MoodMap.briefings { for example in briefing.examples where exercises.contains(key(example.spanish)) { same.append("\(id): \(example.spanish)") } }
        XCTAssertEqual(same.sorted(), [])
        // Worked examples stay out of the round that follows
        let defaults = UserDefaults(suiteName: "MoodMapWorked")!
        defaults.removePersistentDomain(forName: "MoodMapWorked")
        let progress = MoodMapProgress(defaults: defaults)
        for _ in 0..<3 { progress.record("root", right: true) }
        let want = MoodMap.byID["want"]!
        for _ in 0..<10 {
            let worked = MoodMap.workedExamples(for: want, progress: progress)
            XCTAssertFalse(worked.isEmpty)
            let round = MoodRound.make(focus: "want", progress: progress, excluding: Set(worked.map(\.id)))
            XCTAssertTrue(Set(round.map(\.id)).isDisjoint(with: worked.map(\.id)))
            XCTAssertTrue(round.contains { $0.node == "want" })
        }
        // Re-learning a lesson practises its own steps
        let lessonRound = MoodRound.make(focus: "want", progress: progress, lesson: "want")
        let wantSteps = Set(MoodMap.steps(of: want).map(\.id))
        XCTAssertTrue(lessonRound.allSatisfy { wantSteps.contains($0.node) })
    }
}
