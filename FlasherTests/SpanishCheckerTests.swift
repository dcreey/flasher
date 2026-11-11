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

    func testMexicanVersionKeepsGenderAndLeavesVerbsAlone() {
        XCTAssertEqual(CountryTranslation.localize("Cerca del ordenador.").text, "Cerca de la computadora.")
        XCTAssertEqual(CountryTranslation.localize("Abre el grifo.").text, "Abre la llave.")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "Voy a conducir mi coche.").text, "Voy a manejar mi carro.")
        // Verbs and words that are already Mexican are never swapped for something else
        XCTAssertEqual(CountryTranslation.slangVersion(of: "Quiero comer con mi amigo.").text, "Quiero comer con mi amigo.")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "El niño bebe agua.").text, "El chavo bebe agua.")
    }

    /// The dictionary knows the same swaps: Spain's word page names Mexico's, and English search puts Mexico's first.
    func testDictionaryShowsMexicanWords() {
        let defaults = UserDefaults.standard
        defaults.set(Country.mexico.rawValue, forKey: AppSettings.countryKey)
        defer { defaults.removeObject(forKey: AppSettings.countryKey) }
        XCTAssertEqual(MexicoWords.insteadOf["zumo"], "el jugo")
        XCTAssertEqual(MexicoWords.insteadOf["pajita"], "el popote")
        XCTAssertEqual(MexicoWords.insteadOf["gafas"], "los lentes")
        XCTAssertEqual(MexicoWords.insteadOf["conducir"], "manejar")
        XCTAssertNil(MexicoWords.insteadOf["autobús"])
        func rank(_ english: String, _ spanish: String) -> Int {
            DictionaryIndex.search(english, scope: .english).firstIndex { $0.word.spanish == spanish } ?? .max
        }
        XCTAssertLessThan(rank("juice", "jugo"), rank("juice", "zumo"))
        XCTAssertLessThan(rank("drinking straw", "popote"), rank("drinking straw", "pajita"))
        XCTAssertLessThan(rank("computer", "computadora"), rank("computer", "ordenador"))
        XCTAssertLessThan(rank("eyeglasses", "lentes"), rank("eyeglasses", "gafas"))
        // Searching the Spain word in Spanish still finds it first
        XCTAssertEqual(DictionaryIndex.search("zumo", scope: .spanish).first?.word.spanish, "zumo")
    }

    func testMexicanWordsFromTheResearch() {
        let cases: [(String, String)] = [
            ("Coge el autobús.", "Toma el autobús."),
            ("Cogí la pelota.", "Agarré la pelota."),
            ("Me gusta conducir.", "Me gusta manejar."),
            ("Esto conduce a problemas.", "Esto conduce a problemas."),
            ("Bebo zumo de naranja con una pajita.", "Bebo jugo de naranja con un popote."),
            ("Compré una tarta y unas patatas.", "Compré un pastel y unas papas."),
            ("La bombilla del dormitorio no funciona.", "El foco de la recámara no funciona."),
            ("Abre el grifo de la bañera.", "Abre la llave de la tina."),
            ("Pon el móvil en el maletero.", "Pon el celular en la cajuela."),
            ("Se me pinchó la rueda y se estropeó el coche.", "Se me ponchó la rueda y se descompuso el carro."),
            ("Llevo una chaqueta y unos vaqueros.", "Llevo una chamarra y unos jeans."),
            ("Me hice daño en la piscina.", "Me lastimé en la alberca."),
            ("Date prisa, que vamos a alquilar un piso.", "Apúrate, que vamos a rentar un piso."),
            ("Suspendí el examen.", "Reprobé el examen."),
            ("Tiró de la puerta.", "Jaló la puerta."),
            ("Una tira de papel.", "Una tira de papel."),
            ("Las judías verdes y los guisantes.", "Los ejotes y los chícharos."),
            ("Mis camiones y el autobús.", "Mis camiones y el autobús."),
            ("¡Qué guay!", "¡Qué padre!"),
            ("Somos uña y carne.", "Somos uña y mugre."),
            ("Hay que hacer cola.", "Hay que hacer fila."),
            ("La luz intermitente.", "La luz intermitente."),
            ("El intermitente está roto.", "La direccional está roto."),
        ]
        for (spain, mexico) in cases { XCTAssertEqual(CountryTranslation.localize(spain).text, mexico, spain) }
        XCTAssertEqual(MexicoWords.plural(of: "judía verde"), "judías verdes")
        XCTAssertEqual(MexicoWords.plural(of: "interfón"), "interfones")
        XCTAssertEqual(MexicoWords.plural(of: "lápiz labial"), "lápices labiales")
        XCTAssertEqual(MexicoWords.plural(of: "bote de basura"), "botes de basura")
        // Thousands of swaps, but a sentence still takes a moment
        _ = CountryTranslation.localize("Hola.")
        let start = Date()
        for _ in 0..<20 { _ = CountryTranslation.localize("Mañana voy a coger el tren para ver a mi familia, que vive lejos de la ciudad.") }
        XCTAssertLessThan(Date().timeIntervalSince(start) / 20, 0.05)
    }

    func testMissingSomeoneIsExtrañar() {
        // Spain's "echar de menos" becomes "extrañar"
        XCTAssertEqual(CountryTranslation.localize("Te echo de menos.").text, "Te extraño.")
        XCTAssertEqual(CountryTranslation.localize("Te eché de menos.").text, "Te extrañé.")
        XCTAssertEqual(CountryTranslation.localize("Te echo mucho de menos.").text, "Te extraño mucho.")
        XCTAssertEqual(CountryTranslation.localize("Voy a echarte de menos.").text, "Voy a extrañarte.")
        // "te extraño" is the verb (I miss you), not the adjective "strange", so no "fuereño"
        XCTAssertTrue(CountryTranslation.alternatives(in: "Te extraño").isEmpty, "\(CountryTranslation.alternatives(in: "Te extraño"))")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "Te extraño.").text, "Te extraño.")
        XCTAssertEqual(WordLinks.resolve("extraño", after: "te")?.spanish, "extrañar")
        // Still the adjective when it is one
        XCTAssertEqual(WordLinks.resolve("extraño", after: "algo")?.spanish, "extraño")
    }

    func testMexicanPhrases() {
        XCTAssertEqual(CountryTranslation.slangVersion(of: "No puede ser.").text, "No manches.")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "¡De ninguna manera!").text, "¡Ni de chiste!")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "Me voy ahora mismo. No hay problema.").text, "Me voy ahorita. No hay bronca.")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "Tengo resaca.").text, "Tengo cruda.")
        // A reaction inside a longer sentence is literal and stays as it is
        XCTAssertEqual(CountryTranslation.slangVersion(of: "No puede ser tan difícil.").text, "No puede ser tan difícil.")
    }

    func testColombiaSwapsWordsAndDeck() {
        let defaults = UserDefaults.standard
        defaults.set(Country.colombia.rawValue, forKey: AppSettings.countryKey)
        defer { defaults.removeObject(forKey: AppSettings.countryKey) }

        XCTAssertEqual(CountryTranslation.slangVersion(of: "Voy a conducir mi coche.").text, "Voy a manejar mi carro.")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "No puede ser.").text, "No joda.")
        XCTAssertEqual(CountryTranslation.slangVersion(of: "Me voy ahora mismo.").text, "Me voy ya mismo.")

        let ids = Set(SeedData.words.map(\.spanish))
        XCTAssertTrue(ids.contains("esfero"))
        XCTAssertFalse(ids.contains("pluma"))
        XCTAssertEqual(ids.count, SeedData.words.count, "no word appears twice")
        XCTAssertTrue(Lexicon.shared.wordsByID["chévere"] != nil)
        XCTAssertTrue(Lexicon.shared.hasLocalMeaning(Lexicon.shared.wordsByID["esfero"]!))
        defaults.set(Country.mexico.rawValue, forKey: AppSettings.countryKey)
        XCTAssertTrue(SeedData.words.contains { $0.spanish == "pluma" })
    }

    func testHeadsUpTraps() {
        func ids(_ en: String, _ es: String) -> Set<String> { Set(TranslationTraps.find(english: en, spanish: es).map(\.id)) }
        for en in ["I am hot.", "I'm very warm", "I’m so hot right now", "im really really hot", "I feel a little bit warm", "We are too hot", "I was getting hot", "I'm burning up"] {
            XCTAssertTrue(ids(en, "").contains("hot"), en)
        }
        XCTAssertTrue(ids("", "Estoy muy caliente.").contains("hot"))
        XCTAssertTrue(ids("", "Me siento caliente").contains("hot"))
        XCTAssertTrue(ids("She is so hot", "").contains("hotPerson"))
        XCTAssertTrue(ids("You're hot", "").contains("hotPerson"))
        XCTAssertTrue(ids("I'm freezing", "").contains("cold"))
        XCTAssertTrue(ids("He is really cold", "").contains("cold"))
        XCTAssertTrue(ids("She's very hungry", "").contains("tener"))
        XCTAssertTrue(ids("I'm embarrassed", "Estoy avergonzado").contains("embarrassed"))
        XCTAssertTrue(ids("", "Voy a coger el autobús").contains("cogerMX"))
        XCTAssertTrue(ids("", "Cógelo").contains("cogerMX"))
        XCTAssertTrue(ids("Let's take the bus", "Tomemos el autobús").contains("cogerMX"))
        XCTAssertTrue(ids("I'm 25 years old", "Tengo 25 años").contains("age"))
        XCTAssertTrue(ids("She is twenty-five years old", "").contains("age"))
        XCTAssertTrue(ids("", "Soy veinticinco años").contains("age"))
        XCTAssertTrue(ids("I'm good", "Estoy bueno").contains("good"))
        XCTAssertTrue(ids("He's so bored", "Es muy aburrido").contains("bored"))
        XCTAssertTrue(ids("They are ready", "").contains("ready"))
        XCTAssertTrue(ids("I record music", "Grabo música").contains("record"))
        // Not about how a person feels
        XCTAssertFalse(ids("The coffee is hot.", "El café está caliente.").contains("hot"))
        XCTAssertFalse(ids("The coffee is hot.", "").contains("hotPerson"))
        XCTAssertFalse(ids("He says it is hot.", "Dice que hace calor.").contains("hot"))
        XCTAssertFalse(ids("It is cold outside.", "Hace frío afuera.").contains("cold"))
        XCTAssertFalse(ids("I have 25 apples", "Tengo 25 manzanas").contains("age"))
        XCTAssertTrue(ids("I read a book", "Leí un libro").isEmpty)
    }

    func testSavedSettingsShowUpAsExistingInstall() {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "welcome_test_probe")
        defer { defaults.removeObject(forKey: "welcome_test_probe") }
        let saved = Bundle.main.bundleIdentifier.flatMap { defaults.persistentDomain(forName: $0) } ?? [:]
        XCTAssertFalse(saved.isEmpty)
    }

    func testTranslationIsFixedWhenTheEnglishIsClear() {
        func fixed(_ es: String, _ en: String) -> String { TranslationTraps.fixing(es, english: en) }
        XCTAssertEqual(fixed("Estoy caliente.", "I am hot."), "Tengo calor.")
        XCTAssertEqual(fixed("Estoy muy caliente.", "I'm very warm"), "Tengo mucho calor.")
        XCTAssertEqual(fixed("Estamos demasiado calientes.", "We are too hot"), "Tenemos demasiado calor.")
        XCTAssertEqual(fixed("Estoy un poco frío.", "I'm a little cold"), "Tengo un poco de frío.")
        XCTAssertEqual(fixed("Estoy muy hambriento.", "I'm very hungry"), "Tengo mucha hambre.")
        XCTAssertEqual(fixed("Estoy embarazada.", "I'm embarrassed"), "Estoy avergonzada.")
        XCTAssertEqual(fixed("Estoy excitado.", "I'm so excited"), "Estoy emocionado.")
        XCTAssertEqual(fixed("Soy 25 años.", "I'm 25"), "Tengo 25 años.")
        XCTAssertEqual(fixed("Soy aburrido.", "I'm bored"), "Estoy aburrido.")
        XCTAssertEqual(fixed("Me vengo.", "I'm coming"), "Ya voy.")
        // Left alone when the English is about something else
        XCTAssertEqual(fixed("El café está caliente.", "The coffee is hot."), "El café está caliente.")
        XCTAssertEqual(fixed("Estoy caliente.", "He says it is hot."), "Estoy caliente.")
        XCTAssertEqual(fixed("Estoy embarazada.", "I am pregnant."), "Estoy embarazada.")
    }

    func testEnglishIsFixedWhenTheSpanishHasAHiddenMeaning() {
        func fixed(_ en: String, _ es: String) -> String { TranslationTraps.fixingEnglish(en, spanish: es) }
        XCTAssertEqual(fixed("I'm hot.", "Estoy caliente."), "I'm aroused.")
        XCTAssertEqual(fixed("I'm very hot.", "Estoy muy caliente."), "I'm very aroused.")
        XCTAssertEqual(fixed("I'm coming.", "Me vengo."), "I climax.")
        XCTAssertEqual(fixed("I'm good.", "Estoy bueno."), "I'm attractive.")
        // Ordinary Spanish keeps Apple's English
        XCTAssertEqual(fixed("I'm hot.", "Tengo calor."), "I'm hot.")
        XCTAssertEqual(fixed("The coffee is hot.", "El café está caliente."), "The coffee is hot.")
    }

    func testRegionalTrapsFollowTheTargetCountry() {
        let defaults = UserDefaults.standard
        defer { defaults.removeObject(forKey: AppSettings.countryKey) }
        func ids(_ es: String) -> Set<String> { Set(TranslationTraps.find(english: "", spanish: es).map(\.id)) }
        defaults.set(Country.mexico.rawValue, forKey: AppSettings.countryKey)
        XCTAssertTrue(ids("¿Qué pedo?").contains("pedo"))
        XCTAssertTrue(ids("Es un pelado").contains("peladoMX"))
        XCTAssertFalse(ids("Dame un tinto").contains("tinto"))
        defaults.set(Country.colombia.rawValue, forKey: AppSettings.countryKey)
        XCTAssertTrue(ids("Dame un tinto").contains("tinto"))
        XCTAssertTrue(ids("Es un pelado").contains("peladoCO"))
        XCTAssertFalse(ids("¿Qué pedo?").contains("pedo"))
        XCTAssertTrue(ids("Vamos a mamar gallo").contains("mamarCO"))
    }

    func testReflexivePronounWithWrongPersonVerb() {
        let tips = SpanishChecker.check("te vaya a la playa").filter { $0.kind == .tip }
        XCTAssertEqual(tips.count, 1)
        XCTAssertTrue(tips.first?.message.contains("vete") ?? false)
        XCTAssertTrue(tips.first?.message.contains("váyase") ?? false)
        XCTAssertTrue(tips.first?.message.contains("te vayas") ?? false)
        // Fine on their own
        XCTAssertTrue(SpanishChecker.check("Quiero que te vayas a la playa").filter { $0.kind == .tip }.isEmpty)
        XCTAssertTrue(SpanishChecker.check("Ojalá te vaya bien").filter { $0.kind == .tip }.isEmpty)
        XCTAssertTrue(SpanishChecker.check("Vete a la playa").filter { $0.kind == .tip }.isEmpty)
        XCTAssertTrue(SpanishChecker.check("Me guste o no, voy").filter { $0.kind == .tip }.isEmpty)
    }

    func testMoodNoteWhenAppleReadsACommandAsAStatement() {
        XCTAssertNotNil(TranslationTraps.moodNote(spanish: "te vaya a la playa", english: "You go to the beach"))
        XCTAssertNil(TranslationTraps.moodNote(spanish: "Vaya a la playa", english: "Go to the beach"))
        XCTAssertNil(TranslationTraps.moodNote(spanish: "Voy a la playa", english: "I go to the beach"))
        XCTAssertNil(TranslationTraps.moodNote(spanish: "Quiero que vaya", english: "I want him to go"))
    }
}

final class IndicativeAfterBeliefTests: XCTestCase {
    private func mistakes(_ text: String) -> [SpanishIssue] { SpanishChecker.check(text).filter { $0.kind != .tip } }

    func testSubjunctiveAfterBeliefIsFlagged() {
        XCTAssertEqual(mistakes("Creo que tengas buen día").first?.suggestion, "tienes")
        XCTAssertEqual(mistakes("Pienso que vengas mañana").first?.suggestion, "vienes")
        XCTAssertEqual(mistakes("Es verdad que seas mi amigo").first?.suggestion, "eres")
    }

    func testCorrectMoodIsLeftAlone() {
        for text in ["Creo que tienes buen día", "No creo que tengas buen día", "¿Crees que tengas tiempo?", "No me parece que sea verdad", "Quiero que tengas buen día", "No dudo que es verdad"] {
            XCTAssertTrue(mistakes(text).isEmpty, text)
        }
    }
}

final class MoodResearchCheckerTests: XCTestCase {
    private func mistakes(_ text: String) -> [SpanishIssue] { SpanishChecker.check(text).filter { $0.kind != .tip } }

    /// Triggers that always take the subjunctive.
    func testAlwaysSubjunctiveTriggersFlagTheIndicative() {
        let cases = [("Puede que viene mañana", "venga"), ("En caso de que llueve, nos quedamos", "llueva"), ("No es que no quiero", "quiera"),
                     ("Es una lástima que no vienes", "vengas"), ("Hace falta que estudias más", "estudies"), ("Me molesta que llegas tarde", "llegues"),
                     ("Espera a que llega tu padre", "llegue"), ("A no ser que tienes prisa, quédate", "tengas"), ("Más vale que vienes pronto", "vengas")]
        for (text, fix) in cases { XCTAssertEqual(mistakes(text).first?.suggestion, fix, text) }
    }

    /// "Si" and "por si" never take the present subjunctive.
    func testPresentSubjunctiveAfterSiIsFlagged() {
        XCTAssertEqual(mistakes("Si tengas tiempo, llámame").first?.suggestion, "tienes")
        XCTAssertEqual(mistakes("Llévate un paraguas por si llueva").first?.suggestion, "llueve")
    }

    /// Same subject: an infinitive, not "que yo".
    func testSameSubjectWishTakesTheInfinitive() {
        XCTAssertEqual(mistakes("Quiero que yo vaya").first?.suggestion, "Quiero ir")
    }

    /// Both moods are correct here, or the indicative is right: the checker must say nothing.
    func testTwoMoodTriggersStaySilent() {
        for text in ["No dudo que sea verdad", "No dudo que es verdad", "No niego que sea un problema", "Te digo que vengas", "Le dice que se calle",
                     "Me temo que perderemos", "Temo que sea tarde", "Aunque llueve, salgo", "Aunque llueva, saldré", "Cuando llegues, te llamo",
                     "Quizás viene", "Quizás venga", "A lo mejor viene", "No sé si vaya", "Habla como si fuera el jefe", "Si bien es caro, vale la pena",
                     "Si tengo tiempo, te llamo", "Si tuviera tiempo, te llamaría", "Por si llueve, llévate un paraguas", "No es mentira que es caro",
                     "¿No es verdad que viene?", "No es verdad que venga", "Puede que venga", "Es que no tengo tiempo", "Lo importante es que estés bien",
                     "Quiero ir", "Quiero que vayas", "No cabe duda de que es él", "Todos estamos un poco tristes", "¿No crees que ya es tarde?", "¿No piensas que es mejor así?", "Espero que pueda ir", "Es mejor que me vaya", "Trabajé hasta que me cansé", "Me alegro de que hayamos ganado", "Quiero que vayamos juntos"] {
            XCTAssertTrue(mistakes(text).isEmpty, "\(text): \(mistakes(text).map(\.message))")
        }
    }

    /// Certainty takes the indicative.
    func testCertaintyFlagsTheSubjunctive() {
        XCTAssertEqual(mistakes("No cabe duda de que sea él").first?.suggestion, "es")
        XCTAssertEqual(mistakes("Estoy seguro de que tengas razón").first?.suggestion, "tienes")
    }
}

final class TenseAlternativesTests: XCTestCase {
    private func first(_ text: String) -> TenseSuggestion? { TenseAlternatives.suggestions(for: text).first }

    func testPreteriteOffersPresentPerfect() {
        let s = first("Ya terminé el trabajo.")
        XCTAssertEqual(s?.rewritten, "Ya he terminado el trabajo")
        XCTAssertEqual(s?.focus, ConjugationFocus(form: .participle, tense: .present, person: 0))
    }

    func testReflexiveKeepsItsPronoun() {
        XCTAssertEqual(first("Se levantó temprano.")?.rewritten, "Se ha levantado temprano")
    }

    func testDefinitePastTimeGetsNoPerfect() {
        XCTAssertNil(first("Terminé el trabajo ayer."))
        XCTAssertNil(first("Hace dos años viajé a Cali."))
    }

    func testPerfectOffersPreterite() {
        let s = first("No he comido todavía.")
        XCTAssertEqual(s?.rewritten, "No comí todavía")
        XCTAssertEqual(s?.focus, ConjugationFocus(form: .infinitive, tense: .preterite, person: 0))
    }

    func testSequenceOffersPastPerfect() {
        XCTAssertEqual(first("Comí tacos y salí.")?.rewritten, "Ya había comido tacos cuando salí")
        XCTAssertEqual(first("Se levantó y salió.")?.rewritten, "Ya se había levantado cuando salió")
        XCTAssertEqual(first("Comí tacos y salí.")?.focus.tense, .imperfect)
    }

    func testSequenceNeedsPlainOrdering() {
        XCTAssertNil(first("Dije que comí y salí porque quise."))
    }

    func testChainsGetANoteInsteadOfARewrite() {
        for text in ["Comí y bebí y salí.", "Hice un café, lo tomé y salí.", "Comí y luego salí y después dormí.", "Comí y luego, después de eso, salí."] {
            let s = first(text)
            XCTAssertEqual(s?.isNote, true, text)
            XCTAssertEqual(s?.rewritten, "", text)
            XCTAssertTrue(s?.note.contains("chain of finished actions") ?? false, text)
        }
    }

    func testCuandoWithTwoPreteritesExplainsTheShift() {
        let s = first("Cuando llegué, salió.")
        XCTAssertEqual(s?.isNote, true)
        XCTAssertEqual(s?.rewritten, "Cuando llegué, ya había salido")
        XCTAssertTrue(s?.note.contains("right after the first") ?? false)
    }

    func testPastPerfectIsReorderedIntoTwoPreterites() {
        let s = first("Cuando llegué, ya se había ido.")
        XCTAssertEqual(s?.rewritten, "Se fue y después llegué")
        XCTAssertTrue(s?.note.contains("loses some nuance") ?? false)
        XCTAssertEqual(first("Ya se había ido cuando llegué.")?.rewritten, "Se fue y después llegué")
    }

    func testLonePastPerfectExplainsItNeedsAnAnchor() {
        let s = first("Ya había comido.")
        XCTAssertEqual(s?.rewritten, "Cuando llamaste, ya había comido")
        XCTAssertEqual(s?.isNote, true)
        XCTAssertTrue(s?.note.contains("follows a clause that introduced another past event") ?? false)
        XCTAssertNotNil(first("Nunca había visto el mar."))
        XCTAssertNil(first("Todavía no había llegado cuando llamaste."))
    }

    func testPerfectIsNotOfferedWhenAnotherVerbWouldStayBehind() {
        // "tome" without its accent could be tomé, tome or tomes: the second verb can't be placed, so no half-rewritten sentence
        XCTAssertNil(first("Hice un cafe y despues lo tome."))
        XCTAssertEqual(first("Hice un café y después lo tomé.")?.rewritten, "Ya había hecho un café cuando lo tomé")
    }

    func testEverydayWordsAreNotVerbs() {
        XCTAssertNil(first("Así es."))
    }

    func testPlainPresentGetsNothing() {
        XCTAssertTrue(TenseAlternatives.suggestions(for: "Como tacos todos los días.").isEmpty)
    }

    func testCompoundForms() throws {
        let comer = try XCTUnwrap(Conjugator.conjugate("comer"))
        XCTAssertEqual(CompoundForms.form(of: comer, .participle, .present, 0), "he comido")
        XCTAssertEqual(CompoundForms.form(of: comer, .participle, .imperfect, 3), "habíamos comido")
        XCTAssertEqual(CompoundForms.form(of: comer, .gerund, .imperfect, 2), "estaba comiendo")
        XCTAssertNil(CompoundForms.form(of: comer, .participle, .preterite, 0))
    }

    func testFocusRoundTripsThroughALink() throws {
        let word = try XCTUnwrap(Lexicon.shared.wordsByID["comer"])
        let focus = ConjugationFocus(form: .participle, tense: .subjunctiveImperfect, person: 4)
        let url = try XCTUnwrap(WordLinks.url(for: word, focus: focus))
        XCTAssertEqual(ConjugationFocus(queryItems: URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems), focus)
        XCTAssertNil(ConjugationFocus(queryItems: nil))
    }
}

final class SubjunctiveCardsTests: XCTestCase {
    private func first(_ text: String) -> TenseSuggestion? { TenseAlternatives.suggestions(for: text).first }

    func testEveryRule() {
        let cases: [(String, String)] = [
            ("Quería que vengas.", "Quería que vinieras"),
            ("Esperaba que hayas llegado.", "Esperaba que hubieras llegado"),
            ("Quiero que vinieras.", "Quiero que vengas"),
            ("Quiero que hubieras venido.", "Quiero que hayas venido"),
            ("Dudo que llegue ayer.", "Dudo que haya llegado ayer"),
            ("Si tendría tiempo, iría.", "Si tuviera tiempo, iría"),
            ("Si habría sabido, habría venido.", "Si hubiera sabido, habría venido"),
            ("Cuando llegaré, te llamo.", "Cuando llegue, te llamo"),
            ("Si tuviese tiempo, iría.", "Si tuviera tiempo, iría"),
        ]
        for (text, expected) in cases {
            let s = first(text)
            print("CASE \(text) → \(s?.heading ?? "-") · \(s?.title ?? "-") | \(s?.rewritten ?? "nil") | \(s?.note ?? "")")
            XCTAssertEqual(s?.rewritten, expected, text)
        }
        let future = first("Si hubiere necesidad, avise.")
        print("CASE future → \(future?.title ?? "nil") | \(future?.note ?? "")")
        XCTAssertEqual(future?.title, "Future subjunctive")
    }

    func testComoSiUnknownThingAndAunque() {
        XCTAssertEqual(first("Habla como si es el jefe.")?.rewritten, "Habla como si fuera el jefe")
        XCTAssertEqual(first("Habla como si ha ganado.")?.rewritten, "Habla como si hubiera ganado")
        XCTAssertEqual(first("Busco un coche que tiene cuatro puertas.")?.rewritten, "Busco un coche que tenga cuatro puertas")
        let aunque = first("Aunque llueve mañana, iré.")
        XCTAssertEqual(aunque?.rewritten, "Aunque llueva mañana, iré")
        XCTAssertEqual(aunque?.heading, "Good to know")
    }

    func testOtherMoodSentencesStaySilent() {
        for text in ["Habla como si fuera el jefe.", "Busco el coche que tiene cuatro puertas.", "Tengo un coche que tiene cuatro puertas.", "Aunque llueve ahora, voy.",
                     "Aunque llueve por la mañana, voy.", "No dudo que es verdad.", "Es verdad que practicas.", "Creo que es verdad."] {
            XCTAssertNil(TenseAlternatives.suggestions(for: text).first { $0.heading != nil }, text)
        }
    }

    func testCorrectSentencesStaySilent() {
        for text in ["Quería que vinieras.", "Quiero que vengas.", "No sé si tendría tiempo.", "Cuando llegue, te llamo.", "Si tuviera tiempo, iría.", "Espero que hayas llegado.", "Cuando llegué, te llamé."] {
            XCTAssertNil(TenseAlternatives.suggestions(for: text).first { $0.heading == "Tense match" || $0.id.hasPrefix("se-") || $0.id.hasPrefix("future-") }, text)
        }
    }

    func testNounPhraseAfterTriggerIsNotTheVerb() {
        // "luces" is also a form of lucir, but here it is the subject
        XCTAssertTrue(SpanishChecker.check("Espero que las luces empiecen a funcionar.").filter { $0.kind != .tip }.isEmpty)
        XCTAssertTrue(SpanishChecker.check("Quiero que mi hermana venga.").filter { $0.kind != .tip }.isEmpty)
        XCTAssertTrue(SpanishChecker.check("Creo que los precios suben.").filter { $0.kind != .tip }.isEmpty)
    }
}

final class SeguroDeInfinitiveTests: XCTestCase {
    private func fixes(_ text: String) -> [String] {
        SpanishChecker.check(text).filter { $0.kind == .grammar }.compactMap(\.suggestion)
    }

    func testMissingDeBeforeAnInfinitiveIsCaught() {
        XCTAssertEqual(fixes("No estoy seguro podernos hacer la actividad hoy."), ["estoy seguro de podernos"])
        XCTAssertEqual(fixes("Estoy seguro ir mañana."), ["Estoy seguro de ir"])
        XCTAssertEqual(fixes("Estamos convencidos ganar el partido."), ["Estamos convencidos de ganar"])
        XCTAssertEqual(fixes("Estaba segura poder hacerlo."), ["Estaba segura de poder"])
    }

    func testCorrectSentencesAreLeftAlone() {
        XCTAssertTrue(fixes("No estoy seguro de podernos hacer la actividad hoy.").isEmpty)
        XCTAssertTrue(fixes("Estoy seguro de que viene.").isEmpty)
        XCTAssertTrue(fixes("Estoy seguro del plan.").isEmpty)
        XCTAssertTrue(fixes("Ella está segura en casa.").isEmpty)
        // "lugar" ends in -ar but is a noun
        XCTAssertTrue(fixes("Estoy seguro lugar.").isEmpty)
    }
}

final class DecirFutureTests: XCTestCase {
    func testDecirHasTheIrregularFutureAndConditional() throws {
        let decir = try XCTUnwrap(Conjugator.conjugate("decir"))
        XCTAssertEqual((0..<6).compactMap { decir.form(.future, $0) }, ["diré", "dirás", "dirá", "diremos", "diréis", "dirán"])
        XCTAssertEqual((0..<6).compactMap { decir.form(.conditional, $0) }, ["diría", "dirías", "diría", "diríamos", "diríais", "dirían"])
        XCTAssertEqual(decir.form(.present, 0), "digo")
        XCTAssertEqual(decir.form(.preterite, 2), "dijo")
        XCTAssertEqual(decir.participle, "dicho")
    }

    func testVerbsBuiltOnDecirFollowTheAcademyForms() throws {
        // These four have a regular future and conditional
        for (verb, future, conditional) in [("predecir", "predeciré", "predeciría"), ("contradecir", "contradeciré", "contradeciría"),
                                             ("bendecir", "bendeciré", "bendeciría"), ("maldecir", "maldeciré", "maldeciría")] {
            let c = try XCTUnwrap(Conjugator.conjugate(verb), verb)
            XCTAssertEqual(c.form(.future, 0), future, verb)
            XCTAssertEqual(c.form(.conditional, 0), conditional, verb)
        }
        // The rest of their forms still follow decir
        XCTAssertEqual(Conjugator.conjugate("predecir")?.form(.preterite, 2), "predijo")
        XCTAssertEqual(Conjugator.conjugate("contradecir")?.form(.present, 0), "contradigo")
        // desdecir is fully like decir
        XCTAssertEqual(Conjugator.conjugate("desdecir")?.form(.future, 0), "desdiré")
    }

    /// A tapped verb form opens the plain verb, not a phrase verb that shares its forms ("echaron" is echar, not echar relajo).
    func testSharedVerbFormsOfferEveryVerb() {
        let names = VerbForms.candidates("echaron").map(\.spanish)
        XCTAssertEqual(names.first, "echar")
        XCTAssertTrue(names.count > 1)
        let url = WordLinks.linked("Me echaron").runs.compactMap(\.link).last
        XCTAssertTrue(url?.absoluteString.contains("alts=") ?? false)
    }

    func testWordLinksPreferThePlainVerb() {
        for form in ["echaron", "echó", "echo", "echado", "echando"] { XCTAssertEqual(WordLinks.resolve(form)?.spanish, "echar", form) }
        XCTAssertEqual(WordLinks.resolve("tomaron")?.spanish, "tomar")
    }
}
