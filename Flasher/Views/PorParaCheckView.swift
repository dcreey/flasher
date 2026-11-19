import SwiftUI

/// Type a Spanish sentence with por, para or ___ and see which one the simple rules pick, why, and how sure they are.
struct PorParaCheckView: View {
    @State private var text = ""
    @FocusState private var focused: Bool

    private var verdicts: [PorParaEngine.Verdict] { PorParaEngine.explain(text) }
    private let examples = ["Salgo ___ Monterrey mañana.", "Gracias ___ todo.", "Voy ___ las tortillas.", "¿Qué puedo hacer ___ ti?", "La tarea es ___ el lunes.", "Me quedan dos capítulos ___ leer."]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Check a sentence").font(.title2.weight(.bold))
                Text("Type a Spanish sentence with por, para, or ___ where you're not sure. The rules from this guide pick one and say why.")
                    .font(.subheadline).foregroundStyle(.secondary)

                TextField("Ej. Lo compré ___ cien pesos.", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))

                if text.trimmingCharacters(in: .whitespaces).isEmpty {
                    Text("Try one").font(.subheadline.weight(.semibold))
                    FlowList(items: examples) { example in
                        Button { text = example } label: {
                            Text(example).font(.subheadline).padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Color.teal.opacity(0.12), in: Capsule()).foregroundStyle(.primary)
                        }
                        .buttonStyle(.plain)
                    }
                } else if verdicts.isEmpty {
                    Text("No por, para or ___ in that sentence yet.").font(.subheadline).foregroundStyle(.secondary)
                } else {
                    ForEach(Array(verdicts.enumerated()), id: \.offset) { _, verdict in card(verdict) }
                }

                Text("This checker reads the words around the gap, so it can be wrong. On real sentences it agrees with native writers about 93% of the time, and about 98% when it says it's sure.")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItemGroup(placement: .keyboard) { Spacer(); Button("Done") { focused = false } } }
    }

    private func card(_ verdict: PorParaEngine.Verdict) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(answerText(verdict)).font(.title2.weight(.bold)).foregroundStyle(Color.teal)
                Spacer()
                certaintyBadge(verdict.certainty)
            }
            if verdict.disagrees {
                Label("Your sentence has \(verdict.found). The rules expect \(verdict.answer.rawValue).", systemImage: "exclamationmark.triangle")
                    .font(.subheadline).foregroundStyle(.orange)
            }
            Text(verdict.rule.title).font(.subheadline.weight(.semibold))
            Text(verdict.why).font(.subheadline)
            if let alternative = verdict.alternative {
                VStack(alignment: .leading, spacing: 4) {
                    Text(verdict.certainty == .high ? "Also" : "Could be the other one").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                    Text(alternative).font(.subheadline).foregroundStyle(.secondary)
                }
                .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    private func answerText(_ verdict: PorParaEngine.Verdict) -> String {
        switch verdict.answer {
        case .both: "por or para"
        default: verdict.answer.rawValue
        }
    }

    private func certaintyBadge(_ certainty: PorParaEngine.Certainty) -> some View {
        let (label, color): (String, Color) = switch certainty {
        case .high: ("Sure", .green)
        case .medium: ("Probably", .orange)
        case .low: ("Edge case", .red)
        }
        return Text(label).font(.caption.weight(.bold)).textCase(.uppercase)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(color.opacity(0.15), in: Capsule()).foregroundStyle(color)
    }
}

/// Wraps short items onto as many lines as they need.
private struct FlowList<Item: Hashable, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Item) -> Content

    var body: some View {
        FlowLayout(spacing: 8) { ForEach(items, id: \.self) { content($0) } }
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, row: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > width, x > 0 { x = 0; y += row + spacing; row = 0 }
            x += size.width + spacing
            row = max(row, size.height)
        }
        return CGSize(width: width == .infinity ? x : width, height: y + row)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, row: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += row + spacing; row = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            row = max(row, size.height)
        }
    }
}
