import SwiftUI

struct ExampleSentence: Hashable {
    let spanish: String
    let english: String
}

/// A sentence that contains a form of the verb in a particular tense.
struct TenseExample: Hashable {
    let sentence: ExampleSentence
    let token: String        // the conjugated form as written in the sentence
    let exactPerson: Bool    // the form is the very one selected (not just the same tense)
}

/// Finds real sentences for each tense of a verb by spotting its conjugated forms in the example pool.
enum TenseExamples {
    /// Hand-written study sentences plus Wiktionary examples for the verb.
    static func pool(for word: Word) -> [ExampleSentence] {
        var result: [ExampleSentence] = []
        for s in SeedData.sentencesByWord[word.spanish] ?? [] where !s.translation.isEmpty {
            result.append(ExampleSentence(spanish: s.full, english: s.translation))
        }
        for e in Extras.shared.examples(for: word) {
            result.append(ExampleSentence(spanish: e.spanish, english: e.english))
        }
        var seen = Set<String>()
        return result.filter { seen.insert($0.spanish).inserted }
    }

    static func tokens(_ text: String) -> [String] {
        text.lowercased().split(whereSeparator: { !$0.isLetter }).map(String.init)
    }

    /// Every written form of the verb, mapped to the (tense, person) slots that use it.
    static func formIndex(_ conjugation: Conjugation) -> [String: [(tense: Tense, person: Int)]] {
        var index: [String: [(tense: Tense, person: Int)]] = [:]
        for (tense, forms) in conjugation.forms {
            for (person, form) in forms.enumerated() {
                guard let form else { continue }
                index[form.lowercased(), default: []].append((tense, person))
            }
        }
        return index
    }

    /// Sentences for the selected tense and person: exact-form matches first, then other persons of the same tense.
    static func examples(for tense: Tense, person: Int, conjugation: Conjugation, pool: [ExampleSentence]) -> [TenseExample] {
        let index = formIndex(conjugation)
        var exact: [TenseExample] = []
        var sameTense: [TenseExample] = []
        for sentence in pool {
            var best: TenseExample?
            for token in tokens(sentence.spanish) {
                guard let slots = index[token] else { continue }
                if slots.contains(where: { $0.tense == tense && $0.person == person }) {
                    best = TenseExample(sentence: sentence, token: token, exactPerson: true)
                    break
                }
                if best == nil, slots.contains(where: { $0.tense == tense }) {
                    best = TenseExample(sentence: sentence, token: token, exactPerson: false)
                }
            }
            if let best { if best.exactPerson { exact.append(best) } else { sameTense.append(best) } }
        }
        let shortestFirst: (TenseExample, TenseExample) -> Bool = { $0.sentence.spanish.count < $1.sentence.spanish.count }
        return exact.sorted(by: shortestFirst) + sameTense.sorted(by: shortestFirst)
    }

    /// Bolds `token` wherever it appears as a whole word.
    static func highlight(_ text: String, tokens: Set<String>, font: Font = .body) -> AttributedString {
        var result = AttributedString(text)
        for token in tokens {
            let pattern = "(?<![\\p{L}])" + NSRegularExpression.escapedPattern(for: token) + "(?![\\p{L}])"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                guard let range = Range(match.range, in: text),
                      let lower = AttributedString.Index(range.lowerBound, within: result),
                      let upper = AttributedString.Index(range.upperBound, within: result) else { continue }
                result[lower..<upper].inlinePresentationIntent = .stronglyEmphasized
            }
        }
        return result
    }
}

// MARK: - Generated fallback sentences

/// Just enough English inflection to gloss a generated sentence ("Yesterday I worked.").
private enum EnglishVerb {
    static let irregularPast: [String: String] = [
        "have": "had", "do": "did", "go": "went", "say": "said", "get": "got", "make": "made", "know": "knew",
        "think": "thought", "take": "took", "see": "saw", "come": "came", "give": "gave", "find": "found", "tell": "told",
        "become": "became", "leave": "left", "feel": "felt", "put": "put", "bring": "brought", "begin": "began",
        "keep": "kept", "hold": "held", "write": "wrote", "stand": "stood", "hear": "heard", "let": "let", "mean": "meant",
        "set": "set", "meet": "met", "run": "ran", "pay": "paid", "sit": "sat", "speak": "spoke", "lie": "lay",
        "lead": "led", "read": "read", "grow": "grew", "lose": "lost", "fall": "fell", "send": "sent", "build": "built",
        "understand": "understood", "draw": "drew", "break": "broke", "spend": "spent", "cut": "cut", "rise": "rose",
        "drive": "drove", "buy": "bought", "wear": "wore", "choose": "chose", "eat": "ate", "drink": "drank",
        "sleep": "slept", "sing": "sang", "swim": "swam", "throw": "threw", "catch": "caught", "teach": "taught",
        "fly": "flew", "forget": "forgot", "hit": "hit", "hurt": "hurt", "win": "won", "wake": "woke", "sell": "sold",
        "shoot": "shot", "hide": "hid", "steal": "stole", "shake": "shook", "bite": "bit", "cost": "cost",
        "fight": "fought", "ride": "rode", "ring": "rang", "sink": "sank", "lend": "lent", "lay": "laid", "bend": "bent",
        "blow": "blew", "feed": "fed", "deal": "dealt", "dig": "dug", "shut": "shut", "spread": "spread", "spin": "spun",
        "stick": "stuck", "strike": "struck", "swear": "swore", "tear": "tore", "forgive": "forgave", "undo": "undid",
        "sweep": "swept", "bleed": "bled", "seek": "sought", "show": "showed", "burn": "burned",
    ]
    /// Short words stressed on the first syllable that don't double their last letter (open → opened).
    static let noDouble: Set<String> = ["open", "listen", "enter", "offer", "visit", "happen", "answer", "order", "limit", "edit"]

    static func past(_ b: String) -> String {
        if let p = irregularPast[b] { return p }
        if b.hasSuffix("e") { return b + "d" }
        if b.hasSuffix("y"), let before = b.dropLast().last, !"aeiou".contains(before) { return String(b.dropLast()) + "ied" }
        let v = Array(b)
        if v.count >= 3, v.count <= 4, !noDouble.contains(b), !"aeiouwxy".contains(v[v.count - 1]),
           "aeiou".contains(v[v.count - 2]), !"aeiou".contains(v[v.count - 3]) {
            return b + String(v[v.count - 1]) + "ed"
        }
        return b + "ed"
    }

    static func thirdSingular(_ b: String) -> String {
        if b == "have" { return "has" }
        if ["go", "do"].contains(b) { return b + "es" }
        if let last = b.last, "sxz".contains(last) || b.hasSuffix("ch") || b.hasSuffix("sh") { return b + "es" }
        if b.hasSuffix("y"), let before = b.dropLast().last, !"aeiou".contains(before) { return String(b.dropLast()) + "ies" }
        return b + "s"
    }

    static let modals: Set<String> = ["can", "may", "must", "will", "should", "shall", "might"]

    /// The verb and anything after it from a gloss like "to sit down" → ("sit", "down"). Tries each comma-separated term;
    /// nil when no term is a plain verb (modals like "can" can't be inflected here).
    static func parse(_ gloss: String) -> (base: String, rest: String)? {
        let terms = Lexicon.stripParentheses(gloss)
            .split(whereSeparator: { ",;".contains($0) })
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        for term in terms {
            let text = term.hasPrefix("to ") ? String(term.dropFirst(3)) : term
            guard text.range(of: #"^[a-z]+( [a-z]+)?$"#, options: .regularExpression) != nil else { continue }
            let parts = text.split(separator: " ").map(String.init)
            if modals.contains(parts[0]) { continue }
            return (parts[0], parts.dropFirst().joined(separator: " "))
        }
        return nil
    }
}

extension TenseExamples {
    private static let spanishSubjects = ["yo", "tú", "él", "nosotros", "vosotros", "ellos"]
    private static let englishSubjects = ["I", "you", "he", "we", "you all", "they"]
    private static let couldClause = ["Si pudiera", "Si pudieras", "Si pudiera", "Si pudiéramos", "Si pudierais", "Si pudieran"]
    /// Weather verbs only make sense in the third person ("llueve").
    private static let impersonal: Set<String> = ["llover", "nevar", "amanecer", "atardecer", "anochecer", "tronar", "granizar", "lloviznar", "acontecer", "relampaguear"]

    /// A simple made-up sentence that shows the selected form in context. Used when no real sentence has the tense.
    static func generated(tense: Tense, person: Int, conjugation: Conjugation, gloss: String) -> ExampleSentence? {
        guard let form = conjugation.form(tense, person) ?? nil else { return nil }
        let tail = conjugation.tail.isEmpty ? "" : " " + conjugation.tail
        let clitic = conjugation.reflexive && tense != .imperative ? Conjugation.reflexivePronouns[person] + " " : ""
        let isWeather = impersonal.contains(conjugation.infinitive)
        if isWeather && (person != 2 || tense == .imperative || tense == .conditional) { return nil }
        let subject = isWeather ? "" : spanishSubjects[person] + " "
        let verbPhrase = clitic + form + tail
        let spanish: String
        switch tense {
        case .present: spanish = "Hoy \(subject)\(verbPhrase)."
        case .preterite: spanish = "Ayer \(subject)\(verbPhrase)."
        case .imperfect: spanish = "Antes \(subject)\(verbPhrase)."
        case .future: spanish = "Mañana \(subject)\(verbPhrase)."
        case .conditional: spanish = "\(couldClause[person]), \(subject)\(verbPhrase)."
        case .subjunctivePresent: spanish = "Espero que \(subject)\(verbPhrase)."
        case .subjunctiveImperfect: spanish = "Ojalá \(subject)\(verbPhrase)."
        case .imperative:
            let shown = conjugation.attachedImperative?[person] ?? form
            spanish = "¡\(shown)\(tail)!"
        }

        var english = ""
        if let (base, rest) = EnglishVerb.parse(gloss) {
            let who = isWeather ? "it" : englishSubjects[person]
            let tailEn = rest.isEmpty ? "" : " " + rest
            let isBe = base == "be"
            func present() -> String { isBe ? ["am", "are", "is", "are", "are", "are"][person] : (person == 2 || isWeather ? EnglishVerb.thirdSingular(base) : base) }
            func past() -> String { isBe ? [1, 3, 4, 5].contains(person) ? "were" : "was" : EnglishVerb.past(base) }
            switch tense {
            case .present: english = "Today \(who) \(present())\(tailEn)."
            case .preterite: english = "Yesterday \(who) \(past())\(tailEn)."
            case .imperfect: english = "Before, \(who) used to \(base)\(tailEn)."
            case .future: english = "Tomorrow \(who) will \(base)\(tailEn)."
            case .conditional: english = "If \(who) could, \(who) would \(base)\(tailEn)."
            case .subjunctivePresent: english = "I hope \(who) \(present())\(tailEn)."
            case .subjunctiveImperfect: english = "I wish \(who) \(isBe ? "were" : past())\(tailEn)."
            case .imperative:
                let cmd = base.prefix(1).uppercased() + base.dropFirst()
                switch person {
                case 3: english = "Let's \(base)\(tailEn)!"
                case 4, 5: english = "\(cmd)\(tailEn), everyone!"
                default: english = "\(cmd)\(tailEn)!"
                }
            }
        }
        return ExampleSentence(spanish: spanish, english: english)
    }
}
