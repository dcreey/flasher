import Foundation

/// Everything in the dictionary beyond meanings: example sentences, synonyms, antonyms, word families, etymology.
/// Loaded once, on first use, from the bundled extras.tsv.
final class Extras {
    static let shared = Extras()

    struct Example: Hashable {
        let pos: String        // Wiktionary part of speech: verb, noun, adj...
        let spanish: String
        let english: String
    }

    private(set) var examples: [String: [Example]] = [:]
    private(set) var synonyms: [String: [String]] = [:]
    private(set) var antonyms: [String: [String]] = [:]
    private(set) var derived: [String: [String]] = [:]
    private(set) var related: [String: [String]] = [:]
    private(set) var etymology: [String: String] = [:]

    private init() {
        guard let url = Bundle.main.url(forResource: "extras", withExtension: "tsv"),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return }
        func list(_ s: Substring) -> [String] { s.components(separatedBy: "¦") }
        for line in text.split(separator: "\n") {
            let cols = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard cols.count >= 3 else { continue }
            let word = String(cols[1])
            switch cols[0] {
            case "X" where cols.count >= 5:
                examples[word, default: []].append(Example(pos: String(cols[2]), spanish: String(cols[3]), english: String(cols[4])))
            case "Y": synonyms[word] = list(cols[2])
            case "N": antonyms[word] = list(cols[2])
            case "V": derived[word] = list(cols[2])
            case "R": related[word] = list(cols[2])
            case "T": etymology[word] = String(cols[2])
            default: break
            }
        }
    }

    private static func wiktionaryPOS(_ pos: PartOfSpeech) -> Set<String> {
        switch pos {
        case .infinitive: ["verb"]
        case .noun: ["noun"]
        case .adjective: ["adj"]
        case .adverb: ["adv"]
        case .interjection: ["intj"]
        case .pronoun: ["pron"]
        case .article: ["det", "article"]
        case .preposition: ["prep", "contraction"]
        case .conjunction: ["conj"]
        case .numeral: ["num"]
        }
    }

    /// Example sentences for a word, matching its part of speech when possible.
    func examples(for word: Word) -> [Example] {
        guard let all = examples[word.spanish] else { return [] }
        let matching = all.filter { Self.wiktionaryPOS(word.partOfSpeech).contains($0.pos) }
        if !matching.isEmpty || word.partOfSpeech == .infinitive { return matching }
        return all
    }
}
