import SwiftUI

enum AppSettings {
    static let showVosotrosKey = "show_vosotros"
    static let showSpanishChecksKey = "show_spanish_checks"
    static let appearanceKey = "appearance"
    static let conjugationDisplayKey = "conjugation_display"

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

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppSettings.showVosotrosKey) private var showVosotros = true
    @AppStorage(AppSettings.showSpanishChecksKey) private var showSpanishChecks = true
    @AppStorage(AppSettings.appearanceKey) private var appearance = AppSettings.Appearance.system.rawValue
    @AppStorage(AppSettings.conjugationDisplayKey) private var conjugationDisplay = AppSettings.ConjugationDisplay.endings.rawValue

    var body: some View {
        NavigationStack {
            Form {
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
                    Text("Points out likely mistakes in Spanish text: pronoun order, accents, agreement, verb forms and more. You can also toggle it with the checkmark in Translate.")
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
