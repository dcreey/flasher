import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DictionaryView()
            }
            .tabItem { Label("Dictionary", systemImage: "character.book.closed") }

            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Flashcards", systemImage: "rectangle.on.rectangle.angled") }
        }
    }
}
