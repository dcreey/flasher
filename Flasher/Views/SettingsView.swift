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
                    Text("Points out likely mistakes in Spanish text: pronoun order, accents, agreement, punctuation and more. You can also toggle it with the checkmark in Translate.")
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
