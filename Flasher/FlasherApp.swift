import SwiftUI

@main
struct FlasherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(ProgressStore.shared)
        }
    }
}
