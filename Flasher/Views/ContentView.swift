import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DictionaryView()
            }
            .tabItem { Label("Dictionary", systemImage: "character.book.closed") }

            NavigationStack {
                if #available(iOS 18.0, *) {
                    TranslateView()
                } else {
                    ContentUnavailableView("Translate needs iOS 18", systemImage: "translate", description: Text("Update iOS to translate with Apple's offline translator."))
                }
            }
            .tabItem { Label("Translate", systemImage: "translate") }

            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Flashcards", systemImage: "rectangle.on.rectangle.angled") }
        }
    }
}
