import SwiftUI

/// Every conjugated form of every verb in the dictionary, so a form like "manches" leads back to manchar.
enum VerbForms {
    struct Slot { let infinitive: String; let tense: Tense; let person: Int }

    static let index: [String: [Slot]] = {
        var map: [String: [Slot]] = [:]
        for word in Lexicon.shared.allWords where word.partOfSpeech == .infinitive {
            guard let conjugation = Conjugator.conjugate(word.spanish) else { continue }
            for (tense, forms) in conjugation.forms {
                for (person, form) in forms.enumerated() {
                    guard let form, !form.contains(" ") else { continue }
                    map[form.lowercased(), default: []].append(Slot(infinitive: word.spanish, tense: tense, person: person))
                }
            }
        }
        return map
    }()
}

/// A phrase built around a verb ("acabar de", "no manches"): the verb can be conjugated and the rest of the phrase follows along.
struct PhraseVerb {
    let conjugation: Conjugation
    let before: String
    let after: String
    /// The tense and person the phrase is written in (the infinitive's phrases start at "yo, present").
    let start: (tense: Tense, person: Int)
    /// "to have just" when the phrase's meaning is a verb phrase that can be inflected.
    let gloss: String
    let baseMeaning: String

    private static let conjugatedPatterns: Set<String> = ["no manches", "no mames", "no jodas", "no fastidies", "no friegues"]
    private static let leading: Set<String> = ["no", "ni", "ya", "me", "te", "se", "nos", "le", "les", "lo", "la"]

    static func find(for word: Word) -> PhraseVerb? {
        guard word.spanish.contains(" ") else { return nil }
        let tokens = word.spanish.split(separator: " ").map(String.init)
        guard (2...6).contains(tokens.count), isConjugable(tokens) else { return nil }
        let meaning = baseMeaning(of: word)
        // An infinitive up front ("acabar de", "darse cuenta de"), optionally after "no"
        for position in 0..<min(2, tokens.count) where position == 0 || tokens[0] == "no" {
            let verb = tokens[position].lowercased()
            guard let known = Lexicon.shared.wordsByID[verb] ?? Lexicon.shared.wordsByID[String(verb.dropLast(2))],
                  known.partOfSpeech == .infinitive,
                  let conjugation = Conjugator.conjugate(verb) else { continue }
            let plus = tokens.suffix(from: position + 1).filter { $0 != "+" && $0 != "gerundio" }
            return PhraseVerb(conjugation: conjugation, before: tokens.prefix(position).joined(separator: " "),
                              after: plus.joined(separator: " "), start: (.present, 0), gloss: meaning, baseMeaning: meaning)
        }
        // A conjugated verb up front, only for fixed phrases that really are said in other persons ("no manches" → "no manchen").
        // Anything else that merely starts with a verb form (nouns, greetings, proverbs, "me cago en...") stays as written.
        guard conjugatedPatterns.contains(word.spanish.lowercased()) else { return nil }
        for position in 0..<min(3, tokens.count) {
            let form = tokens[position].lowercased()
            if position > 0, !leading.contains(tokens[position - 1].lowercased()) { break }
            if leading.contains(form) { continue }
            guard let slots = VerbForms.index[form], Set(slots.map(\.infinitive)).count == 1,
                  let conjugation = Conjugator.conjugate(slots[0].infinitive) else { break }
            let order = Tense.allCases
            let slot = slots.min { (order.firstIndex(of: $0.tense) ?? 0) < (order.firstIndex(of: $1.tense) ?? 0) }!
            return PhraseVerb(conjugation: conjugation, before: tokens.prefix(position).joined(separator: " "),
                              after: tokens.suffix(from: position + 1).joined(separator: " "),
                              start: (slot.tense, slot.person), gloss: "", baseMeaning: meaning)
        }
        return nil
    }

    /// Fixed sayings, proverbs and signs ("errar es humano", "coser y cantar", "no fumar") never change their verb.
    private static let fixedWords: Set<String> = ["y", "o", "es", "son", "era", "fue", "sea", "ni", "si", "cuando", "donde", "quien"]
    private static let neverConjugated: Set<String> = ["hay", "es", "son"]

    private static func isConjugable(_ tokens: [String]) -> Bool {
        let lower = tokens.map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
        // Anything with a comma, a clause or a coordinated pair is a saying, not a pattern
        if tokens.contains(where: { $0.hasSuffix(",") || $0.hasSuffix("?") || $0.hasSuffix("!") || $0.hasSuffix(".") }) { return false }
        if lower.dropFirst().contains(where: { fixedWords.contains($0) }) { return false }
        // "no" + infinitive is an instruction on a sign ("no fumar"), not a verb that moves
        if lower[0] == "no", lower.count == 2, lower[1].hasSuffix("ar") || lower[1].hasSuffix("er") || lower[1].hasSuffix("ir") { return false }
        // Impersonal haber and "es" stay as written (hay que, es lo que hay)
        if neverConjugated.contains(lower[0]) || (lower[0] == "no" && lower.count > 1 && neverConjugated.contains(lower[1])) { return false }
        return true
    }

    private static func baseMeaning(of word: Word) -> String {
        var text = word.english
        if let cut = text.range(of: " — ") { text = String(text[..<cut.lowerBound]) }
        return text.trimmingCharacters(in: .whitespaces)
    }

    /// The whole phrase with the verb in the chosen tense and person.
    func spanish(core: String) -> String { [before, core, after].filter { !$0.isEmpty }.joined(separator: " ") }

    func english(tense: Tense, person: Int) -> String? {
        TenseExamples.phraseEnglish(gloss: gloss, tense: tense, person: person)
    }
}

/// Makes the Spanish words in a sentence tappable: each one that is in the dictionary (or is a form of a verb that is) links to its page.
enum WordLinks {
    static func resolve(_ token: String) -> Word? {
        let lower = token.lowercased()
        let words = Lexicon.shared.wordsByID
        if let word = words[lower] { return word }
        if let slot = VerbForms.index[lower]?.first, let word = words[slot.infinitive] { return word }
        for candidate in [String(lower.dropLast(2)), String(lower.dropLast()), String(lower.dropLast(2)) + "o"] where candidate.count >= 3 {
            if lower.hasSuffix("es"), candidate == String(lower.dropLast(2)), let word = words[candidate] { return word }
            if lower.hasSuffix("s"), candidate == String(lower.dropLast()), let word = words[candidate] { return word }
            if lower.hasSuffix("as"), candidate.hasSuffix("o"), let word = words[candidate] { return word }
        }
        if lower.hasSuffix("a"), let word = words[String(lower.dropLast()) + "o"] { return word }
        return nil
    }

    static func url(for word: Word) -> URL? {
        var parts = URLComponents()
        parts.scheme = "elpie"
        parts.host = "word"
        parts.queryItems = [URLQueryItem(name: "id", value: word.id)]
        return parts.url
    }

    static func linked(_ text: String) -> AttributedString { linked(AttributedString(text)) }

    static func linked(_ attributed: AttributedString) -> AttributedString {
        var result = attributed
        let plain = String(attributed.characters)
        guard let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return result }
        for match in regex.matches(in: plain, range: NSRange(plain.startIndex..., in: plain)) {
            guard let range = Range(match.range, in: plain),
                  let word = resolve(String(plain[range])), let url = url(for: word),
                  let lower = AttributedString.Index(range.lowerBound, within: result),
                  let upper = AttributedString.Index(range.upperBound, within: result) else { continue }
            result[lower..<upper].link = url
            result[lower..<upper].underlineStyle = Text.LineStyle(pattern: .dot, color: .secondary)
        }
        return result
    }
}

/// Opens a tapped Spanish word in its own dictionary page, pushed onto the current stack.
private struct WordLinkNavigation: ViewModifier {
    @State private var target: Word?

    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                guard url.scheme == "elpie",
                      let id = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "id" })?.value,
                      let word = Lexicon.shared.wordsByID[id] else { return .systemAction }
                target = word
                return .handled
            })
            .navigationDestination(item: $target) { WordDetailView(word: $0) }
    }
}

extension View {
    func opensWordLinks() -> some View { modifier(WordLinkNavigation()) }
}
