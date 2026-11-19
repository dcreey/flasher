import Foundation
let S = CommandLine.arguments.first { $0.hasPrefix("--data=") }.map { String($0.dropFirst(7)) } ?? "./"
func tsv(_ p: String) -> [[String: String]] {
    let lines = try! String(contentsOfFile: S + p, encoding: .utf8).replacingOccurrences(of: "\r", with: "").split(separator: "\n", omittingEmptySubsequences: true).map(String.init)
    let head = lines[0].split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
    return lines.dropFirst().map { l in
        let f = l.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
        var d: [String: String] = [:]; for (k, h) in head.enumerated() where k < f.count { var x = f[k].trimmingCharacters(in: .whitespaces); if x.hasPrefix("\"") && x.hasSuffix("\"") && x.count > 1 { x = String(x.dropFirst().dropLast()).replacingOccurrences(of: "\"\"", with: "\"") }; d[h] = x }
        return d
    }
}
struct Item { let id: String; let sentence: String; let ok: Set<String> }
func load(_ name: String) -> [Item] {
    switch name {
    case "100": return tsv("simple/t100_answers.tsv").map { Item(id: $0["id"]!, sentence: $0["sentence"]!, ok: $0["answer"] == "both" ? ["por", "para", "both"] : [$0["answer"]!]) }
    case "200": return tsv("pp200/answers.tsv").map { Item(id: $0["id"]!, sentence: $0["sentence"]!, ok: $0["answer"] == "both" ? ["por", "para", "both"] : [$0["answer"]!]) }
    case "500":
        let ann = Dictionary(uniqueKeysWithValues: tsv("pp500/annot.tsv").map { ($0["id"]!, $0) })
        return tsv("pp500/truth.tsv").compactMap { r in
            let a = ann[r["id"]!]!; if a["bad"] == "yes" { return nil }
            let o = r["original"]!; return Item(id: r["id"]!, sentence: r["sentence"]!, ok: a["other_ok"] == "yes" ? ["por", "para", "both"] : [o, "both"])
        }
    default: // held-out: strict, the writer's word (or both)
        return tsv("heldout/truth.tsv").map { r in Item(id: r["id"]!, sentence: r["sentence"]!, ok: [r["original"]!, "both"]) }
    }
}
let sets = CommandLine.arguments.count > 1 ? Array(CommandLine.arguments[1...]).filter { !$0.hasPrefix("-") } : ["100", "200", "500"]
let showMiss = CommandLine.arguments.contains("-m")
for name in sets {
    let items = load(name)
    var ok = 0; var byC: [String: (Int, Int)] = [:]; var miss: [String] = []
    for it in items {
        guard let v = PorParaEngine.explain(it.sentence).first(where: { $0.found == "___" }) else { miss.append("\(it.id) NO VERDICT \(it.sentence)"); continue }
        var good = it.ok.contains(v.answer.rawValue)
        if v.answer == .both { good = true }
        ok += good ? 1 : 0
        let c = v.certainty.rawValue; byC[c, default: (0, 0)].0 += 1; byC[c, default: (0, 0)].1 += good ? 1 : 0
        if !good { miss.append("\(it.id) [\(v.certainty.rawValue)] \(v.rule.rawValue)->\(v.answer.rawValue) want \(it.ok.sorted().joined(separator: "/")) | \(it.sentence)") }
    }
    print("SET \(name): \(ok)/\(items.count) = \(String(format: "%.1f", 100.0 * Double(ok) / Double(items.count)))%")
    for c in ["high", "medium", "low"] { if let (n, g) = byC[c] { print("   \(c): \(g)/\(n) = \(String(format: "%.1f", 100.0 * Double(g) / Double(n)))%") } }
    if showMiss { miss.forEach { print("   " + $0) } }
}
