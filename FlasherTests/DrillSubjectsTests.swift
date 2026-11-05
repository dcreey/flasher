import XCTest
@testable import Flasher

/// Every verb, every tense: the target subjects must exist, fit the verb and agree with the conjugator.
final class DrillSubjectsTests: XCTestCase {

    private var infinitives: [String] {
        Lexicon.shared.meaningsByWord.compactMap { word, meanings in
            meanings.contains { $0.partOfSpeech == .infinitive } && !word.contains(" ") ? word : nil
        }.sorted()
    }

    func testEveryVerbHasSubjectsInEveryTense() {
        let verbs = infinitives
        XCTAssertGreaterThan(verbs.count, 4000)
        var checked = 0
        for verb in verbs {
            let conjugation = Conjugator.conjugate(verb)
            for tense in Tense.allCases {
                let subjects = DrillSubjects.subjects(for: verb, tense: tense)
                let kind = VerbProfiles.profile(verb).kind
                // Only commands to things or to the weather have no subject
                if subjects.isEmpty {
                    XCTAssertTrue(tense == .imperative && (kind == .thing || kind == .weather), "\(verb) has no subjects in \(tense)")
                    continue
                }
                guard let conjugation else { continue }   // a verb the engine doesn't conjugate is covered elsewhere
                for subject in subjects {
                    // The chart must have a form for the subject's column
                    if conjugation.form(tense, subject.person) == nil {
                        // The imperative has no yo column; everything else must be filled in
                        XCTAssertTrue(tense == .imperative || ["haber"].contains(verb), "\(verb) \(tense) person \(subject.person) is empty")
                    }
                    checked += 1
                }
            }
        }
        XCTAssertGreaterThan(checked, 100_000)
    }

    func testWeatherVerbsHaveNoSubjectAndOnlyThirdSingular() {
        for verb in ["llover", "nevar", "granizar", "amanecer", "anochecer", "tronar", "lloviznar"] {
            XCTAssertEqual(VerbProfiles.profile(verb).kind, .weather, verb)
            for tense in Tense.allCases where tense != .imperative {
                XCTAssertEqual(DrillSubjects.subjects(for: verb, tense: tense), [DrillSubject(text: "", person: 2)], "\(verb) \(tense)")
            }
            XCTAssertTrue(DrillSubjects.subjects(for: verb, tense: .imperative).isEmpty)
        }
    }

    func testThingVerbsOnlyTakeThirdPersonThings() {
        for verb in ["funcionar", "costar", "gustar", "ocurrir", "suceder", "doler", "haber"] {
            for tense in Tense.allCases {
                for subject in DrillSubjects.subjects(for: verb, tense: tense) {
                    XCTAssertTrue([2, 5].contains(subject.person), "\(verb) \(tense) gave \(subject.text)")
                    XCTAssertFalse(["yo", "tú", "nosotros", "él", "ella", "usted", "ellos", "ustedes"].contains(subject.text), "\(verb): \(subject.text)")
                }
            }
        }
    }

    func testPersonVerbsNeverGetThingsOrAnimals() {
        let nonPeople: Set<String> = ["la puerta", "el coche", "la película", "el precio", "las luces", "los precios", "las clases", "el perro", "los gatos"]
        for verb in ["pensar", "hablar", "comprar", "querer", "decir", "trabajar", "estudiar", "escribir"] {
            XCTAssertEqual(VerbProfiles.profile(verb).kind, .person, verb)
            for tense in Tense.allCases {
                for subject in DrillSubjects.subjects(for: verb, tense: tense) {
                    XCTAssertFalse(nonPeople.contains(subject.text), "\(verb) \(tense): \(subject.text)")
                }
            }
        }
    }

    func testLivingVerbsAllowAnimalsButNotThings() {
        for verb in ["comer", "dormir", "beber", "morir", "correr"] {
            let texts = Set(DrillSubjects.subjects(for: verb, tense: .present).map(\.text))
            XCTAssertTrue(texts.contains("yo"), verb)
            XCTAssertTrue(texts.contains("el perro"), verb)
            XCTAssertFalse(texts.contains("la puerta"), verb)
        }
    }

    func testNarrowPoolsStayNarrow() {
        XCTAssertEqual(DrillSubjects.subjects(for: "ladrar", tense: .present).map(\.text), ["el perro", "los perros"])
        XCTAssertTrue(DrillSubjects.subjects(for: "hervir", tense: .present).allSatisfy { ["el agua", "la sopa", "las lágrimas"].contains($0.text) })
        XCTAssertTrue(DrillSubjects.subjects(for: "costar", tense: .preterite).allSatisfy { ["el libro", "la entrada", "los zapatos"].contains($0.text) })
    }

    func testCommandsGoToPeopleOnly() {
        for verb in ["abrir", "comer", "hablar", "cerrar"] {
            let subjects = DrillSubjects.subjects(for: verb, tense: .imperative)
            XCTAssertEqual(Set(subjects.map(\.text)), ["tú", "usted", "nosotros", "ustedes"], verb)
        }
    }

    func testVosotrosIsHiddenUnlessAsked() {
        XCTAssertFalse(DrillSubjects.subjects(for: "hablar", tense: .present).contains { $0.person == 4 })
        XCTAssertTrue(DrillSubjects.subjects(for: "hablar", tense: .present, includeVosotros: true).contains { $0.person == 4 })
    }

    func testReflexiveResolvesToBaseProfile() {
        XCTAssertEqual(VerbProfiles.profile("dormirse").kind, VerbProfiles.profile("dormir").kind)
    }
}

/// The drill's answer checking and card building.
final class DrillCardTests: XCTestCase {
    func testCardBlanksTheVerbAndKeepsTheAnswer() throws {
        let drill = DrillTense(kind: .simple, tense: .preterite)
        let subject = try XCTUnwrap(DrillSentences.subjects(for: "comer", drill).first)
        let card = try XCTUnwrap(DrillSentences.card("comer", drill, subject: subject))
        XCTAssertTrue(card.prompt.contains("______"))
        XCTAssertFalse(card.prompt.contains(card.answer))
        XCTAssertTrue(card.sentence.contains(card.answer))
    }

    func testCardsExistForEveryDrillTense() {
        let progress = DrillProgress(defaults: UserDefaults(suiteName: "drill-test-\(UUID().uuidString)")!)
        for drill in DrillTense.all {
            XCTAssertFalse(DrillDeck.make(drill, count: 5, progress: progress).isEmpty, drill.title)
        }
    }

    func testAccentsAreForgivenButNotWrongForms() {
        XCTAssertEqual(DrillChecker.grade("comió", answer: "comió", infinitive: "comer"), .correct)
        XCTAssertEqual(DrillChecker.grade("COMIÓ ", answer: "comió", infinitive: "comer"), .correct)
        XCTAssertEqual(DrillChecker.grade("comio", answer: "comió", infinitive: "comer"), .accent)
        // "habló" typed as "hablo" is the present: a different answer
        XCTAssertEqual(DrillChecker.grade("hablo", answer: "habló", infinitive: "hablar"), .wrong)
        XCTAssertEqual(DrillChecker.grade("comía", answer: "comió", infinitive: "comer"), .wrong)
        XCTAssertEqual(DrillChecker.grade("", answer: "comió", infinitive: "comer"), .wrong)
    }

    func testEveryCardHasTwoSentencesAndOnlyTheTargetIsBlank() {
        for drill in DrillTense.all {
            for infinitive in ["comer", "ir", "hablar", "tener"] {
                guard let subject = DrillSentences.subjects(for: infinitive, drill).first,
                      let card = DrillSentences.card(infinitive, drill, subject: subject) else { continue }
                XCTAssertEqual(card.prompt.components(separatedBy: "______").count, 2, card.prompt)
                XCTAssertGreaterThanOrEqual(card.sentence.filter { ".!".contains($0) }.count, 2, card.sentence)
            }
        }
    }

    func testGustarTypeAnswerMayLeaveOutThePronoun() {
        XCTAssertEqual(DrillChecker.grade("gusta", answer: "me gusta", infinitive: "gustar"), .correct)
        XCTAssertEqual(DrillChecker.grade("me gusta", answer: "me gusta", infinitive: "gustar"), .correct)
    }
}

final class DrillMixTests: XCTestCase {
    private func freshProgress() -> DrillProgress { DrillProgress(defaults: UserDefaults(suiteName: "drill-test-\(UUID().uuidString)")!) }

    func testRoundsMixIrregularAndRegularVerbs() {
        let progress = freshProgress()
        for drill in [DrillTense(kind: .simple, tense: .preterite), DrillTense(kind: .simple, tense: .present), DrillTense(kind: .perfect, tense: .present)] {
            var irregular = 0, regular = 0
            for _ in 0..<20 {
                for card in DrillDeck.make(drill, count: 10, progress: progress) {
                    if DrillDeck.isIrregular(card.infinitive, in: drill) { irregular += 1 } else { regular += 1 }
                }
            }
            XCTAssertGreaterThan(irregular, 60, drill.title)
            XCTAssertGreaterThan(regular, 60, drill.title)
        }
    }

    func testIrregularityIsPerTense() {
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        XCTAssertTrue(DrillDeck.isIrregular("tener", in: preterite))
        XCTAssertFalse(DrillDeck.isIrregular("hablar", in: preterite))
        XCTAssertTrue(DrillDeck.isIrregular("abrir", in: DrillTense(kind: .perfect, tense: .present)))
        XCTAssertTrue(DrillDeck.isIrregular("decir", in: DrillTense(kind: .progressive, tense: .present)))
    }

    func testMasteredVerbsDropOutAndRarerOnesStepIn() throws {
        let progress = freshProgress()
        let drill = DrillTense(kind: .simple, tense: .present)
        let first = Set(DrillDeck.make(drill, count: 10, progress: progress).map(\.infinitive))
        // Master every verb in the first round
        for infinitive in first {
            let card = try XCTUnwrap(DrillSentences.subjects(for: infinitive, drill).first.flatMap { DrillSentences.card(infinitive, drill, subject: $0) })
            for _ in 0..<DrillProgress.needed { progress.record(card, correct: true) }
        }
        XCTAssertEqual(progress.currentSet(drill)?.mastered, first.count)
        XCTAssertEqual(progress.currentSet(drill)?.size, DrillProgress.setSize)
        let next = Set(DrillDeck.make(drill, count: 10, progress: progress).map(\.infinitive))
        XCTAssertTrue(next.isDisjoint(with: first), "mastered verbs came back")
    }

    func testMissedVerbsStayInRotation() throws {
        let progress = freshProgress()
        let drill = DrillTense(kind: .simple, tense: .preterite)
        let card = try XCTUnwrap(DrillSentences.subjects(for: "poner", drill).first.flatMap { DrillSentences.card("poner", drill, subject: $0) })
        progress.record(card, correct: false)
        var seen = false
        for _ in 0..<5 where DrillDeck.make(drill, count: 10, progress: progress).contains(where: { $0.infinitive == "poner" }) { seen = true }
        XCTAssertTrue(seen)
    }

    func testQueuedVerbLeadsItsTenseAndMixedPractice() throws {
        let progress = freshProgress()
        let drill = DrillTense(kind: .simple, tense: .conditional)
        progress.queue("pelear", drill)
        XCTAssertTrue(progress.isQueued("pelear", drill))
        XCTAssertEqual(DrillDeck.make(drill, count: 10, progress: progress).first?.infinitive, "pelear")
        // Another tense is not affected
        XCTAssertFalse(DrillDeck.make(DrillTense(kind: .simple, tense: .present), count: 10, progress: progress).contains { $0.infinitive == "pelear" })
        XCTAssertEqual(DrillDeck.makeQueued(count: 10, progress: progress).map(\.infinitive), ["pelear"])
        XCTAssertTrue(DrillDeck.makeMixed(count: 10, progress: progress).contains { $0.infinitive == "pelear" })
        progress.unqueue("pelear", drill)
        XCTAssertTrue(progress.queued.isEmpty)
    }

    func testQueuedVerbStaysUntilItIsRightThreeTimes() throws {
        let progress = freshProgress()
        let drill = DrillTense(kind: .simple, tense: .present)
        let card = try XCTUnwrap(DrillSentences.subjects(for: "pelear", drill).first.flatMap { DrillSentences.card("pelear", drill, subject: $0) })
        progress.queue("pelear", drill)
        progress.record(card, correct: true)
        XCTAssertTrue(progress.isQueued("pelear", drill), "one right answer is not enough")
        progress.record(card, correct: false)
        XCTAssertEqual(progress.item("pelear", drill).queuedCorrect, 1, "a miss does not count")
        progress.record(card, correct: true)
        XCTAssertTrue(progress.isQueued("pelear", drill))
        XCTAssertEqual(DrillDeck.make(drill, count: 10, progress: progress).first?.infinitive, "pelear")
        progress.record(card, correct: true)
        XCTAssertFalse(progress.isQueued("pelear", drill), "three right answers take it out")
        XCTAssertTrue(progress.queued.isEmpty)
        // Queueing it again starts the count over
        progress.queue("pelear", drill)
        XCTAssertEqual(progress.item("pelear", drill).queuedCorrect, 0)
    }

    /// What the word page queues is the table and tense on screen, and the round asks for exactly that tense.
    func testWordPageQueuesTheExactTenseThatIsShowing() throws {
        var checked = 0
        for form in VerbForm.allCases {
            for tense in form.tenses {
                guard let drill = DrillTense.forWordPage(form: form, tense: tense) else { XCTFail("no drill for \(form) \(tense)"); continue }
                XCTAssertEqual(drill.tense, tense)
                XCTAssertEqual(drill.kind, form == .infinitive ? .simple : form == .gerund ? .progressive : .perfect)
                let progress = freshProgress()
                progress.queue("comer", drill)
                let cards = DrillDeck.makeQueued(count: 10, progress: progress)
                XCTAssertEqual(cards.map(\.drill), [drill], "\(form) \(tense)")
                XCTAssertEqual(cards.first?.infinitive, "comer")
                // That tense's round leads with it, and no other tense's round does
                XCTAssertEqual(DrillDeck.make(drill, count: 10, progress: progress).first?.infinitive, "comer")
                for other in DrillTense.all where other != drill {
                    XCTAssertFalse(DrillDeck.make(other, count: 10, progress: progress).contains { $0.infinitive == "comer" && progress.isQueued("comer", other) })
                }
                checked += 1
            }
        }
        XCTAssertEqual(checked, 21)   // 8 simple + 7 progressive + 6 perfect
    }

    func testTwoTensesOfOneVerbAreQueuedSeparately() {
        let progress = freshProgress()
        let past = DrillTense(kind: .simple, tense: .preterite)
        let future = DrillTense(kind: .simple, tense: .future)
        progress.queue("comer", past)
        progress.queue("comer", future)
        XCTAssertEqual(progress.queued.count, 2)
        progress.unqueue("comer", past)
        XCTAssertTrue(progress.isQueued("comer", future))
        XCTAssertFalse(progress.isQueued("comer", past))
    }

    func testQueueingAMasteredVerbStartsItOver() throws {
        let progress = freshProgress()
        let drill = DrillTense(kind: .simple, tense: .present)
        let card = try XCTUnwrap(DrillSentences.subjects(for: "comer", drill).first.flatMap { DrillSentences.card("comer", drill, subject: $0) })
        for _ in 0..<DrillProgress.needed { progress.record(card, correct: true) }
        XCTAssertTrue(progress.item("comer", drill).learned)
        progress.queue("comer", drill)
        XCTAssertFalse(progress.item("comer", drill).learned)
    }
}

final class DrillContextTests: XCTestCase {
    func testEveryPoolHasManyDifferentSentences() {
        XCTAssertEqual(DrillContexts.all.count, 7)
        for (name, list) in DrillContexts.all {
            XCTAssertGreaterThanOrEqual(list.count, 120, name)
            XCTAssertEqual(Set(list).count, list.count, "\(name) repeats a sentence")
            XCTAssertTrue(list.allSatisfy { $0.hasSuffix(".") }, name)
        }
    }

    func testEveryPoolHasAboutTwentyCloseFitsForEachKindOfVerb() {
        let kinds: [DrillContexts.Category] = [.food, .work, .move, .talk, .sudden, .thing]
        for name in DrillContexts.all.keys {
            for kind in kinds {
                XCTAssertGreaterThanOrEqual(DrillContexts.closeCount(name, for: kind), 18, "\(name) has too few for \(kind)")
            }
        }
    }

    func testEveryTenseGroupGetsAContextSentence() {
        for drill in DrillTense.all {
            for verb in ["hablar", "comer", "llover", "funcionar", "caer", "trabajar", "caminar", "saber"] {
                guard let subject = DrillSentences.subjects(for: verb, drill).first, let card = DrillSentences.card(verb, drill, subject: subject) else { continue }
                XCTAssertNotEqual(card.prompt, card.prompt.components(separatedBy: "______").joined(), "\(drill.title) \(verb)")
                XCTAssertGreaterThanOrEqual(card.sentence.filter { ".!".contains($0) }.count, 2, card.sentence)
            }
        }
    }

    func testContextsFitTheKindOfVerb() {
        var talk = Set<String>(), weather = Set<String>(), work = Set<String>()
        for seed in 0..<400 {
            for pool in DrillContexts.all.keys {
                talk.insert(DrillContexts.pick(pool, for: .talk, seed: seed))
                weather.insert(DrillContexts.pick(pool, for: .weather, seed: seed))
                work.insert(DrillContexts.pick(pool, for: .work, seed: seed))
            }
        }
        XCTAssertTrue(talk.allSatisfy { !$0.lowercased().contains("silencio") && !$0.lowercased().contains("nadie") })
        XCTAssertTrue(weather.allSatisfy { !$0.lowercased().contains("llov") && !$0.lowercased().contains("lluvia") && !$0.lowercased().contains("frío") })
        XCTAssertTrue(work.allSatisfy { !$0.lowercased().contains("vacaciones") && !$0.lowercased().contains("domingo") })
        // A food verb leans toward meal scenes
        let food = (0..<300).map { DrillContexts.pick("imperfectScenes", for: .food, seed: $0) }
        XCTAssertGreaterThan(food.filter { ["comida", "café", "cena", "mercado", "olor"].contains(where: $0.lowercased().contains) }.count, 150)
    }

    func testCategoriesFollowTheVerbUsage() {
        func category(_ verb: String, person: Bool = true) -> DrillContexts.Category {
            DrillContexts.category(verb, usage: VerbUsage.of(verb)!, subjectIsPerson: person)
        }
        XCTAssertEqual(category("llover"), .weather)
        XCTAssertEqual(category("hablar"), .talk)
        XCTAssertEqual(category("comer"), .food)
        XCTAssertEqual(category("caminar"), .move)
        XCTAssertEqual(category("funcionar", person: false), .thing)
    }
}

final class DrillAdjectiveTests: XCTestCase {
    func testEveryAdjectiveIsTaggedForItsKindOfSubject() {
        for (category, kinds) in DrillAdjectives.bank {
            for (_, words) in kinds {
                for word in words {
                    let tags = Extras.shared.adjectiveCategories[word] ?? []
                    XCTAssertTrue(tags.contains { $0.contains(String(category)) }, "\(word) is not tagged '\(category)' in the lexicon")
                }
            }
        }
    }

    func testAdjectivesAgreeWithTheSubject() {
        func f(_ a: String, _ fem: Bool, _ pl: Bool) -> String { DrillAdjectives.inflect(a, feminine: fem, plural: pl) }
        XCTAssertEqual([f("bonito", false, false), f("bonito", true, false), f("bonito", false, true), f("bonito", true, true)], ["bonito", "bonita", "bonitos", "bonitas"])
        XCTAssertEqual([f("grande", true, false), f("grande", false, true)], ["grande", "grandes"])
        XCTAssertEqual([f("feliz", true, false), f("feliz", false, true)], ["feliz", "felices"])
        XCTAssertEqual([f("joven", true, true), f("trabajador", true, false), f("trabajador", false, true), f("trabajador", true, true)], ["jóvenes", "trabajadora", "trabajadores", "trabajadoras"])
        XCTAssertEqual(f("azul", false, true), "azules")
    }

    func testSerAndEstarGetAnAdjectiveThatFitsTheSubject() throws {
        let present = DrillTense(kind: .simple, tense: .present)
        let door = DrillSubject(text: "la puerta", person: 2)
        let windows = DrillSubject(text: "las ventanas", person: 5)
        let soup = DrillSubject(text: "la sopa", person: 2)
        let she = DrillSubject(text: "ella", person: 2)
        let us = DrillSubject(text: "mi amigo y yo", person: 3)
        for subject in [door, windows, soup, she, us] {
            XCTAssertTrue(DrillSentences.subjects(for: "estar", present).contains(subject), subject.text)
        }
        let kinds: [(String, DrillSubject, [String])] = [
            ("estar", door, ["abierta", "cerrada", "rota", "limpia", "sucia", "lista", "mojada"]),
            ("estar", windows, ["abiertas", "cerradas", "rotas", "limpias", "sucias", "listas", "mojadas"]),
            ("estar", soup, ["fría", "caliente", "rica", "fresca", "frita", "congelada"]),
            ("estar", she, ["enferma", "cansada", "contenta", "feliz", "casada", "enamorada", "segura", "ocupada", "lista", "triste", "nerviosa", "tranquila", "preocupada", "sana"]),
            ("ser", us, ["altos", "bajos", "jóvenes", "viejos", "fuertes", "guapos", "graciosos", "pacientes", "responsables", "amables", "simpáticos", "inteligentes", "trabajadores", "honestos", "famosos", "serios", "tontos"]),
        ]
        for (verb, subject, allowed) in kinds {
            for tense in [present, DrillTense(kind: .simple, tense: .imperfect)] {
                let text = try XCTUnwrap(DrillSentences.sentence(verb, tense, subject: subject))
                XCTAssertTrue(allowed.contains { text.contains(" \($0).") || text.hasSuffix(" \($0).") }, "\(verb) \(subject.text): \(text)")
            }
        }
    }

    func testSoupIsNeverTiredAndDoorsAreNeverTall() {
        let tired = Set(["cansado", "cansada", "alto", "alta", "enfermo", "enferma", "casado", "casada"])
        for tense in DrillTense.all where !(tense.tense == .imperative) {
            for verb in ["ser", "estar", "quedar", "resultar"] {
                for subject in DrillSentences.subjects(for: verb, tense) where !subject.isPerson {
                    guard let text = DrillSentences.sentence(verb, tense, subject: subject) else { continue }
                    XCTAssertFalse(text.split(whereSeparator: { " .,".contains($0) }).contains { tired.contains(String($0)) }, text)
                }
            }
        }
    }
}

final class DrillGroupingTests: XCTestCase {
    func testConditionalIsItsOwnMoodAndEveryTenseIsPlaced() {
        func count(_ mood: DrillMood) -> Int { DrillTense.matching(mood: mood, time: nil, moment: nil).count }
        XCTAssertEqual(count(.conditional), 3)   // would eat, would be eating, would have eaten
        XCTAssertEqual(count(.imperative), 1)
        XCTAssertEqual(count(.phrases), 7)
        XCTAssertEqual(count(.subjunctive), 6)
        XCTAssertEqual(count(.indicative), 11)
        XCTAssertEqual(DrillMood.allCases.map(count).reduce(0, +), DrillTense.all.count)
    }

    func testTimeAndMomentSeparateTheTenses() {
        func titles(_ mood: DrillMood?, _ time: DrillTime?, _ moment: DrillMoment?) -> Set<String> {
            Set(DrillTense.matching(mood: mood, time: time, moment: moment).map(\.title))
        }
        // Before a past moment: had done it; just before: had just done it
        XCTAssertEqual(titles(.indicative, .past, .before), ["Pluscuamperfecto"])
        XCTAssertEqual(titles(.indicative, .future, .before), ["Futuro perfecto"])
        XCTAssertTrue(titles(.indicative, .present, .before).contains("Pretérito perfecto"))
        XCTAssertTrue(titles(.phrases, .past, .after).contains("Ir a (antes)"))
        // The perfect is also "during": it can say something is still open up to that moment (todavía no)
        XCTAssertTrue(titles(.indicative, .past, .during).isSuperset(of: ["Pretérito", "Imperfecto", "Pretérito progresivo", "Imperfecto progresivo", "Pluscuamperfecto"]))
        // Tenses can sit at more than one time: the present also says the future ("mañana viajo")
        XCTAssertTrue(titles(.indicative, .future, .during).contains("Presente"))
        XCTAssertTrue(titles(.subjunctive, .future, .during).contains("Presente de subjuntivo"))
        XCTAssertTrue(titles(.conditional, .past, .before) == ["Condicional perfecto"])
        // Every filter combination leaves something or nothing, never a tense twice
        for drill in DrillTense.all { XCTAssertEqual(DrillTense.matching(mood: drill.mood, time: drill.time, moment: drill.moment).filter { $0 == drill }.count, 1) }
    }
}

final class DrillExplainerTests: XCTestCase {
    private func card(_ verb: String, _ drill: DrillTense) throws -> DrillSentences.Card {
        let subject = try XCTUnwrap(DrillSentences.subjects(for: verb, drill).first { $0.person == 2 } ?? DrillSentences.subjects(for: verb, drill).first)
        return try XCTUnwrap(DrillSentences.card(verb, drill, subject: subject))
    }

    func testEveryDrillTenseHasAnExplanationWithAClueForRealCards() throws {
        for drill in DrillTense.all {
            XCTAssertNotNil(DrillExplainer.entries[drill.key], drill.title)
            let made = try card("hablar", drill)
            let why = DrillExplainer.explain(made)
            XCTAssertFalse(why.rule.isEmpty, drill.title)
            XCTAssertFalse(why.moment.isEmpty, drill.title)
            XCTAssertNotNil(why.clue, "no clue found for \(drill.title): \(made.sentence)")
        }
    }

    func testEveryContrastNamesTwoRealTenses() {
        let keys = Set(DrillTense.all.map(\.key))
        for pair in DrillExplainer.contrasts.keys {
            let parts = pair.split(separator: "|").map(String.init)
            XCTAssertEqual(parts.count, 2, pair)
            XCTAssertTrue(parts.allSatisfy(keys.contains), pair)
        }
    }

    func testTypingTheWrongTenseSaysWhichTenseAndWhy() throws {
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        let made = try card("hablar", preterite)
        XCTAssertEqual(made.answer, "habló")
        let imperfect = DrillExplainer.diagnose("hablaba", card: made)
        XCTAssertTrue(imperfect.contains("imperfecto"), imperfect)
        XCTAssertTrue(imperfect.contains("one finished event"), imperfect)
        let present = DrillExplainer.diagnose("hablo", card: made)
        XCTAssertTrue(present.contains("presente"), present)
    }

    func testRightTenseWrongPersonIsSaidSo() throws {
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        let made = try card("hablar", preterite)   // an él/ella/usted subject
        let text = DrillExplainer.diagnose("hablé", card: made)
        XCTAssertTrue(text.contains("right tense"), text)
        XCTAssertTrue(text.contains("yo"), text)
    }

    func testSubjunctiveTriggerIsExplained() throws {
        let subjunctive = DrillTense(kind: .simple, tense: .subjunctivePresent)
        let made = try card("hablar", subjunctive)
        let text = DrillExplainer.diagnose("habla", card: made)
        XCTAssertTrue(text.contains("subjunctive"), text)
        let why = DrillExplainer.explain(made)
        XCTAssertTrue((why.clue ?? "").lowercased().contains("espero que") || (why.clue ?? "").lowercased().contains("importante"), why.clue ?? "")
    }

    func testTypoAndNonsenseAreHandled() throws {
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        let made = try card("hablar", preterite)
        XCTAssertTrue(DrillExplainer.diagnose("hablo ", card: made).contains("presente"))
        XCTAssertTrue(DrillExplainer.diagnose("habl", card: made).hasPrefix("Close"))
        XCTAssertTrue(DrillExplainer.diagnose("zzzzzz", card: made).contains("not a form"))
        XCTAssertEqual(DrillExplainer.diagnose("", card: made), "Nothing was typed.")
    }
}

final class DrillSelectionSummaryTests: XCTestCase {
    func testSummaryListsTheTensesAndTheirExamples() {
        let past = DrillSelectionSummary.make(mood: .indicative, time: .past, moment: .before)
        XCTAssertEqual(past.lines, ["Pluscuamperfecto · había comido"])
        XCTAssertTrue(past.headline.contains("Indicative · Past · Before"))
        XCTAssertTrue(past.headline.contains("1 tense"))
        // Any mood: every past tense that is already done by then, from the perfect forms and "acababa de"
        let anyMood = DrillSelectionSummary.make(mood: nil, time: .past, moment: .before).lines.joined(separator: "\n")
        XCTAssertTrue(anyMood.contains("había comido"))
        XCTAssertTrue(anyMood.contains("acababa de comer"))
        XCTAssertTrue(anyMood.contains("habría comido"))
    }

    func testExamplesChangeWithTheSelection() {
        let a = DrillSelectionSummary.make(mood: .indicative, time: .present, moment: .during)
        let b = DrillSelectionSummary.make(mood: .indicative, time: .future, moment: .during)
        XCTAssertNotEqual(a.lines, b.lines)
        XCTAssertTrue(a.lines.joined().contains("come"))
        XCTAssertTrue(b.lines.joined().contains("comerá"))
        // No example text is baked into the explanation of a moment any more
        for moment in DrillMoment.allCases { XCTAssertFalse(moment.blurb.contains("comer") || moment.blurb.contains("comido")) }
    }

    func testAnImpossibleSelectionSaysWhatWouldWork() {
        // The screenshot case: subjunctive, present, after
        let none = DrillSelectionSummary.make(mood: .subjunctive, time: .present, moment: .after)
        XCTAssertTrue(none.lines.isEmpty)
        XCTAssertTrue(none.headline.contains("no tense fits"))
        let hint = none.hint ?? ""
        XCTAssertTrue(hint.contains("Moment could be Before or During"), hint)
        XCTAssertTrue(hint.contains("Mood could be Phrases"), hint)
    }

    func testNothingSelectedCountsAllTenses() {
        let all = DrillSelectionSummary.make(mood: nil, time: nil, moment: nil)
        XCTAssertEqual(all.headline, "All \(DrillTense.all.count) tenses")
        XCTAssertTrue(all.lines.isEmpty)
    }
}

final class DrillVarietyAndSubjectTests: XCTestCase {
    private func freshProgress() -> DrillProgress { DrillProgress(defaults: UserDefaults(suiteName: "drill-test-\(UUID().uuidString)")!) }

    func testTheSameVerbTenseAndSubjectGivesDifferentSentencesAcrossVariants() throws {
        let drill = DrillTense(kind: .simple, tense: .preterite)
        let subject = DrillSubject(text: "él", person: 2)
        let base = try XCTUnwrap(DrillSentences.card("comprar", drill, subject: subject))
        XCTAssertEqual(base.sentence, DrillSentences.sentence("comprar", drill, subject: subject), "variant 0 is the fixed one")
        let sentences = Set((1..<60).compactMap { DrillSentences.card("comprar", drill, subject: subject, variant: $0)?.sentence })
        XCTAssertGreaterThan(sentences.count, 15)
        // él, ella, usted and a noun subject share a person, but no longer share a sentence
        let people = ["él", "ella", "usted", "mi hermana"].compactMap { DrillSentences.card("comprar", drill, subject: DrillSubject(text: $0, person: 2), variant: 7)?.sentence }
        XCTAssertEqual(people.count, 4)
    }

    func testAVerbPractisedAgainNeverComesBackWithTheSameSentence() throws {
        let progress = freshProgress()
        let drill = DrillTense(kind: .simple, tense: .preterite)
        progress.queue("comprar", drill)
        var previous: String?
        for round in 0..<25 {
            let card = try XCTUnwrap(DrillDeck.makeQueued(count: 1, progress: progress).first)
            XCTAssertNotEqual(card.sentence, previous, "round \(round) repeated the last sentence")
            previous = card.sentence
            progress.record(card, correct: false)   // stays queued
        }
    }

    func testEveryCardSaysWhoItIsAbout() {
        XCTAssertEqual(DrillSubject(text: "yo", person: 0).label, "yo (I)")
        XCTAssertEqual(DrillSubject(text: "tú", person: 1).label, "tú (you, informal)")
        XCTAssertEqual(DrillSubject(text: "ustedes", person: 5).label, "ustedes (you all)")
        XCTAssertEqual(DrillSubject(text: "mi hermana", person: 2).label, "mi hermana (my sister)")
        XCTAssertEqual(DrillSubject(text: "", person: 2).label, "no subject (weather)")
        XCTAssertEqual(DrillSubject(text: "la puerta", person: 2).label, "la puerta")
        for subject in DrillSentences.subjects(for: "hablar", DrillTense(kind: .simple, tense: .present)) { XCTAssertFalse(subject.label.isEmpty) }
    }

    func testASentenceThatFitsTwoTensesOffersBoth() throws {
        let future = DrillTense(kind: .simple, tense: .future)
        let subject = DrillSubject(text: "él", person: 2)
        // Find a "Mañana …" future card
        let card = try XCTUnwrap((0..<200).compactMap { DrillSentences.card("comprar", future, subject: subject, variant: $0) }.first { $0.sentence.contains("Mañana") })
        let options = DrillAlternates.options(for: card)
        XCTAssertEqual(options.map(\.drill.title), ["Ir a (ahora)", "Presente"])
        // Picking one changes the answer and the sentence, and the blank stays where it was
        let irA = card.choosing(options[0].drill)
        XCTAssertEqual(irA.answer, "va a comprar")
        XCTAssertTrue(irA.sentence.contains("Mañana él va a comprar"), irA.sentence)
        XCTAssertEqual(irA.drill, options[0].drill)
        XCTAssertEqual(card.choosing(card.drill), card)
        // The answer is graded for the tense that was picked
        XCTAssertEqual(DrillChecker.grade("va a comprar", answer: irA.answer, infinitive: "comprar"), .correct)
    }

    func testOnlyTheKnownAmbiguousSentencesOfferChoices() throws {
        // A sudden event ("de repente") has one answer; "ayer" also allows the present perfect, as heard in Mexico
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        let subject = DrillSubject(text: "él", person: 2)
        let sudden = try XCTUnwrap((0..<200).compactMap { DrillSentences.card("caer", preterite, subject: subject, variant: $0) }.first { $0.sentence.contains("De repente") })
        XCTAssertTrue(DrillAlternates.options(for: sudden).isEmpty)
        let yesterday = try XCTUnwrap((0..<200).compactMap { DrillSentences.card("comprar", preterite, subject: subject, variant: $0) }.first { $0.sentence.contains("Ayer") })
        XCTAssertEqual(DrillAlternates.options(for: yesterday).map(\.drill.title), ["Pretérito perfecto"])
        XCTAssertTrue(yesterday.choosing(DrillTense(kind: .perfect, tense: .present)).sentence.contains("Ayer él ha comprado"))
        // The explanations no longer call the other tense wrong
        let contrast = DrillExplainer.contrasts["simple preterite|perfect present"] ?? ""
        XCTAssertTrue(contrast.contains("also used"), contrast)
        let card = try XCTUnwrap(DrillSentences.card("comprar", preterite, subject: subject))
        _ = card
        // "Hoy …" present perfect allows the preterite
        let perfect = DrillTense(kind: .perfect, tense: .present)
        let hoy = try XCTUnwrap(DrillSentences.card("comprar", perfect, subject: DrillSubject(text: "él", person: 2)))
        XCTAssertEqual(DrillAlternates.options(for: hoy).map(\.drill.title), ["Pretérito"])
        XCTAssertEqual(hoy.choosing(DrillTense(kind: .simple, tense: .preterite)).sentence, hoy.prompt.replacingOccurrences(of: "______", with: "compró"))
        // Every alternate is a real drill tense
        for drill in DrillTense.all {
            for variant in 0..<6 {
                guard let subject = DrillSentences.subjects(for: "hablar", drill).first, let made = DrillSentences.card("hablar", drill, subject: subject, variant: variant) else { continue }
                for option in DrillAlternates.options(for: made) { XCTAssertTrue(DrillTense.all.contains(option.drill)) }
            }
        }
    }
}

final class DrillInterchangeabilityTests: XCTestCase {
    private func card(_ verb: String, _ drill: DrillTense, containing text: String, subject: DrillSubject = DrillSubject(text: "él", person: 2)) throws -> DrillSentences.Card {
        try XCTUnwrap((0..<400).compactMap { DrillSentences.card(verb, drill, subject: subject, variant: $0) }.first { $0.sentence.lowercased().contains(text.lowercased()) }, "no \(drill.title) card with “\(text)”")
    }
    private func titles(_ card: DrillSentences.Card) -> [String] { DrillAlternates.options(for: card).map(\.drill.title) }

    func testThePluperfectIsNotInterchangeableWithThePreterite() throws {
        let card = try card("comprar", DrillTense(kind: .perfect, tense: .imperfect), containing: "cuando llegué, ya")
        XCTAssertTrue(DrillAlternates.options(for: card).isEmpty)
    }

    func testEachAuditedRowOffersExactlyWhatTheAuditSays() throws {
        func t(_ kind: DrillTense.Kind, _ tense: Tense) -> DrillTense { DrillTense(kind: kind, tense: tense) }
        XCTAssertEqual(titles(try card("comprar", t(.simple, .preterite), containing: "ayer")), ["Pretérito perfecto"])
        XCTAssertEqual(titles(try card("comprar", t(.perfect, .present), containing: "hoy")), ["Pretérito"])
        XCTAssertEqual(titles(try card("comprar", t(.simple, .future), containing: "mañana")), ["Ir a (ahora)", "Presente"])
        // "Algún día" goes with verbs about states and understanding
        XCTAssertEqual(titles(try card("comprender", t(.simple, .future), containing: "algún día")), ["Ir a (ahora)"])
        XCTAssertEqual(titles(try card("comprar", t(.irA, .present), containing: "mañana")), ["Futuro", "Presente"])
        XCTAssertEqual(titles(try card("comprar", t(.progressive, .present), containing: "ahora")), ["Presente"])
        XCTAssertEqual(titles(try card("comprar", t(.progressive, .preterite), containing: "toda la tarde")), ["Pretérito"])
        XCTAssertEqual(titles(try card("comprar", t(.progressive, .imperfect), containing: "cuando llamaste")), ["Imperfecto"])
        XCTAssertEqual(titles(try card("comprar", t(.progressive, .future), containing: "mañana a esta hora")), ["Futuro"])
        XCTAssertEqual(titles(try card("comprar", t(.progressive, .conditional), containing: "si hubiera tiempo")), ["Condicional"])
        XCTAssertEqual(titles(try card("comprar", t(.simple, .conditional), containing: "si hubiera tiempo")), ["Imperfecto"])
        XCTAssertEqual(titles(try card("comprar", t(.perfect, .conditional), containing: "si hubiera habido tiempo")), ["Pluscuamperfecto de subjuntivo"])
        XCTAssertEqual(titles(try card("comprar", t(.perfect, .future), containing: "para el viernes")), ["Futuro", "Ir a (ahora)"])
        XCTAssertEqual(titles(try card("comprar", t(.estarPor, .present), containing: "ahora")), ["Ir a (ahora)"])
        XCTAssertEqual(titles(try card("comprar", t(.estarPor, .imperfect), containing: "cuando llamaste")), ["Ir a (antes)"])
        XCTAssertEqual(titles(try card("comprar", t(.estarPor, .preterite), containing: "no pasó nada")), ["Ir a (antes)"])
        // Cards with no row have one answer
        XCTAssertTrue(DrillAlternates.options(for: try card("comprar", t(.acabarDe, .imperfect), containing: "cuando llegué")).isEmpty)
        XCTAssertTrue(DrillAlternates.options(for: try card("comprar", t(.simple, .subjunctivePresent), containing: "espero que")).isEmpty)
        XCTAssertTrue(DrillAlternates.options(for: try card("comprar", t(.simple, .imperfect), containing: "antes")).isEmpty)
    }

    func testNosotrosCommandsAcceptVamosA() throws {
        let imperative = DrillTense(kind: .simple, tense: .imperative)
        let card = try card("comprar", imperative, containing: "!", subject: DrillSubject(text: "nosotros", person: 3))
        let options = DrillAlternates.options(for: card)
        XCTAssertEqual(options.map(\.drill.title), ["Ir a (ahora)"])
        let chosen = card.choosing(options[0].drill)
        XCTAssertEqual(chosen.answer, "vamos a comprar")
        XCTAssertTrue(chosen.sentence.contains("¡Vamos a comprar"), chosen.sentence)
        // A command to tú has one answer
        let tu = try self.card("comprar", imperative, containing: "!", subject: DrillSubject(text: "tú", person: 1))
        XCTAssertTrue(DrillAlternates.options(for: tu).isEmpty)
    }

    func testColloquialOptionsAreLabelled() throws {
        let card = try card("comprar", DrillTense(kind: .simple, tense: .conditional), containing: "si hubiera tiempo")
        XCTAssertEqual(DrillAlternates.options(for: card).map(\.colloquial), [true])
        let standard = try self.card("comprar", DrillTense(kind: .simple, tense: .future), containing: "mañana")
        XCTAssertTrue(DrillAlternates.options(for: standard).allSatisfy { !$0.colloquial })
    }

    func testTheSeFormOfTheImperfectSubjunctiveIsTheSameAnswer() throws {
        let subjunctive = DrillTense(kind: .simple, tense: .subjunctiveImperfect)
        let card = try card("comprar", subjunctive, containing: "quería que")
        XCTAssertTrue(card.answer.hasSuffix("ara") || card.answer.hasSuffix("aran") || card.answer.hasSuffix("aras") || card.answer.hasSuffix("áramos"), card.answer)
        let seForm = try XCTUnwrap(DrillAlternates.equivalentForms(for: card).first)
        XCTAssertTrue(seForm.contains("ase") || seForm.contains("ásemos"), seForm)
        XCTAssertEqual(DrillChecker.grade(seForm, answer: seForm, infinitive: "comprar"), .correct)
        // Spot-check the transformation
        func seOf(_ answer: String) -> String? {
            let made = DrillSentences.Card(infinitive: "x", drill: subjunctive, subject: DrillSubject(text: "él", person: 2), prompt: "", sentence: "", answer: answer)
            return DrillAlternates.equivalentForms(for: made).first
        }
        XCTAssertEqual(seOf("comiera"), "comiese")
        XCTAssertEqual(seOf("comiéramos"), "comiésemos")
        XCTAssertEqual(seOf("hablaran"), "hablasen")
        XCTAssertEqual(seOf("hubiera comido"), "hubiese comido")
        XCTAssertEqual(seOf("estuviéramos hablando"), "estuviésemos hablando")
        XCTAssertEqual(seOf("fuera"), "fuese")
        // Other tenses have no -se spelling
        let present = DrillSentences.Card(infinitive: "x", drill: DrillTense(kind: .simple, tense: .present), subject: DrillSubject(text: "él", person: 2), prompt: "", sentence: "", answer: "come")
        XCTAssertTrue(DrillAlternates.equivalentForms(for: present).isEmpty)
    }

    func testEveryAlternateBuildsForRealVerbs() {
        for drill in DrillTense.all {
            for verb in ["hablar", "comer", "vivir", "ir", "tener", "hacer"] {
                for variant in 0..<12 {
                    guard let subject = DrillSentences.subjects(for: verb, drill).first, let made = DrillSentences.card(verb, drill, subject: subject, variant: variant) else { continue }
                    for option in DrillAlternates.options(for: made) {
                        let other = made.choosing(option.drill)
                        XCTAssertEqual(other.drill, option.drill)
                        XCTAssertFalse(other.answer.isEmpty)
                        XCTAssertFalse(other.sentence.contains("______"), other.sentence)
                        XCTAssertFalse(option.why.isEmpty)
                    }
                }
            }
        }
    }
}

final class DrillRelatedContextTests: XCTestCase {
    func testTheObjectIsReadFromTheComplement() throws {
        func thing(_ text: String, _ kind: Character) -> DrillRelatedContext.Thing? { DrillRelatedContext.thing(from: text, kind: kind) }
        let maestra = try XCTUnwrap(thing("a la maestra", "p"))
        XCTAssertEqual([maestra.definite, maestra.noun], ["la maestra", "maestra"])
        XCTAssertTrue(maestra.feminine && !maestra.plural)
        let vecino = try XCTUnwrap(thing("al vecino", "p"))
        XCTAssertEqual(vecino.definite, "el vecino")
        XCTAssertFalse(vecino.feminine)
        let ninos = try XCTUnwrap(thing("a los niños", "p"))
        XCTAssertTrue(ninos.plural && !ninos.feminine)
        let regalo = try XCTUnwrap(thing("un regalo", "t"))
        XCTAssertEqual(regalo.definite, "el regalo")
        XCTAssertEqual(regalo.phrase, "un regalo")
        let llaves = try XCTUnwrap(thing("las llaves", "t"))
        XCTAssertTrue(llaves.plural && llaves.feminine)
        let agua = try XCTUnwrap(thing("agua", "y"))
        XCTAssertEqual(agua.definite, "el agua")
        XCTAssertTrue(agua.feminine)
        // Not a noun phrase, or a kind that is not described
        XCTAssertNil(thing("ayuda", "j"))
        XCTAssertNil(thing("dinero", "g"))
        XCTAssertNil(thing("el libro", "q"))
    }

    func testTheSecondSentenceIsAboutTheObjectOfTheFirst() {
        let verbs = ["comprar", "ver", "leer", "escribir", "romper", "comer", "ayudar", "abrir", "llamar", "cuidar", "visitar", "vender", "preparar", "limpiar", "buscar"]
        var covered = 0, mentioned = 0
        for verb in verbs {
            guard let usage = VerbUsage.of(verb), usage.valency == "T", DrillRelatedContext.adjectives[usage.object] != nil else { continue }
            for drill in DrillTense.all {
                for subject in DrillSentences.subjects(for: verb, drill).prefix(2) {
                    for variant in 0..<3 {
                        guard let card = DrillSentences.card(verb, drill, subject: subject, variant: variant) else { continue }
                        covered += 1
                        // The noun of the object comes up in the sentence at least twice: in the first sentence and in the second
                        let nouns = Set(VerbUsage.objectNouns(usage.object))
                        if nouns.contains(where: { noun in card.sentence.lowercased().components(separatedBy: noun).count - 1 >= 2 }) { mentioned += 1 }
                    }
                }
            }
        }
        XCTAssertGreaterThan(covered, 500)
        XCTAssertGreaterThan(Double(mentioned) / Double(covered), 0.9, "\(mentioned) of \(covered) cards mention the object twice")
    }

    func testAdjectivesAgreeWithThePluralFeminineObject() throws {
        let llaves = try XCTUnwrap(DrillRelatedContext.thing(from: "las llaves", kind: "t"))
        for pool in ["imperfectScenes", "presentStates", "pastCloses", "futureCloses", "nowContrasts", "imperfectCloses", "timeContrasts"] {
            for seed in 0..<60 {
                guard let text = DrillRelatedContext.sentence(pool: pool, thing: llaves, seed: seed, infinitive: "comprar", target: "") else { continue }
                let words = text.lowercased().components(separatedBy: CharacterSet(charactersIn: " ."))
                XCTAssertFalse(words.contains { ["estaba", "era", "está", "es", "fue", "estuvo", "será", "estará"].contains($0) }, "singular verb with “las llaves”: \(text)")
                for word in words where ["sucio", "limpio", "listo", "roto", "mojado", "grande", "pequeño", "bonito", "nuevo", "viejo", "caro", "barato"].contains(word) {
                    XCTFail("masculine singular adjective with “las llaves”: \(text)")
                }
            }
        }
    }

    func testTheSecondSentenceNeverGivesAwayOrContradictsTheVerb() throws {
        let libro = try XCTUnwrap(DrillRelatedContext.thing(from: "el libro", kind: "d"))
        for seed in 0..<80 {
            for pool in ["imperfectScenes", "presentStates", "pastCloses", "futureCloses", "nowContrasts", "imperfectCloses", "timeContrasts"] {
                if let text = DrillRelatedContext.sentence(pool: pool, thing: libro, seed: seed, infinitive: "abrir", target: "") { XCTAssertFalse(text.contains("abierto"), text) }
                if let text = DrillRelatedContext.sentence(pool: pool, thing: libro, seed: seed, infinitive: "cerrar", target: "") { XCTAssertFalse(text.contains("cerrado"), text) }
            }
        }
        let paquete = try XCTUnwrap(DrillRelatedContext.thing(from: "el paquete", kind: "t"))
        for seed in 0..<80 {
            if let text = DrillRelatedContext.sentence(pool: "imperfectScenes", thing: paquete, seed: seed, infinitive: "romper", target: "") { XCTAssertFalse(text.contains("roto"), text) }
        }
    }

    func testItDoesNotRepeatTheTimeWordOrTheVerbOfTheFirstSentence() throws {
        let libro = try XCTUnwrap(DrillRelatedContext.thing(from: "el libro", kind: "t"))
        for seed in 0..<80 {
            if let text = DrillRelatedContext.sentence(pool: "timeContrasts", thing: libro, seed: seed, infinitive: "comprar", target: "Ayer él compró el libro.") {
                XCTAssertFalse(text.lowercased().contains("ayer"), text)
            }
            if let text = DrillRelatedContext.sentence(pool: "imperfectScenes", thing: libro, seed: seed, infinitive: "buscar", target: "") {
                XCTAssertFalse(text.contains("buscaban"), text)
            }
            if let text = DrillRelatedContext.sentence(pool: "pastCloses", thing: libro, seed: seed, infinitive: "hablar", target: "") {
                XCTAssertFalse(text.contains("hablaron"), text)
            }
        }
    }

    func testEveryAdjectiveCarriesTheLexiconTagForItsKindOfObject() {
        let needed: [Character: Set<String>] = [
            "f": ["f"], "y": ["f"], "p": ["p"], "l": ["l"], "c": ["l"],
            "t": ["t"], "d": ["t"], "v": ["t"], "n": ["t"], "m": ["t"], "b": ["t"], "a": ["i", "t"], "x": ["i", "t"], "h": ["i", "t"], "e": ["i", "t"],
        ]
        for (kind, words) in DrillRelatedContext.adjectives {
            for word in words.ser + words.estar {
                let tags = Set((Extras.shared.adjectiveCategories[word] ?? []).flatMap { $0 })
                XCTAssertFalse(tags.isDisjoint(with: needed[kind] ?? []), "\(word) is not tagged \(needed[kind] ?? []) for objects of kind \(kind)")
            }
        }
    }
}

final class DrillRelatedSourcesTests: XCTestCase {
    private func sources(_ verb: String, _ drill: DrillTense, subject: DrillSubject? = nil) -> [String] {
        let subjects = DrillSentences.subjects(for: verb, drill)
        guard let subject = subject ?? subjects.first else { return [] }
        return (1..<40).compactMap { DrillSentences.card(verb, drill, subject: subject, variant: $0)?.sentence }
    }

    func testDestinationsAndPeopleAfterAPrepositionAreDescribed() {
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        // A verb of motion: the second sentence is about where it goes
        let ir = sources("ir", preterite, subject: DrillSubject(text: "él", person: 2))
        XCTAssertTrue(ir.allSatisfy { sentence in sentence.contains("al trabajo") || ["escuela", "mercado", "oficina", "casa", "centro"].contains { sentence.lowercased().components(separatedBy: $0).count >= 3 } || sentence.contains("a casa") })
        // Not "el tiempo estaba preocupado"
        let luchar = sources("luchar", preterite, subject: DrillSubject(text: "él", person: 2))
        XCTAssertFalse(luchar.contains { $0.contains("El tiempo estaba") || $0.contains("Se necesitaba al tiempo") || $0.contains("Todos buscaban al tiempo") })
        // Not "el trabajo estaba vacío"
        let volver = sources("volver", DrillTense(kind: .simple, tense: .present), subject: DrillSubject(text: "él", person: 2))
        XCTAssertFalse(volver.contains { $0.contains("el trabajo estaba") || $0.contains("El trabajo estaba") || $0.contains("el trabajo es ") })
    }

    func testWhatIsSaidAndWantedHasRelatedSentences() {
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        let decir = sources("decir", preterite, subject: DrillSubject(text: "él", person: 2))
        // "que ya era tarde" goes with a sentence about the hour or the night
        for sentence in decir where sentence.contains("ya era tarde") {
            XCTAssertTrue(sentence.contains("de noche") || sentence.contains("las ocho") || sentence.contains("largo"), sentence)
        }
        let querer = sources("querer", preterite, subject: DrillSubject(text: "él", person: 2))
        for sentence in querer where sentence.contains("trabajar") { XCTAssertTrue(sentence.contains("trabajo"), sentence) }
        for sentence in querer where sentence.contains("estudiar") { XCTAssertTrue(sentence.contains("examen"), sentence) }
    }

    func testThingsThatAreTheSubjectGetSentencesAboutThem() {
        let present = DrillTense(kind: .simple, tense: .present)
        for sentence in sources("funcionar", present) { XCTAssertGreaterThanOrEqual(sentence.lowercased().components(separatedBy: "lavadora").count + sentence.lowercased().components(separatedBy: "teléfono").count + sentence.lowercased().components(separatedBy: "coche").count, 5, sentence) }
        // gustar: the thing that is liked
        let gustar = sources("gustar", present)
        XCTAssertFalse(gustar.isEmpty)
        for sentence in gustar { XCTAssertTrue(["libro", "idea", "clases", "película", "serie", "programa"].contains { sentence.lowercased().components(separatedBy: $0).count >= 3 }, sentence) }
    }

    func testTheDifferencesBetweenFilteredTensesAreSaid() {
        // The perfect shows under During too, so nothing is hidden here
        let during = DrillSelectionSummary.make(mood: .subjunctive, time: .present, moment: .during)
        XCTAssertEqual(during.lines.count, 5)  // the imperfect subjunctive also says unreal present
        XCTAssertTrue(during.lines.joined().contains("haya comido"))
        XCTAssertNil(during.hint)
        // Before holds only the perfect, and says what Before leaves out
        let before = DrillSelectionSummary.make(mood: .subjunctive, time: .present, moment: .before)
        XCTAssertEqual(before.lines, ["Pretérito perfecto de subjuntivo · haya comido"])
        let hint = before.hint ?? ""
        XCTAssertTrue(hint.contains("Clear Moment to add: Presente de subjuntivo (During)"), hint)
        // Nothing hidden: no hint
        XCTAssertNil(DrillSelectionSummary.make(mood: .imperative, time: nil, moment: nil).hint)
    }
}

final class DrillStillOpenTests: XCTestCase {
    private func cards(_ verb: String, _ drill: DrillTense, containing text: String, subject: DrillSubject = DrillSubject(text: "él", person: 2)) -> [DrillSentences.Card] {
        (0..<300).compactMap { DrillSentences.card(verb, drill, subject: subject, variant: $0) }.filter { $0.sentence.lowercased().contains(text) }
    }

    func testPerfectTensesAlsoCountAsDuring() {
        for moment in [DrillMoment.before, .during] {
            let titles = Set(DrillTense.matching(mood: nil, time: nil, moment: moment).map(\.title))
            XCTAssertTrue(titles.contains("Pretérito perfecto"), "\(moment)")
            XCTAssertTrue(titles.contains("Pretérito perfecto de subjuntivo"), "\(moment)")
            XCTAssertTrue(titles.contains("Pluscuamperfecto"), "\(moment)")
            XCTAssertTrue(titles.contains("Futuro perfecto"), "\(moment)")
        }
        // The phrases are not: "acaba de" is just before, "va a" is after
        XCTAssertFalse(DrillTense.matching(mood: .phrases, time: nil, moment: .during).contains { $0.kind == .acabarDe })
        // Every tense has at least one reading, and the first is its main one
        XCTAssertTrue(DrillTense.all.allSatisfy { !$0.readings.isEmpty })
    }

    func testPresentPerfectCardsAboutSomethingNotYetDone() throws {
        let perfect = DrillTense(kind: .perfect, tense: .present)
        let made = cards("comprar", perfect, containing: "todavía no")
        XCTAssertFalse(made.isEmpty, "no “todavía no” card among 300 variants")
        for card in made {
            XCTAssertTrue(card.sentence.contains("todavía no ha comprado"), card.sentence)
            XCTAssertTrue(card.prompt.contains("todavía no ______"), card.prompt)
            XCTAssertEqual(card.answer, "ha comprado")
            XCTAssertNotNil(DrillExplainer.explain(card).clue)
            XCTAssertTrue(DrillExplainer.explain(card).clue?.contains("Todavía no") == true)
            XCTAssertEqual(DrillAlternates.options(for: card).map(\.drill.title), ["Pretérito"])
        }
        // “Hoy” cards still exist
        XCTAssertFalse(cards("comprar", perfect, containing: "hoy").isEmpty)
    }

    func testThePluperfectAndTheSubjunctiveHaveStillOpenFramesToo() throws {
        let pluperfect = DrillTense(kind: .perfect, tense: .imperfect)
        let past = cards("comprar", pluperfect, containing: "todavía no")
        XCTAssertFalse(past.isEmpty)
        for card in past {
            XCTAssertTrue(card.sentence.contains("Cuando llegué, él todavía no había comprado"), card.sentence)
            XCTAssertTrue(DrillAlternates.options(for: card).isEmpty, "the pluperfect is not interchangeable with the preterite")
            XCTAssertNotNil(DrillExplainer.explain(card).clue)
        }
        let subjunctive = DrillTense(kind: .perfect, tense: .subjunctivePresent)
        let doubt = cards("comprar", subjunctive, containing: "no creo que")
        XCTAssertFalse(doubt.isEmpty)
        for card in doubt {
            XCTAssertTrue(card.sentence.contains("No creo que él haya comprado"), card.sentence)
            XCTAssertTrue(card.sentence.contains("todavía"), card.sentence)
            XCTAssertTrue(DrillExplainer.explain(card).clue?.contains("No creo que") == true)
        }
        // A same-subject card keeps the plain trigger ("No creo que yo haya…" would be odd)
        let same = cards("comprar", subjunctive, containing: "importante que", subject: DrillSubject(text: "yo", person: 0))
        XCTAssertTrue(cards("comprar", subjunctive, containing: "no creo que", subject: DrillSubject(text: "yo", person: 0)).isEmpty)
        XCTAssertFalse(same.isEmpty)
    }

    func testTheMomentLineSaysTheStillOpenReading() {
        XCTAssertTrue(DrillExplainer.momentLine(DrillTense(kind: .perfect, tense: .present)).contains("todavía no"))
        XCTAssertTrue(DrillExplainer.momentLine(DrillTense(kind: .perfect, tense: .imperfect)).contains("still had not happened"))
        // Acabar de is just before, and does not claim it
        XCTAssertFalse(DrillExplainer.momentLine(DrillTense(kind: .acabarDe, tense: .present)).contains("todavía"))
    }
}

final class DrillSelectionTests: XCTestCase {
    func testTappingATenseTogglesItAndTheChoiceIsSaved() {
        var selection = DrillSelection(raw: "")
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        let future = DrillTense(kind: .simple, tense: .future)
        XCTAssertTrue(selection.isEmpty)
        selection.toggle(preterite)
        selection.toggle(future)
        XCTAssertTrue(selection.contains(preterite) && selection.contains(future))
        selection.toggle(preterite)
        XCTAssertFalse(selection.contains(preterite))
        // Saved text comes back the same
        XCTAssertEqual(DrillSelection(raw: selection.raw), selection)
        XCTAssertEqual(DrillSelection(raw: selection.raw).tenses, [future])
    }

    func testPracticeUsesTheSelectedTensesOrWhatTheFiltersShow() {
        let shown = DrillTense.matching(mood: .subjunctive, time: nil, moment: nil)
        var selection = DrillSelection(raw: "")
        XCTAssertEqual(selection.practiceSet(shown: shown), shown, "nothing toggled: the filtered tenses")
        let preterite = DrillTense(kind: .simple, tense: .preterite)
        selection.toggle(preterite)
        XCTAssertEqual(selection.practiceSet(shown: shown), [preterite], "toggled tenses win, even when the filters hide them")
        XCTAssertEqual(selection.hiddenCount(shown: shown), 1)
        selection.add(shown)
        XCTAssertEqual(selection.practiceSet(shown: shown).count, shown.count + 1)
        XCTAssertEqual(selection.hiddenCount(shown: shown), 1)
        selection.remove(shown)
        XCTAssertEqual(selection.tenses, [preterite])
        selection.clear()
        XCTAssertTrue(selection.isEmpty)
    }

    func testTheSelectionIsKeptInTheDrillsOwnOrder() {
        var selection = DrillSelection(raw: "")
        selection.add(Array(DrillTense.all.reversed().prefix(5)))
        XCTAssertEqual(selection.tenses, Array(DrillTense.all.suffix(5)))
    }

    func testSavedTextWithUnknownTensesIsIgnored() {
        let selection = DrillSelection(raw: "simple present,not a tense,,perfect future")
        XCTAssertEqual(selection.tenses.map(\.title), ["Presente", "Futuro perfecto"])
    }
}

final class DrillProgressiveSettingTests: XCTestCase {
    override func tearDown() { UserDefaults.standard.removeObject(forKey: AppSettings.drillProgressiveKey) }

    func testTurningProgressiveOffLeavesThemOutEverywhere() {
        UserDefaults.standard.set(false, forKey: AppSettings.drillProgressiveKey)
        XCTAssertFalse(DrillTense.available.contains { $0.kind == .progressive })
        XCTAssertFalse(DrillTense.matching(mood: nil, time: nil, moment: nil).contains { $0.kind == .progressive })
        let saved = DrillSelection(raw: DrillTense.all.map(\.key).joined(separator: ","))
        XCTAssertFalse(saved.tenses.contains { $0.kind == .progressive })
        UserDefaults.standard.set(true, forKey: AppSettings.drillProgressiveKey)
        XCTAssertEqual(DrillTense.available.count, DrillTense.all.count)
    }
}
