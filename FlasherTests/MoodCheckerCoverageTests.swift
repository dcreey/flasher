import XCTest
@testable import Flasher

/// The Spanish checker against everything the Learn course and the trigger list teach: every wrong answer on a Learn card,
/// and every trigger example put in the wrong mood, must be flagged; the right versions must not be.
final class MoodCheckerCoverageTests: XCTestCase {
    /// An error, or a mood heads-up (for what's standard but heard otherwise in Latin America).
    static func flagged(_ text: String) -> Bool {
        SpanishChecker.check(text).contains { $0.kind == .verb || $0.kind == .grammar } || SpanishChecker.moodIssues(text).contains { $0.kind == .tip }
    }

    /// A trigger example with its verb moved to the other mood ("Quiero que vengas." → "Quiero que vienes.").
    static func otherMood(_ sentence: String, toSubjunctive: Bool, after phrase: String) -> String? {
        let words = sentence.lowercased().split { !$0.isLetter }.map(String.init)
        let last = phrase.lowercased().split { !$0.isLetter }.last.map(String.init) ?? ""
        let start = words.firstIndex { $0 == last || $0.hasPrefix(String(last.prefix(4))) } ?? 0
        let verbs = MoodTenseLabels.verbs(in: sentence).filter { $0.position > start }
        guard let verb = (toSubjunctive ? verbs.first { $0.base == .present || $0.base == .imperfect || $0.base == .preterite } : verbs.first { $0.isSubjunctive }),
              !verb.perfect, let person = verb.persons.first, let c = Conjugator.conjugate(verb.verb) else { return nil }
        let target: Tense
        switch verb.base {
        case .subjunctivePresent?: target = .present
        case .subjunctiveImperfect?: target = .imperfect
        case .present?: target = .subjunctivePresent
        default: target = .subjunctiveImperfect
        }
        guard let form = c.form(target, person), form.lowercased() != verb.word else { return nil }
        guard let range = sentence.range(of: "\\b\(verb.word)\\b", options: [.regularExpression, .caseInsensitive]) else { return nil }
        var out = sentence
        out.replaceSubrange(range, with: form)
        return out
    }

    func testReport() {
        var report = "LEARN WRONG ANSWERS NOT FLAGGED\n"
        var missed = 0, total = 0
        for item in MoodMap.items where item.kind == .form {
            for (i, choice) in item.choices.enumerated() where !item.correct.contains(i) {
                let text = item.prompt.replacingOccurrences(of: "___", with: choice)
                total += 1
                if !Self.flagged(text) { missed += 1; report += "\(item.id)\t\(text)\t[\(item.context)]\n" }
            }
        }
        report += "\(missed) of \(total) missed\n\nTRIGGER EXAMPLES IN THE WRONG MOOD NOT FLAGGED\n"
        var tMissed = 0, tTotal = 0
        for trigger in MoodTriggers.all {
            var cases: [String] = []
            if let subj = trigger.subjunctive, [.subjunctive, .indicativeWithNo].contains(trigger.behavior), let bad = Self.otherMood(subj, toSubjunctive: false, after: trigger.phrase) { cases.append(bad) }
            if let ind = trigger.indicative, [.indicative, .subjunctiveWithNo].contains(trigger.behavior), let bad = Self.otherMood(ind, toSubjunctive: true, after: trigger.phrase) { cases.append(bad) }
            for bad in cases {
                tTotal += 1
                if !Self.flagged(bad) { tMissed += 1; report += "\(trigger.phrase)\t\(bad)\n" }
            }
        }
        report += "\(tMissed) of \(tTotal) missed\n\nFALSE FLAGS ON CORRECT SPANISH\n"
        var correct: [String] = []
        for item in MoodMap.items {
            switch item.kind {
            case .form: correct += item.correct.map { item.prompt.replacingOccurrences(of: "___", with: item.choices[$0]) }
            case .meaning: correct.append(item.prompt)
            case .flip: correct.append(item.prompt); MoodTenseLabels.changed(item).map { correct.append($0) }
            }
        }
        correct += MoodMap.briefings.values.flatMap { $0.examples.map(\.spanish) }
        correct += MoodTriggers.all.flatMap { [$0.indicative, $0.subjunctive].compactMap { $0 } }
        correct += SeedData.handcraftedSentenceMap.values.flatMap { $0.map(\.1) }
        var falseFlags = 0
        for text in Set(correct).sorted() {
            for issue in SpanishChecker.moodIssues(text) where issue.kind != .tip { falseFlags += 1; report += "\(text)\t<<< \(issue.message)\n" }
        }
        report += "\(falseFlags) false flags in \(Set(correct).count) correct sentences\n"
        try? report.write(toFile: NSTemporaryDirectory() + "checker_coverage.txt", atomically: true, encoding: .utf8)
        print("COVERAGE:" + NSTemporaryDirectory() + "checker_coverage.txt")
    }

    /// Learn cards whose wrong answer is still grammatical Spanish: only the card's situation makes it wrong, so no checker can
    /// flag it without knowing what the writer meant. Every other wrong answer on a Learn card must be flagged.
    static let meaningOnly: [String: String] = {
        var reasons: [String: String] = [:]
        // The same person or someone else: "quiero que vaya" is right when it's about him
        for id in ["want.same.1", "want.same.3", "want.same.4", "subject.1", "subject.feel.1", "subject.feel.3", "subject.feel.4", "subject.prep.1",
                   "subject.prep.3", "subject.impersonal.1", "subject.impersonal.8", "subject.doer.1", "subject.doer.3", "subject.perfect.1"] {
            reasons[id] = "same person or someone else"
        }
        // Both moods are correct; they say different things (a fact, a habit or something known vs a wish, something to come or unknown)
        for id in ["want.decir.3", "subject.belief.2", "want.meaning.4", "want.meaning.5", "want.meaning.6", "want.convencer.1", "unknown.1",
                   "unknown.superlative.4", "unknown.free.1", "unknown.free.2", "unknown.free.4", "unknown.ask.5", "time.1", "time.2", "time.4",
                   "time.despues.2", "time.mientras.1", "time.mientras.2", "time.mientras.3", "time.mientras.4", "subject.allowed.5",
                   "concession.1", "concession.2", "concession.3", "concession.pormas.1", "concession.pormas.2", "concession.pormas.3",
                   "concession.unreal.3", "condition.others.4", "purpose.demodo.2", "purpose.nosea.3", "purpose.nosea.4", "doubt.mentira.2",
                   "imperfect.unreal.2", "imperfect.unreal.3", "alone.ojala.2", "sequence.haber.1", "sequence.haber.3", "sequence.earlier.2"] {
            reasons[id] = "both moods are correct, with different meanings"
        }
        // A question or a statement that reads as either: "No hablas" (you don't speak) vs the command "no hables"
        for id in ["belief.question.1", "belief.question.2", "belief.question.3", "impersonal.agree.1", "alone.commands.1", "alone.commands.2",
                   "alone.commands.3", "alone.que.1", "alone.que.2", "alone.que.3"] {
            reasons[id] = "reads as a statement, question or warning that is correct"
        }
        // Heard in Mexico and accepted there
        for id in ["condition.si.2", "belief.whether.1", "feel.temerse.1"] { reasons[id] = "regional, accepted in Mexico" }
        // The later cards: each wrong answer is still correct Spanish with another meaning (a habit or a plan, same person or
        // another, a command or a statement, a regional form), so only the card's situation makes it wrong
        for id in ["belief.6", "time.5", "time.6", "concession.4", "concession.5", "concession.6", "alone.5", "want.same.5", "want.same.6", "want.same.7", "want.decir.4", "want.decir.5", "feel.temerse.4", "feel.temerse.6", "belief.question.4", "belief.question.5", "belief.question.6", "unknown.none.6", "unknown.superlative.6", "time.despues.4", "time.despues.6", "condition.como.4", "purpose.demodo.4", "purpose.demodo.5", "purpose.demodo.6", "concession.pormas.6", "alone.que.5", "alone.que.6", "subject.4", "subject.6", "subject.feel.5", "subject.prep.5", "subject.prep.6", "subject.doer.5", "subject.allowed.6", "subject.belief.6", "subject.perfect.5", "subject.perfect.6", "want.convencer.4", "want.convencer.6", "doubt.mentira.5", "belief.whether.4", "belief.whether.6", "impersonal.agree.4", "unknown.free.6", "time.mientras.5", "time.mientras.6", "purpose.nosea.6", "alone.commands.4", "alone.commands.5", "alone.commands.6"] { reasons[id] = "correct Spanish with another meaning" }
        reasons["want.same.2"] = "word order, not mood"
        return reasons
    }()

    /// Trigger examples whose wrong-mood version is also correct Spanish (or that the generator can't build cleanly).
    static let triggerOK: Set<String> = ["saber que", "seguramente", "que (a wish)", "es cierto que"]

    func testCatchesEveryDocumentedRule() {
        var missed: [String] = []
        for item in MoodMap.items where item.kind == .form && Self.meaningOnly[item.id] == nil {
            for (i, choice) in item.choices.enumerated() where !item.correct.contains(i) {
                let text = item.prompt.replacingOccurrences(of: "___", with: choice)
                if !Self.flagged(text) { missed.append("\(item.id): \(text)") }
            }
        }
        XCTAssertEqual(missed, [], "Learn wrong answers the checker lets through")
        // The reviewed list only holds cards that really are missed
        for id in Self.meaningOnly.keys { XCTAssertNotNil(MoodMap.items.first { $0.id == id }, id) }

        var triggerMissed: [String] = []
        for trigger in MoodTriggers.all where !Self.triggerOK.contains(trigger.phrase) {
            var cases: [String] = []
            if let subj = trigger.subjunctive, [.subjunctive, .indicativeWithNo].contains(trigger.behavior), let bad = Self.otherMood(subj, toSubjunctive: false, after: trigger.phrase) { cases.append(bad) }
            if let ind = trigger.indicative, [.indicative, .subjunctiveWithNo].contains(trigger.behavior), let bad = Self.otherMood(ind, toSubjunctive: true, after: trigger.phrase) { cases.append(bad) }
            for bad in cases where !Self.flagged(bad) { triggerMissed.append("\(trigger.phrase): \(bad)") }
        }
        XCTAssertEqual(triggerMissed, [], "trigger examples in the wrong mood the checker lets through")
    }

    /// Correct Spanish isn't flagged: every Learn answer, explanation example and trigger example, and the dictionary's example
    /// sentences (some of which are subtitles with real mistakes, listed here after review).
    func testCorrectSpanishIsNotFlagged() {
        var curated: [String] = []
        for item in MoodMap.items {
            switch item.kind {
            case .form: curated += item.correct.map { item.prompt.replacingOccurrences(of: "___", with: item.choices[$0]) }
            case .meaning: curated.append(item.prompt)
            case .flip: curated.append(item.prompt); MoodTenseLabels.changed(item).map { curated.append($0) }
            }
        }
        curated += MoodMap.briefings.values.flatMap { $0.examples.map(\.spanish) }
        curated += MoodTriggers.all.flatMap { [$0.indicative, $0.subjunctive].compactMap { $0 } }
        let wronglyFlagged = Set(curated).sorted().filter { !SpanishChecker.moodIssues($0).filter { $0.kind != .tip }.isEmpty }
        XCTAssertEqual(wronglyFlagged, [])

        // Dictionary examples: these are flagged because they really are wrong (machine-translated subtitles)
        let knownMistakes: Set<String> = [
            "- Como si estoy en falta y ser injusto con ella.", "- Si sólo Mustafa podría persuadir a Meltem.", "Antes de eso, espero que me olvido de ti.",
            "Confié en mi oncólogo e ignore a los demás.", "Cualquier cosa que te mole, me la tiro.", "Debo Desenchufe el televisor de la pared.",
            "Es justo que un protón es más masivo.", "Espero que usas lentes cuando conduces.", "Manténgase a no cuestionar, para que el reloj está por venir.",
            "No era que no podían desarrollar ciudades.", "Observe que cuando presiona Enter, vemos que cadena que se muestra.",
            "Ojalá se fue; pero éste es muy descarado.", "Ojalá tiene sentido un poco, pero hay otro enganche en este problema.",
            "Pero ... no puede ser que Fatmagül está embarazada?", "Quiero que entender por qué las reglas son lo que son.",
            "Señor, ¿No és ese el Señor Fiscal? No sé preocupe.", "Una vez que ves esto, entonces la mente perderá su influencia.",
            "Y podríamos normalizar el área para que es igual a uno.", "Y si nos enchufe x = dos en aquí, ¿qué obtenemos?",
            "Y si podría estar en el encintado del retiro de equipaje?", "¿Desea que me hacen ser un hipócrita?", "¿Y si él -¡bendito sea!corre hacia mí?",
        ]
        let corpus = Set(SeedData.handcraftedSentenceMap.values.flatMap { $0.map(\.1) })
        let flagged = corpus.sorted().filter { !SpanishChecker.moodIssues($0).filter { $0.kind != .tip }.isEmpty }
        XCTAssertEqual(flagged.filter { !knownMistakes.contains($0) }, [], "correct dictionary sentences flagged")
        XCTAssertGreaterThan(corpus.count, 10_000)
    }

    /// The messages give the fix.
    func testMessagesSuggestTheFix() {
        func fix(_ text: String) -> String? { SpanishChecker.check(text).first { $0.kind == .verb }?.suggestion }
        XCTAssertEqual(fix("Quiero que vienes."), "vengas")
        XCTAssertEqual(fix("Si tendría tiempo, te llamaría."), "tuviera")
        XCTAssertEqual(fix("Cuando llegarás, te llamo."), "llegues")
        XCTAssertEqual(SpanishChecker.moodIssues("Me sorprendió que ganaron el partido.").first { $0.kind == .tip }?.suggestion, "ganaran")
        XCTAssertEqual(fix("Habla como si es el jefe."), "fuera")
        XCTAssertEqual(fix("No hay nadie que sabe la respuesta."), "sepa")
        XCTAssertEqual(fix("Si lo había sabido, te habría avisado."), "si hubiera sabido")
        XCTAssertEqual(fix("Entendemos si no pudieran apartarnos las fechas."), "entenderíamos")
        XCTAssertEqual(fix("¿Está bien si decidimos después de este fin de semana? Entendemos si no pudiéramos bloquear las fechas."), "entenderíamos")
        XCTAssertEqual(fix("Te ayudo si tuviera tiempo."), "ayudaría")
        XCTAssertNil(fix("Si pudieras, llámame."))
        XCTAssertNil(fix("Entendemos si no pueden apartarnos las fechas."))
        XCTAssertNil(fix("Entenderíamos si no pudieran apartarnos las fechas."))
        XCTAssertEqual(SpanishChecker.check("Entendemos si no pudíeramos venir.").first { $0.kind == .spelling }?.suggestion, "pudiéramos")
        XCTAssertNil(fix("Creo que tiene razón."))
        XCTAssertNil(fix("Juan no cree que la Tierra es redonda."))
    }
}
