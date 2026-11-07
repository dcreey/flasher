import XCTest
@testable import Flasher

/// The dictionary ranks the strongest relationship first: exact matches (weighted by how early the meaning comes and
/// how common the word is), then a word inside a longer meaning, then prefixes and substrings, then misspellings.
final class SearchRankingTests: XCTestCase {
    private func top(_ query: String, _ n: Int, scope: SearchScope = .all) -> [String] {
        DictionaryIndex.search(query, scope: scope).prefix(n).map(\.word.spanish)
    }

    private func assertTop(_ query: String, _ n: Int, contains expected: [String], scope: SearchScope = .all, line: UInt = #line) {
        let found = top(query, n, scope: scope)
        for word in expected { XCTAssertTrue(found.contains(word), "\(query): \(word) not in top \(n): \(found)", line: line) }
    }

    func testCommonEnglishWordsFindTheirEverydaySpanish() {
        assertTop("test", 5, contains: ["prueba", "examen"])
        assertTop("exam", 3, contains: ["examen"])
        assertTop("house", 3, contains: ["casa"])
        assertTop("dog", 3, contains: ["perro"])
        assertTop("run", 5, contains: ["correr"])
        assertTop("eat", 3, contains: ["comer"])
        assertTop("to eat", 3, contains: ["comer"])
        assertTop("red", 5, contains: ["rojo"])
        assertTop("owner", 3, contains: ["dueño"])
        assertTop("landlord", 5, contains: ["dueño"])
        assertTop("proof", 3, contains: ["prueba"])
        assertTop("teacher", 5, contains: ["maestro", "profesor"])
    }

    func testSpanishWordsComeFirstForThemselves() {
        XCTAssertEqual(top("casa", 1).first, "casa")
        XCTAssertEqual(top("prueba", 1).first, "prueba")
        XCTAssertEqual(top("el profesor", 1).first, "profesor")
        XCTAssertEqual(top("profesoras", 1).first, "profesor")
        XCTAssertEqual(top("duena", 1).first, "dueño")
    }

    /// Exact matches outrank prefixes, which outrank misspellings.
    func testBandsStayInOrder() {
        let results = top("test", 40)
        let testament = results.firstIndex(of: "testamento")
        if let testament, let prueba = results.firstIndex(of: "prueba") { XCTAssertLessThan(prueba, testament) }
        // A misspelling still finds the word when nothing matches directly
        assertTop("perrro", 3, contains: ["perro"], scope: .spanish)
        assertTop("hablr", 3, contains: ["hablar"], scope: .spanish)
        assertTop("hosue", 5, contains: ["casa"], scope: .english)
    }

    func testSearchIsQuickOnceBuilt() {
        DictionaryIndex.warmUp()
        let start = Date()
        for q in ["test", "casa", "landlord", "profesora", "hablar", "run", "perro"] { _ = DictionaryIndex.search(q, scope: .all) }
        let average = Date().timeIntervalSince(start) / 7
        XCTAssertLessThan(average, 0.25, "average search took \(Int(average * 1000)) ms")
        print("SEARCH_AVERAGE_MS \(Int(average * 1000))")
    }
}
