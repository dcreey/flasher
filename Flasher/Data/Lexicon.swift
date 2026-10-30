import Foundation

/// One meaning of a word. Mexican meanings are flagged in the data and sorted first.
struct Sense: Hashable {
    let text: String
    let isMexican: Bool

    /// Vulgar or offensive senses never become a word's one-line gloss.
    var isCrude: Bool {
        guard text.hasPrefix("(") else { return false }
        let label = text.prefix { $0 != ")" }
        return ["vulgar", "offensive", "derogatory"].contains { label.contains($0) }
    }

    init(raw: String) {
        isMexican = raw.hasPrefix("§")
        text = isMexican ? String(raw.dropFirst()) : raw
    }

    init(text: String, isMexican: Bool) {
        self.text = text
        self.isMexican = isMexican
    }
}

/// One part-of-speech block of a dictionary entry, with every meaning listed for it.
struct Meaning: Hashable {
    let partOfSpeech: PartOfSpeech
    let gender: String?   // "m", "f" or "mf"
    let senses: [Sense]
}

/// A Mexican meaning together with the part of speech it belongs to.
struct MexicanMeaning: Hashable {
    let text: String
    let partOfSpeech: PartOfSpeech?
}

/// The bundled dictionary: Wiktionary entries that are also attested in real subtitle text, ordered by frequency.
/// Words from the original flashcard set keep their own entries; everything else is dictionary-only.
final class Lexicon {
    static let shared = Lexicon()

    let meaningsByWord: [String: [Meaning]]
    /// Dictionary-only words, most frequent first.
    let extraWords: [Word]
    let allWords: [Word]
    let wordsByID: [String: Word]
    /// Diminutive / augmentative / superlative forms Wiktionary links to a base word, keyed by accent-free form.
    let derivations: [String: (base: String, kind: String)]

    func meanings(for spanish: String) -> [Meaning] { meaningsByWord[spanish] ?? [] }

    private init() {
        var meanings: [String: [Meaning]] = [:]
        var firstRank: [String: Int] = [:]
        var derived: [String: (base: String, kind: String)] = [:]

        if let url = Bundle.main.url(forResource: "lexicon", withExtension: "tsv"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            for line in text.split(separator: "\n") {
                let cols = line.split(separator: "\t", omittingEmptySubsequences: false)
                switch cols.first.map(String.init) ?? "" {
                case "W" where cols.count >= 6:
                    guard let pos = Self.partOfSpeech(String(cols[2])) else { continue }
                    let word = String(cols[1])
                    let gender = cols[3].isEmpty ? nil : String(cols[3])
                    let senses = cols[5].components(separatedBy: " ¦ ").map { Sense(raw: $0) }
                    meanings[word, default: []].append(Meaning(partOfSpeech: pos, gender: gender, senses: senses))
                    if firstRank[word] == nil { firstRank[word] = Int(cols[4]) ?? Int.max }
                case "D" where cols.count >= 4:
                    derived[String(cols[1]).searchKey] = (String(cols[2]), String(cols[3]))
                default:
                    break
                }
            }
        }

        var byID: [String: Word] = [:]
        for word in SeedData.words where byID[word.id] == nil { byID[word.id] = word }
        let originalCount = SeedData.words.count

        let newHeadwords = meanings.keys.filter { byID[$0] == nil }
            .sorted { (firstRank[$0] ?? .max, $0) < (firstRank[$1] ?? .max, $1) }
        var extras: [Word] = []
        extras.reserveCapacity(newHeadwords.count)
        for (index, headword) in newHeadwords.enumerated() {
            guard let blocks = meanings[headword], let first = blocks.first else { continue }
            // The headline follows the block holding a Mexican meaning, if there is one
            let main = blocks.first { $0.senses.contains { $0.isMexican } } ?? first
            let gender = main.gender == "m" || main.gender == "f" ? main.gender : nil
            let word = Word(order: originalCount + index, spanish: headword,
                            english: Self.summary(of: main.senses), partOfSpeech: main.partOfSpeech, gender: gender)
            extras.append(word)
            byID[headword] = word
        }

        meaningsByWord = meanings
        extraWords = extras
        wordsByID = byID
        allWords = SeedData.words + extras
        derivations = derived
    }

    private static func partOfSpeech(_ raw: String) -> PartOfSpeech? { PartOfSpeech(rawValue: raw) }

    /// "(MX)", "(Mexican)", "(Mexico)" or "(MX CDMX)" in the flashcard data marks a Mexican gloss.
    private static let mexicanMarker = try! NSRegularExpression(pattern: #"\s*\((?:MX|Mexican|Mexico)\b[^)]*\)"#)

    private static func removingMexicanMarker(_ text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)
        guard mexicanMarker.firstMatch(in: text, range: range) != nil else { return nil }
        return mexicanMarker.stringByReplacingMatches(in: text, range: range, withTemplate: "")
    }

    /// "(also Guatemala) submarine sandwich" reads better as "submarine sandwich (also Guatemala)".
    private static func tidyAlsoLabel(_ text: String) -> String {
        guard text.hasPrefix("(also "), let close = text.firstIndex(of: ")") else { return text }
        let label = text[text.startIndex...close]
        let rest = text[text.index(after: close)...].trimmingCharacters(in: .whitespaces)
        return rest.isEmpty ? text : "\(rest) \(label)"
    }

    /// Meanings Mexican Spanish uses: the flagged Wiktionary senses, plus anything the flashcard data marks as Mexican.
    func mexicanMeanings(for word: Word) -> [MexicanMeaning] {
        var result: [MexicanMeaning] = []
        func add(_ text: String, _ pos: PartOfSpeech?) {
            let clean = Self.tidyAlsoLabel(text.trimmingCharacters(in: .whitespaces))
            if !clean.isEmpty, !result.contains(where: { $0.text.lowercased() == clean.lowercased() }) {
                result.append(MexicanMeaning(text: clean, partOfSpeech: pos))
            }
        }
        if let gloss = Self.removingMexicanMarker(word.english) {
            add(gloss, word.partOfSpeech)
        }
        for block in meanings(for: word.spanish) {
            for sense in block.senses where sense.isMexican { add(sense.text, block.partOfSpeech) }
        }
        return result
    }

    func hasMexicanMeaning(_ word: Word) -> Bool {
        Self.removingMexicanMarker(word.english) != nil
            || meanings(for: word.spanish).contains { $0.senses.contains { $0.isMexican } }
    }

    /// A short flashcard-friendly gloss: the first couple of senses without parenthetical detail.
    static func summary(of senses: [Sense]) -> String {
        var parts: [String] = []
        // Mexican meanings lead; vulgar ones only if nothing else exists
        let ordered = senses.filter { !$0.isCrude } + senses.filter { $0.isCrude }
        let mexicanFirst = ordered.filter(\.isMexican) + ordered.filter { !$0.isMexican }
        for sense in mexicanFirst.prefix(3) {
            let short = stripParentheses(sense.text)
            if !short.isEmpty, !parts.contains(short) { parts.append(short) }
            if parts.count == 2 { break }
        }
        let joined = parts.joined(separator: ", ")
        return joined.count > 70 ? String(joined.prefix(70)) : joined
    }

    static func stripParentheses(_ text: String) -> String {
        var result = ""
        var depth = 0
        for ch in text {
            if ch == "(" { depth += 1 }
            else if ch == ")" { depth = max(0, depth - 1) }
            else if depth == 0 { result.append(ch) }
        }
        return result.split(separator: " ").joined(separator: " ").trimmingCharacters(in: CharacterSet(charactersIn: " ,;:"))
    }
}
