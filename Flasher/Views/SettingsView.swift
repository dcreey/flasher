import SwiftUI

enum AppSettings {
    static let showVosotrosKey = "show_vosotros"
    /// Whether the drill includes the progressive (estar + -ando) tenses.
    static let drillProgressiveKey = "drill_progressive"
    static let showSpanishChecksKey = "show_spanish_checks"
    static let appearanceKey = "appearance"
    static let conjugationDisplayKey = "conjugation_display"
    static let countryKey = "target_country"
    static let welcomeSeenKey = "welcome_seen"

    /// How the app looks: follow the phone, or always light or dark.
    enum Appearance: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }
        var title: String { rawValue.capitalized }
        var colorScheme: ColorScheme? {
            switch self {
            case .system: nil
            case .light: .light
            case .dark: .dark
            }
        }
    }

    /// What conjugation charts show until the user taps the switch above them.
    enum ConjugationDisplay: String, CaseIterable, Identifiable {
        case endings, full
        var id: String { rawValue }
        var title: String { self == .endings ? "Endings" : "Full forms" }
    }
}

/// The Spanish-speaking country the app is tuned for: flagged dictionary meanings, regional wording in Translate and the word deck.
enum Country: String, CaseIterable, Identifiable {
    case mexico, colombia
    var id: String { rawValue }

    static var current: Country {
        UserDefaults.standard.string(forKey: AppSettings.countryKey).flatMap(Country.init(rawValue:)) ?? .mexico
    }

    var name: String { self == .mexico ? "Mexico" : "Colombia" }
    var demonym: String { self == .mexico ? "Mexican" : "Colombian" }
    var flag: String { self == .mexico ? "🇲🇽" : "🇨🇴" }
    var code: String { self == .mexico ? "MX" : "CO" }
    /// How dictionary labels spell the country: "(Colombia, slang) …".
    var label: String { name }
    /// "(MX)", "(Mexican)" or "(Mexico …)" in the flashcard data marks a gloss from this country.
    var markerPattern: String { self == .mexico ? #"\s*\((?:MX|Mexican|Mexico)\b[^)]*\)"# : #"\s*\((?:CO|Colombian|Colombia)\b[^)]*\)"# }
}

/// Keeps one value per country, built on first use, so switching country never recomputes what was already built.
final class PerCountry<Value> {
    private var values: [Country: Value] = [:]
    private let lock = NSLock()
    private let make: (Country) -> Value
    init(_ make: @escaping (Country) -> Value) { self.make = make }

    var current: Value { value(for: Country.current) }

    func value(for country: Country) -> Value {
        lock.lock()
        defer { lock.unlock() }
        if let existing = values[country] { return existing }
        let built = make(country)
        values[country] = built
        return built
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppSettings.showVosotrosKey) private var showVosotros = true
    @AppStorage(AppSettings.drillProgressiveKey) private var drillProgressive = true
    @AppStorage(AppSettings.showSpanishChecksKey) private var showSpanishChecks = true
    @AppStorage(AppSettings.appearanceKey) private var appearance = AppSettings.Appearance.system.rawValue
    @AppStorage(AppSettings.conjugationDisplayKey) private var conjugationDisplay = AppSettings.ConjugationDisplay.endings.rawValue
    @AppStorage(AppSettings.countryKey) private var country = Country.mexico.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Country", selection: $country) {
                        ForEach(Country.allCases) { Text("\($0.flag) \($0.name)").tag($0.rawValue) }
                    }
                } header: {
                    Text("Target country")
                } footer: {
                    Text("Tunes the app to this country's Spanish: its flag marks local meanings in the dictionary, Translate suggests its wording, and the word deck swaps in its vocabulary.")
                }

                Section {
                    Picker("Appearance", selection: $appearance) {
                        ForEach(AppSettings.Appearance.allCases) { Text($0.title).tag($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("System follows your phone's light or dark setting.")
                }

                Section {
                    Toggle("Show Spanish checks", isOn: $showSpanishChecks)
                } header: {
                    Text("Translate")
                } footer: {
                    Text("Points out likely mistakes in Spanish text: pronoun order, accents, agreement, verb forms and more.")
                }

                Section {
                    Toggle("Progressive tenses", isOn: $drillProgressive)
                } header: {
                    Text("Drill")
                } footer: {
                    Text("Turn off to leave out the progressive tenses (estoy comiendo, estaba comiendo…) from the tense list and from mixed practice.")
                }

                Section {
                    Picker("Show by default", selection: $conjugationDisplay) {
                        ForEach(AppSettings.ConjugationDisplay.allCases) { Text($0.title).tag($0.rawValue) }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Show vosotros", isOn: $showVosotros)
                } header: {
                    Text("Conjugation")
                } footer: {
                    Text("Endings shows only the part that changes; full forms spell out every word. You can still switch on any chart. Vosotros is used mainly in Spain: turn it off to hide that column.")
                }
                Section {
                    Text("Word meanings come from Wiktionary (CC BY-SA 4.0), via Kaikki.org. Only words that also appear in real movie and TV subtitles (OpenSubtitles word frequencies) are included.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Dictionary data")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
    }
}

/// The info button in the top-left of each tab; opens `AboutView`.
struct AboutButton: View {
    @State private var show = false

    var body: some View {
        Button { show = true } label: { Image(systemName: "info.circle") }
            .accessibilityLabel("About this app")
            .sheet(isPresented: $show) { AboutView() }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 6) {
                        Image(systemName: "lock.shield.fill").font(.system(size: 44)).foregroundStyle(.green)
                        Text("Your privacy").font(.title2.bold())
                        Text("El Pie keeps everything on your phone.").font(.subheadline).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                Section {
                    point("eye.slash", "We do not track you", "No analytics, no advertising, no accounts and no profiling.")
                    point("airplane", "Fully offline", "The dictionary, conjugations, flashcards and Spanish checks all work without a connection.")
                    point("icloud.slash", "No data is sent anywhere", "What you search, study and type never leaves your device. Your progress and settings are stored only on this phone.")
                    point("character.bubble", "Translation stays on device", "The Translate tab uses Apple's on-device translation. The first time, iOS may download a language pack, and after that translating needs no internet.")
                    point("trash", "You are in control", "Deleting the app deletes everything it stored.")
                }
            }
            .navigationTitle("About El Pie")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }

    private func point(_ icon: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon).frame(width: 26).foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

/// The first-launch walkthrough: what the app is for, then the choice of target country.
struct WelcomeView: View {
    @AppStorage(AppSettings.countryKey) private var country = Country.mexico.rawValue
    @State private var page = 0
    let onFinish: () -> Void

    private let pages: [(symbol: String, title: String, text: String)] = [
        ("text.bubble.fill", "Learn Spanish the way people really talk",
         "El Pie helps you learn idioms, slang and sayings, not just textbook words, so you sound like someone from the country you care about."),
        ("character.book.closed.fill", "Look up, translate, practice",
         "Search words with local meanings flagged, translate with suggestions for how people there say it, and practice with flashcards."),
        ("lock.shield.fill", "Private and fully offline",
         "We don't track you, and nothing is ever sent off your device. No accounts, no analytics, no internet needed."),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 20) {
                        Spacer()
                        Image(systemName: pages[index].symbol).font(.system(size: 64)).foregroundStyle(.tint)
                        Text(pages[index].title).font(.title.bold()).multilineTextAlignment(.center)
                        Text(pages[index].text).font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                    .tag(index)
                }
                countryPage.tag(pages.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button {
                if page < pages.count { withAnimation { page += 1 } } else { onFinish() }
            } label: {
                Text(page < pages.count ? "Continue" : "Get started").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 32).padding(.bottom, 32)
        }
    }

    private var countryPage: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Pick your target country").font(.title.bold()).multilineTextAlignment(.center)
            Text("It's all Spanish. This just tunes the slang, local words and translations to the country you care about. You can change it any time in Settings.")
                .font(.body).foregroundStyle(.secondary).multilineTextAlignment(.center)
            ForEach(Country.allCases) { option in
                Button { country = option.rawValue } label: {
                    HStack(spacing: 14) {
                        Text(option.flag).font(.system(size: 40))
                        Text(option.name).font(.title3.weight(.semibold))
                        Spacer()
                        Image(systemName: country == option.rawValue ? "checkmark.circle.fill" : "circle")
                            .font(.title2).foregroundStyle(country == option.rawValue ? Color.accentColor : .secondary)
                    }
                    .padding(16)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.accentColor, lineWidth: country == option.rawValue ? 2 : 0))
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}
