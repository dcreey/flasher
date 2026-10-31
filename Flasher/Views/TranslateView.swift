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
        ("ordenadores", "computadoras"), ("ordenador", "computadora"), ("coches", "carros"), ("coche", "carro"),
        ("móviles", "celulares"), ("móvil", "celular"), ("zumos", "jugos"), ("zumo", "jugo"), ("patatas", "papas"), ("patata", "papa"),
        ("gafas", "lentes"), ("aparcamiento", "estacionamiento"), ("aparcar", "estacionar"), ("conducir", "manejar"),
        ("autobús", "camión"), ("jersey", "suéter"), ("melocotón", "durazno"), ("grifo", "llave"), ("chaval", "muchacho"), ("guay", "chido"),
    ]

    static func replacing(_ pairs: [(String, String)], in text: String) -> (text: String, changes: [(String, String)]) {
        var result = text
        var changes: [(String, String)] = []
        for (from, to) in pairs {
            guard let regex = try? NSRegularExpression(pattern: "(?<![\\p{L}])" + NSRegularExpression.escapedPattern(for: from) + "(?![\\p{L}])", options: .caseInsensitive),
                  regex.firstMatch(in: result, range: NSRange(result.startIndex..., in: result)) != nil else { continue }
            result = regex.stringByReplacingMatches(in: result, range: NSRange(result.startIndex..., in: result), withTemplate: to)
            changes.append((from, to))
        }
        return (result, changes)
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
    @State private var request: (text: String, direction: Direction, readAs: String?)?
    @FocusState private var focused: Bool
    @Environment(AppRouter.self) private var router: AppRouter?
    /// False right after translating Spanish, when the input shows as tappable words instead of an editor.
    @State private var isEditing = true

    private var showsLinkedInput: Bool { !isEditing && output?.direction == .toEnglish && !input.isEmpty }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Picker("Direction", selection: $direction) {
                    ForEach(Direction.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)

                inputField

                Button(action: translate) {
                    HStack {
                        if isWorking { ProgressView().tint(.white) }
                        Text("Translate").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .disabled(input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isWorking)

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
                if let output { results(output) }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: direction) {
            // Switching direction translates the same text the other way
            if output != nil || errorText != nil { translate() }
        }
        .navigationTitle("El Pie")
        .navigationBarTitleDisplayMode(.inline)
        .translationTask(configuration) { session in
            guard let request else { return }
            do {
                // Missing language packs: the system asks to download them
                try await session.prepareTranslation()
                let response = try await session.translate(request.text)
                var text = response.targetText
                var adjusted: [(String, String)] = []
                if request.direction == .toSpanish {
                    let local = MexicanTranslation.localize(text)
                    text = local.text
                    adjusted = local.changes
                }
                output = Output(input: input, direction: request.direction, translation: text, readAs: request.readAs, adjusted: adjusted)
                errorText = nil
            } catch {
                needsDownload = error is TranslationError
                errorText = needsDownload ? "Spanish and English need to be downloaded for offline translation." : error.localizedDescription
            }
            isWorking = false
        }
        .opensWordLinks(inDictionary: true)
    }

    private var inputField: some View {
        ZStack(alignment: .topLeading) {
            if showsLinkedInput {
                // Translated Spanish becomes tappable words; tapping anywhere else turns it back into the editor
                Text(WordLinks.linked(input))
                    .font(.body)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
                    .padding(13)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                    .contentShape(Rectangle())
                    .onTapGesture { isEditing = true; focused = true }
            } else {
                TextEditor(text: $input)
                    .focused($focused)
                    .autocorrectionDisabled()
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 120)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
            }
            if input.isEmpty {
                Text(direction == .toEnglish ? "Type or paste Spanish" : "Type or paste English")
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 13)
                    .padding(.vertical, 16)
                    .allowsHitTesting(false)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if !input.isEmpty {
                Button { input = ""; output = nil; errorText = nil; isEditing = true } label: { Image(systemName: "xmark.circle.fill") }
                    .foregroundStyle(.secondary)
                    .padding(10)
            }
        }
    }

    @ViewBuilder
    private func results(_ output: Output) -> some View {
        let spanish = output.direction == .toEnglish ? output.input : output.translation
        VStack(alignment: .leading, spacing: 12) {
            card(title: output.direction == .toEnglish ? "English" : "Spanish · tap a word") {
                if output.direction == .toSpanish {
                    Text(WordLinks.linked(output.translation)).font(.title3).textSelection(.enabled)
                } else {
                    Text(output.translation).font(.title3).textSelection(.enabled)
                }
            }
            if let readAs = output.readAs {
                note("Read as", readAs, symbol: "text.magnifyingglass")
            }
            if !output.adjusted.isEmpty {
                note("Adjusted for Mexico", output.adjusted.map { "\($0.0) → \($0.1)" }.joined(separator: "  ·  "), symbol: "mappin.and.ellipse")
            }
            let slang = MexicanTranslation.slang(in: output.direction == .toEnglish ? output.input : output.translation)
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
            let alternatives = MexicanTranslation.alternatives(in: spanish)
            if !alternatives.isEmpty {
                card(title: "In Mexico you'd also say") {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(alternatives, id: \.0) { Text("\($0.0) → **\($0.1)**") }
                    }
                }
            }
        }
    }

    private func card(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.weight(.semibold)).foregroundStyle(.secondary).textCase(.uppercase)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    private func note(_ title: String, _ text: String, symbol: String) -> some View {
        Label { Text("**\(title):** \(text)") } icon: { Image(systemName: symbol) }
            .font(.footnote)
            .foregroundStyle(.secondary)
    }

    private func translate() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        focused = false
        isEditing = false
        isWorking = true
        errorText = nil
        needsDownload = false
        var sent = text
        var readAs: String?
        if direction == .toEnglish {
            let prepared = MexicanTranslation.prepare(text)
            sent = prepared.text
            if !prepared.changes.isEmpty { readAs = prepared.text }
        }
        request = (sent, direction, readAs)
        let next = TranslationSession.Configuration(source: direction.source, target: direction.target)
        if configuration == next { configuration?.invalidate() } else { configuration = next }
    }
}
