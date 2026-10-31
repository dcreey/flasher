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
    var id: String { word.id }
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
    static func search(_ query: String, scope: SearchScope, isFallback: Bool = false) -> [SearchHit] {
        let q = query.searchKey
        guard !q.isEmpty else { return [] }

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
        let formIDs = Set(formWords.map(\.id))
        // "el profesor" searches like "profesor"
        let articles = ["el ", "la ", "los ", "las ", "un ", "una ", "unos ", "unas "]
        let bare = articles.first(where: { q.hasPrefix($0) && q.count > $0.count }).map { String(q.dropFirst($0.count)) }

        for entry in entries where entry.word.id != diminutive?.base.id && !formIDs.contains(entry.word.id) {
            var best: (tier: Int, language: Int)?
            if scope != .english {
                let direct = spanishTier(q, entry.spanish)
                let viaBare = bare.flatMap { spanishTier($0, entry.spanish) }.map { $0 + 1 }
                if let tier = [direct, viaBare].compactMap({ $0 }).min() { best = (tier, 0) }
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
