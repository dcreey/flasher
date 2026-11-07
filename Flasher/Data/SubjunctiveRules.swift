import Foundation

/// Cards for the subjunctive tenses: the tense after *que* has to match the verb in front of it, a condition with *si* or a time
/// word like *cuando* takes the subjunctive, and the older -se and future forms have a modern equivalent.
extension TenseAlternatives {
    /// Verbs that ask for the subjunctive after *que*: wishes, orders, hopes, doubts and fears.
    private static let triggers: Set<String> = ["querer", "pedir", "necesitar", "exigir", "rogar", "mandar", "preferir", "permitir", "prohibir", "sugerir",
                                                "recomendar", "aconsejar", "ordenar", "desear", "esperar", "dudar", "temer"]
    /// The ones where the subjunctive looks forward, so a past form after a present verb is out of place.
    private static let volition: Set<String> = ["querer", "pedir", "necesitar", "exigir", "rogar", "mandar", "preferir", "permitir", "prohibir", "sugerir", "recomendar"]
    private static let subjects: Set<String> = clitics.union(["no", "yo", "tú", "él", "ella", "usted", "ustedes", "nosotros", "nosotras", "ellos", "ellas"])
    private static let hayaForms = ["haya", "hayas", "haya", "hayamos", "hayáis", "hayan"]
    private static let hubieraForms = ["hubiera", "hubieras", "hubiera", "hubiéramos", "hubierais", "hubieran"]
    /// Before a "si" these make it "whether", which takes the conditional: "no sé si tendría tiempo".
    private static let asking: Set<String> = ["sé", "sabes", "sabe", "sabemos", "pregunto", "pregunta", "preguntó", "duda", "dudo", "saber", "ver", "averiguar", "comprobar", "ignoro", "imagino"]
    private static let timeWords: [[String]] = [["cuando"], ["apenas"], ["en", "cuanto"], ["hasta", "que"], ["después", "de", "que"], ["tan", "pronto", "como"]]
    private static let finishedPast = try! NSRegularExpression(pattern: #"\b(?:ayer|anoche|anteayer|antier|hace\s+\p{L}+\s+(?:días?|semanas?|meses|años?|horas?)|(?:el|la)\s+\p{L}+\s+pasad[oa]|el\s+otro\s+día|en\s+(?:19|20)\d\d)\b"#, options: .caseInsensitive)

    /// -se endings of the imperfect subjunctive and the -ra ending that says the same thing.
    private static let seEndings: [(String, String)] = [("iésemos", "iéramos"), ("ieseis", "ierais"), ("iesen", "ieran"), ("ieses", "ieras"), ("iese", "iera"),
                                                          ("ásemos", "áramos"), ("aseis", "arais"), ("asen", "aran"), ("ases", "aras"), ("ase", "ara"),
                                                          ("ésemos", "éramos"), ("eseis", "erais"), ("esen", "eran"), ("eses", "eras"), ("ese", "era")]
    /// Future subjunctive endings and the imperfect subjunctive they sit next to.
    private static let futureEndings: [(String, String)] = [("iéremos", "iéramos"), ("iereis", "ierais"), ("ieren", "ieran"), ("ieres", "ieras"), ("iere", "iera"),
                                                              ("áremos", "áramos"), ("areis", "arais"), ("aren", "aran"), ("ares", "aras"), ("are", "ara"),
                                                              ("éremos", "éramos"), ("ereis", "erais"), ("eren", "eran"), ("eres", "eras"), ("ere", "era")]

    static func subjunctiveSuggestion(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        sequence(tokens, in: sentence) ?? condition(tokens, in: sentence) ?? comoSi(tokens, in: sentence) ?? unknownThing(tokens, in: sentence)
            ?? aunque(tokens, in: sentence) ?? futureAfterTime(tokens, in: sentence)
            ?? seForm(tokens, in: sentence) ?? futureSubjunctive(tokens, in: sentence)
    }

    // MARK: - Helpers

    private static func replacing(_ range: Range<String.Index>, in sentence: String, with text: String, matching raw: String) -> String {
        var result = sentence
        result.replaceSubrange(range, with: capital(raw, text))
        return result
    }

    /// The verb a form belongs to and the persons it could be, when every reading of it is in `allowed`; `want` picks the persons.
    /// `loose` is for a verb whose tense the sentence already points to (right after "que" or "si"): other readings of the spelling are ignored.
    private static func finite(_ word: String, allowed: Set<Tense>, want: Set<Tense>, loose: Bool = false) -> (verb: String, persons: Set<Int>)? {
        guard !notVerbs.contains(word), let all = VerbForms.index[word] else { return nil }
        if !loose, let entry = Lexicon.shared.wordsByID[word], entry.partOfSpeech != .infinitive { return nil }
        let usable = all.filter { !$0.infinitive.contains(" ") && (!loose || want.contains($0.tense)) }
        guard !usable.isEmpty, usable.allSatisfy({ allowed.contains($0.tense) }) else { return nil }
        let persons = Set(usable.filter { want.contains($0.tense) }.map(\.person))
        let verbs = Set(usable.map { baseVerb($0.infinitive) })
        guard !persons.isEmpty, verbs.count == 1, let verb = verbs.first else { return nil }
        return (verb, persons)
    }

    /// The one written form the persons share ("hable" for yo and él), nil if they differ.
    private static func form(_ verb: String, _ tense: Tense, _ persons: Set<Int>) -> String? {
        guard let conjugation = Conjugator.conjugate(verb) else { return nil }
        let forms = Set(persons.compactMap { conjugation.form(tense, $0) })
        return forms.count == 1 ? forms.first : nil
    }

    private static func nextVerb(after index: Int, _ tokens: [Token]) -> Int? {
        var j = index + 1
        while j < tokens.count, subjects.contains(tokens[j].text) { j += 1 }
        return j < tokens.count ? j : nil
    }

    private static func participle(at index: Int, _ tokens: [Token]) -> (text: String, end: Int)? {
        guard index < tokens.count, VerbForms.participleOwners[tokens[index].text] != nil else { return nil }
        return (tokens[index].text, index)
    }

    private static func tenseMatch(_ id: String, _ title: String, _ original: String, _ rewritten: String, _ note: String, verb: String, focus: ConjugationFocus) -> TenseSuggestion? {
        make(id, title, original, rewritten, note, verb: verb, focus: focus, heading: "Tense match")
    }

    // MARK: - Tense after "que"

    /// A verb of wishing or doubting + *que* + a subjunctive in the wrong tense for it.
    private static func sequence(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        for q in tokens.indices where tokens[q].text == "que" && q > 0 {
            guard let j = nextVerb(after: q, tokens) else { continue }
            let main = tokens[q - 1]
            let past: Set<Tense> = [.preterite, .imperfect, .conditional]
            let now: Set<Tense> = [.present, .future]
            let candidate = tokens[j]
            let isHaya = hayaForms.contains(candidate.text)
            let isHubiera = hubieraForms.contains(candidate.text) || ["hubiese", "hubieses", "hubiésemos", "hubieseis", "hubiesen"].contains(candidate.text)

            if let lead = finite(main.text, allowed: past, want: past), triggers.contains(lead.verb) {
                // Past verb + perfect subjunctive → pluperfect subjunctive
                if isHaya, let part = participle(at: j + 1, tokens), let owner = VerbForms.participleOwners[part.text] {
                    let fixed = hubieraForms[hayaForms.firstIndex(of: candidate.text) ?? 0] + " " + part.text
                    let range = candidate.range.lowerBound..<tokens[part.end].range.upperBound
                    return tenseMatch("sequence-\(owner)", "Pluperfect subjunctive", sentence, replacing(range, in: sentence, with: fixed, matching: candidate.raw),
                                      "After a past verb (**“\(main.text)”**), the perfect subjunctive moves back too: **“\(fixed)”**, the pluperfect subjunctive.",
                                      verb: baseVerb(owner), focus: ConjugationFocus(form: .participle, tense: .subjunctiveImperfect, person: 0))
                }
                // Past verb + present subjunctive → imperfect subjunctive
                if let sub = finite(candidate.text, allowed: [.subjunctivePresent], want: [.subjunctivePresent], loose: true),
                   let fixed = form(sub.verb, .subjunctiveImperfect, sub.persons) {
                    return tenseMatch("sequence-\(sub.verb)", "Imperfect subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                                      "After a past verb (**“\(main.text)”**), the verb after *que* normally moves to the imperfect subjunctive: **“\(fixed)”**. You hear the present subjunctive when the wish still holds now, but the matching tense is the standard.",
                                      verb: sub.verb, focus: ConjugationFocus(form: .infinitive, tense: .subjunctiveImperfect, person: sub.persons.min() ?? 0))
                }
            }
            if let lead = finite(main.text, allowed: now, want: now), volition.contains(lead.verb) {
                // Present verb + pluperfect subjunctive → perfect subjunctive
                if isHubiera, let part = participle(at: j + 1, tokens), let owner = VerbForms.participleOwners[part.text] {
                    let person = hubieraForms.firstIndex(of: candidate.text) ?? 0
                    let fixed = hayaForms[person] + " " + part.text
                    let range = candidate.range.lowerBound..<tokens[part.end].range.upperBound
                    return tenseMatch("sequence-\(owner)", "Perfect subjunctive", sentence, replacing(range, in: sentence, with: fixed, matching: candidate.raw),
                                      "After a verb in the present (**“\(main.text)”**), the completed action uses the perfect subjunctive: **“\(fixed)”**.",
                                      verb: baseVerb(owner), focus: ConjugationFocus(form: .participle, tense: .subjunctivePresent, person: person))
                }
                // Present verb + imperfect subjunctive → present subjunctive
                if let sub = finite(candidate.text, allowed: [.subjunctiveImperfect], want: [.subjunctiveImperfect], loose: true),
                   let fixed = form(sub.verb, .subjunctivePresent, sub.persons) {
                    return tenseMatch("sequence-\(sub.verb)", "Present subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                                      "After a verb in the present (**“\(main.text)”**), the verb after *que* stays in the present subjunctive: **“\(fixed)”**. The imperfect subjunctive points to a past or imagined moment.",
                                      verb: sub.verb, focus: ConjugationFocus(form: .infinitive, tense: .subjunctivePresent, person: sub.persons.min() ?? 0))
                }
            }
            // Present trigger + present subjunctive + a finished time → perfect subjunctive
            if let lead = finite(main.text, allowed: now, want: now), triggers.contains(lead.verb),
               finishedPast.firstMatch(in: sentence, range: NSRange(sentence.startIndex..., in: sentence)) != nil,
               let sub = finite(candidate.text, allowed: [.subjunctivePresent], want: [.subjunctivePresent], loose: true),
               let helper = form("haber", .subjunctivePresent, sub.persons), let part = Conjugator.conjugate(sub.verb)?.participle {
                let fixed = helper + " " + part
                return tenseMatch("perfect-\(sub.verb)", "Perfect subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                                  "This is about something already finished, so the present subjunctive doesn't fit. Use the perfect subjunctive: **“\(fixed)”**.",
                                  verb: sub.verb, focus: ConjugationFocus(form: .participle, tense: .subjunctivePresent, person: sub.persons.min() ?? 0))
            }
        }
        return nil
    }

    // MARK: - "si" and time words

    /// *Si* + conditional: the "if" half takes the imperfect subjunctive and the conditional goes in the result.
    private static func condition(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        for i in tokens.indices where tokens[i].text == "si" {
            if tokens[..<i].contains(where: { asking.contains($0.text) || $0.text == "como" }) { continue }
            guard let j = nextVerb(after: i, tokens) else { continue }
            let candidate = tokens[j]
            if let person = ["habría", "habrías", "habría", "habríamos", "habríais", "habrían"].firstIndex(of: candidate.text),
               let part = participle(at: j + 1, tokens), let owner = VerbForms.participleOwners[part.text] {
                let fixed = hubieraForms[person] + " " + part.text
                let range = candidate.range.lowerBound..<tokens[part.end].range.upperBound
                return tenseMatch("if-\(owner)", "Pluperfect subjunctive", sentence, replacing(range, in: sentence, with: fixed, matching: candidate.raw),
                                  "After **si**, an imagined condition in the past takes the pluperfect subjunctive: **“\(fixed)”**. The conditional perfect goes in the result: *si hubiera sabido, habría venido*.",
                                  verb: baseVerb(owner), focus: ConjugationFocus(form: .participle, tense: .subjunctiveImperfect, person: person))
            }
            if let plain = finite(candidate.text, allowed: [.conditional], want: [.conditional], loose: true),
               let fixed = form(plain.verb, .subjunctiveImperfect, plain.persons) {
                return tenseMatch("if-\(plain.verb)", "Imperfect subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                                  "After **si**, an imagined condition takes the imperfect subjunctive: **“\(fixed)”**. The conditional belongs in the result: *si tuviera tiempo, iría*.",
                                  verb: plain.verb, focus: ConjugationFocus(form: .infinitive, tense: .subjunctiveImperfect, person: plain.persons.min() ?? 0))
            }
        }
        return nil
    }

    /// *Cuando*, *en cuanto*, *hasta que*… + future: the future event takes the present subjunctive.
    private static func futureAfterTime(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        for i in tokens.indices {
            for words in timeWords where i + words.count <= tokens.count && zip(words, tokens[i...]).allSatisfy({ $0 == $1.text }) {
                guard let j = nextVerb(after: i + words.count - 1, tokens), let plain = finite(tokens[j].text, allowed: [.future], want: [.future], loose: true),
                      let fixed = form(plain.verb, .subjunctivePresent, plain.persons) else { continue }
                let candidate = tokens[j]
                return tenseMatch("time-\(plain.verb)", "Present subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                                  "After **\(words.joined(separator: " "))**, a future event takes the present subjunctive, not the future: **“\(fixed)”**. *Cuando llegue, te llamo.*",
                                  verb: plain.verb, focus: ConjugationFocus(form: .infinitive, tense: .subjunctivePresent, person: plain.persons.min() ?? 0))
            }
        }
        return nil
    }

    // MARK: - "como si", the unknown, "aunque"

    /// *Como si* (as if) always takes the imperfect or pluperfect subjunctive: "habla como si fuera el jefe".
    private static func comoSi(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        for i in tokens.indices.dropLast() where tokens[i].text == "como" && tokens[i + 1].text == "si" {
            guard let j = nextVerb(after: i + 1, tokens) else { continue }
            let candidate = tokens[j]
            let note = "After **como si** (as if) the verb is always in the subjunctive, because it is an imagined comparison: **“%@”**. It takes the imperfect subjunctive, or the pluperfect for something in the past."
            if let person = perfectHelper.firstIndex(of: candidate.text), let part = participle(at: j + 1, tokens), let owner = VerbForms.participleOwners[part.text] {
                let fixed = hubieraForms[person] + " " + part.text
                let range = candidate.range.lowerBound..<tokens[part.end].range.upperBound
                return tenseMatch("comosi-\(owner)", "Pluperfect subjunctive", sentence, replacing(range, in: sentence, with: fixed, matching: candidate.raw),
                                  String(format: note, fixed), verb: baseVerb(owner), focus: ConjugationFocus(form: .participle, tense: .subjunctiveImperfect, person: person))
            }
            if let plain = finite(candidate.text, allowed: [.present, .future, .imperfect, .preterite], want: [.present, .future, .imperfect, .preterite], loose: true),
               let fixed = form(plain.verb, .subjunctiveImperfect, plain.persons) {
                return tenseMatch("comosi-\(plain.verb)", "Imperfect subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                                  String(format: note, fixed), verb: plain.verb, focus: ConjugationFocus(form: .infinitive, tense: .subjunctiveImperfect, person: plain.persons.min() ?? 0))
            }
        }
        return nil
    }

    /// Looking for or needing something that may not exist ("busco un coche que tenga…"): the description takes the subjunctive.
    private static func unknownThing(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        let seeking: Set<String> = ["buscar", "necesitar", "querer"]
        let indefinite: Set<String> = ["un", "una", "unos", "unas", "algún", "alguna", "algunos", "algunas", "alguien", "algo"]
        let present: Set<Tense> = [.present]
        for i in tokens.indices {
            guard let lead = finite(tokens[i].text, allowed: present, want: present, loose: true), seeking.contains(lead.verb),
                  let q = tokens[(i + 1)...].prefix(6).firstIndex(where: { $0.text == "que" }),
                  tokens[(i + 1)..<q].contains(where: { indefinite.contains($0.text) }),
                  let j = nextVerb(after: q, tokens),
                  let plain = finite(tokens[j].text, allowed: present, want: present, loose: true),
                  let fixed = form(plain.verb, .subjunctivePresent, plain.persons) else { continue }
            let candidate = tokens[j]
            return tenseMatch("unknown-\(plain.verb)", "Present subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                              "When you describe something you are looking for that may not exist, the verb that describes it takes the subjunctive: **“\(fixed)”**. If you mean one particular thing you already know, the indicative is right (*busco el coche que tiene cuatro puertas*).",
                              verb: plain.verb, focus: ConjugationFocus(form: .infinitive, tense: .subjunctivePresent, person: plain.persons.min() ?? 0))
        }
        return nil
    }

    /// *Aunque* with a future event: the present subjunctive when it isn't certain. A known fact takes the indicative, so this is a choice and not a mistake.
    private static func aunque(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        let future: Set<String> = ["mañana", "próximo", "próxima", "viene"]
        let notTomorrow: Set<String> = ["la", "esta", "cada", "de", "en", "por"]
        guard let hasFuture = tokens.indices.first(where: { future.contains(tokens[$0].text) && !($0 > 0 && notTomorrow.contains(tokens[$0 - 1].text)) }) else { return nil }
        _ = hasFuture
        for i in tokens.indices where tokens[i].text == "aunque" {
            guard let j = nextVerb(after: i, tokens),
                  let plain = finite(tokens[j].text, allowed: [.present], want: [.present], loose: true),
                  let fixed = form(plain.verb, .subjunctivePresent, plain.persons) else { continue }
            let candidate = tokens[j]
            return make("aunque-\(plain.verb)", "Present subjunctive", sentence, replacing(candidate.range, in: sentence, with: fixed, matching: candidate.raw),
                        "With **aunque** and an event that hasn't happened yet, the present subjunctive says it is only possible: **“\(fixed)”** (*even if it rains*). If you are sure it will happen, such as a forecast you trust, the indicative is fine, so this is a choice and not a mistake.",
                        verb: plain.verb, focus: ConjugationFocus(form: .infinitive, tense: .subjunctivePresent, person: plain.persons.min() ?? 0), heading: "Good to know")
        }
        return nil
    }

    // MARK: - Other forms of the same tense

    /// The -se imperfect subjunctive ("hablase"): the same tense as the -ra form, which is the everyday one in Mexico and Colombia.
    private static func seForm(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        for token in tokens where token.text.count > 4 {
            guard let (ending, replacement) = seEndings.first(where: { token.text.hasSuffix($0.0) }) else { continue }
            let ra = String(token.text.dropLast(ending.count)) + replacement
            guard let slots = VerbForms.index[ra], slots.allSatisfy({ $0.tense == .subjunctiveImperfect }), let first = slots.first else { continue }
            return make("se-\(first.infinitive)", "Imperfect subjunctive", sentence, replacing(token.range, in: sentence, with: ra, matching: token.raw),
                        "**“\(token.text)”** is the -se form of the imperfect subjunctive. It means the same as **“\(ra)”**, which is the one people use in \(country). The -se form feels formal or literary.",
                        verb: baseVerb(first.infinitive), focus: ConjugationFocus(form: .infinitive, tense: .subjunctiveImperfect, person: first.person))
        }
        return nil
    }

    /// The future subjunctive ("si hubiere", "el que fuere"): gone from everyday Spanish, still found in laws and proverbs.
    private static func futureSubjunctive(_ tokens: [Token], in sentence: String) -> TenseSuggestion? {
        for token in tokens where token.text.count > 5 && VerbForms.index[token.text] == nil && Lexicon.shared.wordsByID[token.text] == nil {
            guard let (ending, replacement) = futureEndings.first(where: { token.text.hasSuffix($0.0) }) else { continue }
            let ra = String(token.text.dropLast(ending.count)) + replacement
            guard let slots = VerbForms.index[ra], slots.allSatisfy({ $0.tense == .subjunctiveImperfect }), let first = slots.first else { continue }
            // The RAE: the future subjunctive "has largely been replaced by the present subjunctive"; after "si" it is the present indicative
            let present = Clitics.formOf(first.infinitive, .subjunctivePresent, first.person)
            let indicative = Clitics.formOf(first.infinitive, .present, first.person)
            let afterSi = tokens.contains { $0.text == "si" }
            let modern = afterSi ? indicative.map { "after *si* the present indicative: **“\($0)”**" } : present.map { "the present subjunctive: **“\($0)”**" }
            return make("future-\(first.infinitive)", "Future subjunctive", sentence, "",
                        "**“\(token.text)”** is the future subjunctive, which is no longer used in everyday Spanish. You'll see it in laws and old sayings (*sea lo que fuere*, *adonde fueres, haz lo que vieres*). Today people use \(modern ?? "the present subjunctive (*cuando llegue*)").",
                        verb: baseVerb(first.infinitive), focus: ConjugationFocus(form: .infinitive, tense: afterSi ? .present : .subjunctivePresent, person: first.person), heading: "Good to know")
        }
        return nil
    }
}
