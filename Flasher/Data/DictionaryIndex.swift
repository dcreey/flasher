import Foundation

enum SearchScope: String, CaseIterable, Identifiable {
    case all, spanish, english

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .spanish: "🇲🇽 Español"
        case .english: "🇺🇸 English"
        }
    }

    var prompt: String {
        switch self {
        case .all: "Search Spanish or English"
        case .spanish: "Search in Spanish"
        case .english: "Search in English"
        }
    }
}

/// A search result. `diminutive` is set when the query (or the word itself) is a derived form such as -ito/-ita;
/// `matchedEnglish` is set when the word was found through its English meaning.
struct SearchHit: Identifiable, Hashable {
    let word: Word
    let diminutive: Diminutive?
    var matchedEnglish = false
    /// The meaning of an adjective that fits the chosen type of thing ("rich" + food → "tasty, yummy").
    var senseNote: String?
    /// Set when the query is a verb with pronouns attached ("vernos"): the page explains the form.
    var attached: Clitics.Match?
    var id: String { word.id }
}

/// What an adjective describes: the filter behind "rich food" / "rich person".
enum TypeCategory: String, CaseIterable, Identifiable {
    case person = "p", animal = "a", food = "f", place = "l", thing = "t", weather = "w", body = "b", idea = "i"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .person: "Person"
        case .animal: "Animal"
        case .food: "Food & drink"
        case .place: "Place"
        case .thing: "Thing"
        case .weather: "Weather"
        case .body: "Body"
        case .idea: "Situation or idea"
        }
    }

    var symbol: String {
        switch self {
        case .person: "person.fill"
        case .animal: "pawprint.fill"
        case .food: "fork.knife"
        case .place: "mappin.and.ellipse"
        case .thing: "shippingbox.fill"
        case .weather: "cloud.sun.fill"
        case .body: "hand.raised.fill"
        case .idea: "lightbulb.fill"
        }
    }

    private static let nouns: [TypeCategory: [String]] = [
        .person: ["person", "man", "woman", "boy", "girl", "guy", "people", "child", "kid", "friend", "teacher", "student", "boss", "someone", "mother", "father", "husband", "wife", "doctor", "worker", "baby", "neighbor", "persona", "hombre", "mujer", "nino", "nina", "chico", "chica", "amigo", "gente", "maestro", "jefe"],
        .animal: ["animal", "dog", "cat", "horse", "bird", "cow", "pig", "fish", "pet", "perro", "gato", "caballo", "pajaro", "vaca", "cerdo", "pez", "mascota"],
        .food: ["food", "meal", "dish", "dessert", "drink", "wine", "coffee", "beer", "soup", "sauce", "cake", "bread", "meat", "fruit", "cheese", "salsa", "tea", "juice", "taste", "flavor", "comida", "plato", "postre", "bebida", "vino", "cafe", "cerveza", "sopa", "salsa", "pan", "carne", "fruta", "queso", "sabor"],
        .place: ["place", "city", "town", "house", "room", "home", "street", "country", "area", "neighborhood", "restaurant", "park", "building", "village", "lugar", "ciudad", "pueblo", "casa", "cuarto", "calle", "pais", "barrio", "restaurante", "parque", "edificio"],
        .thing: ["thing", "object", "car", "book", "table", "clothes", "shirt", "material", "fabric", "box", "bag", "cosa", "objeto", "carro", "coche", "libro", "mesa", "ropa", "camisa", "tela", "caja", "bolsa"],
        .weather: ["weather", "day", "rain", "wind", "sky", "climate", "night", "morning", "clima", "dia", "lluvia", "viento", "cielo", "noche", "manana"],
        .body: ["body", "skin", "hair", "face", "hand", "eyes", "voice", "cuerpo", "piel", "pelo", "cabello", "cara", "mano", "ojos", "voz"],
        .idea: ["idea", "situation", "problem", "question", "task", "exam", "test", "job", "story", "news", "life", "matter", "decision", "issue", "answer", "situacion", "problema", "pregunta", "tarea", "examen", "trabajo", "historia", "noticia", "vida", "decision", "respuesta"],
    ]
    private static let lookup: [String: TypeCategory] = {
        var map: [String: TypeCategory] = [:]
        for (category, words) in nouns { for word in words where map[word] == nil { map[word] = category } }
        return map
    }()
    private static let fillers: Set<String> = ["a", "an", "the", "of", "el", "la", "los", "las", "un", "una", "unos", "unas", "de", "that", "is", "very", "muy"]

    /// "rich food" → (food, "rich"); "a heavy person" → (person, "heavy"). The last type word wins, the rest is the adjective.
    static func parse(_ query: String) -> (category: TypeCategory, core: String)? {
        let tokens = query.split(separator: " ").map(String.init)
        guard tokens.count >= 2, let index = tokens.lastIndex(where: { lookup[$0] != nil }) else { return nil }
        let core = tokens.enumerated().filter { $0.offset != index && !fillers.contains($0.element) }.map(\.element)
        guard !core.isEmpty, let category = lookup[tokens[index]] else { return nil }
        return (category, core.joined(separator: " "))
    }
}

/// Precomputed accent-free strings so each keystroke is a cheap scan of the whole dictionary.
enum DictionaryIndex {
    private struct Entry {
        let word: Word
        let spanish: String
        let headlineTerms: [String]       // the word's own one-line gloss ("sit down")
        let primaryTerms: Set<String>     // English terms of the first meaning ("ant", "run")
        let secondaryTerms: Set<String>   // English terms of later meanings
        let termList: [String]
        let englishText: String
        let fuzzy: [[UInt8]]              // Spanish headword first, then English terms
        let diminutive: Diminutive?
    }

    private static let entries: [Entry] = Lexicon.shared.allWords.map { word in
        let meanings = Lexicon.shared.meanings(for: word.spanish)
        var primary = Set(englishTerms(word.english))
        var secondary: Set<String> = []
        var text = [word.english]
        for meaning in meanings {
            for (index, sense) in meaning.senses.enumerated() {
                let terms = englishTerms(sense.text)
                // The first meaning and every Mexican meaning count as primary
                if index == 0 || sense.isMexican { primary.formUnion(terms) } else { secondary.formUnion(terms) }
                text.append(sense.text)
            }
        }
        secondary.subtract(primary)
        let spanish = word.spanish.searchKey
        let termList = Array(primary) + Array(secondary)
        let fuzzyTerms = [Array(spanish.utf8)] + (Array(primary) + Array(secondary).prefix(8)).map { Array($0.utf8) }
        return Entry(word: word, spanish: spanish, headlineTerms: englishTerms(word.english), primaryTerms: primary, secondaryTerms: secondary,
                     termList: termList, englishText: text.joined(separator: " ¦ ").searchKey,
                     fuzzy: fuzzyTerms, diminutive: DiminutiveResolver.resolve(word.spanish))
    }

    /// Every plural and other-sex form of a noun, so "profesoras" finds profesor.
    private static let formIndex: [String: [Word]] = {
        var map: [String: [Word]] = [:]
        for (headword, forms) in Extras.shared.nounForms {
            guard let word = Lexicon.shared.wordsByID[headword] else { continue }
            let all = forms.plural + forms.feminine + forms.femininePlural + forms.masculine + forms.masculinePlural
            for form in all where form != headword {
                let key = form.searchKey
                if !(map[key]?.contains(word) ?? false) { map[key, default: []].append(word) }
            }
        }
        return map
    }()

    /// The nouns a plural or other-sex form belongs to ("bocas" → boca), most common first.
    static func nounsWithForm(_ form: String) -> [Word] {
        (formIndex[form.searchKey] ?? []).sorted { $0.order < $1.order }
    }

    /// "los profesores y las profesoras" → the words behind each form: articles are dropped, "y"/"o"/commas separate the parts.
    private static func wordsForForms(in q: String) -> [Word] {
        let articles: Set<String> = ["el", "la", "los", "las", "un", "una", "unos", "unas"]
        var parts = [q]
        for separator in [" y ", " o ", ",", "/"] { parts = parts.flatMap { $0.components(separatedBy: separator) } }
        var found: [Word] = []
        for part in parts {
            var tokens = part.split(separator: " ").map(String.init)
            if tokens.count > 1, articles.contains(tokens[0]) { tokens.removeFirst() }
            let key = tokens.joined(separator: " ")
            let matches = formIndex[key] ?? []
            for word in matches where !found.contains(word) { found.append(word) }
        }
        return found
    }

    /// Builds the index ahead of the first search.
    static func warmUp() { _ = entries.count }

    /// "foot (a part of the body), base" → ["foot", "base"]; verbs drop the leading "to".
    private static func englishTerms(_ gloss: String) -> [String] {
        Lexicon.stripParentheses(gloss).searchKey
            .split(whereSeparator: { ",;/:".contains($0) })
            .map { term -> String in
                var t = term.trimmingCharacters(in: .whitespaces)
                for article in ["to ", "a ", "an ", "the "] where t.hasPrefix(article) {
                    t = String(t.dropFirst(article.count))
                    break
                }
                return t
            }
            .filter { !$0.isEmpty && $0.count <= 40 }
    }

    /// Exact matches in either language rank first (the primary meaning ahead of secondary ones), then Spanish
    /// prefixes, English prefixes / Spanish substrings and English substrings. Queries of 4+ characters also
    /// match near-misses (typos) after the direct matches.
    static func search(_ query: String, scope: SearchScope, category: TypeCategory? = nil, readsTypeFromQuery: Bool = true, isFallback: Bool = false) -> [SearchHit] {
        var q = query.searchKey
        guard !q.isEmpty else { return [] }
        // "rich food": the type word sets the filter, the rest is what we search for
        var filter = category
        if !isFallback, readsTypeFromQuery, let parsed = TypeCategory.parse(q) {
            q = parsed.core
            filter = category ?? parsed.category
            let found = search(q, scope: scope, category: filter, isFallback: true)
            let described = describing(found, as: filter!, matching: q)
            if !described.isEmpty || category != nil { return described }
            q = query.searchKey
            filter = nil
        } else if let category, !isFallback {
            return describing(search(q, scope: scope, category: category, isFallback: true), as: category, matching: q)
        }

        // "to sit" / "a house" / "the ant" search the same as "sit" / "house" / "ant" on the English side
        var englishQuery = q
        for article in ["to ", "a ", "an ", "the "] where q.hasPrefix(article) && q.count > article.count + 1 {
            englishQuery = String(q.dropFirst(article.count))
            break
        }
        let queryBytes = Array(q.utf8)
        let englishBytes = Array(englishQuery.utf8)
        func typos(_ text: String) -> Int { text.count >= 7 ? 2 : (text.count >= 4 ? 1 : 0) }
        let maxTypos = max(typos(q), typos(englishQuery))
        var ranked: [(rank: Int, language: Int, hit: SearchHit)] = []

        // "casita" → casa. Goes first unless "casita" has its own entry; that entry then stays on top.
        let diminutive = scope == .english ? nil : DiminutiveResolver.resolve(q)
        if let diminutive {
            ranked.append((diminutive.inDictionary ? 1 : -1, 0, SearchHit(word: diminutive.base, diminutive: diminutive)))
        }

        // "los profesores y las profesoras" / "profesoras": plural and other-sex forms lead
        let formWords = scope == .english ? [] : wordsForForms(in: q)
        for word in formWords where word.id != diminutive?.base.id {
            ranked.append((0, 0, SearchHit(word: word, diminutive: nil)))
        }
        var formIDs = Set(formWords.map(\.id))
        // "vernos" / "dámelo" / "hacerlo": a verb with pronouns attached, when it isn't an entry of its own
        if scope != .english, !q.contains(" "), !entries.contains(where: { $0.spanish == q }), let attached = Clitics.resolve(q),
           attached.verb.id != diminutive?.base.id, formIDs.insert(attached.verb.id).inserted {
            ranked.append((0, 0, SearchHit(word: attached.verb, diminutive: nil, senseNote: attached.note, attached: attached)))
        }
        // "el profesor" searches like "profesor"
        let articles = ["el ", "la ", "los ", "las ", "un ", "una ", "unos ", "unas "]
        let bare = articles.first(where: { q.hasPrefix($0) && q.count > $0.count }).map { String(q.dropFirst($0.count)) }

        // "nos veo" / "me lo dice": pronouns in front of a conjugated verb. Rank 1 keeps real entries ("me gusta") above it.
        if scope != .english, q.contains(" "), let phrase = Clitics.resolvePhrase(q), phrase.verb.id != diminutive?.base.id, formIDs.insert(phrase.verb.id).inserted {
            ranked.append((1, 0, SearchHit(word: phrase.verb, diminutive: nil, senseNote: phrase.note, attached: phrase)))
        }

        // "recordarse" / "soñarse" find recordar / soñar when they have no reflexive entry of their own
        var reflexiveBase: String?
        if q.count > 5, ["arse", "erse", "irse"].contains(where: q.hasSuffix) { reflexiveBase = String(q.dropLast(2)) }

        for entry in entries where entry.word.id != diminutive?.base.id && !formIDs.contains(entry.word.id) {
            var best: (tier: Int, language: Int)?
            if scope != .english {
                let direct = spanishTier(q, entry.spanish)
                let viaBare = bare.flatMap { spanishTier($0, entry.spanish) }.map { $0 + 1 }
                let viaReflexive = entry.word.partOfSpeech == .infinitive && entry.spanish == reflexiveBase ? 1 : nil
                if let tier = [direct, viaBare, viaReflexive].compactMap({ $0 }).min() { best = (tier, 0) }
            }
            if scope != .spanish, let tier = englishTier(englishQuery, entry), best == nil || tier < best!.tier { best = (tier, 1) }

            if let best {
                ranked.append((best.tier * 2, best.language,
                               SearchHit(word: entry.word, diminutive: entry.diminutive, matchedEnglish: best.language == 1)))
            } else if maxTypos > 0 {
                var closest: (distance: Int, language: Int)?
                for (index, term) in entry.fuzzy.enumerated() {
                    if index == 0 ? scope == .english : scope == .spanish { continue }
                    let isSpanish = index == 0
                    let allowed = isSpanish ? typos(q) : typos(englishQuery)
                    if let d = editDistance(isSpanish ? queryBytes : englishBytes, term, limit: allowed), closest == nil || d < closest!.distance {
                        closest = (d, index == 0 ? 0 : 1)
                    }
                }
                if let closest {
                    ranked.append(((5 + closest.distance) * 2, closest.language,
                                   SearchHit(word: entry.word, diminutive: entry.diminutive, matchedEnglish: closest.language == 1)))
                }
            }
        }
        // "it reminds me of" / "it seems like": drop the subject and the trailing particles, and find the verb
        if scope != .spanish, !isFallback, let core = englishCore(englishQuery) {
            for variant in core {
                let hits = search(variant, scope: scope, isFallback: true)
                if !hits.isEmpty {
                    let ids = Set(hits.prefix(12).map(\.id))
                    ranked.removeAll { ids.contains($0.hit.id) && $0.rank > 3 }
                    let kept = Set(ranked.map(\.hit.id))
                    for (index, hit) in hits.prefix(12).enumerated() where !kept.contains(hit.id) { ranked.append((3 + index, hit.matchedEnglish ? 1 : 0, hit)) }
                    break
                }
            }
        }
        // Nothing matched the whole phrase ("que gusto"): fall back to the words in it, the content words first
        if ranked.isEmpty, englishQuery.contains(" "), !isFallback {
            let small: Set<String> = ["que", "de", "la", "el", "los", "las", "un", "una", "y", "a", "en", "lo", "se", "me", "te", "por", "para", "con", "no", "to", "the", "of", "an"]
            let tokens = englishQuery.split(separator: " ").map(String.init)
            for group in [tokens.filter { !small.contains($0) }, tokens.filter { small.contains($0) }] {
                var seen: Set<String> = []
                for token in group {
                    for hit in search(token, scope: scope, isFallback: true).prefix(6) where seen.insert(hit.id).inserted {
                        ranked.append((6 + (group.first == token ? 0 : 1), hit.matchedEnglish ? 1 : 0, hit))
                    }
                }
                if !ranked.isEmpty { break }
            }
        }
        return ranked
            .sorted {
                if $0.rank != $1.rank { return $0.rank < $1.rank }
                if $0.hit.word.order != $1.hit.word.order { return $0.hit.word.order < $1.hit.word.order }
                return $0.language < $1.language
            }
            .map(\.hit)
    }

    /// "it reminds me of" → ["remind", "reminds", ...]: the verb of an English phrase with its subject and trailing particles removed.
    private static func englishCore(_ q: String) -> [String]? {
        let subjects: Set<String> = ["it", "he", "she", "they", "we", "you", "i", "that", "this", "which", "who"]
        let trailing: Set<String> = ["me", "of", "like", "to", "you", "him", "her", "us", "them", "it", "as", "about", "that", "up", "for"]
        var tokens = q.split(separator: " ").map(String.init)
        guard tokens.count > 1 else { return nil }
        while let first = tokens.first, tokens.count > 1, subjects.contains(first) { tokens.removeFirst() }
        while let last = tokens.last, tokens.count > 1, trailing.contains(last) { tokens.removeLast() }
        let phrase = tokens.joined(separator: " ")
        guard phrase != q, let verb = tokens.first else { return nil }
        var variants: [String] = []
        if tokens.count == 1 {
            for suffix in ["s", "ed", "ing", "es", "d"] where verb.hasSuffix(suffix) && verb.count > suffix.count + 2 {
                variants.append(String(verb.dropLast(suffix.count)))
            }
        }
        return variants + [phrase]
    }

    /// Keeps the adjectives that can describe this kind of thing, the ones whose meaning is tagged for it first.
    private static func describing(_ hits: [SearchHit], as category: TypeCategory, matching text: String) -> [SearchHit] {
        var tagged: [SearchHit] = []
        var open: [SearchHit] = []
        for hit in hits {
            // Words like "rico" are filed under their main meaning but also have an adjective one
            guard let adjective = Lexicon.shared.meanings(for: hit.word.spanish).first(where: { $0.partOfSpeech == .adjective }) else { continue }
            guard let tags = Extras.shared.adjectiveCategories[hit.word.spanish] else { open.append(hit); continue }
            let fitting = tags.indices.filter { tags[$0].contains(category.rawValue) }
            if !fitting.isEmpty {
                var hit = hit
                let senses = adjective.senses
                // The fitting meaning that mentions what was typed ("rich" → rico's "rich (having a lot of money)")
                let index = fitting.first { $0 < senses.count && senses[$0].text.searchKey.contains(text) } ?? fitting[0]
                if index < senses.count { hit.senseNote = senses[index].text }
                tagged.append(hit)
            }
        }
        // Adjectives nobody has tagged yet stay available, after the ones known to fit
        return tagged + open.prefix(10)
    }

    private static func spanishTier(_ q: String, _ spanish: String) -> Int? {
        if spanish == q { return 0 }
        if spanish.hasPrefix(q) { return 2 }
        if spanish.contains(q) { return 3 }
        return nil
    }

    private static func englishTier(_ q: String, _ entry: Entry) -> Int? {
        // The word's own gloss leads: "sit" finds sentarse ("to sit down") before words that only mention sitting
        if entry.headlineTerms.contains(where: { $0 == q || $0.hasPrefix(q + " ") }) { return 0 }
        if entry.primaryTerms.contains(q) { return 1 }
        if entry.primaryTerms.contains(where: { $0.hasPrefix(q + " ") }) || entry.secondaryTerms.contains(q) { return 2 }
        if entry.termList.contains(where: { $0.hasPrefix(q) }) { return 3 }
        if entry.englishText.contains(q) { return 4 }
        return nil
    }

    /// Damerau-Levenshtein (adjacent swaps count as one edit). Returns nil once the
    /// distance is certain to exceed `limit`, so most comparisons bail out immediately.
    private static func editDistance(_ a: [UInt8], _ b: [UInt8], limit: Int) -> Int? {
        if abs(a.count - b.count) > limit { return nil }
        if a.isEmpty || b.isEmpty { return max(a.count, b.count) <= limit ? max(a.count, b.count) : nil }

        var twoAgo = [Int](repeating: 0, count: b.count + 1)
        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)

        for i in 1...a.count {
            current[0] = i
            var rowMin = i
            for j in 1...b.count {
                let cost = a[i - 1] == b[j - 1] ? 0 : 1
                var d = min(previous[j] + 1, current[j - 1] + 1, previous[j - 1] + cost)
                if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                    d = min(d, twoAgo[j - 2] + 1)
                }
                current[j] = d
                rowMin = min(rowMin, d)
            }
            if rowMin > limit { return nil }
            (twoAgo, previous, current) = (previous, current, twoAgo)
        }
        return previous[b.count] <= limit ? previous[b.count] : nil
    }
}
