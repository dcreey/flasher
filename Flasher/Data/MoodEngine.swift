import Foundation

/// The mood rules from the Learn course (docs/conjugation-drill/subjunctive-rules.md), as a checker for Spanish typed into
/// Translate. It finds each trigger (a verb + que, a connector, a set phrase), the verb the trigger governs (even with a subject
/// or "no" in between), and checks the mood, the tense that goes with the main verb, si sentences, time words, and subjunctives
/// that nothing calls for. Like the rest of the checker it only flags what is wrong in any context; sentences where both moods
/// are correct and only the meaning changes ("busco un piso que tiene balcón") are left alone.
extension SpanishChecker {
    // MARK: Verbs in the text

    /// How a word reads as a verb: its most common verb, the tenses that form can be, and its persons.
    struct VerbReading {
        let first: Int
        let last: Int
        let infinitive: String
        let tenses: Set<Tense>
        /// Every tense the form has across all verbs: "funda" is fundar's present and fundir's subjunctive.
        var allTenses: Set<Tense> = []
        let persons: [Int]
        /// haber + participle: "haya venido", "había dicho".
        let perfect: Bool
        let participle: String?

        /// The mood only counts when every reading of the form agrees.
        var isSubjunctive: Bool { !tenses.isEmpty && tenses.isSubset(of: [.subjunctivePresent, .subjunctiveImperfect]) && allTenses.isSubset(of: [.subjunctivePresent, .subjunctiveImperfect]) }
        var isIndicative: Bool { !tenses.isEmpty && tenses.isDisjoint(with: [.subjunctivePresent, .subjunctiveImperfect]) && allTenses.isDisjoint(with: [.subjunctivePresent, .subjunctiveImperfect]) }
        var isPast: Bool { isIndicative && !tenses.isDisjoint(with: [.preterite, .imperfect]) && !tenses.contains(.present) }
        var isPresent: Bool { tenses == [.present] }
        var isFutureLike: Bool { isIndicative && (tenses.contains(.future) || tenses.contains(.conditional)) && !tenses.contains(.present) }
    }

    /// Words that are spelled like a verb form but almost never are one in a sentence ("como", "para", "nada").
    private static let notVerbWords: Set<String> = [
        "como", "para", "sobre", "entre", "bajo", "nada", "casa", "cara", "solo", "ante", "media", "vino", "río", "seguro", "segura",
        "mientras", "bien", "mal", "mi", "agua", "así", "cosa", "frío", "idea", "mesa", "pena", "piso", "salvo", "tarde", "una", "listo",
        "abrigo", "enfermo", "enferma", "ganas", "sin", "cuenta", "noticia", "verdad", "mentira", "duda", "miedo", "hora", "falta",
        "que", "qué", "no", "si", "sí", "ya", "hasta", "desde", "cuando", "donde", "aunque", "porque", "pues", "luego", "entonces",
        "claro", "cierto", "obvio", "mejor", "peor", "fin", "caso", "tal", "vez", "menos", "más", "muy", "tan", "tanto", "poco",
        "mucho", "todo", "toda", "todos", "todas", "otro", "otra", "algo", "alguien", "nadie", "cualquier", "cualquiera",
        "quizás", "quizá", "ojalá", "acaso", "tampoco", "también", "nunca", "jamás", "siempre", "aquí", "ahí", "allí", "hoy",
        "mañana", "ayer", "ahora", "antes", "después", "pronto", "temprano", "bueno", "buena", "malo", "mala", "rico", "rica",
        "papá", "mamá", "llegada", "llamada", "partido", "hecho", "dicho", "lado", "parte", "tiempo", "dios",
        "importante", "necesario", "posible", "imposible", "probable", "raro", "normal", "lástima", "contento", "contenta",
        "cansado", "cansada", "convencido", "convencida", "harto", "harta", "triste", "feliz", "felices", "caro", "cara",
    ]
    private static let determiners: Set<String> = ["el", "la", "los", "las", "un", "una", "unos", "unas", "mi", "mis", "tu", "tus", "su", "sus",
        "nuestro", "nuestra", "nuestros", "nuestras", "este", "esta", "estos", "estas", "ese", "esa", "esos", "esas", "aquel", "aquella",
        "del", "al", "de", "en", "con", "por", "para", "sin", "muy", "tan", "lo", "tantos", "tantas", "muchos", "muchas", "varios", "varias",
        "pocos", "pocas", "algunos", "algunas", "algún", "ningún", "ninguna", "cada", "otros", "otras", "dos", "tres", "cuatro", "cinco"]
    private static let clitics: Set<String> = ["me", "te", "se", "nos", "os", "le", "les", "lo", "la", "los", "las"]
    private static let subjectWords: Set<String> = ["yo", "tú", "él", "ella", "usted", "nosotros", "nosotras", "vosotros", "vosotras", "ellos", "ellas", "ustedes"]

    static func isNoun(_ word: String) -> Bool {
        !DictionaryIndex.nounsWithForm(word).isEmpty || Lexicon.shared.meanings(for: word).contains { $0.partOfSpeech == .noun }
    }

    /// How common the word is as a noun or adjective (lower is more common), if it is one.
    static func nonVerbRank(_ word: String) -> Int? {
        var ranks: [Int] = DictionaryIndex.nounsWithForm(word).map(\.order)
        var bases = [word]
        if word.hasSuffix("es") { bases.append(String(word.dropLast(2))) }
        if word.hasSuffix("s") { bases.append(String(word.dropLast())) }
        for base in bases where base.hasSuffix("a") { bases.append(String(base.dropLast()) + "o") }
        for base in bases {
            if let w = Lexicon.shared.wordsByID[base], w.partOfSpeech != .infinitive, Lexicon.shared.meanings(for: base).contains(where: { $0.partOfSpeech != .infinitive }) { ranks.append(w.order) }
        }
        return ranks.min()
    }

    /// A noun or adjective in any of its forms: "cosas", "calle", "mejores", "solas", "viva".
    static func isNounOrAdjective(_ word: String) -> Bool {
        if !DictionaryIndex.nounsWithForm(word).isEmpty { return true }
        if Lexicon.shared.meanings(for: word).contains(where: { $0.partOfSpeech != .infinitive }) { return true }
        // Adjective endings only: "mejores" → mejor, "solas" → solo, "viva" → vivo ("descansa" isn't "descanso")
        var bases: [String] = []
        if word.hasSuffix("es") { bases.append(String(word.dropLast(2))) }
        if word.hasSuffix("s") { bases.append(String(word.dropLast())) }
        for base in [word] + bases where base.hasSuffix("a") { bases.append(String(base.dropLast()) + "o") }
        return bases.contains { base in Lexicon.shared.meanings(for: base).contains { $0.partOfSpeech == .adjective } }
    }

    /// The verb starting at token i, or nil. haber + participle counts as one verb.
    static func verbReading(_ words: [String], _ i: Int) -> VerbReading? {
        let word = words[i]
        guard !notVerbWords.contains(word), !clitics.contains(word), !subjectWords.contains(word) else { return nil }
        let prev = i > 0 ? words[i - 1] : ""
        let next = i + 1 < words.count ? words[i + 1] : ""
        // "fuera de", "dentro de": an adverb
        if word == "fuera", next == "de" { return nil }
        // After an article or preposition it's a noun or adjective ("mi hermana", "de pena"); lo, la, los, las can also be pronouns
        if determiners.contains(prev), !clitics.contains(prev) { return nil }
        var found = VerbForms.index[word]
        // An accent on the wrong letter ("pudíeramos"): read it as the one form it can be
        if found == nil, word != word.searchKey, let variants = SpanishChecker.accentVariants[word.searchKey], variants.count == 1 {
            found = VerbForms.index[variants[0]]
        }
        // Typed without its accent: "hicieramos" (hiciéramos), "podria" (podría)
        if found == nil, word == word.searchKey, word.hasSuffix("ramos") || word.hasSuffix("semos") || word.hasSuffix("ria") || word.hasSuffix("rias") || word.hasSuffix("riamos") || word.hasSuffix("rian") {
            found = Clitics.formOptions(word).map { VerbForms.Slot(infinitive: $0.infinitive, tense: $0.tense, person: $0.person) }
        }
        guard let slots = found?.filter({ !$0.infinitive.contains(" ") && $0.tense != .imperative }), !slots.isEmpty else { return nil }
        // The most common verb the form belongs to ("vino" is venir, not vinar; "fue" is ser or ir: both the same tense)
        func rank(_ infinitive: String) -> Int { Lexicon.shared.wordsByID[infinitive]?.order ?? Int.max }
        let infinitive = slots.map(\.infinitive).min { rank($0) < rank($1) }!
        // A noun or adjective spelled the same ("cosas", "calle", "mejores", "viva") isn't a verb, unless a word that only
        // comes before verbs says it is ("me", "no", "que", "si", "yo")
        let verbLikely: Set<String> = ["me", "te", "se", "nos", "os", "le", "les", "no", "que", "si", "ojalá", "ojala", "quizás", "quizá", "ya",
                                       "también", "nunca", "siempre", "jamás", "tampoco", "aunque", "cuando", "como", "cuándo"]
        let core: Set<String> = ["ser", "estar", "ir", "haber", "tener", "hacer", "poder", "querer", "saber", "venir", "decir", "dar", "ver"]
        // After a subject noun ("que mi papá descansa", "que la gente compra") the next word is likely the verb: then a noun or
        // adjective reading only wins if it's more common than the verb ("la lucha libre", not librar)
        let afterSubject = i >= 2 && determiners.contains(words[i - 2]) && !determiners.contains(prev) && (isNoun(prev) || prev == "papá" || prev == "mamá")
            && rank(infinitive) < 2500
        let strongCue = ["me", "te", "se", "nos", "os", "le", "les", "no", "que"].contains(prev)
        if !strongCue, (afterSubject || subjectWords.contains(prev)), word != "fuera", let other = nonVerbRank(word), other < rank(infinitive) { return nil }
        if !verbLikely.contains(prev), !subjectWords.contains(prev), !afterSubject, i > 0, word != "fuera", !slots.contains(where: { core.contains($0.infinitive) }), isNounOrAdjective(word) { return nil }
        let mine = slots.filter { $0.infinitive == infinitive || $0.infinitive == infinitive + "se" }
        let tenses = Set(mine.map(\.tense))
        let persons = Array(Set(mine.map(\.person))).sorted()
        // Other verbs' readings count when that verb isn't far rarer ("funda": fundar and fundir; not "venga" from vengar)
        let near = rank(infinitive) == Int.max ? Int.max : rank(infinitive) * 10
        let all = Set(slots.filter { $0.infinitive == infinitive || $0.infinitive == infinitive + "se" || rank($0.infinitive) <= near }.map(\.tense))
        if infinitive == "haber", i + 1 < words.count, VerbForms.nonFiniteForms.contains(words[i + 1]), let owner = VerbForms.participleOwners[words[i + 1]] {
            return VerbReading(first: i, last: i + 1, infinitive: owner, tenses: tenses, allTenses: all, persons: persons, perfect: true, participle: words[i + 1])
        }
        return VerbReading(first: i, last: i, infinitive: infinitive, tenses: tenses, allTenses: all, persons: persons, perfect: false, participle: nil)
    }

    // MARK: Triggers

    enum MoodNeed {
        /// Always the subjunctive: querer que, para que, ojalá.
        case subjunctive
        /// Always the indicative: saber que, porque, a lo mejor.
        case indicative
        /// A claim: indicative affirmed, subjunctive negated (creer que, es verdad que). Questions take either.
        case claim
        /// A rejection: subjunctive affirmed, either negated (dudar que, negar que).
        case rejection
        /// Si, por si: never the present subjunctive or the conditional.
        case condition
        /// Como si, ni que: only a past subjunctive.
        case pastOnly
        /// Cuando, hasta que, en cuanto...: indicative for what happens or happened, subjunctive for what's still to come.
        case time
    }

    struct MoodTrigger {
        /// Words to match; "~verb" is any form of that verb, "*" is any one word.
        let pattern: [String]
        let need: MoodNeed
        /// Wanting or asking: its subjunctive points forward, so "quiero que vinieras" is wrong.
        var influence = false
        var label: String { pattern.map { $0.hasPrefix("~") ? String($0.dropFirst()) : $0 }.joined(separator: " ") }
    }

    private static func triggers(_ need: MoodNeed, influence: Bool = false, _ patterns: [String]) -> [MoodTrigger] {
        patterns.map { MoodTrigger(pattern: $0.split(separator: " ").map(String.init), need: need, influence: influence) }
    }

    static let moodTriggers: [MoodTrigger] = {
        var all: [MoodTrigger] = []
        // Wanting, asking, ordering, allowing (Learn: want)
        all += triggers(.subjunctive, influence: true, [
            "~querer que", "~desear que", "~preferir que", "~necesitar que", "~pedir que", "~rogar que", "~exigir que", "~mandar que",
            "~ordenar que", "~aconsejar que", "~recomendar que", "~proponer que", "~permitir que", "~dejar que",
            "~prohibir que", "~impedir que", "~evitar que", "~lograr que", "~conseguir que", "~hacer que", "~esperar a que",
            "~venir a que", "~ir a que", "~salir a que",
        ])
        all += triggers(.subjunctive, ["~esperar que", "~ojalá"])
        // Feelings and judgements (Learn: feel)
        all += triggers(.subjunctive, [
            "~gustar que", "~alegrar de que", "~alegrar que", "~encantar que", "~molestar que", "~importar que", "~preocupar que", "~sorprender que",
            "~extrañar que", "~lamentar que", "~odiar que", "~agradecer que", "~doler que", "~fastidiar que", "~enojar que", "~enfadar que",
            "~asustar que", "~tener miedo de que", "~dar miedo que", "~dar pena que", "~dar rabia que", "~dar igual que", "~dar vergüenza que",
            "~estar contento de que", "~estar contenta de que", "~estar harto de que", "~estar harta de que",
            "~ser una lástima que", "~ser una pena que", "~ser una vergüenza que", "qué bueno que", "qué pena que", "qué lástima que",
            "qué raro que", "qué bien que", "~parecer bien que", "~parecer mal que", "~parecer raro que", "~parecer increíble que",
            "~parecer mentira que", "~parecer genial que", "lo mejor es que", "lo ideal es que",
        ])
        // Es + adjective + que (Learn: impersonal)
        all += triggers(.subjunctive, [
            "necesario", "importante", "posible", "imposible", "probable", "improbable", "mejor", "peor", "bueno", "malo", "raro", "normal",
            "natural", "lógico", "preciso", "fundamental", "urgente", "conveniente", "útil", "fácil", "difícil", "increíble", "extraño",
            "dudoso", "preferible", "justo", "injusto", "triste", "hora de",
        ].map { "~ser \($0) que" })
        all += triggers(.subjunctive, ["~hacer falta que", "más vale que", "~poder que", "~poder ser que", "~convenir que", "~bastar con que",
                                        "no ~ser que"])
        // Doubt and denial (Learn: doubt)
        all += triggers(.rejection, ["~dudar que", "~dudar de que", "~negar que", "~ser mentira que"])
        // Believing, knowing, saying something is true (Learn: belief, impersonal.truth)
        all += triggers(.claim, [
            "~creer que", "~pensar que", "~parecer que", "~opinar que", "~suponer que", "~imaginar que", "~considerar que", "~ver que",
            "~estar seguro de que", "~estar segura de que", "~estar seguros de que", "~estar convencido de que", "~estar convencida de que",
            "~ser verdad que", "~ser cierto que", "~ser obvio que", "~ser evidente que", "~ser seguro que", "~ser indudable que",
            "~estar claro que", "~estar demostrado que",
        ])
        all += triggers(.indicative, [
            "~saber que", "~darse cuenta de que", "~dar cuenta de que", "~contar que", "~afirmar que", "~asegurar que", "~confirmar que",
            "~demostrar que", "~anunciar que", "~notar que", "~oír que", "~leer que", "~enterarse de que", "~enterar de que",
            "no hay duda de que", "no hay ninguna duda de que", "no cabe ninguna duda de que", "sin duda", "lo cierto es que", "lo que pasa es que", "~resultar que", "menos mal que", "no ~caber duda de que", "no ~haber duda de que",
            "la noticia de que", "y eso que", "si bien", "a lo mejor", "ya que", "puesto que", "así que", "por eso", "por lo tanto",
            "porque", "dado que", "visto que", "debido a que", "en vista de que",
        ])
        // Nouns + de que (Learn: belief.nouns)
        all += triggers(.subjunctive, ["la posibilidad de que", "~tener ganas de que", "el riesgo de que", "esperanza de que", "necesidad de que",
                                        "nadie que", "ningún * que", "ninguna * que", "ni aunque", "mal que"])
        // Something unknown or that doesn't exist (Learn: unknown)
        all += triggers(.subjunctive, [
            "no ~haber nadie que", "no ~haber nada que", "no ~haber ningún * que", "no ~haber ninguna * que",
            "no hay nadie que", "no hay nada que", "no hay ningún * que", "no hay ninguna * que", "no había nadie que", "no había nada que", "no ~conocer a nadie que",
            "~buscar a alguien que", "~necesitar a alguien que", "~buscar algo que", "~necesitar algo que", "~querer algo que",
            "quienquiera que", "cualquiera que", "cualquier * que", "dondequiera que", "comoquiera que", "todo el que", "todos los que",
        ])
        // Connectors that are never a fact (Learn: purpose, condition)
        all += triggers(.subjunctive, [
            "para que", "sin que", "antes de que", "a menos que", "a no ser que", "con tal de que", "con tal que", "siempre y cuando",
            "en caso de que", "a fin de que", "no sea que", "de ahí que", "a condición de que",
        ])
        all += triggers(.condition, ["si", "por si"])
        all += triggers(.pastOnly, ["como si", "ni que"])
        all += triggers(.time, ["cuando", "en cuanto", "tan pronto como", "hasta que", "después de que", "desde que", "una vez que"])
        return all.sorted { $0.pattern.count > $1.pattern.count }
    }()

    /// Whether the words from i on match a trigger; returns the index of its last word and of its verb (for "~" patterns).
    private static func match(_ trigger: MoodTrigger, _ words: [String], _ keys: [String], at i: Int, boundary: Set<Int>) -> (end: Int, verb: Int?)? {
        var j = i
        var verb: Int?
        for (n, part) in trigger.pattern.enumerated() {
            guard j < words.count, n == 0 || !boundary.contains(j) else { return nil }
            if part == "*" { j += 1; continue }
            if part.hasPrefix("~") {
                let lemma = String(part.dropFirst())
                if lemma == "ojalá" {
                    guard keys[j] == "ojala" else { return nil }
                } else {
                    guard let slots = VerbForms.index[words[j]], slots.contains(where: { $0.infinitive == lemma || $0.infinitive == lemma + "se" }) else { return nil }
                    verb = j
                }
            } else if !(words[j] == part || keys[j] == part.searchKey && words[j] == keys[j]) {
                // Accents count ("sí" isn't "si"), but a word typed with no accents at all still matches ("ojala", "despues")
                return nil
            }
            j += 1
        }
        return (j - 1, verb)
    }

    /// Only the mood engine's findings, for tests and tuning.
    static func moodIssues(_ text: String) -> [SpanishIssue] {
        let ns = text as NSString
        guard ns.length > 0, let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return [] }
        let tokens: [Token] = regex.matches(in: text, range: NSRange(location: 0, length: ns.length)).map { match in
            let word = ns.substring(with: match.range)
            return Token(text: word, range: match.range, lower: word.lowercased(), key: word.searchKey)
        }
        func adjacent(_ i: Int) -> Bool { i + 1 < tokens.count }
        func span(_ a: Int, _ b: Int) -> NSRange { NSUnionRange(tokens[a].range, tokens[b].range) }
        var issues: [SpanishIssue] = []
        moodRules(tokens, text: ns, adjacent: adjacent, span: span) { kind, range, message, fix in
            guard !issues.contains(where: { NSIntersectionRange($0.range, range).length > 0 }) else { return }
            issues.append(SpanishIssue(kind: kind, range: range, found: ns.substring(with: range), message: message, suggestion: fix))
        }
        return issues
    }

    // MARK: The engine

    static func moodRules(_ tokens: [Token], text: NSString, adjacent: (Int) -> Bool, span: (Int, Int) -> NSRange, add: SpanishIssueAdder) {
        let words = tokens.map(\.lower)
        let keys = tokens.map(\.key)
        guard !words.isEmpty else { return }
        // Sentence and clause breaks: a token that starts after . ! ? ; or a newline starts a sentence; after a comma, a clause
        var sentenceStart = Set<Int>([0]), clauseStart = Set<Int>([0])
        for i in 1..<tokens.count {
            let start = tokens[i - 1].range.location + tokens[i - 1].range.length
            let gap = text.substring(with: NSRange(location: start, length: tokens[i].range.location - start))
            let abbreviation = gap.hasPrefix(".") && ["ud", "uds", "sr", "sra", "srta", "dr", "dra", "etc", "vd", "vds"].contains(words[i - 1])
            if gap.contains(where: { "!?;\n:".contains($0) }) || gap.contains(".") && !abbreviation { sentenceStart.insert(i); clauseStart.insert(i) }
            else if gap.contains(where: { ",—()«»\"“”".contains($0) }) { clauseStart.insert(i) }
        }
        func sentence(of i: Int) -> Range<Int> {
            let start = sentenceStart.filter { $0 <= i }.max() ?? 0
            let end = sentenceStart.filter { $0 > i }.min() ?? tokens.count
            return start..<end
        }
        var readings: [Int: VerbReading] = [:]
        func verb(_ i: Int) -> VerbReading? {
            if let r = readings[i] { return r }
            let r = verbReading(words, i)
            readings[i] = r
            return r
        }
        func question(_ i: Int) -> Bool { isInQuestion(at: tokens[i].range.location, in: text) || {
            // A question mark at the end of the sentence, with no ¿ at the start
            let s = sentence(of: i)
            let end = tokens[s.upperBound - 1].range.location + tokens[s.upperBound - 1].range.length
            return end < text.length && text.character(at: end) == 63
        }() }
        func negated(_ verbIndex: Int) -> Bool {
            var k = verbIndex - 1
            while k >= 0, clitics.contains(words[k]) { k -= 1 }
            return k >= 0 && ["no", "nunca", "jamás", "tampoco", "nadie"].contains(words[k]) && !clauseStart.contains(k + 1)
        }
        /// The first verb after a trigger, inside the same clause: "que mi hermana no venga" → venga.
        func governed(after end: Int) -> VerbReading? {
            var j = end + 1
            var steps = 0
            while j < tokens.count, steps < 7, !clauseStart.contains(j) {
                if let r = verb(j) { return r }
                j += 1; steps += 1
            }
            return nil
        }
        /// The main verb of the sentence outside a clause that starts at `start` and ends at `end`.
        /// `nearest`: the verb right before the clause (what a time clause hangs on: "dijo que me llamaría cuando llegara" → llamaría).
        func mainVerb(outside start: Int, _ end: Int, nearest wantNearest: Bool = false) -> VerbReading? {
            let s = sentence(of: start)
            // The clause comes first ("Cuando llegues, te llamo"): the main verb follows the next comma
            if clauseStart.contains(start) || sentenceStart.contains(start) {
                var j = end + 1
                while j < s.upperBound, !clauseStart.contains(j) { j += 1 }
                while j < s.upperBound { if let r = verb(j), !(j > 0 && words[j - 1] == "que") { return r }; j += 1 }
                return nil
            }
            // The clause comes after: the main verb is the first one before it that isn't inside a que clause
            // ("Declararías que ya es tarde si hubiera tiempo" → declararías, not es)
            var subordinate = false
            var first: VerbReading?
            var nearest: VerbReading?
            var j = s.lowerBound
            while j < start {
                if ["que", "cuando", "porque", "aunque", "donde", "quien"].contains(words[j]) { subordinate = true }
                if let r = verb(j) {
                    nearest = r
                    if !subordinate, first == nil { first = r }
                    j = r.last
                }
                j += 1
            }
            return wantNearest ? (nearest ?? first) : (first ?? nearest)
        }
        func attachedCommand(_ j: Int) -> Bool {
            let folded = words[j].folding(options: .diacriticInsensitive, locale: Locale(identifier: "es"))
            for clitic in ["melo", "telo", "selo", "nos", "les", "los", "las", "me", "te", "se", "lo", "la", "le"] where folded.hasSuffix(clitic) && folded.count > clitic.count + 1 {
                let base = String(folded.dropLast(clitic.count))
                if VerbForms.index[base]?.contains(where: { $0.tense == .imperative }) == true, words[j] != base { return true }
            }
            return false
        }
        /// Whether the main clause (outside the clause at start...end) opens with a command: "Avísame", "ven", "no te vayas", "espérame".
        func command(outside start: Int, _ end: Int) -> Bool {
            let s = sentence(of: start)
            var j: Int
            if clauseStart.contains(start) || sentenceStart.contains(start) {
                j = end + 1
                while j < s.upperBound, !clauseStart.contains(j) { j += 1 }
            } else {
                // The verb the time clause hangs on: the nearest one before it ("Veamos qué sucede cuando…" hangs on "sucede")
                var k = start - 1
                func commandOnly(_ k: Int) -> Bool {
                    let w = words[k]
                    guard !notVerbWords.contains(w), !determiners.contains(w), !clitics.contains(w), !isNounOrAdjective(w),
                          let slots = VerbForms.index[w], !slots.isEmpty else { return false }
                    return slots.contains { $0.tense == .imperative } && slots.allSatisfy { $0.tense == .imperative || $0.tense == .subjunctivePresent }
                }
                while k >= s.lowerBound, verb(k) == nil, !commandOnly(k), !attachedCommand(k) { k -= 1 }
                guard k >= s.lowerBound else { return false }
                j = k
                while j > s.lowerBound, words[j - 1] == "no" || clitics.contains(words[j - 1]) { j -= 1 }
            }
            guard j < s.upperBound, j < start || j > end else { return false }
            var negative = false
            while j < s.upperBound, words[j] == "no" || clitics.contains(words[j]) { if words[j] == "no" { negative = true }; j += 1 }
            guard j < s.upperBound else { return false }
            let slots = VerbForms.index[words[j]] ?? []
            // Short tú commands that are also other words: "ve hacia él", "ten cuidado"
            if !negative, ["ve", "ven", "haz", "pon", "sal", "di", "ten", "sé", "id", "oye", "mira", "espera", "dime", "dame"].contains(words[j]) { return true }
            if negative { return !slots.isEmpty && slots.allSatisfy { $0.tense == .subjunctivePresent || $0.tense == .imperative } }
            // A command form that isn't also a statement ("ven", "haz", "pon"; "venga" for usted)
            if !slots.isEmpty, slots.allSatisfy({ $0.tense == .imperative || $0.tense == .subjunctivePresent }), slots.contains(where: { $0.tense == .imperative }) { return true }
            // A command with pronouns attached: "avísame", "llámalo", "espérame"
            let folded = words[j].folding(options: .diacriticInsensitive, locale: Locale(identifier: "es"))
            for clitic in ["melo", "telo", "selo", "nos", "les", "los", "las", "me", "te", "se", "lo", "la", "le"] where folded.hasSuffix(clitic) && folded.count > clitic.count + 1 {
                let base = String(folded.dropLast(clitic.count))
                if VerbForms.index[base]?.contains(where: { $0.tense == .imperative }) == true, words[j] != base { return true }
            }
            return false
        }
        func person(_ r: VerbReading, _ i: Int) -> Int {
            let s = sentence(of: i)
            if r.persons.count > 1, r.persons.contains(0), r.persons.contains(2) {
                return words[s.lowerBound..<r.first].contains("yo") ? 0 : 2
            }
            return r.persons.first ?? 2
        }
        func form(_ r: VerbReading, _ tense: Tense, _ i: Int) -> String? {
            let p = person(r, i)
            if r.perfect, let participle = r.participle, let helper = Clitics.formOf("haber", tense, p) { return "\(helper) \(participle)" }
            return Clitics.formOf(r.infinitive, tense, p)
        }
        func say(_ r: VerbReading) -> String { words[r.first...r.last].joined(separator: " ") }
        func flag(_ r: VerbReading, from: Int, _ message: String, _ fix: String?) { add(.verb, span(from, r.last), message, fix) }
        func futureMarker(_ i: Int) -> Bool {
            let s = sentence(of: i)
            let w = Array(words[s])
            return w.contains("mañana") || w.contains("pronto") || w.contains("luego") || w.contains("próximo") || w.contains("próxima")
                || zip(w, w.dropFirst()).contains { $0 == "que" && $1 == "viene" }
        }

        var licensed = Set<Int>()   // subjunctives a trigger accounts for
        var consumed = -1            // a trigger inside a longer one ("duda de que" in "no cabe duda de que") is skipped

        for i in words.indices where i > consumed {
            guard let found = moodTriggers.lazy.compactMap({ t -> (MoodTrigger, Int, Int?)? in
                guard let m = match(t, words, keys, at: i, boundary: clauseStart) else { return nil }
                return (t, m.end, m.verb)
            }).first else { continue }
            let (trigger, end, verbAt) = found
            consumed = end
            // "Nadie que…" only counts as a relative at the start of a clause ("nunca le dije a nadie que…" reports)
            if ["nadie", "ningún", "ninguna"].contains(trigger.pattern[0]), !(clauseStart.contains(i) || sentenceStart.contains(i)) { continue }
            // "de cuando era niño" (from when): not a time clause to check
            if trigger.need == .time, i > 0, words[i - 1] == "de" { continue }
            // "Para qué" written without its accent is a question, not "para que"
            if trigger.label == "para que", question(i) { continue }
            // "lo mejor" also starts "lo mejor es que" only when "es" follows; "cuándo" with an accent is a question word, matched below
            guard let clause = governed(after: end) else { continue }
            // "no porque fuera difícil, sino…": a rejected reason
            if trigger.label == "porque", i > 0 && words[i - 1] == "no" || i > 1 && words[i - 2] == "no" && ["es", "era", "fue"].contains(words[i - 1]) || words[sentence(of: i)].contains("sino") { continue }
            if clause.isSubjunctive { licensed.insert(clause.first) }
            let said = trigger.label
            let main = verbAt.flatMap { verb($0) }
            let neg = verbAt.map(negated) ?? false
            let asked = question(i)

            switch trigger.need {
            case .subjunctive:
                let feeling = trigger.pattern.contains { ["~alegrar", "~gustar", "~encantar", "~molestar", "~importar", "~preocupar", "~sorprender",
                    "~extrañar", "~lamentar", "~odiar", "~agradecer", "~doler", "~fastidiar", "~enojar", "~enfadar", "~asustar", "miedo", "pena",
                    "rabia", "lástima", "vergüenza", "~estar", "bueno", "bien", "mal", "raro"].contains($0) }
                if clause.isIndicative, feeling, said != "qué bueno que", clause.isPast || clause.perfect && !clause.tenses.contains(.present) {
                    // "Me alegro de que terminaron": recorded in Latin America for a real past fact; the standard is the subjunctive
                    let fix = form(clause, clause.perfect ? .subjunctiveImperfect : .subjunctiveImperfect, clause.first)
                    add(.tip, span(i, clause.last), "After “\(said)” the standard is the subjunctive\(fix.map { ": “\($0)”" } ?? ""). The indicative for something that happened is heard in Latin America, to stress the fact.", fix)
                    continue
                }
                if clause.isIndicative, said == "qué bueno que", clause.isPast || clause.perfect {
                    let fix = form(clause, .subjunctivePresent, clause.first)
                    add(.tip, span(i, clause.last), "“¡Qué bueno que \(say(clause))!” is common in Mexico for something that happened; the standard is the subjunctive\(fix.map { ": “hayas …” or “\($0)”" } ?? "").", nil)
                    continue
                }
                if clause.isIndicative {
                    // "lo que pasa es que" / "es que" are indicative; "no es que" is the rejection; "no ser que" needs the "no" right before
                    let fix = form(clause, main?.isPast == true || main?.tenses.contains(.conditional) == true ? .subjunctiveImperfect : .subjunctivePresent, clause.first)
                    flag(clause, from: i, "After “\(said)” Spanish uses the subjunctive, but “\(say(clause))” is indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
                    continue
                }
                guard clause.isSubjunctive, let main else { break }
                // The main verb sets the tense of the subjunctive
                // The present after a past or conditional main verb is common in Latin America: a heads-up, not an error
                if main.tenses == [.conditional], clause.tenses == [.subjunctivePresent] {
                    let fix = form(clause, .subjunctiveImperfect, clause.first)
                    add(.tip, span(main.first, clause.last), "After the conditional (“\(say(main))”) the standard is the imperfect subjunctive\(fix.map { ": “\($0)”" } ?? ""). The present is common in Latin American speech.", fix)
                } else if main.isPast, clause.tenses == [.subjunctivePresent], !futureMarker(i) {
                    let fix = form(clause, .subjunctiveImperfect, clause.first)
                    add(.tip, span(main.first, clause.last), "“\(say(main))” is in the past, so the standard is the imperfect subjunctive\(fix.map { ": “\($0)”" } ?? ""). The present is heard, mostly in Latin America, when the thing is still to come.", fix)
                } else if trigger.influence, main.isPresent || main.tenses.contains(.future), clause.tenses == [.subjunctiveImperfect], !clause.perfect {
                    let fix = form(clause, .subjunctivePresent, clause.first)
                    flag(clause, from: main.first, "“\(say(main))” is present and points forward, so the subjunctive stays in the present\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            case .indicative:
                // "No sabía que estuvieras aquí" is also heard: a negated saber is left alone
                guard clause.isSubjunctive, !asked, !(neg && main?.infinitive == "saber") else { break }
                let fix = form(clause, clause.tenses.contains(.subjunctiveImperfect) ? .imperfect : .present, clause.first)
                // "así que tengan paciencia": a command after a result word is fine
                if ["así que", "por eso", "por lo tanto"].contains(said), clause.tenses == [.subjunctivePresent] { break }
                if said == "a lo mejor" {
                    add(.tip, span(i, clause.last), "“A lo mejor” (maybe) normally takes the indicative\(fix.map { ": “\($0)”" } ?? ""). The subjunctive is heard, mostly in Mexico, but the indicative is the standard.", fix)
                    break
                }
                flag(clause, from: i, "“\(said)” states a fact, so the verb is indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
            case .claim:
                guard !asked else { break }
                // "no creas que" (a negative command) points out a fact: indicative
                let command = main.map { $0.tenses == [.subjunctivePresent] } ?? false
                let hedged = main?.tenses == [.conditional]   // "parecería que fuera…"
                let mainPerson = main.flatMap { m in m.persons.first }
                // "Eso supone que tengamos que esperar": suponer (entail) with a thing as subject takes the subjunctive
                let entail = main?.infinitive == "suponer" && !(main?.persons.contains(0) ?? false) && !(main?.persons.contains(3) ?? false)
                if !neg, !hedged, !entail, clause.isSubjunctive {
                    let fix = form(clause, clause.tenses.contains(.subjunctiveImperfect) ? .imperfect : .present, clause.first)
                    flag(clause, from: i, "“\(said)” claims it's true, so the verb is indicative\(fix.map { ": “\($0)”" } ?? ""). It takes the subjunctive only when negated (no \(said)…).", fix)
                } else if neg, !command, clause.isIndicative, !clause.tenses.contains(.future),
                          // Only your own view right now: "no creo que", "no parece que", "no es verdad que". "Juan no cree que la Tierra es
                          // redonda" and "no creía que eras tan simpático" keep the indicative to say the speaker vouches for it
                          main?.isPresent == true, mainPerson == 0 || ["parecer", "ser", "estar"].contains(main?.infinitive ?? "") {
                    let past = main?.isPast == true || clause.isPast
                    let fix = form(clause, past ? .subjunctiveImperfect : .subjunctivePresent, clause.first)
                    flag(clause, from: verbAt.map { max(0, $0 - 1) } ?? i, "Negated, “\(said)” no longer claims it, so the verb is subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            case .rejection:
                // "¿Niegas que lo dijiste?": the indicative shows the speaker thinks it's true
                if asked { break }
                if !neg, clause.isIndicative {
                    let fix = form(clause, main?.isPast == true ? .subjunctiveImperfect : .subjunctivePresent, clause.first)
                    flag(clause, from: i, "“\(said)” rejects it, so the verb is subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                } else if !neg, let main, main.isPast, clause.tenses == [.subjunctivePresent] {
                    let fix = form(clause, .subjunctiveImperfect, clause.first)
                    add(.tip, span(main.first, clause.last), "“\(say(main))” is in the past, so the standard is the imperfect subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            case .condition:
                // "Si, eso es": "sí" typed without its accent
                if clauseStart.contains(end + 1) { break }
                let before = i > 0 && !clauseStart.contains(i) ? words[i - 1] : ""
                // "no sé si…", "me preguntó si…": si = whether, which takes the tense of a question
                let whether = ["sé", "sabe", "sabes", "sabemos", "saben", "sabía", "pregunto", "preguntó", "pregunta", "preguntaba", "ver", "saber", "dudo", "duda", "averiguar", "decidir", "depende"].contains(before)
                if whether {
                    if clause.tenses == [.subjunctiveImperfect], ["preguntó", "preguntaba", "pregunta", "pregunto"].contains(before) {
                        let fix = form(clause, .imperfect, clause.first)
                        flag(clause, from: i, "Si meaning “whether” takes the tense of a question, not the subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                    }
                    break
                }
                if clause.tenses == [.subjunctivePresent] {
                    let fix = form(clause, .present, clause.first)
                    let unreal = form(clause, .subjunctiveImperfect, clause.first)
                    flag(clause, from: i, "After “\(said)” Spanish never uses the present subjunctive\(fix.map { ": “\($0)”" } ?? "")\(unreal.map { ". For something unlikely or unreal: “\($0)”" } ?? "").", fix)
                } else if clause.tenses == [.future], clauseStart.contains(i) || sentenceStart.contains(i) {
                    let fix = form(clause, .present, clause.first)
                    flag(clause, from: i, "“Si” never takes the future: for a real condition use the present\(fix.map { ": “\($0)”" } ?? "").", fix)
                } else if clause.tenses == [.conditional] {
                    let fix = form(clause, .subjunctiveImperfect, clause.first)
                    flag(clause, from: i, "The conditional never goes after “si”. For something unlikely or unreal use the \(clause.perfect ? "pluperfect" : "imperfect") subjunctive\(fix.map { ": “\($0)”" } ?? ""); the conditional goes in the other half.", fix)
                } else if said == "si", !asked, let other = mainVerb(outside: i, clause.last), !["poder", "deber", "tener", "haber", "convenir"].contains(other.infinitive) {
                    // Si + present goes with present or future; si + imperfect subjunctive with the conditional
                    if other.tenses == [.conditional], clause.isIndicative, clause.tenses.contains(.present) || clause.tenses.contains(.imperfect) {
                        let fix = form(clause, .subjunctiveImperfect, clause.first)
                        flag(clause, from: i, "With “\(say(other))” (would) the si half is unreal, so it takes the \(clause.perfect ? "pluperfect" : "imperfect") subjunctive\(fix.map { ": “si \($0)”" } ?? ""). Si + \(clause.perfect ? "pluperfect" : clause.isPresent ? "present" : "imperfect") goes with the \(clause.isPresent ? "present or future" : "indicative").", fix.map { "si \($0)" })
                    } else if clause.tenses == [.subjunctiveImperfect], other.isIndicative, other.tenses.contains(.future) || other.isPresent,
                              !command(outside: i, clause.last) {
                        // "Entendemos si no pudieran…": an unreal si goes with "would" (a command is fine: "si pudieras, llámame")
                        let fix = form(other, other.perfect ? .conditional : .conditional, other.first)
                        flag(other, from: other.first, "Si + \(clause.perfect ? "pluperfect" : "imperfect") subjunctive (“\(say(clause))”) is about something unreal or unlikely, so the other half takes the conditional\(fix.map { ": “\($0)”" } ?? ""), not the \(other.isPresent ? "present" : "future"). If it's a real possibility, keep the present and use si + present: “si no \(form(clause, .present, clause.first) ?? "…")”.", fix)
                    }
                }
            case .pastOnly:
                if !(clause.tenses == [.subjunctiveImperfect]) {
                    let target: Tense = .subjunctiveImperfect
                    let fix = form(clause, target, clause.first)
                    flag(clause, from: i, "“\(said)” only takes a past subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            case .time:
                // "¿Cuándo…?" is matched by its accent below; plain "cuando" here
                if asked { break }
                if clause.isFutureLike, said != "desde que" {
                    let fix = form(clause, .subjunctivePresent, clause.first)
                    flag(clause, from: i, "Time words never take the future or conditional: for something still to come, “\(said)” takes the subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                    break
                }
                let commandMain = command(outside: i, clause.last)
                let other = mainVerb(outside: i, clause.last, nearest: true)
                guard commandMain || other != nil else { break }
                // "Dijo que me llamaría cuando llegaba": still to come from a past point, so the imperfect subjunctive
                if let other, other.tenses == [.conditional], clause.tenses == [.imperfect], said != "mientras",
                   words[sentence(of: i).lowerBound..<other.first].contains("que") {
                    let fix = form(clause, .subjunctiveImperfect, clause.first)
                    flag(clause, from: i, "“\(say(other))” looks ahead from the past, so “\(said)” is about something still to come then: imperfect subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                    break
                }
                let forward = commandMain || (other.map { $0.tenses.contains(.future) && $0.isIndicative } ?? false)
                if forward, clause.isPresent, said != "mientras" {
                    let fix = form(clause, .subjunctivePresent, clause.first)
                    flag(clause, from: i, "The main verb points forward, so “\(said)” is about something still to come: subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                } else if let other, !commandMain, clause.isSubjunctive, said != "después de que", other.isPast || (said == "desde que" && other.isIndicative && !other.tenses.contains(.future)) {
                    let fix = form(clause, clause.tenses.contains(.subjunctiveImperfect) ? .preterite : .present, clause.first)
                    flag(clause, from: i, "This already happened (or happens), so “\(said)” takes the indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            }
        }

        for s in sentenceStart.sorted() {
            let range = sentence(of: s)
            let w = Array(words[range])
            // "¿Cuándo llegues?": a question takes the indicative
            for (k, word) in w.enumerated() where word == "cuándo" {
                if let r = governed(after: range.lowerBound + k), r.isSubjunctive {
                    licensed.insert(r.first)
                    let fix = form(r, .present, r.first)
                    flag(r, from: range.lowerBound + k, "“Cuándo” with an accent asks a question, and questions take the indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            }
            // "Aunque soy rico, no lo compraría": with "would", aunque is about something unreal
            if let k = w.firstIndex(of: "aunque"), let r = governed(after: range.lowerBound + k), r.isIndicative,
               let other = mainVerb(outside: range.lowerBound + k, r.last), other.tenses == [.conditional], !["poder", "deber"].contains(other.infinitive) {
                let fix = form(r, .subjunctiveImperfect, r.first)
                flag(r, from: range.lowerBound + k, "With “\(say(other))” (would), aunque is about something unreal, so it takes the \(r.perfect ? "pluperfect" : "imperfect") subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
            }
            // "Comió tanto que se enfermara": a result is a fact (indicative); negated ("no es tan rico que pueda") it's subjunctive
            if let t = w.firstIndex(where: { ["tan", "tanto", "tanta", "tantos", "tantas"].contains($0) }), let q = w[t...].firstIndex(of: "que"), q - t <= 3,
               !(q + 1 < w.count && w[q + 1] == "como"),
               let r = governed(after: range.lowerBound + q) {
                let neg = w[..<t].contains("no")
                if !neg, r.isSubjunctive {
                    licensed.insert(r.first)
                    let fix = form(r, r.tenses.contains(.subjunctiveImperfect) ? .preterite : .present, r.first)
                    flag(r, from: range.lowerBound + q, "A result (so much… that) is a fact, so it's indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
                } else if neg, r.isIndicative {
                    let fix = form(r, .subjunctivePresent, r.first)
                    flag(r, from: range.lowerBound + q, "With “no… tan… que” the result is rejected, so it's subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            }
            // "Pase lo que pasa": the doubled verb is subjunctive both times
            for (k, word) in w.enumerated() where ["lo", "como", "donde", "cuando", "quien"].contains(word) && k > 0 {
                let afterQue = word == "lo" ? (k + 1 < w.count && w[k + 1] == "que" ? k + 2 : nil) : k + 1
                guard let a = afterQue, a < w.count, let first = verb(range.lowerBound + k - 1), let second = verb(range.lowerBound + a),
                      first.infinitive == second.infinitive, first.isSubjunctive, second.isIndicative, !first.perfect else { continue }
                licensed.insert(first.first)
                let fix = form(second, first.tenses.contains(.subjunctiveImperfect) ? .subjunctiveImperfect : .subjunctivePresent, second.first)
                flag(second, from: second.first, "In “\(say(first)) \(w[k..<a].joined(separator: " ")) …” (no matter) the verb is subjunctive both times\(fix.map { ": “\($0)”" } ?? "").", fix)
            }
            // "Que yo sé": the hedge is "que yo sepa"
            if w.count >= 3, w[0] == "que", w[1] == "yo", let r = verb(range.lowerBound + 2), r.isIndicative, ["saber", "recordar", "entender", "ver"].contains(r.infinitive) {
                let fix = form(r, .subjunctivePresent, range.lowerBound + 2)
                flag(r, from: range.lowerBound, "The hedge “que yo…” (as far as I…) is always subjunctive\(fix.map { ": “que yo \($0)”" } ?? "").", fix.map { "que yo \($0)" })
            }
            // "Te gusta o no, vamos": like it or not is "te guste o no"
            if !question(range.lowerBound), let o = w.firstIndex(of: "o"), o + 1 < w.count, w[o + 1] == "no", o >= 1, clauseStart.contains(range.lowerBound + o + 2), let r = verb(range.lowerBound + o - 1), r.isIndicative, r.isPresent,
               w[..<(o - 1)].allSatisfy({ clitics.contains($0) }) {
                let fix = form(r, .subjunctivePresent, r.first)
                flag(r, from: range.lowerBound, "“… o no” (whether or not) takes the subjunctive\(fix.map { ": “\($0) o no”" } ?? "").", fix.map { "\($0) o no" })
            }
            // "Que estás aquí me alegra" / "El que no has venido me molestó": a clause that is the subject of a feeling is subjunctive
            if w.count >= 3, w[0] == "que" || (w[0] == "el" && w[1] == "que") {
                let q = w[0] == "que" ? 0 : 1
                if let r = governed(after: range.lowerBound + q), r.isIndicative,
                   w[(r.last - range.lowerBound + 1)...].contains(where: { ["alegra", "alegró", "molesta", "molestó", "sorprende", "sorprendió", "gusta", "gustó", "encanta", "preocupa", "preocupó", "importa", "duele", "dolió"].contains($0) }) {
                    let fix = form(r, r.isPast || r.perfect ? .subjunctivePresent : .subjunctivePresent, r.first)
                    flag(r, from: range.lowerBound, "A clause that is the subject of a feeling (“que… me alegra”) is subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
                }
            }
            // "Es que esté cansado": "es que" giving a reason is indicative
            if w.count >= 3, w[0] == "es", w[1] == "que", let r = governed(after: range.lowerBound + 1), r.isSubjunctive {
                licensed.insert(r.first)
                let fix = form(r, r.tenses.contains(.subjunctiveImperfect) ? .imperfect : .present, r.first)
                flag(r, from: range.lowerBound, "“Es que” gives a reason as a fact, so it's indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
            }
            // "Queremos que vayamos": we want that we go is "queremos ir"
            if let q = w.firstIndex(of: "que"), q >= 1, let main = verb(range.lowerBound + q - 1), ["querer", "preferir", "necesitar", "desear"].contains(main.infinitive),
               main.persons == [3], let r = governed(after: range.lowerBound + q), r.isSubjunctive, r.persons.contains(3), r.persons.count == 1 {
                flag(r, from: range.lowerBound + q - 1, "When the ones who want are the ones who do it, Spanish uses the infinitive: “\(say(main)) \(r.infinitive)”.", "\(say(main)) \(r.infinitive)")
            }
            // "Hay alguien que sepa…" as a statement: someone who exists takes the indicative
            if !question(range.lowerBound), let h = w.firstIndex(where: { $0 == "hay" }), h + 2 < w.count, w[h + 1] == "alguien", w[h + 2] == "que",
               (h == 0 || w[h - 1] != "no"), let r = governed(after: range.lowerBound + h + 2), r.isSubjunctive {
                licensed.insert(r.first)
                let fix = form(r, .present, r.first)
                flag(r, from: range.lowerBound + h, "“Hay alguien que…” says that person exists, so it's indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
            }
            // "Busco el piso que tenga…": a known, particular thing takes the indicative
            for (k, word) in w.enumerated() where ["el", "la", "al", "los", "las"].contains(word) && k > 0 {
                guard let b = verb(range.lowerBound + k - 1), ["buscar", "necesitar", "querer"].contains(b.infinitive), k + 2 < w.count, w[k + 2] == "que",
                      let r = governed(after: range.lowerBound + k + 2), r.isSubjunctive, r.tenses == [.subjunctivePresent] else { continue }
                licensed.insert(r.first)
                let fix = form(r, .present, r.first)
                flag(r, from: range.lowerBound + k, "“\(word) \(w[k + 1])” is a particular, known one, so the description is indicative\(fix.map { ": “\($0)”" } ?? ""). Something you only hope exists takes the subjunctive (“un… que \(say(r))”).", fix)
            }
            // "Cuanto más estudias, más aprenderás": with a future, cuanto más is about what's to come
            if w.count > 2, w[0] == "cuanto", ["más", "menos"].contains(w[1]), let r = governed(after: range.lowerBound + 1), r.isPresent,
               let other = mainVerb(outside: range.lowerBound, r.last), other.tenses.contains(.future) {
                let fix = form(r, .subjunctivePresent, r.first)
                flag(r, from: range.lowerBound, "With the future in the other half, “cuanto \(w[1])” is about something still to come: subjunctive\(fix.map { ": “\($0)”" } ?? "").", fix)
            }
            // "Como no llamaras, me fui": como + subjunctive is a warning about the future; about the past it means "since"
            if w.first == "como", let r = governed(after: range.lowerBound), r.isSubjunctive, let other = mainVerb(outside: range.lowerBound, r.last), other.isPast {
                licensed.insert(r.first)
                let fix = form(r, .preterite, r.first)
                flag(r, from: range.lowerBound, "About the past, “como” means “since” and takes the indicative\(fix.map { ": “\($0)”" } ?? "").", fix)
            }
        }

        // A subjunctive that nothing calls for: "Era tarde, por eso me fuera", "Siento no haya llamado"
        let licensors: Set<String> = ["que", "ojala", "quizas", "quiza", "tal", "acaso", "posiblemente", "probablemente", "aunque", "cuando", "si",
                                      "como", "donde", "mientras", "hasta", "quien", "quienes", "quienquiera", "cualquiera", "cualquier", "dondequiera",
                                      "adonde", "cuanto", "cuanta", "cuantos", "cuantas", "comoquiera", "asi", "viva", "vivan", "porque",
                                      "apenas", "conforme", "cual", "cuales", "cuan", "segun", "entre", "dios"]
        for s in sentenceStart.sorted() {
            let range = sentence(of: s)
            for j in range {
                guard !licensed.contains(j), let r = verb(j), r.first == j, r.isSubjunctive,
                      // Every reading of the word is a subjunctive ("crea" is also crear: "se crea" = it is created)
                      VerbForms.index[words[j]]?.allSatisfy({ $0.tense == .subjunctivePresent || $0.tense == .subjunctiveImperfect || $0.tense == .imperative }) ?? false,
                      !words[j].hasPrefix("hub"), !words[j].hasPrefix("fuera"), !question(j),
                      // "Pasara lo que pasara": a doubled verb
                      !words[(j + 1)..<range.upperBound].contains(words[j]) else { continue }
                // Commands and set phrases: a subjunctive that opens its clause ("Hable más alto", "No hables", "Sea como sea")
                var k = j - 1
                while k >= range.lowerBound, clitics.contains(words[k]) || words[k] == "no" || subjectWords.contains(words[k]) { k -= 1 }
                // A command can also open a clause after "y", "pero", "ni": "Deja el salón y no vuelvas"
                let opens = k < range.lowerBound || clauseStart.contains(k + 1) || ["y", "e", "o", "pero", "ni", "sino", "mas"].contains(words[k])
                if opens, r.tenses == [.subjunctivePresent] { continue }
                let clauseFrom = clauseStart.filter { $0 <= j }.max() ?? range.lowerBound
                // A present subjunctive is only out of place after a statement verb in the same clause ("Siento no haya llamado");
                // otherwise it's a command after "pero", "y ahora", "solo"…
                if r.tenses == [.subjunctivePresent] {
                    if !(clauseFrom..<j).contains(where: { verb($0)?.isIndicative == true }) { continue }
                }
                // "o sea" (I mean), "Dios quiera"
                if k >= range.lowerBound, (words[k] == "o" || words[k] == "ya") && words[j] == "sea" || words[k] == "dios" { continue }
                // Hubiera + participle also works as "would have" in the main clause
                if r.perfect, words[j].hasPrefix("hub") { continue }
                // Quisiera, pudiera, debiera are polite on their own
                if !r.perfect, ["querer", "poder", "deber"].contains(r.infinitive), r.tenses == [.subjunctiveImperfect] { continue }
                let before = keys[range.lowerBound..<j].indices.filter { licensors.contains(keys[$0]) }
                // "Si hubiera estudiado, ahora tuviera trabajo": the si licenses its own clause, not the main one
                let onlyEarlierSi = !before.isEmpty && before.allSatisfy { keys[$0] == "si" && $0 < clauseFrom } && r.tenses == [.subjunctiveImperfect]
                if !before.isEmpty, !onlyEarlierSi { continue }
                let fix: String?
                if r.tenses == [.subjunctiveImperfect] {
                    let sentenceWords = Array(words[range])
                    fix = sentenceWords.contains("ahora") || sentenceWords.contains("hoy") ? form(r, .conditional, j) : form(r, .preterite, j)
                } else {
                    fix = form(r, .present, j)
                }
                flag(r, from: j, "“\(say(r))” is a subjunctive, but nothing in the sentence calls for one (a trigger like que, ojalá or quizás before it)\(fix.map { ": “\($0)”" } ?? "").", fix)
            }
        }
    }
}
