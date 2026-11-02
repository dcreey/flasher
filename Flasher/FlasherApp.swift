import SwiftUI

@main
struct FlasherApp: App {
    init() {
        Self.skipWelcomeForExistingUsers()
        // Load the bundled dictionary and build the search index before the first search
        Task.detached(priority: .utility) { DictionaryIndex.warmUp(); _ = Extras.shared; _ = VerbForms.index }
    }

    /// The welcome walkthrough is for new installs only. An update over an install that already saved anything
    /// (progress, settings, recent words) counts as seen, so it never appears after updating.
    private static func skipWelcomeForExistingUsers() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: AppSettings.welcomeSeenKey) == nil else { return }
        let saved = Bundle.main.bundleIdentifier.flatMap { defaults.persistentDomain(forName: $0) } ?? [:]
        if !saved.isEmpty { defaults.set(true, forKey: AppSettings.welcomeSeenKey) }
    }

    @AppStorage(AppSettings.appearanceKey) private var appearance = AppSettings.Appearance.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ProgressStore.shared)
                .preferredColorScheme(AppSettings.Appearance(rawValue: appearance)?.colorScheme)
        }
    }
}

extension View {
    /// A Done button in the bar above the keyboard that puts the keyboard away. Attach it once to the screen with the text field.
    func keyboardDoneButton() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .fontWeight(.semibold)
            }
        }
    }
}
