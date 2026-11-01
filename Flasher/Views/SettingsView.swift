import SwiftUI

enum AppSettings {
    static let showVosotrosKey = "show_vosotros"
    static let showSpanishChecksKey = "show_spanish_checks"
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppSettings.showVosotrosKey) private var showVosotros = true
    @AppStorage(AppSettings.showSpanishChecksKey) private var showSpanishChecks = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Show Spanish checks", isOn: $showSpanishChecks)
                } header: {
                    Text("Translate")
                } footer: {
                    Text("Points out likely mistakes in Spanish text: pronoun order, accents, agreement, punctuation and more. You can also toggle it with the checkmark in Translate.")
                }

                Section {
                    Toggle("Show vosotros", isOn: $showVosotros)
                } header: {
                    Text("Conjugation")
                } footer: {
                    Text("Vosotros is used mainly in Spain. Turn it off to hide that column in conjugation charts.")
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
