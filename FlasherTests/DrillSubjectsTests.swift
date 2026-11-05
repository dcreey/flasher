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
        XCTAssertTrue(titles(.indicative, .present, .before).contains("Presente perfecto"))
        XCTAssertTrue(titles(.phrases, .past, .after).contains("Ir a (antes)"))
        XCTAssertEqual(titles(.indicative, .past, .during), ["Pretérito", "Imperfecto", "Pretérito progresivo", "Imperfecto progresivo"])
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
