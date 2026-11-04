import Foundation

/// A different tense that would also say what a sentence says, with how the meaning shifts.
struct TenseSuggestion: Identifiable {
    let id: String
    /// The tense suggested ("Present perfect").
    let title: String
    let original: String
    let rewritten: String
    /// What changes, in a sentence or two (markdown).
    let note: String
    let verb: Word
    /// Where the verb's page should open in the conjugation chart.
    let focus: ConjugationFocus
    /// A heads-up about the sentence as written, with an example, rather than a different way to say it.
    var isNote = false
    /// Replaces the card's usual "Also possible" / "Good to know" title ("Tense match").
    var heading: String?
}

/// Finds sentences whose tense could be swapped for a close neighbour:
/// preterite ↔ present perfect, and two finished actions in a row ↔ past perfect.
/// These are not mistakes: the sentence is right as written, another tense just says it a little differently.
enum TenseAlternatives {
    static let perfectHelper = ["he", "has", "ha", "hemos", "habéis", "han"]
    static let pastHelper = ["había", "habías", "había", "habíamos", "habíais", "habían"]
    static let clitics: Set<String> = ["me", "te", "se", "nos", "os", "lo", "la", "los", "las", "le", "les"]
    static let adverbs: Set<String> = ["ya", "nunca", "jamás", "todavía", "aún", "siempre", "también"]
    /// Words that look like a preterite but are everyday words ("así" is also asir's *yo* form).
    static let notVerbs: Set<String> = ["así", "allí", "ahí", "sí", "mí", "dé", "fe", "ti"]
    /// A sentence tied to a definite moment in the past, where the present perfect doesn't fit.
    private static let definitePast = try! NSRegularExpression(pattern: #"\b(?:ayer|anoche|anteayer|antier|anteanoche|hace\s+\p{L}+\s+(?:días?|semanas?|meses|años?|horas?|minutos?)|hace\s+(?:un|una)\s+\p{L}+|(?:el|la)\s+\p{L}+\s+pasad[oa]|el\s+otro\s+día|esa\s+vez|aquella?\s+(?:vez|día|noche)|ese\s+día|de\s+(?:niñ|pequeñ)[oa]|en\s+(?:19|20)\d\d|en\s+(?:enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)|cuando|entonces|de\s+repente|(?:19|20)\d\d)\b"#, options: .caseInsensitive)
    /// Words that tie two verbs together in ways other than "one after the other".
    private static let notSequence: Set<String> = ["cuando", "mientras", "porque", "que", "si", "aunque", "pero", "apenas", "cuanto", "hasta", "como"]
    private static let sequenceLink = try! NSRegularExpression(pattern: #"^(.*?)[,\s]*\b(?:(?:y|e)\s+(?:luego|después|entonces|enseguida)|y|e|luego|después|entonces|enseguida)\s*$"#, options: .caseInsensitive)

    struct Token {
        let text: String
        let raw: String
        let range: Range<String.Index>
    }

    private struct Event {
        enum Kind { case preterite, perfect, pluperfect }
        let kind: Kind
        let infinitive: String
        let person: Int
        /// The verb itself (for a compound tense, from the helper to the participle).
        let range: Range<String.Index>
        /// Where the verb's unit starts, counting the pronouns and "no" in front of it.
        let start: String.Index
        let participle: String?
        let adverb: String?
        let raw: String
    }

    /// At most two suggestions for the text, in the order the sentences appear.
    static func suggestions(for text: String) -> [TenseSuggestion] {
        guard let sentences = try? NSRegularExpression(pattern: #"[^.!?;\n]+"#) else { return [] }
        var found: [TenseSuggestion] = []
        for match in sentences.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            guard let range = Range(match.range, in: text) else { continue }
            if let suggestion = suggestion(forSentence: String(text[range])) { found.append(suggestion) }
            if found.count == 2 { break }
        }
        return found
    }

    // MARK: - One sentence

    private static func suggestion(forSentence sentence: String) -> TenseSuggestion? {
        guard let letters = try? NSRegularExpression(pattern: #"\p{L}+"#) else { return nil }
        let tokens: [Token] = letters.matches(in: sentence, range: NSRange(sentence.startIndex..., in: sentence)).compactMap { match in
            Range(match.range, in: sentence).map { Token(text: sentence[$0].lowercased(), raw: String(sentence[$0]), range: $0) }
        }
        if let subjunctive = subjunctiveSuggestion(tokens, in: sentence) { return subjunctive }
        let events = scan(tokens, in: sentence)
        guard !events.isEmpty else { return nil }
        if let event = events.first(where: { $0.kind == .pluperfect }) {
            if let swapped = pastPerfectToPreterite(event, tokens: tokens, in: sentence) { return swapped }
            return events.count == 1 && !tokens.contains(where: { $0.text == "cuando" }) ? loneAnchorNote(event, in: sentence) : nil
        }
        if let event = events.first(where: { $0.kind == .perfect }) { return perfectToPreterite(event, in: sentence) }
        let preterites = events.filter { $0.kind == .preterite }
        let links = tokens.filter { ["luego", "después", "entonces", "enseguida"].contains($0.text) }.count
        // "que", "porque", "si"… make it something other than a plain story
        if tokens.contains(where: { notSequence.contains($0.text) && $0.text != "cuando" }) { return nil }
        if preterites.count >= 3 || links >= 2 { return chainNote(preterites[0]) }
        if preterites.count == 2 {
            if let swapped = sequenceToPastPerfect(preterites[0], preterites[1], tokens: tokens, in: sentence) { return swapped }
            return tokens.contains(where: { $0.text == "cuando" }) ? cuandoNote(preterites[1], tokens: tokens, in: sentence) : nil
        }
        if let only = preterites.first {
            // Another verb in the sentence (even one that can't be placed, like an unaccented "tome") would be left in the old tense
            let others = tokens.contains { $0.range != only.range && isVerbForm($0.text) }
            return others ? nil : preteriteToPerfect(only, in: sentence)
        }
        return nil
    }

    private static func scan(_ tokens: [Token], in sentence: String) -> [Event] {
        var events: [Event] = []
        var i = 0
        while i < tokens.count {
            if let event = compound(at: i, tokens, in: sentence) {
                events.append(event)
                i += event.adverb == nil ? 2 : 3
            } else if let event = preterite(at: i, tokens, in: sentence) {
                events.append(event)
                i += 1
            } else {
                i += 1
            }
        }
        return events
    }

    private static func unitStart(before i: Int, _ tokens: [Token]) -> String.Index {
        var j = i
        while j > 0, clitics.contains(tokens[j - 1].text) { j -= 1 }
        if j > 0, tokens[j - 1].text == "no" { j -= 1 }
        return tokens[j].range.lowerBound
    }

    /// "he comido", "había ido", "ya se había ido".
    private static func compound(at i: Int, _ tokens: [Token], in sentence: String) -> Event? {
        let helper = tokens[i].text
        let perfect = perfectHelper.firstIndex(of: helper)
        let past = pastHelper.firstIndex(of: helper)
        guard perfect != nil || past != nil else { return nil }
        var next = i + 1
        var adverb: String?
        if next < tokens.count, adverbs.contains(tokens[next].text) { adverb = tokens[next].raw; next += 1 }
        guard next < tokens.count, let owner = VerbForms.participleOwners[tokens[next].text] else { return nil }
        let person: Int
        if let perfect { person = perfect }
        else if let past, past == 0 || past == 2 { person = pastPerson(at: i, tokens) }
        else { person = past ?? 2 }
        return Event(kind: perfect != nil ? .perfect : .pluperfect, infinitive: baseVerb(owner), person: person,
                     range: tokens[i].range.lowerBound..<tokens[next].range.upperBound, start: unitStart(before: i, tokens),
                     participle: tokens[next].text, adverb: adverb, raw: tokens[i].raw)
    }

    /// "había" is *yo* or *él*: a "me" in front or a "yo" in the sentence says *yo*, another subject or a "se"/"lo" says *él*.
    /// With only "no" or an adverb in front ("ya había comido") it is most likely the speaker answering.
    private static func pastPerson(at i: Int, _ tokens: [Token]) -> Int {
        if i > 0, tokens[i - 1].text == "me" { return 0 }
        if tokens.contains(where: { $0.text == "yo" }) { return 0 }
        let before = tokens[..<i].map(\.text)
        return before.allSatisfy({ $0 == "no" || adverbs.contains($0) || $0 == "cuando" }) ? 0 : 2
    }

    /// A verb form that can only be one person of the preterite ("comí", "se levantó").
    private static func preterite(at i: Int, _ tokens: [Token], in sentence: String) -> Event? {
        let word = tokens[i].text
        guard !notVerbs.contains(word), let slots = VerbForms.index[word] else { return nil }
        if let entry = Lexicon.shared.wordsByID[word], entry.partOfSpeech != .infinitive { return nil }
        let usable = slots.filter { !$0.infinitive.contains(" ") }
        guard !usable.isEmpty, usable.allSatisfy({ $0.tense == .preterite }), Set(usable.map(\.person)).count == 1 else { return nil }
        let bases = Set(usable.map { baseVerb($0.infinitive) })
        guard bases.count == 1, let base = bases.first else { return nil }
        return Event(kind: .preterite, infinitive: base, person: usable[0].person, range: tokens[i].range, start: unitStart(before: i, tokens),
                     participle: nil, adverb: nil, raw: tokens[i].raw)
    }

    /// Any conjugated verb form, whichever tense it is in. Everyday words that share a spelling with one ("como", "así") don't count.
    static func isVerbForm(_ word: String) -> Bool {
        guard VerbForms.index[word] != nil else { return false }
        if let entry = Lexicon.shared.wordsByID[word], entry.partOfSpeech != .infinitive { return false }
        return !notVerbs.contains(word)
    }

    /// "levantarse" → "levantar" when that is also a verb of its own.
    static func baseVerb(_ infinitive: String) -> String {
        guard infinitive.hasSuffix("se") else { return infinitive }
        let plain = String(infinitive.dropLast(2))
        return Lexicon.shared.wordsByID[plain]?.partOfSpeech == .infinitive ? plain : infinitive
    }

    // MARK: - The four swaps

    static func capital(_ original: String, _ text: String) -> String { CountryTranslation.matchingCapital(of: original, in: text) }

    static func make(_ id: String, _ title: String, _ original: String, _ rewritten: String, _ note: String, verb: String, focus: ConjugationFocus, heading: String? = nil) -> TenseSuggestion? {
        guard let word = Lexicon.shared.wordsByID[verb] else { return nil }
        return TenseSuggestion(id: id, title: title, original: original.trimmingCharacters(in: .whitespaces), rewritten: rewritten.trimmingCharacters(in: .whitespaces),
                               note: note, verb: word, focus: focus, heading: heading)
    }

    static var country: String { Country.current.name }

    /// 1. A finished action in the preterite that could be the present perfect when it still matters now.
    private static func preteriteToPerfect(_ event: Event, in sentence: String) -> TenseSuggestion? {
        let whole = NSRange(sentence.startIndex..., in: sentence)
        guard definitePast.firstMatch(in: sentence, range: whole) == nil,
              let participle = Conjugator.conjugate(event.infinitive)?.participle else { return nil }
        let replacement = capital(event.raw, perfectHelper[event.person] + " " + participle)
        var rewritten = sentence
        rewritten.replaceSubrange(event.range, with: replacement)
        return make("perfect-\(event.infinitive)", "Present perfect", sentence, rewritten,
                    "**“\(event.raw.lowercased())”** is the preterite: a finished action. If it's completed but still matters right now, the present perfect (**“\(replacement.lowercased())”**) can sound more natural. In \(country) the preterite is the everyday choice, so both are fine.",
                    verb: event.infinitive, focus: ConjugationFocus(form: .participle, tense: .present, person: event.person))
    }

    /// 2. The present perfect that could just be the preterite.
    private static func perfectToPreterite(_ event: Event, in sentence: String) -> TenseSuggestion? {
        guard let conjugation = Conjugator.conjugate(event.infinitive), let form = conjugation.form(.preterite, event.person) else { return nil }
        let replacement = capital(event.raw, [event.adverb, form].compactMap { $0 }.joined(separator: " "))
        var rewritten = sentence
        rewritten.replaceSubrange(event.range, with: replacement)
        return make("preterite-\(event.infinitive)", "Preterite", sentence, rewritten,
                    "The present perfect ties the action to now. If it's simply finished and you're telling it, the preterite (**“\(form)”**) says the same thing without that link, and it's what most people in \(country) would say.",
                    verb: event.infinitive, focus: ConjugationFocus(form: .infinitive, tense: .preterite, person: event.person))
    }

    /// 3. Two finished actions one after the other: the first can go in the past perfect.
    private static func sequenceToPastPerfect(_ first: Event, _ second: Event, tokens: [Token], in sentence: String) -> TenseSuggestion? {
        guard !tokens.contains(where: { notSequence.contains($0.text) }),
              first.range.upperBound <= second.start,
              let participle = Conjugator.conjugate(first.infinitive)?.participle else { return nil }
        let between = String(sentence[first.range.upperBound..<second.start])
        guard let match = sequenceLink.firstMatch(in: between, range: NSRange(between.startIndex..., in: between)),
              let objects = Range(match.range(at: 1), in: between).map({ String(between[$0]) }) else { return nil }
        let before = String(sentence[..<first.start])
        let pronouns = String(sentence[first.start..<first.range.lowerBound]).lowercased()
        let started = capital(before.trimmingCharacters(in: .whitespaces).isEmpty ? String(sentence[first.start...].prefix(1)) : "x", "ya " + pronouns + pastHelper[first.person] + " " + participle)
        let after = String(sentence[second.start...])
        let rewritten = before + started + objects + " cuando " + after
        let unit = "ya \(pronouns)\(pastHelper[first.person]) \(participle)"
        return make("pluperfect-\(first.infinitive)", "Past perfect", sentence, rewritten,
                    "Two finished actions in a row can be ordered with the past perfect: **“\(unit)”** says the first one was already done before the second. The plain preterites only list them one after the other.",
                    verb: first.infinitive, focus: ConjugationFocus(form: .participle, tense: .imperfect, person: first.person))
    }

    /// 4. The past perfect that could be two preterites told in the order things happened. The sentence is reordered
    /// ("Cuando llegué, ya se había ido" → "Se fue y después llegué"), and the "already before" nuance is lost.
    /// Only sentences where one clause anchors the other with *cuando* are rewritten: anywhere else a plain swap would change the meaning.
    private static func pastPerfectToPreterite(_ event: Event, tokens: [Token], in sentence: String) -> TenseSuggestion? {
        let blockers: Set<String> = ["nunca", "jamás", "todavía", "aún", "hasta", "desde", "que", "porque", "si", "mientras"]
        guard !tokens.contains(where: { blockers.contains($0.text) }),
              let conjugation = Conjugator.conjugate(event.infinitive), let form = conjugation.form(.preterite, event.person),
              let c = tokens.firstIndex(where: { $0.text == "cuando" }) else { return nil }
        let hasPreterite = { (clause: [Token]) in scan(clause, in: sentence).contains { $0.kind == .preterite } }
        // Where the pluperfect's unit begins, taking a "ya" in front of it with it
        let before = tokens.last(where: { $0.range.upperBound <= event.start })
        let unitFrom = before?.text == "ya" ? before!.range.lowerBound : event.start
        let pronouns = String(sentence[event.start..<event.range.lowerBound])
        let keptAdverb = event.adverb.map { $0.lowercased() == "ya" ? "" : $0 + " " } ?? ""
        func verb(_ rest: String) -> String { pronouns + keptAdverb + form + rest }

        var main: String
        var anchor: String
        if tokens[c].range.lowerBound == tokens[0].range.lowerBound {
            // "Cuando llegué, ya se había ido"
            guard let comma = sentence[tokens[c].range.upperBound...].firstIndex(of: ","), comma < unitFrom,
                  hasPreterite(tokens.filter { $0.range.lowerBound > tokens[c].range.upperBound && $0.range.upperBound <= comma }) else { return nil }
            anchor = String(sentence[tokens[c].range.upperBound..<comma])
            let lead = String(sentence[sentence.index(after: comma)..<unitFrom])
            main = lead + verb(String(sentence[event.range.upperBound...]))
        } else {
            // "Ya se había ido cuando llegué"
            guard event.range.upperBound <= tokens[c].range.lowerBound,
                  hasPreterite(tokens.filter { $0.range.lowerBound >= tokens[c].range.upperBound }) else { return nil }
            anchor = String(sentence[tokens[c].range.upperBound...])
            main = String(sentence[..<unitFrom]) + verb(String(sentence[event.range.upperBound..<tokens[c].range.lowerBound]))
        }
        main = main.trimmingCharacters(in: .whitespaces)
        anchor = anchor.trimmingCharacters(in: .whitespaces)
        guard !main.isEmpty, !anchor.isEmpty else { return nil }
        let rewritten = capital(String(sentence.drop { !$0.isLetter }.prefix(1)), main) + " y después " + anchor
        return make("simple-\(event.infinitive)", "Preterite", sentence, rewritten,
                    "Two preterites told in the order things happened (**“\(form)”** first) say the same story in a shorter, everyday way. It loses some nuance: the past perfect said it was already done before the other moment, while the preterites only list what happened one after the other.",
                    verb: event.infinitive, focus: ConjugationFocus(form: .infinitive, tense: .preterite, person: event.person))
    }

    /// Three or more finished actions in a row, or several *luego* / *después*: a story, which plain preterites tell best.
    private static func chainNote(_ first: Event) -> TenseSuggestion? {
        guard let word = Lexicon.shared.wordsByID[first.infinitive] else { return nil }
        return TenseSuggestion(id: "chain-\(first.infinitive)", title: "Past perfect", original: "", rewritten: "",
                               note: "This tells a chain of finished actions, and plain preterites are the natural way to do that. The past perfect only says that one thing was already done before another moment, so putting one verb in it would change the story. Use it for a single “already done” point, like *ya había comido cuando salí*.",
                               verb: word, focus: ConjugationFocus(form: .participle, tense: .imperfect, person: first.person), isNote: true)
    }

    /// *Cuando* with two preterites means the second happened right after the first. Saying it was already done needs the past perfect.
    private static func cuandoNote(_ second: Event, tokens: [Token], in sentence: String) -> TenseSuggestion? {
        guard let word = Lexicon.shared.wordsByID[second.infinitive] else { return nil }
        var example = ""
        if tokens.first?.text == "cuando", let participle = Conjugator.conjugate(second.infinitive)?.participle,
           let comma = sentence.firstIndex(of: ","), comma < second.start {
            let pronouns = String(sentence[second.start..<second.range.lowerBound]).lowercased()
            example = String(sentence[..<second.start]) + "ya " + pronouns + pastHelper[second.person] + " " + participle + String(sentence[second.range.upperBound...])
        }
        return TenseSuggestion(id: "cuando-\(second.infinitive)", title: "Past perfect", original: sentence.trimmingCharacters(in: .whitespaces),
                               rewritten: example.trimmingCharacters(in: .whitespaces),
                               note: "With **cuando**, two preterites mean the second thing happened right after the first (*cuando llegué, salió*: he left once I arrived). To say it was already done when the first happened, put it in the past perfect\(example.isEmpty ? "" : ", as above").",
                               verb: word, focus: ConjugationFocus(form: .participle, tense: .imperfect, person: second.person), isNote: true)
    }

    /// A past perfect with no other past verb in the sentence: it is right, but only after something that introduced another past event.
    private static func loneAnchorNote(_ event: Event, in sentence: String) -> TenseSuggestion? {
        guard let word = Lexicon.shared.wordsByID[event.infinitive] else { return nil }
        let trimmed = sentence.trimmingCharacters(in: .whitespaces)
        let example = "Cuando llamaste, " + trimmed.prefix(1).lowercased() + trimmed.dropFirst()
        return TenseSuggestion(id: "anchor-\(event.infinitive)", title: "Past perfect", original: trimmed, rewritten: example,
                               note: "**“\(trimmed)”** is correct, but only in a context where it follows a clause that introduced another past event. The past perfect looks back from that moment, so on its own it needs something before it, like a question about the past (*¿querías comer?*) or a clause like the one above.",
                               verb: word, focus: ConjugationFocus(form: .participle, tense: .imperfect, person: event.person), isNote: true)
    }
}
