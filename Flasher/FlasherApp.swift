import SwiftUI

@main
struct FlasherApp: App {
    init() {
        Self.skipWelcomeForExistingUsers()
        KeyboardDoneBar.install()
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

/// Puts a Done bar above the keyboard for every text field, text editor and search field in the app.
enum KeyboardDoneBar {
    static func install() {
        for name in [UITextField.textDidBeginEditingNotification, UITextView.textDidBeginEditingNotification] {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { note in
                guard let field = note.object as? UIResponder else { return }
                attach(to: field)
            }
        }
    }

    private static func attach(to responder: UIResponder) {
        let bar = UIToolbar()
        let dismiss = UIAction { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        let done = UIBarButtonItem(title: "Done", primaryAction: dismiss)
        done.style = .done
        bar.items = [UIBarButtonItem.flexibleSpace(), done]
        bar.sizeToFit()
        if let field = responder as? UITextField, field.inputAccessoryView == nil {
            field.inputAccessoryView = bar
            field.reloadInputViews()
        } else if let view = responder as? UITextView, view.inputAccessoryView == nil {
            view.inputAccessoryView = bar
            view.reloadInputViews()
        }
    }
}
