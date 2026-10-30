import Foundation

enum SearchScope: String, CaseIterable, Identifiable {
    case all, spanish, english

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "All"
        case .spanish: "Español"
        case .english: "English"
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
                let terms = englishTerms(sense)
                if index == 0 { primary.formUnion(terms) } else { secondary.formUnion(terms) }
                text.append(sense)
            }
        }
        secondary.subtract(primary)
        let spanish = word.spanish.searchKey
        let termList = Array(primary) + Array(secondary)
        let fuzzyTerms = [Array(spanish.utf8)] + (Array(primary) + Array(secondary).prefix(8)).map { Array($0.utf8) }
        return Entry(word: word, spanish: spanish, primaryTerms: primary, secondaryTerms: secondary,
                     termList: termList, englishText: text.joined(separator: " ¦ ").searchKey,
                     fuzzy: fuzzyTerms, diminutive: DiminutiveResolver.resolve(word.spanish))
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
    static func search(_ query: String, scope: SearchScope) -> [SearchHit] {
        let q = query.searchKey
        guard !q.isEmpty else { return [] }

        let queryBytes = Array(q.utf8)
        let maxTypos = q.count >= 7 ? 2 : (q.count >= 4 ? 1 : 0)
        var ranked: [(rank: Int, language: Int, hit: SearchHit)] = []

        // "casita" → casa. Goes first unless "casita" has its own entry; that entry then stays on top.
        let diminutive = scope == .english ? nil : DiminutiveResolver.resolve(q)
        if let diminutive {
            ranked.append((diminutive.inDictionary ? 1 : -1, 0, SearchHit(word: diminutive.base, diminutive: diminutive)))
        }

        for entry in entries where entry.word.id != diminutive?.base.id {
            var best: (tier: Int, language: Int)?
            if scope != .english, let tier = spanishTier(q, entry.spanish) { best = (tier, 0) }
            if scope != .spanish, let tier = englishTier(q, entry), best == nil || tier < best!.tier { best = (tier, 1) }

            if let best {
                ranked.append((best.tier * 2, best.language,
                               SearchHit(word: entry.word, diminutive: entry.diminutive, matchedEnglish: best.language == 1)))
            } else if maxTypos > 0 {
                var closest: (distance: Int, language: Int)?
                for (index, term) in entry.fuzzy.enumerated() {
                    if index == 0 ? scope == .english : scope == .spanish { continue }
                    if let d = editDistance(queryBytes, term, limit: maxTypos), closest == nil || d < closest!.distance {
                        closest = (d, index == 0 ? 0 : 1)
                    }
                }
                if let closest {
                    ranked.append(((5 + closest.distance) * 2, closest.language,
                                   SearchHit(word: entry.word, diminutive: entry.diminutive, matchedEnglish: closest.language == 1)))
                }
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
        if entry.primaryTerms.contains(q) { return 0 }
        if entry.secondaryTerms.contains(q) { return 1 }
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
