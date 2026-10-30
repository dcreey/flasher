import Foundation

/// Dictionary words that share a verb's root: the noun (trabajo), the doer (trabajador), the participle (cerrado)...
enum RelatedForms {
    private static let wordsByKey: [String: [Word]] = {
        let skipped: Set<PartOfSpeech> = [.infinitive, .preposition, .conjunction, .pronoun, .article]
        var map: [String: [Word]] = [:]
        for word in Lexicon.shared.allWords where !skipped.contains(word.partOfSpeech) {
            map[word.spanish.searchKey, default: []].append(word)
        }
        return map
    }()

    /// Endings that turn a verb root into a noun (trabajo), so only nouns may match.
    private static let nounEndings = ["o", "a", "e"]

    /// Endings that reliably build the doer or the action from a verb root (trabajador, información).
    private static let reliableEndings = [
        "ada", "ida", "ador", "adora", "edor", "edora", "idor", "idora",
        "ación", "ición", "ción", "sión", "amiento", "imiento", "miento",
    ]

    /// Looser endings (pesero, pasante, vivo) that only count when the meanings overlap.
    private static let looseEndings = [
        "ante", "ente", "iente", "anza", "ura", "dura", "aje", "ero", "era", "ería",
        "able", "ible", "ivo", "iva", "ismo", "ista", "oso", "osa", "ancia", "encia",
    ]

    static func find(for verb: Word, limit: Int = 12) -> [Word] {
        guard verb.partOfSpeech == .infinitive, let conjugation = Conjugator.conjugate(verb.spanish) else { return [] }

        var found: [Word] = []
        var seen: Set<String> = [verb.id]
        func add(_ words: [Word]?) {
            for word in words ?? [] where seen.insert(word.id).inserted { found.append(word) }
        }

        add(wordsByKey[conjugation.participle.searchKey]?.filter { $0.spanish.lowercased() == conjugation.participle })

        let infinitive = conjugation.infinitive
        let stem = String(infinitive.dropLast(2))
        guard stem.count >= 3 else { return sorted(found, limit) }

        for variant in stemVariants(stem, infinitive: infinitive, conjugation: conjugation) {
            let key = variant.searchKey
            for ending in nounEndings {
                // -o/-a/-e collide with unrelated words (cerro, coma, jugo), so the meanings must overlap too
                add(wordsByKey[key + ending]?.filter { $0.partOfSpeech == .noun && sharesMeaning($0, verb) })
            }
            for ending in reliableEndings {
                add(wordsByKey[key + ending.searchKey])
            }
            for ending in looseEndings {
                add(wordsByKey[key + ending.searchKey]?.filter { sharesMeaning($0, verb) })
            }
        }
        return sorted(found, limit)
    }

    private static func meaningRoots(_ word: Word) -> Set<String> {
        let tokens = word.english.lowercased().split { !$0.isLetter }
        return Set(tokens.filter { $0.count >= 4 }.map { String($0.prefix(4)) })
    }

    private static func sharesMeaning(_ a: Word, _ b: Word) -> Bool {
        !meaningRoots(a).isDisjoint(with: meaningRoots(b))
    }

    /// Stem plus the spelling and stem-change variants a derived word might use (cuenta ← contar, comienzo ← comenzar).
    private static func stemVariants(_ stem: String, infinitive: String, conjugation: Conjugation) -> [String] {
        var variants = [stem]
        func add(_ s: String) { if s.count >= 3, !variants.contains(s) { variants.append(s) } }

        if let yo = conjugation.form(.present, 0), yo.hasSuffix("o") { add(String(yo.dropLast())) }
        if let yo = conjugation.form(.subjunctivePresent, 0), yo.hasSuffix("e") || yo.hasSuffix("a") { add(String(yo.dropLast())) }

        let isAr = infinitive.hasSuffix("ar")
        let bases = variants
        for base in bases {
            if base.hasSuffix("qu") { add(String(base.dropLast(2)) + "c") }
            if base.hasSuffix("c") && isAr { add(String(base.dropLast()) + "qu") }
            if base.hasSuffix("z") && isAr { add(String(base.dropLast()) + "c") }
            if base.hasSuffix("g") && isAr { add(base + "u") }
            if base.hasSuffix("j") { add(String(base.dropLast()) + "g") }
        }
        return variants
    }

    private static func sorted(_ words: [Word], _ limit: Int) -> [Word] {
        func rank(_ pos: PartOfSpeech) -> Int {
            switch pos {
            case .noun: 0
            case .adjective: 1
            default: 2
            }
        }
        return Array(words.sorted {
            rank($0.partOfSpeech) != rank($1.partOfSpeech) ? rank($0.partOfSpeech) < rank($1.partOfSpeech) : $0.order < $1.order
        }.prefix(limit))
    }
}
