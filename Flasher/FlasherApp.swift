import SwiftUI

@main
struct FlasherApp: App {
    init() {
        // Load the bundled dictionary and build the search index before the first search
        Task.detached(priority: .utility) { DictionaryIndex.warmUp(); _ = Extras.shared; _ = VerbForms.index }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ProgressStore.shared)
        }
    }
}
