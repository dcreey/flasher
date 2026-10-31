import SwiftUI

enum AppTab: Hashable { case dictionary, translate, flashcards }

/// Lets any screen send the user to a word's page in the Dictionary tab.
@Observable
final class AppRouter {
    var tab: AppTab = .dictionary
    var dictionaryPath = NavigationPath()

    func showWord(_ word: Word) {
        dictionaryPath = NavigationPath()
        dictionaryPath.append(SearchHit(word: word, diminutive: DiminutiveResolver.resolve(word.spanish)))
        tab = .dictionary
    }
}

struct ContentView: View {
    @State private var router = AppRouter()

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.tab) {
            NavigationStack(path: $router.dictionaryPath) {
                DictionaryView()
            }
            .tabItem { Label("Dictionary", systemImage: "character.book.closed") }
            .tag(AppTab.dictionary)

            NavigationStack {
                if #available(iOS 18.0, *) {
                    TranslateView()
                } else {
                    ContentUnavailableView("Translate needs iOS 18", systemImage: "translate", description: Text("Update iOS to translate with Apple's offline translator."))
                }
            }
            .tabItem { Label("Translate", systemImage: "translate") }
            .tag(AppTab.translate)

            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Flashcards", systemImage: "rectangle.on.rectangle.angled") }
            .tag(AppTab.flashcards)
        }
        .environment(router)
    }
}
