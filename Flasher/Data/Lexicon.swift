import Foundation

/// One part-of-speech block of a dictionary entry, with every meaning listed for it.
struct Meaning: Hashable {
    let partOfSpeech: PartOfSpeech
    let gender: String?   // "m", "f" or "mf"
    let senses: [String]
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
                    let senses = cols[5].components(separatedBy: " ¦ ")
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
            guard let main = meanings[headword]?.first else { continue }
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

    /// A short flashcard-friendly gloss: the first couple of senses without parenthetical detail.
    static func summary(of senses: [String]) -> String {
        var parts: [String] = []
        for sense in senses.prefix(3) {
            let short = stripParentheses(sense)
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
