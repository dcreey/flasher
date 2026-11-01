import XCTest
@testable import Flasher

/// Tests for the Spanish rules engine. Every rule has cases that must be flagged and cases that look similar but are
/// correct and must stay silent: a false alarm on good Spanish is worse than a missed mistake.
final class SpanishCheckerTests: XCTestCase {

    // MARK: - Helpers

    private func issues(_ text: String) -> [SpanishIssue] { SpanishChecker.check(text) }

    /// The mistakes (everything except heads-up tips) found in the text.
    private func mistakes(_ text: String) -> [SpanishIssue] { issues(text).filter { $0.kind != .tip } }

    private func assertFlags(_ text: String, _ kind: SpanishIssue.Kind, found: String? = nil, suggestion: String? = nil,
                             file: StaticString = #filePath, line: UInt = #line) {
        let all = issues(text)
        guard let issue = all.first(where: { $0.kind == kind && (found == nil || $0.found.lowercased() == found!.lowercased()) }) else {
            XCTFail("Expected a \(kind.rawValue) issue\(found.map { " on “\($0)”" } ?? "") in “\(text)”, got: \(all.map { "\($0.kind.rawValue): \($0.found)" })", file: file, line: line)
            return
        }
        if let suggestion { XCTAssertEqual(issue.suggestion?.lowercased(), suggestion.lowercased(), "suggestion for “\(text)”", file: file, line: line) }
    }

    private func assertClean(_ text: String, file: StaticString = #filePath, line: UInt = #line) {
        let found = mistakes(text)
        XCTAssertTrue(found.isEmpty, "Expected no mistakes in “\(text)”, got: \(found.map { "\($0.kind.rawValue): \($0.found) — \($0.message)" })", file: file, line: line)
    }

    // MARK: - Pronoun order

    func testLeLoBecomesSeLo() {
        assertFlags("Le lo dije ayer.", .pronouns, found: "Le lo")
        assertFlags("Les las di a mis amigos.", .pronouns)
        assertClean("Se lo dije ayer.")
    }

    func testDirectBeforeIndirectIsBackwards() {
        assertFlags("Lo me dijo ayer.", .pronouns)
        assertClean("Me lo dijo ayer.")
        assertClean("Te lo dije.")
    }

    func testLoSeMeansIKnowIt() {
        assertClean("Yo lo se.")
        assertClean("Lo sé todo.")
    }

    func testReflexiveOrder() {
        assertFlags("Me se cayó el vaso.", .pronouns, suggestion: "se me")
        assertFlags("Te se perdió la llave.", .pronouns, suggestion: "se te")
        assertClean("Se me cayó el vaso.")
        assertClean("Se te perdió la llave.")
        assertClean("Yo me se la lección.")      // "se" is the verb sé written without its accent
    }

    // MARK: - Pronouns and commands

    func testPronounBeforeAffirmativeCommand() {
        assertFlags("Me haz un favor.", .pronouns, found: "Me haz")
        assertClean("Hazme un favor.")
        assertClean("La sal está en la mesa.")   // "la" is an article here, "sal" a noun
    }

    func testEveryMistakeIsListed() {
        let found = SpanishChecker.check("Le lo haz.").map(\.found)
        XCTAssertEqual(found.count, 2, "\(found)")
        XCTAssertTrue(found.contains("Le lo") && found.contains("lo haz"), "\(found)")
    }

    func testHaberExamplesUseAParticiple() {
        let c = Conjugator.conjugate("haber")!
        for tense in [Tense.present, .imperfect, .future, .conditional, .subjunctivePresent, .subjunctiveImperfect] {
            let e = TenseExamples.generated(tense: tense, person: 0, conjugation: c, gloss: "to have")
            XCTAssertTrue(e?.spanish.contains("comido") == true, "\(tense)")
        }
    }

    func testAttachedPronounOnNegativeCommand() {
        assertFlags("No dímelo.", .pronouns)
        assertClean("No me lo digas.")
        assertClean("Dímelo ahora.")
    }

    func testPronounAttachedToConjugatedVerb() {
        assertFlags("Quiero digome algo.", .pronouns, found: "digome", suggestion: "me digo")
        assertClean("Quiero decírtelo.")
        assertClean("Dame un momento.")
    }

    func testAttachedFormsNeedTheirAccent() {
        assertFlags("Hablame ya.", .spelling, suggestion: "háblame")
        assertFlags("Dimelo ahora.", .spelling, suggestion: "dímelo")
        assertClean("Háblame ya.")
        assertClean("Dímelo ahora.")
        assertClean("Quiero verte pronto.")
        assertClean("Vámonos.")
    }

    // MARK: - Spelling

    func testMissingAccents() {
        assertFlags("Mi telefono no funciona.", .spelling, found: "telefono", suggestion: "teléfono")
        assertClean("Mi teléfono no funciona.")
        assertClean("Maria dice hola.")           // capitalised words are never accent-checked: they may be names
        assertClean("Esta es mi casa.")           // "esta" is a real word
    }

    // MARK: - Agreement

    func testArticleGender() {
        assertFlags("Tengo un casa nueva.", .agreement, found: "un casa", suggestion: "una casa")
        assertFlags("La problema es grande.", .agreement, found: "La problema", suggestion: "el problema")
        assertClean("Tengo una casa nueva.")
        assertClean("El problema es grande.")
    }

    func testFeminineNounsWithStressedA() {
        assertClean("El agua está fría.")
        assertClean("Un alma buena.")
        assertClean("El hambre es mala.")
    }

    func testNounsWithBothGendersAreSkipped() {
        assertClean("El capital y la capital.")
        assertClean("El policía y la policía.")
        assertClean("El cura y la cura.")
    }

    func testArticleNumber() {
        assertFlags("Las flor son bonitas.", .agreement, found: "Las flor")
        assertClean("Las flores son bonitas.")
        assertClean("Los lunes trabajo.")         // lunes is the same singular and plural
        assertClean("Las crisis pasan.")
    }

    func testPronounLikeArticlesBeforeVerbs() {
        assertClean("La canto cada noche.")       // "la" is "it" here: I sing it
        assertClean("Las casa con mi hermano.")   // "casar" form: he marries them
    }

    func testAdjectiveAgreement() {
        assertFlags("La casa bonito es mía.", .agreement, found: "casa bonito", suggestion: "casa bonita")
        assertFlags("Los niños pequeñas juegan.", .agreement)
        assertFlags("Las casas bonita son caras.", .agreement)
        assertClean("La casa bonita es mía.")
        assertClean("Las casas bonitas son caras.")
        assertClean("Un día bonito.")
        assertClean("La mano derecha.")
        assertClean("Las casas rosa y los coches naranja.")   // colors taken from nouns never change
        assertClean("El problema grande y la casa grande.")
    }

    func testSubjectAndVerb() {
        assertFlags("Yo tiene hambre.", .agreement, found: "Yo tiene")
        assertFlags("Ellos va al cine.", .agreement)
        assertClean("Yo tengo hambre.")
        assertClean("Ellos van al cine.")
        assertClean("Mi hermano y yo vamos al cine.")
        assertClean("Ella y yo comemos juntas.")
        assertClean("Entre tú y yo hay confianza.")
        assertClean("Tú ven aquí.")               // ven is also the command for tú
    }

    // MARK: - Grammar

    func testContractions() {
        assertFlags("Voy a el mercado.", .grammar, found: "a el", suggestion: "al")
        assertFlags("Es el libro de el profesor.", .grammar, suggestion: "del")
        assertClean("Voy al mercado.")
        assertClean("Vive en El Salvador y viajó a El Paso.")
        assertClean("Es de él.")
    }

    func testRepeatedWords() {
        assertFlags("Vi el el perro.", .grammar, found: "el el")
        assertClean("No, no quiero.")
        assertClean("Es que, que yo sepa, no.")
    }

    func testAgeUsesTener() {
        assertFlags("Soy 25 años.", .grammar, suggestion: "tengo 25 años")
        assertFlags("Estás veinte años.", .grammar)
        assertClean("Tengo 25 años.")
        assertClean("Hace 25 años que vivo aquí.")
    }

    func testDoubleComparative() {
        assertFlags("Es más mejor que el otro.", .grammar, suggestion: "mejor")
        assertClean("Es mejor que el otro.")
        assertClean("Es más bueno que el otro.")
    }

    func testWhyInQuestions() {
        assertFlags("¿Porque lloras?", .spelling, suggestion: "¿por qué")
        assertClean("¿Por qué lloras?")
        assertClean("Lloro porque estoy triste.")
    }

    func testDequeismo() {
        assertFlags("Pienso de que es buena idea.", .grammar, suggestion: "Pienso que")
        assertFlags("Me dijo de que vendría.", .grammar)
        assertClean("Pienso que es buena idea.")
        assertClean("Dudo de que venga.")         // dudar de que is correct
        assertClean("La espera de que llegue fue larga.")
    }

    func testQueismo() {
        assertFlags("Me alegro que vengas.", .grammar, suggestion: "Me alegro de que")
        assertFlags("Me di cuenta que era tarde.", .grammar, suggestion: "Me di cuenta de que")
        assertFlags("Estoy seguro que viene.", .grammar, suggestion: "Estoy seguro de que")
        assertClean("Me alegro de que vengas.")
        assertClean("Me alegra que vengas.")      // alegrar needs no "de"
        assertClean("Me di cuenta de que era tarde.")
        assertClean("Seguro que viene.")
    }

    func testRedundancy() {
        assertFlags("Voy a subir para arriba.", .style)
        assertFlags("Quiero entrar adentro.", .style)
        assertFlags("Tengo que volver a repetir la lección.", .style)
        assertClean("Voy a subir las escaleras.")
        assertClean("Voy para arriba.")
    }

    // MARK: - Punctuation

    /// Missing ¿ and ¡ are informal and common, and Apple's translations don't need them flagged, so they are not checked.
    func testMissingQuestionAndExclamationMarksAreIgnored() {
        assertClean("Como estas?")
        assertClean("Hola!")
        assertClean("¿Cómo estás?")
    }

    // MARK: - Mood and verb forms

    func testSubjunctiveAfterTriggers() {
        assertFlags("Quiero que vienes mañana.", .verb, suggestion: "vengas")
        assertFlags("Espero que estás bien.", .verb, suggestion: "estés")
        assertFlags("Ojalá tengo suerte.", .verb, suggestion: "tenga")
        assertFlags("Es importante que estudias.", .verb)
        assertFlags("No creo que viene.", .verb)
        assertClean("Quiero que vengas mañana.")
        assertClean("Espero que estés bien.")
        assertClean("Ojalá tenga suerte.")
        assertClean("Quiero que los niños vengan.")   // a noun phrase comes first, so the verb isn't checked
        assertClean("¿Para que sirve esto?")          // "para qué" written without its accent
        assertClean("Te lo digo para que lo sepas.")
        assertClean("Creo que viene.")
    }

    func testIrregularVerbsConjugatedAsRegular() {
        assertFlags("Ella tenió suerte ayer.", .verb, found: "tenió", suggestion: "tuvo")
        assertFlags("Ayer hací la tarea.", .verb, found: "hací", suggestion: "hice")
        assertFlags("Ella ponió la mesa.", .verb, found: "ponió", suggestion: "puso")
        assertClean("Tuvo suerte ayer.")
        assertClean("Hice la tarea.")
        assertClean("Ella puso la mesa.")
        assertClean("Yo sé la respuesta.")
        assertClean("Vos tenés razón.")
    }

    // MARK: - Heads-up tips

    func testFalseFriendsAreTipsNotMistakes() {
        let found = issues("Ella está embarazada.")
        XCTAssertTrue(found.contains { $0.kind == .tip && $0.found == "embarazada" })
        XCTAssertTrue(mistakes("Ella está embarazada.").isEmpty)
        XCTAssertTrue(issues("Es una carpeta nueva.").contains { $0.kind == .tip })
        XCTAssertTrue(issues("Tengo una casa.").isEmpty)
    }

    // MARK: - Correct Spanish must stay silent

    func testCorrectSpanishProducesNoMistakes() {
        let sentences = [
            "Hola Cati, ¿cómo estás? Yo me veo bien. Nos vemos mañana en el mercado.",
            "Dímelo ahora, por favor. No me lo digas todavía. Díselo a tu mamá.",
            "El agua está fría, pero el niño quiere un vaso. Las manos limpias.",
            "La capital es bonita y el capital es grande. El cura habla con la cura.",
            "Mi hermano y yo vamos al cine. Ella y yo comemos juntas. Entre tú y yo hay confianza.",
            "Quiero verte pronto, y también vernos el sábado. Vámonos ya.",
            "Ellos no me lo dijeron. Se lo di ayer. Se me cayó el vaso.",
            "Tuvo suerte, hizo la tarea, supo la verdad y dijo que sí. Puso la mesa.",
            "Pienso que es buena idea. Me di cuenta de que era tarde. Estoy seguro de que viene.",
            "Ojalá venga. Para que lo sepas. Antes de que llegue. Quiero que vengas.",
            "Las casas son grandes. Los problemas son difíciles. Una persona amable y unas personas amables.",
            "El estudiante y la estudiante. El lunes y los lunes. La crisis y las crisis.",
            "Voy al mercado con el niño. Es del profesor. Vive en El Salvador.",
            "Tengo 25 años y tengo hambre. Hace tres años que vivo aquí.",
            "¿Por qué lloras? ¿Para qué sirve? ¡Qué bonito! Lloro porque estoy triste.",
            "Lo sé todo. La sal está en la mesa. La canto cada noche.",
            "Compré una casa bonita, unos libros rojos y las flores amarillas.",
            "Hablamos del problema y salió de la casa. Subió las escaleras.",
        ]
        for sentence in sentences { assertClean(sentence) }
    }

    // MARK: - Pieces the rules are built on

    func testAttachingPronounsMovesTheAccent() {
        let cases: [(String, [String], Int?, String)] = [
            ("ver", ["nos"], nil, "vernos"), ("hacer", ["lo"], nil, "hacerlo"), ("oír", ["lo"], nil, "oírlo"),
            ("viendo", ["nos"], nil, "viéndonos"), ("diciendo", ["le"], nil, "diciéndole"), ("dando", ["me", "lo"], nil, "dándomelo"),
            ("dar", ["me", "lo"], nil, "dármelo"), ("di", ["me", "lo"], 1, "dímelo"), ("diga", ["me"], 2, "dígame"),
            ("digan", ["me"], 5, "díganme"), ("digamos", ["nos"], 3, "digámonos"), ("vamos", ["nos"], 3, "vámonos"),
            ("sentad", ["os"], 4, "sentaos"), ("dé", ["me"], 2, "deme"), ("da", ["me"], 1, "dame"), ("da", ["me", "lo"], 1, "dámelo"),
            ("ve", ["nos"], 1, "venos"), ("veamos", ["nos"], 3, "veámonos"), ("vean", ["nos"], 5, "véannos"), ("di", ["se", "lo"], 1, "díselo"),
            ("comprar", ["se", "lo"], nil, "comprárselo"), ("escribir", ["le"], nil, "escribirle"), ("trae", ["me", "lo"], 1, "tráemelo"),
            ("diciendo", ["se", "lo"], nil, "diciéndoselo"), ("leyendo", ["lo"], nil, "leyéndolo"), ("pon", ["lo"], 1, "ponlo"),
        ]
        for (form, pronouns, person, expected) in cases {
            XCTAssertEqual(SpanishStress.attach(form, pronouns: pronouns, person: person), expected, "\(form) + \(pronouns)")
        }
    }

    func testSyllableStress() {
        func stressed(_ word: String) -> Int {
            let letters = Array(word)
            return SpanishStress.stress(letters, SpanishStress.syllables(letters))
        }
        XCTAssertEqual(stressed("casa"), 0)
        XCTAssertEqual(stressed("papel"), 1)
        XCTAssertEqual(stressed("teléfono"), 1)
        XCTAssertEqual(stressed("canción"), 1)
        XCTAssertEqual(stressed("agua"), 0)
        XCTAssertEqual(stressed("hambre"), 0)
    }

    func testCliticResolution() {
        XCTAssertEqual(Clitics.resolve("vernos")?.verb.spanish, "ver")
        XCTAssertEqual(Clitics.resolve("dímelo")?.pronouns, ["me", "lo"])
        XCTAssertEqual(Clitics.resolve("vámonos")?.verb.spanish, "ir")
        XCTAssertEqual(Clitics.resolve("dándomelo")?.verb.spanish, "dar")
        XCTAssertEqual(Clitics.resolve("vayámonos")?.verb.spanish, "ir")           // vayamos + nos
        XCTAssertEqual(Clitics.resolveApproximately("vamanos")?.didYouMean, "vámonos")
        XCTAssertNil(Clitics.resolveApproximately("lavamanos"))                    // a real word
        XCTAssertNil(Clitics.resolve("casa"))
        XCTAssertNil(Clitics.resolve("telefono"))
    }

    func testPronounPlusConjugatedVerb() {
        XCTAssertEqual(Clitics.resolvePhrase("nos veo")?.verb.spanish, "ver")
        XCTAssertEqual(Clitics.resolvePhrase("yo me veo")?.verb.spanish, "ver")        // the subject is dropped
        XCTAssertEqual(Clitics.resolvePhrase("me lo dice")?.pronouns, ["me", "lo"])
        XCTAssertEqual(Clitics.resolvePhrase("le lo dice")?.pronouns, ["se", "lo"])    // corrected
        XCTAssertNotNil(Clitics.resolvePhrase("le lo dice")?.correction)
        XCTAssertNil(Clitics.resolvePhrase("la casa"))
    }

    func testSearchFindsMisspelledAttachedForms() {
        XCTAssertEqual(DictionaryIndex.search("vamanos", scope: .all).first?.word.spanish, "ir")
        XCTAssertEqual(DictionaryIndex.search("vámonos", scope: .all).first?.word.spanish, "ir")
        XCTAssertEqual(DictionaryIndex.search("nos veo", scope: .all).first?.word.spanish, "ver")
        assertFlags("Vamanos ya, que es tarde.", .spelling, suggestion: "vámonos")
        assertClean("Vámonos ya, que es tarde.")
    }

    func testSearchCorrections() {
        XCTAssertNotNil(Clitics.correction(forQuery: "le lo"))
        XCTAssertNotNil(Clitics.correction(forQuery: "lo me"))
        XCTAssertNotNil(Clitics.correction(forQuery: "me haz"))
        XCTAssertNotNil(Clitics.correction(forQuery: "no dímelo"))
        XCTAssertNil(Clitics.correction(forQuery: "lo se"))
        XCTAssertNil(Clitics.correction(forQuery: "la sal"))
        XCTAssertNil(Clitics.correction(forQuery: "no me lo digas"))
    }

    func testIssuesAreSortedAndDoNotOverlap() {
        let found = issues("Le lo dije. Yo tiene un casa. Me haz un favor?")
        XCTAssertEqual(found.map(\.range.location), found.map(\.range.location).sorted())
        for (a, b) in zip(found, found.dropFirst()) {
            XCTAssertEqual(NSIntersectionRange(a.range, b.range).length, 0, "\(a.found) overlaps \(b.found)")
        }
    }

    func testEmptyAndPlainText() {
        XCTAssertTrue(issues("").isEmpty)
        XCTAssertTrue(issues("   ").isEmpty)
        XCTAssertTrue(issues("12345 !!! ...").isEmpty)
    }

    // MARK: - Real sentences

    /// The dictionary's own example sentences are real Spanish. Most are correct, so the engine should rarely object. What it
    /// does flag should be a missing accent or an actual error in the example, not a false alarm.
    func testRealExampleSentencesRarelyTriggerGrammarRules() {
        var sentences: [String] = []
        var seen = Set<String>()
        for (_, list) in Extras.shared.examples { for example in list where seen.insert(example.spanish).inserted { sentences.append(example.spanish) } }
        XCTAssertGreaterThan(sentences.count, 2000, "the example sentences should be bundled with the app")
        sentences.sort()

        var byKind: [SpanishIssue.Kind: Int] = [:]
        for sentence in sentences {
            for issue in SpanishChecker.check(sentence) where issue.kind != .tip { byKind[issue.kind, default: 0] += 1 }
        }
        // Spelling hits are mostly true omissions in informal text; the grammar rules should almost never fire.
        let grammarRules: [SpanishIssue.Kind] = [.agreement, .verb, .pronouns, .grammar, .style]
        let grammarHits = grammarRules.reduce(0) { $0 + (byKind[$1] ?? 0) }
        XCTAssertLessThanOrEqual(grammarHits, 12, "grammar rules fired \(grammarHits) times on \(sentences.count) real sentences: \(byKind)")
        XCTAssertLessThanOrEqual(byKind[.spelling] ?? 0, 40, "spelling rule fired too often: \(byKind)")
    }
}
