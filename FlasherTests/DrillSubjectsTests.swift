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
