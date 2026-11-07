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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ProgressStore.shared)
                .preferredColorScheme(AppSettings.Appearance(rawValue: appearance)?.colorScheme)
                // Swiping down on any list or page puts the keyboard away, the way iOS does natively
                .scrollDismissesKeyboard(.interactively)
                .overlay(alignment: .bottomTrailing) { KeyboardDismissButton() }
        }
        .onChange(of: scenePhase) { _, phase in
            // Leaving the app closes the keyboard, so it isn't stuck open (with no Done button) on return
            if phase != .active { dismissKeyboard() }
        }
    }
}

func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

/// A small button on the top edge of the keyboard whenever it's open. The toolbar Done button can vanish after
/// switching apps (a SwiftUI bug), so this one follows the keyboard's own show and hide notifications instead.
private struct KeyboardDismissButton: View {
    @State private var keyboardTop: CGFloat?

    var body: some View {
        GeometryReader { proxy in
            if let keyboardTop {
                Button(action: dismissKeyboard) {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(width: 44, height: 36)
                        .background(.regularMaterial, in: Capsule())
                        .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Hide keyboard")
                .position(x: proxy.size.width - 36, y: keyboardTop - proxy.frame(in: .global).minY - 26)
            }
        }
        .ignoresSafeArea(.keyboard)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { note in
            guard let frame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let screen = UIScreen.main.bounds.height
            keyboardTop = frame.minY < screen - 1 ? frame.minY : nil
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in keyboardTop = nil }
    }
}

extension View {
    /// A Done button in the bar above the keyboard that puts the keyboard away. Attach it once to the screen with the text field.
    func keyboardDoneButton() -> some View {
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { dismissKeyboard() }
                .fontWeight(.semibold)
            }
        }
    }
}
