import SwiftUI

enum AppSettings {
    static let showVosotrosKey = "show_vosotros"
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppSettings.showVosotrosKey) private var showVosotros = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Show vosotros", isOn: $showVosotros)
                } header: {
                    Text("Conjugation")
                } footer: {
                    Text("Vosotros is used mainly in Spain. Turn it off to hide that column in conjugation charts.")
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
