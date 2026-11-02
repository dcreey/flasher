import Foundation

/// One meaning of a word. Meanings used in the target country are flagged and sorted first.
struct Sense: Hashable {
    let text: String
    /// Used in the target country (`Country.current`).
    let isLocal: Bool
    /// Flagged as Mexican in the bundled data, whichever country is selected.
    let fromMexico: Bool

    /// Vulgar or offensive senses never become a word's one-line gloss.
    var isCrude: Bool {
        guard text.hasPrefix("(") else { return false }
        let label = text.prefix { $0 != ")" }
        return ["vulgar", "offensive", "derogatory"].contains { label.contains($0) }
    }

    init(raw: String) {
        fromMexico = raw.hasPrefix("§")
        isLocal = fromMexico
        text = fromMexico ? String(raw.dropFirst()) : raw
    }

    init(text: String, isLocal: Bool, fromMexico: Bool) {
        self.text = text
        self.isLocal = isLocal
        self.fromMexico = fromMexico
    }

    /// The same meaning as seen from another country: local if its label names that country, with Mexico spelled out once it no longer leads.
    func seen(from country: Country) -> Sense {
        if country == .mexico { return Sense(text: text, isLocal: fromMexico, fromMexico: fromMexico) }
        let labelEnd = text.hasPrefix("(") ? text.firstIndex(of: ")") : nil
        let label = labelEnd.map { String(text[text.startIndex...$0]) } ?? ""
        if label.contains(country.label) { return Sense(text: text, isLocal: true, fromMexico: fromMexico) }
        guard fromMexico else { return Sense(text: text, isLocal: false, fromMexico: false) }
        // The data drops "Mexico" from Mexican meanings, so put it back
        let labelled: String
        if label.hasPrefix("(also ") { labelled = text }
        else if label.isEmpty { labelled = "(Mexico) " + text }
        else { labelled = "(Mexico, " + text.dropFirst() }
        return Sense(text: labelled, isLocal: false, fromMexico: true)
    }
}

/// One part-of-speech block of a dictionary entry, with every meaning listed for it.
struct Meaning: Hashable {
    let partOfSpeech: PartOfSpeech
    let gender: String?   // "m", "f" or "mf"
    let senses: [Sense]
}

/// A meaning used in the target country together with the part of speech it belongs to.
struct LocalMeaning: Hashable {
    let text: String
    let partOfSpeech: PartOfSpeech?
}

/// The bundled dictionary: Wiktionary entries that are also attested in real subtitle text, ordered by frequency.
/// Words from the original flashcard set keep their own entries; everything else is dictionary-only.
final class Lexicon {
    static let shared = Lexicon()

    let meaningsByWord: [String: [Meaning]]
    /// Diminutive / augmentative / superlative forms Wiktionary links to a base word, keyed by accent-free form.
    let derivations: [String: (base: String, kind: String)]
    private let firstRank: [String: Int]

    /// The word lists depend on the target country: its deck, and which meaning leads each dictionary-only word.
    private struct Words {
        let extra: [Word]
        let all: [Word]
        let byID: [String: Word]
    }
    private var words: PerCountry<Words>!

    /// Dictionary-only words, most frequent first.
    var extraWords: [Word] { words.current.extra }
    var allWords: [Word] { words.current.all }
    var wordsByID: [String: Word] { words.current.byID }

    /// A word's meanings as the target country sees them: its own meanings first.
    func meanings(for spanish: String) -> [Meaning] { meanings(for: spanish, country: .current) }

    private func meanings(for spanish: String, country: Country) -> [Meaning] {
        guard let blocks = meaningsByWord[spanish] else { return [] }
        if country == .mexico { return blocks }
        return blocks.map { block in
            let senses = block.senses.map { $0.seen(from: country) }
            return Meaning(partOfSpeech: block.partOfSpeech, gender: block.gender, senses: senses.filter(\.isLocal) + senses.filter { !$0.isLocal })
        }
    }

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

        meaningsByWord = meanings
        derivations = derived
        self.firstRank = firstRank
        words = PerCountry { [unowned self] country in self.buildWords(for: country) }
    }

    private func buildWords(for country: Country) -> Words {
        let deck = SeedData.words(for: country)
        var byID: [String: Word] = [:]
        for word in deck where byID[word.id] == nil { byID[word.id] = word }
        // Dictionary-only words are numbered after the full deck, so their numbers match in every country
        let originalCount = SeedData.baseWords.count

        let newHeadwords = meaningsByWord.keys.filter { byID[$0] == nil }
            .sorted { (firstRank[$0] ?? .max, $0) < (firstRank[$1] ?? .max, $1) }
        var extras: [Word] = []
        extras.reserveCapacity(newHeadwords.count)
        for (index, headword) in newHeadwords.enumerated() {
            let blocks = meanings(for: headword, country: country)
            guard let first = blocks.first else { continue }
            // The headline follows the block holding a local meaning, if there is one
            let main = blocks.first { $0.senses.contains { $0.isLocal } } ?? first
            let gender = main.gender == "m" || main.gender == "f" ? main.gender : nil
            let word = Word(order: originalCount + index, spanish: headword,
                            english: Self.summary(of: main.senses), partOfSpeech: main.partOfSpeech, gender: gender)
            extras.append(word)
            byID[headword] = word
        }
        return Words(extra: extras, all: deck + extras, byID: byID)
    }

    private static func partOfSpeech(_ raw: String) -> PartOfSpeech? { PartOfSpeech(rawValue: raw) }

    private static let flags: [String: String] = [
        "Mexico": "🇲🇽", "Spain": "🇪🇸", "Chile": "🇨🇱", "Argentina": "🇦🇷", "Rioplatense": "🇦🇷", "Colombia": "🇨🇴",
        "Peru": "🇵🇪", "Venezuela": "🇻🇪", "Cuba": "🇨🇺", "Guatemala": "🇬🇹", "El Salvador": "🇸🇻", "Honduras": "🇭🇳",
        "Nicaragua": "🇳🇮", "Bolivia": "🇧🇴", "Dominican Republic": "🇩🇴", "Puerto Rico": "🇵🇷", "Canary Islands": "🇮🇨",
        "Ecuador": "🇪🇨", "Costa Rica": "🇨🇷", "Panama": "🇵🇦", "Paraguay": "🇵🇾", "Uruguay": "🇺🇾",
        "Latin America": "🌎",
    ]

    /// Puts a flag in front of each country in a label: "(Spain, colloquial) flatbread" → "(🇪🇸 Spain, colloquial) flatbread".
    static func flagged(_ text: String) -> String {
        var result = ""
        var rest = Substring(text)
        while let open = rest.firstIndex(of: "("), let close = rest[open...].firstIndex(of: ")") {
            result += rest[..<open]
            let items = rest[rest.index(after: open)..<close].components(separatedBy: ", ").map { item -> String in
                let isAlso = item.hasPrefix("also ")
                let name = isAlso ? String(item.dropFirst(5)) : item
                guard let flag = flags[name] else { return item }
                return (isAlso ? "also " : "") + flag + " " + name
            }
            result += "(" + items.joined(separator: ", ") + ")"
            rest = rest[rest.index(after: close)...]
        }
        return result + rest
    }

    /// "(MX)", "(Mexican)", "(Mexico)" or "(MX CDMX)" in the flashcard data marks a Mexican gloss; likewise "(CO)" for Colombia.
    private static let markers = PerCountry { try! NSRegularExpression(pattern: $0.markerPattern) }

    private static func removingMarker(_ text: String) -> String? {
        let marker = markers.current
        let range = NSRange(text.startIndex..., in: text)
        guard marker.firstMatch(in: text, range: range) != nil else { return nil }
        return marker.stringByReplacingMatches(in: text, range: range, withTemplate: "")
    }

    /// "(also Guatemala) submarine sandwich" reads better as "submarine sandwich (also Guatemala)".
    private static func tidyAlsoLabel(_ text: String) -> String {
        guard text.hasPrefix("(also "), let close = text.firstIndex(of: ")") else { return text }
        let label = text[text.startIndex...close]
        let rest = text[text.index(after: close)...].trimmingCharacters(in: .whitespaces)
        return rest.isEmpty ? text : "\(rest) \(label)"
    }

    /// Meanings the target country uses: the flagged Wiktionary senses, plus anything the flashcard data marks for that country.
    func localMeanings(for word: Word) -> [LocalMeaning] {
        var result: [LocalMeaning] = []
        func add(_ text: String, _ pos: PartOfSpeech?) {
            let clean = Self.tidyAlsoLabel(text.trimmingCharacters(in: .whitespaces))
            if !clean.isEmpty, !result.contains(where: { $0.text.lowercased() == clean.lowercased() }) {
                result.append(LocalMeaning(text: clean, partOfSpeech: pos))
            }
        }
        if let gloss = Self.removingMarker(word.english) {
            add(gloss, word.partOfSpeech)
        }
        for block in meanings(for: word.spanish) {
            for sense in block.senses where sense.isLocal { add(sense.text, block.partOfSpeech) }
        }
        return result
    }

    func hasLocalMeaning(_ word: Word) -> Bool {
        Self.removingMarker(word.english) != nil
            || meanings(for: word.spanish).contains { $0.senses.contains { $0.isLocal } }
    }

    /// A short flashcard-friendly gloss: the first couple of senses without parenthetical detail.
    static func summary(of senses: [Sense]) -> String {
        var parts: [String] = []
        // Local meanings lead; vulgar ones only if nothing else exists
        let ordered = senses.filter { !$0.isCrude } + senses.filter { $0.isCrude }
        let localFirst = ordered.filter(\.isLocal) + ordered.filter { !$0.isLocal }
        for sense in localFirst.prefix(3) {
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
