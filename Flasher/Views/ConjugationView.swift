import SwiftUI

/// The "ending map": each row factors the stem out, so a cell only shows the ending that varies by person.
/// Regular endings read as colored columns; stem changes and irregular forms break the pattern in orange.
struct ConjugationView: View {
    let conjugation: Conjugation
    /// Real sentences for the verb; the one shown follows the selected tense.
    var examples: [ExampleSentence] = []
    /// The verb's English gloss, used to translate generated sentences.
    var gloss: String = ""

    private struct Selection: Equatable {
        var tense: Tense
        var person: Int
    }

    @State private var selection = Selection(tense: .present, person: 0)
    @State private var showFullForms = false
    @State private var exampleIndex = 0
    @AppStorage(AppSettings.showVosotrosKey) private var showVosotros = true

    private let labelWidth: CGFloat = 68
    private let groupGap: CGFloat = 6
    private let cellSpacing: CGFloat = 2
    private let columnTitles = ["yo", "tú", "él", "nos.", "vos.", "ellos"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            banner
            exampleCard
            Picker("Display", selection: $showFullForms) {
                Text("Endings").tag(false)
                Text("Full forms").tag(true)
            }
            .pickerStyle(.segmented)
            chart
            nonFiniteForms
            footer
        }
        .onChange(of: showVosotros) { _, shown in
            if !shown && selection.person == 4 { selection.person = 0 }
        }
    }

    // MARK: - Infinitive, gerund, participle

    private var nonFiniteForms: some View {
        HStack(spacing: 8) {
            nonFiniteChip("Infinitive", conjugation.infinitive)
            nonFiniteChip("Gerund", conjugation.gerund)
            nonFiniteChip("Participle", conjugation.participle)
        }
    }

    private func nonFiniteChip(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Selected form

    private var banner: some View {
        let tense = selection.tense
        let person = selection.person
        let subject = tense == .imperative ? Conjugation.imperativePronouns[person] : bannerPronouns[person]
        return VStack(alignment: .leading, spacing: 4) {
            Text("\(tense.mood.title) · \(tense.title) (\(tense.gloss))")
                .font(.caption.weight(.semibold))
                .foregroundStyle(tense.mood.color)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                if !bannerPrefix.isEmpty {
                    Text(bannerPrefix)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Text(bannerForm)
                    .font(.title2.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            if tense == .imperative {
                Text(subject)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tense.mood.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .animation(.easeOut(duration: 0.15), value: selection)
    }

    // MARK: - Example sentence for the selected tense

    private var tenseExamples: [TenseExample] {
        TenseExamples.examples(for: selection.tense, person: selection.person, conjugation: conjugation, pool: examples)
    }

    @ViewBuilder
    private var exampleCard: some View {
        let real = tenseExamples.filter(\.exactPerson)
        VStack(alignment: .leading, spacing: 4) {
            if !real.isEmpty {
                let match = real[exampleIndex % real.count]
                Text(TenseExamples.highlight(match.sentence.spanish, tokens: [match.token]))
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                Text(match.sentence.english)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if real.count > 1 {
                    Text("\((exampleIndex % real.count) + 1) of \(real.count) · tap the form again for the next")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            } else if let made = TenseExamples.generated(tense: selection.tense, person: selection.person, conjugation: conjugation, gloss: gloss),
                      let form = conjugation.attachedImperativeOrForm(selection.tense, selection.person) {
                Text(TenseExamples.highlight(made.spanish, tokens: [form.lowercased()]))
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                if !made.english.isEmpty {
                    Text(made.english)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("No English translation for this verb")
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
                Text("Made-up example · real sentences show up when we have them")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                Text("This verb isn't used in this form.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 12))
    }

    private let bannerPronouns = ["yo", "tú", "él / ella", "nosotros", "vosotros", "ellos / ellas"]

    private var bannerPrefix: String {
        let tense = selection.tense
        guard tense != .imperative else { return "" }
        var parts: [String] = []
        if tense.mood == .subjunctive { parts.append("que") }
        parts.append(bannerPronouns[selection.person])
        return parts.joined(separator: " ")
    }

    private var bannerForm: String {
        let tense = selection.tense
        let person = selection.person
        var form: String
        if tense == .imperative, let attached = conjugation.attachedImperative {
            form = attached[person] ?? "–"
        } else {
            form = conjugation.form(tense, person) ?? "–"
            if conjugation.reflexive, tense != .imperative {
                form = Conjugation.reflexivePronouns[person] + " " + form
            }
        }
        if !conjugation.tail.isEmpty { form += " " + conjugation.tail }
        return tense == .imperative ? "¡\(form)!" : form
    }

    // MARK: - Chart

    private var chart: some View {
        VStack(spacing: 6) {
            HStack(spacing: 0) {
                Color.clear.frame(width: labelWidth, height: 1)
                columns { i in
                    VStack(spacing: 0) {
                        Text(columnTitles[i])
                        if conjugation.reflexive {
                            Text(Conjugation.reflexivePronouns[i])
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                }
            }
            ForEach(Mood.allCases) { mood in
                VStack(spacing: 3) {
                    moodBand(mood)
                    ForEach(Tense.tenses(in: mood)) { tense in
                        tenseRow(tense)
                    }
                }
            }
        }
    }

    private func columns<Content: View>(@ViewBuilder _ content: @escaping (Int) -> Content) -> some View {
        HStack(spacing: cellSpacing) {
            ForEach(0..<3, id: \.self) { content($0) }
            Color.clear.frame(width: groupGap, height: 1)
            ForEach([3, 4, 5].filter { showVosotros || $0 != 4 }, id: \.self) { content($0) }
        }
    }

    private func moodBand(_ mood: Mood) -> some View {
        HStack(spacing: 6) {
            Text(mood.title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(mood.color)
            Rectangle()
                .fill(mood.color.opacity(0.3))
                .frame(height: 1)
        }
        .padding(.top, 4)
    }

    private func tenseRow(_ tense: Tense) -> some View {
        let rowStem = conjugation.rowStem(tense)
        let changed = conjugation.stemChangedPersons(tense)
        let stemIsIrregular = rowStem != conjugation.regularRowStem(tense)
        return HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(tense.title)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(rowStem.isEmpty ? " " : rowStem + "-")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(stemIsIrregular ? Color.orange : Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(width: labelWidth, alignment: .leading)
            columns { person in cell(tense, person, rowStem: rowStem, changed: changed.contains(person)) }
        }
    }

    private func cell(_ tense: Tense, _ person: Int, rowStem: String, changed: Bool) -> some View {
        let isSelected = selection == Selection(tense: tense, person: person)
        return Button {
            let tapped = Selection(tense: tense, person: person)
            if tapped == selection { exampleIndex += 1 } else { selection = tapped; exampleIndex = 0 }
        } label: {
            cellText(tense, person, rowStem: rowStem, changed: changed)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(
                    (changed ? Color.orange.opacity(0.18) : tense.mood.color.opacity(0.07)),
                    in: RoundedRectangle(cornerRadius: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? tense.mood.color : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(tense.title), \(Conjugation.pronouns[person]): \(conjugation.form(tense, person) ?? "none")")
    }

    @ViewBuilder
    private func cellText(_ tense: Tense, _ person: Int, rowStem: String, changed: Bool) -> some View {
        if tense == .imperative, let attached = conjugation.attachedImperative, let form = attached[person] {
            Text(form)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(tense.mood.color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 1)
        } else if let parts = conjugation.parts(tense, person) {
            Text(styled(parts, tense: tense, changed: changed))
                .font(.system(size: 12, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 1)
        } else {
            Text("–")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
    }

    private func styled(_ parts: (stem: String, ending: String, regularEnding: Bool), tense: Tense, changed: Bool) -> AttributedString {
        var result = AttributedString()
        if !parts.regularEnding {
            var whole = AttributedString(parts.ending)
            whole.foregroundColor = .orange
            whole.inlinePresentationIntent = .stronglyEmphasized
            return whole
        }
        if showFullForms || changed {
            var stem = AttributedString(parts.stem)
            stem.foregroundColor = changed ? Color.orange : Color.secondary
            if changed { stem.inlinePresentationIntent = .stronglyEmphasized }
            result += stem
        }
        var ending = AttributedString(parts.ending)
        ending.foregroundColor = tense.mood.color
        ending.inlinePresentationIntent = .stronglyEmphasized
        result += ending
        return result
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let shape = presentShapeNote {
                Label(shape, systemImage: "shoeprints.fill")
                    .font(.footnote)
                    .foregroundStyle(.orange)
            }
            HStack(spacing: 14) {
                legend(color: Mood.indicative.color.opacity(0.25), "regular ending")
                legend(color: Color.orange.opacity(0.4), "stem change / irregular")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            Text(notes)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func legend(color: Color, _ text: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 14, height: 10)
            Text(text)
        }
    }

    /// The pattern of changed forms in the present: a boot, or only "yo".
    private var presentShapeNote: String? {
        let changed = conjugation.stemChangedPersons(.present)
        switch changed {
        case [0, 1, 2, 5]:
            return "Boot verb: the stem changes in yo, tú, él and ellos. Nosotros and vosotros keep the original stem."
        case [0]:
            return "Only the yo form breaks the pattern."
        case [0, 1, 2, 3, 4, 5]:
            return "Irregular in every present form."
        case []:
            return nil
        default:
            return "The highlighted present forms break the regular pattern."
        }
    }

    private var notes: String {
        var lines = ["Perfect tenses use haber + \(conjugation.participle): he \(conjugation.participle), había \(conjugation.participle)…"]
        lines.append("Negative commands use the subjunctive: no \(conjugation.form(.subjunctivePresent, 1) ?? "").")
        if !conjugation.tail.isEmpty {
            lines.append("Forms show the verb only; “\(conjugation.tail)” follows it.")
        }
        return lines.joined(separator: "\n")
    }
}

private extension Mood {
    var color: Color {
        switch self {
        case .indicative: .blue
        case .subjunctive: .purple
        case .imperative: .green
        }
    }
}
