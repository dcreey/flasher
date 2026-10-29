import Foundation

extension String {
    /// Lowercased, accent-free form used for dictionary lookups.
    var searchKey: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// A word built from a dictionary word plus -ito/-ita (casita = casa + -ita).
struct Diminutive: Hashable {
    let form: String      // the diminutive itself, e.g. "casita"
    let base: Word        // dictionary word it comes from, e.g. casa
    let ending: String    // what was added, e.g. "-ita", "-ecito"
    let isPlural: Bool
    let inDictionary: Bool  // true when the form has its own dictionary entry (ahorita, carrito)

    /// "little house" – nil for base words where a literal gloss would read oddly.
    var meaning: String? {
        let gloss = base.english
            .split(whereSeparator: { ",/(;".contains($0) })
            .first.map { $0.trimmingCharacters(in: .whitespaces) } ?? base.english
        switch base.partOfSpeech {
        case .noun:      return "little \(gloss)"
        case .adjective: return "somewhat or very \(gloss)"
        case .adverb:    return "a softer, friendlier “\(gloss)”"
        default:         return nil
        }
    }

    var explanation: String {
        "-ito/-ita usually means “little”. In Mexico it is also used to sound friendly, soften a request or show affection (un momentito, cafecito, ahorita)."
    }
}

enum DiminutiveResolver {
    private static let wordsByKey: [String: Word] = {
        var map: [String: Word] = [:]
        for word in SeedData.words where map[word.spanish.searchKey] == nil {
            map[word.spanish.searchKey] = word
        }
        return map
    }()

    /// Words that end in -ito/-ita but are not felt as diminutives (or whose "base" is a false friend, like visita/visa).
    private static let lexicalized: Set<String> = [
        "bonito", "bonita", "frito", "frita", "fajita", "cita", "mito", "grito", "delito", "bendito", "bendita",
        "exito", "circuito", "mosquito", "margarita", "finiquito", "exquisito", "exquisita", "explicito",
        "implicito", "insolito", "hipocrita", "orbita", "ermita", "leucocito", "eritrocito", "proposito",
        "visita", "favorito", "favorita", "tepito", "chocolatito", "quito"
    ]

    private static let endings = ["itos", "itas", "ito", "ita"]

    /// The dictionary word `text` is a diminutive of, if any.
    static func resolve(_ text: String) -> Diminutive? {
        let form = text.searchKey
        guard form.count >= 5, !lexicalized.contains(form),
              let ending = endings.first(where: { form.hasSuffix($0) }) else { return nil }

        let stem = String(form.dropLast(ending.count))
        let vowels = ending.contains("a") ? ["a", "o"] : ["o", "a"]

        for (stemCandidate, connector) in stemCandidates(stem) {
            let candidates = [stemCandidate + vowels[0], stemCandidate + vowels[1],
                              stemCandidate, stemCandidate + "io", stemCandidate + "e"]
            for key in candidates where key.count >= 3 && key != form {
                if let base = wordsByKey[key] {
                    return Diminutive(
                        form: text,
                        base: base,
                        ending: "-" + connector + ending,
                        isPlural: ending.hasSuffix("s"),
                        inDictionary: wordsByKey[form] != nil
                    )
                }
            }
        }
        return nil
    }

    /// Undoes the spelling changes that happen before -ito/-ita, paired with the connector that was removed.
    private static func stemCandidates(_ stem: String) -> [(String, String)] {
        var out = [(stem, "")]
        if stem.hasSuffix("ec") { out.append((String(stem.dropLast(2)), "ec")) }               // florecita → flor
        if stem.hasSuffix("c") {
            let t = String(stem.dropLast())
            out.append((t, "c"))                                                                // cafecito → café
            out.append((t + "z", "c"))                                                          // pedacito → pedazo
        }
        if stem.hasSuffix("qu") { out.append((String(stem.dropLast(2)) + "c", "")) }            // poquito → poco
        if stem.hasSuffix("gu") { out.append((String(stem.dropLast(2)) + "g", "")) }            // amiguito → amigo
        return out
    }
}
