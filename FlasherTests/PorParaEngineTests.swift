import XCTest
@testable import Flasher

/// The checker on the Por vs para guide. The full scoring against real sentences lives in docs/research/por-para-engine.
final class PorParaEngineTests: XCTestCase {

    private func check(_ sentence: String, _ answer: PorParaEngine.Answer, _ rule: PorParaEngine.Rule? = nil, file: StaticString = #filePath, line: UInt = #line) {
        guard let verdict = PorParaEngine.explain(sentence).first else { return XCTFail("no verdict: \(sentence)", file: file, line: line) }
        XCTAssertEqual(verdict.answer, answer, "\(sentence): \(verdict.rule) \(verdict.why)", file: file, line: line)
        if let rule { XCTAssertEqual(verdict.rule, rule, sentence, file: file, line: line) }
    }

    func testTheFivePs() {
        check("Salgo ___ Monterrey mañana.", .para, .place)
        check("Este regalo es ___ ti.", .para)
        check("La tarea es ___ el lunes.", .para, .pointInTime)
        check("Estudio ___ aprender.", .para, .purpose)
        check("___ mí, es la mejor película.", .para, .perspective)
        check("Habla muy bien ___ su edad.", .para, .perspective)
    }

    func testPorDrivesItOrPassesThrough() {
        check("Gracias ___ la ayuda.", .por, .reason)
        check("Caminamos ___ el parque.", .por, .route)
        check("Te llamo ___ teléfono.", .por, .means)
        check("Lo compré ___ cien pesos.", .por, .price)
        check("Trabajo ___ la mañana.", .por, .time)
        check("Fue escrito ___ Cervantes.", .por, .agent)
        check("Voy ___ las tortillas.", .por, .after)
        check("Luchan ___ la libertad.", .por, .after)
        check("¿Qué puedo hacer ___ ti?", .por, .forSomeone)
    }

    func testExceptionsAndSetPhrases() {
        check("Te voy a querer ___ siempre.", .para, .memorised)
        check("Tranquilo, no es ___ tanto.", .para, .memorised)
        check("Dos tacos, ___ favor.", .por, .setPhrase)
        check("Me quedan dos capítulos ___ leer.", .por, .stillToDo)
        check("No hay razón ___ quedarnos.", .para, .purpose)
        check("Son diez ___ las cinco.", .para, .pointInTime)
    }

    func testEveryAnswerNamesALineOfTheSimpleRules() {
        for rule in [PorParaEngine.Rule.place, .person, .pointInTime, .purpose, .perspective, .reason, .after, .forSomeone, .agent, .route, .means, .price, .time, .memorised] {
            XCTAssertTrue(rule.inRules, "\(rule)")
            XCTAssertTrue(rule.title.hasPrefix("Para: where it ends up") || rule.title.hasPrefix("Por: ") || rule.title.hasPrefix("Memorise: "), rule.title)
        }
        for rule in [PorParaEngine.Rule.aboutTo, .stillToDo, .setPhrase] {
            XCTAssertFalse(rule.inRules)
            XCTAssertEqual(rule.title, "Not covered by the rules: memorise this one")
        }
    }

    func testSpotsTheWrongOne() {
        let verdict = PorParaEngine.explain("Gracias para la ayuda.").first
        XCTAssertEqual(verdict?.answer, .por)
        XCTAssertTrue(verdict?.disagrees == true)
        XCTAssertFalse(PorParaEngine.explain("Gracias por la ayuda.").first?.disagrees ?? true)
    }

    func testParaTheVerbIsLeftAlone() {
        XCTAssertTrue(PorParaEngine.explain("El bus para en la esquina.").isEmpty)
        XCTAssertEqual(PorParaEngine.explain("Voy por pan para la cena.").count, 2)
    }
}
