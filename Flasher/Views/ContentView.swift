import SwiftUI

enum AppTab: Hashable { case dictionary, translate, flashcards, drill, learn }

/// Lets any screen send the user to a word's page in the Dictionary tab.
@Observable
final class AppRouter {
    var tab: AppTab = .dictionary
    var dictionaryPath = NavigationPath()
    /// The tab a word was opened from; going back from that word returns there instead of to the dictionary's search.
    private var returnTab: AppTab?

    func showWord(_ word: Word, attached: Clitics.Match? = nil, focus: ConjugationFocus? = nil) {
        if tab != .dictionary { returnTab = tab }
        dictionaryPath = NavigationPath()
        dictionaryPath.append(SearchHit(word: word, diminutive: DiminutiveResolver.resolve(word.spanish), attached: attached, focus: focus))
        tab = .dictionary
    }

    /// Called when the dictionary's stack changes: backing out of the word returns to where it was opened from.
    func pathChanged() {
        guard dictionaryPath.isEmpty, let back = returnTab else { return }
        returnTab = nil
        tab = back
    }

    /// Picking a tab by hand ends the "return to" trip.
    func tabChanged() {
        if tab != .dictionary { returnTab = nil }
    }
}

struct ContentView: View {
    @State private var router = AppRouter()
    /// Changing the target country rebuilds every screen so each one shows that country's words.
    @AppStorage(AppSettings.countryKey) private var country = Country.mexico.rawValue
    @AppStorage(AppSettings.welcomeSeenKey) private var welcomeSeen = false

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

            NavigationStack {
                DrillView()
            }
            .tabItem { Label("Drill", systemImage: "pencil.and.list.clipboard") }
            .tag(AppTab.drill)

            NavigationStack {
                LearnView()
            }
            .tabItem { Label("Learn", systemImage: "graduationcap") }
            .tag(AppTab.learn)
        }
        .id(country)
        .environment(router)
        .onChange(of: router.dictionaryPath) { router.pathChanged() }
        .onChange(of: router.tab) { router.tabChanged() }
        .fullScreenCover(isPresented: Binding(get: { !welcomeSeen }, set: { welcomeSeen = !$0 })) {
            WelcomeView { welcomeSeen = true }
        }
    }
}
