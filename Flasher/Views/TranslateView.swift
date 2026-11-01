import SwiftUI
import Translation

/// Apple's translator knows nothing about Mexican Spanish, so the text is prepared before it goes in and fixed after it comes out.
enum MexicanTranslation {
    /// Mexican words and phrases → plain Spanish the translator understands.
    private static let plainer: [(String, String)] = [
        ("no manches", "no puede ser"), ("no mames", "no puede ser"), ("qué padre", "qué bien"), ("está padre", "está muy bien"),
        ("qué chido", "qué bien"), ("está chido", "está muy bien"), ("chido", "genial"), ("chida", "genial"), ("padrísimo", "estupendo"),
        ("la neta", "la verdad"), ("neta", "verdad"), ("chambear", "trabajar"), ("chamba", "trabajo"), ("güey", "amigo"), ("wey", "amigo"),
        ("ahorita", "ahora mismo"), ("órale", "vamos"), ("ándale", "vamos"), ("cuate", "amigo"), ("carnal", "hermano"), ("lana", "dinero"),
        ("chavo", "muchacho"), ("chava", "muchacha"), ("chamaco", "niño"), ("ni modo", "qué le vamos a hacer"), ("a poco", "de verdad"),
        ("me vale", "no me importa"), ("no hay bronca", "no hay problema"), ("bronca", "problema"), ("aguas", "cuidado"),
        ("chela", "cerveza"), ("güero", "rubio"), ("chafa", "de mala calidad"), ("cruda", "resaca"), ("pinche", "maldito"),
    ]

    /// Spain's wording → what is said in Mexico.
    private static let mexican: [(String, String)] = [
        // Words whose gender changes come first, so the article follows
        ("del ordenador", "de la computadora"), ("el ordenador", "la computadora"), ("un ordenador", "una computadora"),
        ("los ordenadores", "las computadoras"), ("unos ordenadores", "unas computadoras"),
        ("el grifo", "la llave"), ("un grifo", "una llave"), ("del grifo", "de la llave"),
        ("las gafas", "los lentes"), ("unas gafas", "unos lentes"), ("de las gafas", "de los lentes"),
        ("ordenadores", "computadoras"), ("ordenador", "computadora"), ("coches", "carros"), ("coche", "carro"),
        ("móviles", "celulares"), ("móvil", "celular"), ("zumos", "jugos"), ("zumo", "jugo"), ("patatas", "papas"), ("patata", "papa"),
        ("gafas", "lentes"), ("aparcamiento", "estacionamiento"), ("aparcar", "estacionar"), ("conducir", "manejar"),
        ("autobús", "camión"), ("jersey", "suéter"), ("resaca", "cruda"), ("melocotón", "durazno"), ("grifo", "llave"), ("chaval", "muchacho"), ("guay", "chido"),
    ]

    static func replacing(_ pairs: [(String, String)], in text: String) -> (text: String, changes: [(String, String)]) {
        var result = text
        var changes: [(String, String)] = []
        for (from, to) in pairs {
            guard let regex = try? NSRegularExpression(pattern: "(?<![\\p{L}])" + NSRegularExpression.escapedPattern(for: from) + "(?![\\p{L}])", options: .caseInsensitive) else { continue }
            let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
            guard !matches.isEmpty else { continue }
            for match in matches.reversed() {
                guard let range = Range(match.range, in: result) else { continue }
                // A capital at the start of what was replaced carries over ("No puede ser" → "No manches")
                result.replaceSubrange(range, with: Self.matchingCapital(of: String(result[range]), in: to))
            }
            changes.append((from, to))
        }
        return (result, changes)
    }

    static func matchingCapital(of original: String, in replacement: String) -> String {
        guard original.first?.isUppercase == true, let first = replacement.first else { return replacement }
        return first.uppercased() + replacement.dropFirst()
    }

    static func prepare(_ text: String) -> (text: String, changes: [(String, String)]) { replacing(plainer, in: text) }
    static func localize(_ text: String) -> (text: String, changes: [(String, String)]) { replacing(mexican, in: text) }

    struct Slang: Identifiable {
        let term: String
        let word: Word
        let meaning: String
        var id: String { term }
    }

    /// Words and phrases in the Spanish text that the dictionary marks as Mexican, longest phrases first.
    static func slang(in text: String) -> [Slang] {
        guard let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return [] }
        let tokens = regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap { Range($0.range, in: text).map { String(text[$0]).lowercased() } }
        var found: [Slang] = []
        var used = Set<Int>()
        for size in stride(from: min(4, tokens.count), through: 1, by: -1) {
            guard tokens.count >= size else { continue }
            for start in 0...(tokens.count - size) {
                let range = start..<start + size
                guard used.isDisjoint(with: range) else { continue }
                let phrase = tokens[range].joined(separator: " ")
                if size == 1, phrase.count <= 2 { continue }
                guard let word = Lexicon.shared.wordsByID[phrase], let meaning = Lexicon.shared.mexicanMeanings(for: word).first?.text else { continue }
                used.formUnion(range)
                found.append(Slang(term: phrase, word: word, meaning: meaning))
            }
        }
        return Array(found.prefix(6))
    }

    /// Other ways to say a word in the Spanish text that Mexicans use: its synonyms that carry a Mexican meaning.
    static func alternatives(in text: String) -> [(String, String)] {
        guard let regex = try? NSRegularExpression(pattern: "\\p{L}+") else { return [] }
        var result: [(String, String)] = []
        var seen = Set<String>()
        for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
            guard let range = Range(match.range, in: text) else { continue }
            let token = String(text[range]).lowercased()
            guard seen.insert(token).inserted, let word = WordLinks.resolve(token),
                  let synonym = Extras.shared.synonyms[word.spanish]?.first(where: { Lexicon.shared.wordsByID[$0].map(Lexicon.shared.hasMexicanMeaning) ?? false }) else { continue }
            result.append((token, synonym))
            if result.count == 5 { break }
        }
        return result
    }

    /// Plain Spanish phrases that Mexicans say another way, wherever they appear.
    private static let mexicanPhrases: [(String, String)] = [
        ("ahora mismo", "ahorita"), ("no hay problema", "no hay bronca"), ("de mala calidad", "chafa"),
        ("no me importa", "me vale"), ("qué le vamos a hacer", "ni modo"), ("no hay remedio", "ni modo"),
        ("qué bien", "qué padre"), ("qué genial", "qué chido"),
    ]

    /// Short reactions, swapped only when they are a whole sentence ("No puede ser." but not "No puede ser tan difícil.").
    private static let mexicanReactions: [(String, String)] = [
        ("no puede ser", "no manches"), ("de ninguna manera", "ni de chiste"), ("ni hablar", "ni de chiste"),
        ("ni de broma", "ni de chiste"), ("qué increíble", "no manches"), ("genial", "chido"), ("estupendo", "padrísimo"),
    ]

    /// Replaces whole sentences that are just a reaction, keeping the sentence's own punctuation.
    private static func swappingReactions(in text: String) -> (text: String, changes: [(String, String)]) {
        guard let regex = try? NSRegularExpression(pattern: "[^.!?¡¿\\n]+") else { return (text, []) }
        var result = text
        var changes: [(String, String)] = []
        for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            let segment = String(result[range])
            let key = segment.trimmingCharacters(in: .whitespaces).lowercased()
            guard let pair = mexicanReactions.first(where: { $0.0 == key }) else { continue }
            let leading = segment.prefix { $0 == " " }
            result.replaceSubrange(range, with: leading + matchingCapital(of: String(segment.drop { $0 == " " }), in: pair.1))
            changes.append(pair)
        }
        return (result, changes)
    }

    /// The text with Mexican wording: Spain's words swapped, then each plain noun or adjective that has a Mexican synonym replaced by it.
    /// Only dictionary headwords are swapped, never words that are already Mexican, and a noun only becomes a noun of the same
    /// gender, so "el", "la" and adjectives still agree. Verbs, adverbs and prepositions are left alone. `replaced` lists what changed.
    static func slangVersion(of text: String) -> (text: String, replaced: [(String, String)]) {
        let reactions = swappingReactions(in: text)
        let phrases = replacing(mexicanPhrases, in: reactions.text)
        let local = localize(phrases.text)
        var result = local.text
        // Everything swapped so far counts, so the bottom card doesn't repeat it
        var replaced: [(String, String)] = (reactions.changes + phrases.changes + local.changes)
            .flatMap { change in change.0.split(separator: " ").map { (String($0), change.1) } }
        func gender(_ word: Word) -> String? { Lexicon.shared.meanings(for: word.spanish).first?.gender }
        for (token, synonym) in alternatives(in: result) {
            guard let word = WordLinks.resolve(token), word.spanish == token, [.noun, .adjective].contains(word.partOfSpeech),
                  !Lexicon.shared.hasMexicanMeaning(word),
                  let other = Lexicon.shared.wordsByID[synonym], other.partOfSpeech == word.partOfSpeech, !synonym.contains(" "),
                  word.partOfSpeech == .adjective || (gender(word) != nil && gender(word) == gender(other)) else { continue }
            result = replacing([(token, synonym)], in: result).text
            replaced.append((token, synonym))
        }
        if let first = text.first, first.isUppercase, let now = result.first, now.isLowercase { result = result.prefix(1).uppercased() + result.dropFirst() }
        return (result, replaced)
    }
}

@available(iOS 18.0, *)
struct TranslateView: View {
    private enum Direction: String, CaseIterable, Identifiable {
        case toEnglish = "Spanish → English", toSpanish = "English → Spanish"
        var id: String { rawValue }
        var source: Locale.Language { Locale.Language(identifier: self == .toEnglish ? "es" : "en") }
        var target: Locale.Language { Locale.Language(identifier: self == .toEnglish ? "en" : "es") }
    }

    private struct Output {
        let input: String
        let direction: Direction
        let translation: String
        let readAs: String?
        let adjusted: [(String, String)]
    }

    @State private var direction: Direction = .toEnglish
    @State private var input = ""
    @State private var output: Output?
    @State private var errorText: String?
    @State private var needsDownload = false
    @Environment(\.openURL) private var openSystemURL
    @State private var isWorking = false
    @State private var configuration: TranslationSession.Configuration?
    @State private var request: (text: String, direction: Direction, readAs: String?, source: String)?
    /// Translating waits until typing has paused for this long.
    private static let typingPause: Duration = .milliseconds(500)
    @State private var pending: Task<Void, Never>?
    /// What was last sent to the translator, so the same text isn't translated twice.
    @State private var lastSent = ""
    /// The English translation put back into Spanish, to show how a natural speaker would say the same thing.
    @State private var backText: String?
    @State private var backConfiguration: TranslationSession.Configuration?
    @State private var backRequest: String?
    @FocusState private var focused: Bool
    @Environment(AppRouter.self) private var router: AppRouter?
    @AppStorage(AppSettings.showSpanishChecksKey) private var showChecks = true
    /// What the Spanish checks found in the Spanish text on screen: the typed text, or the translation into Spanish.
    @State private var issues: [SpanishIssue] = []
    /// False right after translating Spanish, when the input shows as tappable words instead of an editor.
    @State private var isEditing = true

    private var showsLinkedInput: Bool { !isEditing && output?.direction == .toEnglish && output?.input == input && !input.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Direction", selection: $direction) {
                    ForEach(Direction.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                combinedBox

                if isWorking {
                    HStack(spacing: 8) { ProgressView(); Text("Translating…").font(.footnote).foregroundStyle(.secondary) }
                }

                if let errorText {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(errorText, systemImage: "exclamationmark.triangle")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                        if needsDownload {
                            Text("Open Settings › Apps › Translate › Languages, download Spanish and English, then come back and try again.")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Button("Open Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) { openSystemURL(url) }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
                if let output { results(output).padding(.top, 8) }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: input) { scheduleTranslation() }
        .onChange(of: focused) {
            // Once the keyboard is away, translated Spanish turns into tappable words
            if !focused, let done = output, done.direction == .toEnglish, done.input == input { isEditing = false }
        }
        .onChange(of: direction) {
            if let done = output, done.direction != direction, done.input == input {
                // A finished, unedited translation: flip the languages, so the result becomes the new input
                input = done.direction == .toSpanish ? MexicanTranslation.localize(done.translation).text : done.translation
                output = nil
                translate()
            } else if output != nil || errorText != nil || !input.isEmpty {
                // Nothing trustworthy to flip (edited text or an error): translate the same text the other way
                translate()
            }
        }
        .navigationTitle("El Pie")
        .navigationBarTitleDisplayMode(.inline)
        .translationTask(configuration) { session in
            guard let request else { return }
            do {
                // Missing language packs: the system asks to download them
                try await session.prepareTranslation()
                let response = try await session.translate(request.text)
                // Typing carried on while this was translating: the newer text has its own translation coming
                guard request.source == input.trimmingCharacters(in: .whitespacesAndNewlines) else { isWorking = false; return }
                let text = response.targetText
                var adjusted: [(String, String)] = []
                if request.direction == .toSpanish { adjusted = MexicanTranslation.localize(text).changes }
                output = Output(input: input, direction: request.direction, translation: text, readAs: request.readAs, adjusted: adjusted)
                errorText = nil
                if !focused { isEditing = false }
                checkSpanish(request.direction == .toEnglish ? input : text)
                backText = nil
                if request.direction == .toEnglish { startBackTranslation(of: text) }
            } catch {
                needsDownload = error is TranslationError
                errorText = needsDownload ? "Spanish and English need to be downloaded for offline translation." : error.localizedDescription
            }
            isWorking = false
        }
        .translationTask(backConfiguration) { session in
            guard let source = backRequest else { return }
            // A failure here only hides the extra card; the main translation is already on screen
            guard let response = try? await session.translate(source), backRequest == source else { return }
            backText = response.targetText
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) { AboutButton() }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showChecks.toggle() } label: { Image(systemName: showChecks ? "checkmark.seal.fill" : "checkmark.seal") }
                    .accessibilityLabel(showChecks ? "Hide Spanish checks" : "Show Spanish checks")
            }
        }
        .opensWordLinks(inDictionary: true)
    }

    /// The input and its direct translation share one box, with a short line between them.
    private var combinedBox: some View {
        let flagged = showChecks && showsCheckResult && issues.contains { $0.kind != .tip }
        return VStack(alignment: .leading, spacing: 0) {
            inputField
            if let output {
                Divider().padding(.horizontal, 28)
                directTranslation(output)
            }
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.6), lineWidth: flagged ? 1 : 0))
    }

    private var inputField: some View {
        VStack(alignment: .leading, spacing: 0) {
            inputText
            if showsCheckFooter && output?.direction == .toEnglish { checkFooter.padding(.horizontal, 13).padding(.bottom, 10) }
        }
        .overlay(alignment: .topTrailing) {
            if !input.isEmpty {
                Button { input = ""; output = nil; errorText = nil; isEditing = true } label: { Image(systemName: "xmark.circle.fill") }
                    .foregroundStyle(.secondary)
                    .padding(10)
            }
        }
    }

    private func directTranslation(_ output: Output) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(output.direction == .toEnglish ? "English" : "Spanish · tap a word")
                    .font(.caption2.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase)
                Spacer()
                CopyButton(text: output.translation)
            }
            if output.direction == .toSpanish {
                Text(showChecks ? SpanishChecker.highlighted(WordLinks.linked(output.translation), text: output.translation, issues: issues) : WordLinks.linked(output.translation))
                    .font(.callout).textSelection(.enabled)
                if showsCheckFooter { checkFooter.padding(.top, 4) }
            } else {
                Text(output.translation).font(.callout).textSelection(.enabled)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).padding(.vertical, 10)
    }

    /// The Spanish checks only describe the text on screen once its translation has finished.
    private var showsCheckResult: Bool { output != nil && output?.input == input && !isWorking }

    /// The notes only take room when the checks found something to say.
    private var showsCheckFooter: Bool { showChecks && showsCheckResult && !issues.isEmpty }

    /// What the checks found, small, right under the text: a red list of mistakes and orange tips.
    @ViewBuilder
    private var checkFooter: some View {
        let mistakes = issues.filter { $0.kind != .tip }
        let tips = issues.filter { $0.kind == .tip }
        VStack(alignment: .leading, spacing: 3) {
            ForEach(mistakes) { inlineIssue($0, color: .red, icon: "exclamationmark.circle.fill") }
            ForEach(tips) { inlineIssue($0, color: .orange, icon: "lightbulb.fill") }
        }
    }

    private func inlineIssue(_ issue: SpanishIssue, color: Color, icon: String) -> some View {
        HStack(alignment: .top, spacing: 5) {
            Image(systemName: icon).font(.system(size: 9)).foregroundStyle(color).padding(.top, 2)
            Text("**“\(issue.found)”** \(issue.message)\(issue.suggestion.map { " → \($0)" } ?? "")")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var inputText: some View {
        ZStack(alignment: .topLeading) {
            if showsLinkedInput {
                // Translated Spanish becomes tappable words; tapping anywhere else turns it back into the editor
                Text(showChecks ? SpanishChecker.highlighted(WordLinks.linked(input), text: input, issues: issues) : WordLinks.linked(input))
                    .font(.body)
                    .frame(maxWidth: .infinity, minHeight: 24, alignment: .topLeading)
                    .padding(.leading, 13).padding(.vertical, 14).padding(.trailing, 34)
                    .contentShape(Rectangle())
                    .onTapGesture { isEditing = true; focused = true }
            } else {
                // The invisible text sizes the box, so it starts small and grows with what is typed
                Text(input + "\u{200B}")
                    .font(.body)
                    .opacity(0)
                    .frame(maxWidth: .infinity, minHeight: 24, alignment: .topLeading)
                    .padding(.leading, 13).padding(.vertical, 14).padding(.trailing, 34)
                    .overlay { TextEditor(text: $input).focused($focused).autocorrectionDisabled().scrollContentBackground(.hidden).padding(.leading, 8).padding(.vertical, 6).padding(.trailing, 26) }
            }
            if input.isEmpty {
                Text(direction == .toEnglish ? "Type or paste Spanish" : "Type or paste English")
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 14)
                    .allowsHitTesting(false)
            }
        }
    }

    @ViewBuilder
    /// The re-worded Spanish cards. Each only appears when it says something different from what was typed (ignoring case, accents and punctuation).
    private func alternateTexts(_ output: Output) -> (natural: String?, mexican: String?, slang: Set<String>) {
        if output.direction == .toEnglish, let backText {
            let typed = Self.comparable(output.input)
            let natural = Self.comparable(backText) != typed ? backText : nil
            let version = MexicanTranslation.slangVersion(of: backText)
            let showMexican = Self.comparable(version.text) != typed && Self.comparable(version.text) != Self.comparable(backText)
            return (natural, showMexican ? version.text : nil, showMexican ? Set(version.replaced.map(\.0)) : [])
        }
        if output.direction == .toSpanish {
            let version = MexicanTranslation.slangVersion(of: output.translation)
            let show = Self.comparable(version.text) != Self.comparable(output.translation)
            return (nil, show ? version.text : nil, show ? Set(version.replaced.map(\.0)) : [])
        }
        return (nil, nil, [])
    }

    @ViewBuilder
    private func results(_ output: Output) -> some View {
        let spanish = output.direction == .toEnglish ? output.input : output.translation
        let alternates = alternateTexts(output)
        let slang = MexicanTranslation.slang(in: spanish)
        let alternatives = MexicanTranslation.alternatives(in: spanish).filter { !alternates.slang.contains($0.0) }
        let hasNatural = alternates.natural != nil || alternates.mexican != nil
        let hasWords = output.readAs != nil || !output.adjusted.isEmpty || !slang.isEmpty || !alternatives.isEmpty
        VStack(alignment: .leading, spacing: 24) {
            // Lines only separate sections that both have something in them
            if hasNatural || hasWords { Divider().padding(.horizontal, 28) }
            if let natural = alternates.natural {
                card(title: "Another way to say it", copy: natural) {
                    Text(WordLinks.linked(natural)).font(.callout).textSelection(.enabled)
                }
            }
            if let mexican = alternates.mexican { mexicanCard(mexican) }
            if hasNatural && hasWords { Divider().padding(.horizontal, 28) }
            if let readAs = output.readAs {
                note("Read as", readAs, symbol: "text.magnifyingglass")
            }
            if !output.adjusted.isEmpty {
                note("Adjusted for Mexico", output.adjusted.map { "\($0.0) → \($0.1)" }.joined(separator: "  ·  "), symbol: "mappin.and.ellipse")
            }
            if !slang.isEmpty {
                card(title: "Mexican words in this text") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(slang) { item in
                            Button { router?.showWord(item.word) } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.term).font(.headline)
                                        Text(item.meaning).font(.subheadline).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(.tertiary)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            if !alternatives.isEmpty {
                card(title: "In Mexico you'd also say") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(alternatives, id: \.0) { Text("\($0.0) → **\($0.1)**") }
                    }
                }
            }
        }
    }

    private func card(title: String, copy: String? = nil, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.caption2.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase)
                Spacer()
                if let copy { CopyButton(text: copy) }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func note(_ title: String, _ text: String, symbol: String) -> some View {
        Label { Text("**\(title):** \(text)") } icon: { Image(systemName: symbol) }
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    /// Runs the Spanish checks off the main thread; the result replaces what was shown before.
    private func checkSpanish(_ text: String) {
        Task {
            let found = await Task.detached(priority: .userInitiated) { SpanishChecker.check(text) }.value
            issues = found
        }
    }

    private func mexicanCard(_ text: String) -> some View {
        card(title: "More natural in Mexico", copy: text) {
            Text(WordLinks.linked(text)).font(.callout).textSelection(.enabled)
        }
    }

    private static func comparable(_ text: String) -> String {
        text.searchKey.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).joined(separator: " ")
    }

    private func startBackTranslation(of english: String) {
        backRequest = english
        let next = TranslationSession.Configuration(source: Locale.Language(identifier: "en"), target: Locale.Language(identifier: "es"))
        if backConfiguration == next { backConfiguration?.invalidate() } else { backConfiguration = next }
    }

    /// Translates once typing has paused; clears the results when the text is emptied.
    private func scheduleTranslation() {
        pending?.cancel()
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            output = nil; errorText = nil; issues = []; backText = nil; isWorking = false; lastSent = ""
            return
        }
        guard "\(direction.rawValue)|\(text)" != lastSent else { return }
        pending = Task {
            try? await Task.sleep(for: Self.typingPause)
            guard !Task.isCancelled else { return }
            translate()
        }
    }

    private func translate() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        pending?.cancel()
        lastSent = "\(direction.rawValue)|\(text)"
        isWorking = true
        errorText = nil
        needsDownload = false
        issues = []
        backText = nil
        var sent = text
        var readAs: String?
        if direction == .toEnglish {
            let prepared = MexicanTranslation.prepare(text)
            sent = prepared.text
            if !prepared.changes.isEmpty { readAs = prepared.text }
        }
        request = (sent, direction, readAs, text)
        let next = TranslationSession.Configuration(source: direction.source, target: direction.target)
        if configuration == next { configuration?.invalidate() } else { configuration = next }
    }
}

/// A small "copy" button that confirms with a checkmark for a moment.
struct CopyButton: View {
    let text: String
    @State private var copied = false

    var body: some View {
        Button {
            UIPasteboard.general.string = text
            copied = true
            Task { try? await Task.sleep(for: .seconds(1.5)); copied = false }
        } label: {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .font(.footnote.weight(.semibold))
                .frame(minWidth: 24, minHeight: 20)
        }
        .buttonStyle(.plain)
        .foregroundStyle(copied ? Color.green : Color.accentColor)
        .accessibilityLabel(copied ? "Copied" : "Copy text")
    }
}
