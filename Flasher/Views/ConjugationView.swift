import SwiftUI

/// The "ending map": each row factors the stem out, so a cell only shows the ending that varies by person.
/// Regular endings read as colored columns; stem changes and irregular forms break the pattern in orange.
struct ConjugationView: View {
    let conjugation: Conjugation
    /// Real sentences for the verb; the one shown follows the selected tense.
    var examples: [ExampleSentence] = []
    /// The verb's English gloss, used to translate generated sentences.
    var gloss: String = ""

    /// Set for a phrase built around this verb: the banner then shows the whole phrase and its meaning.
    var phrase: PhraseVerb?
    /// Set when the word was reached through a form with pronouns attached ("dímelo"): its command, infinitive or gerund is marked.
    var attached: Clitics.Match?

    private struct Selection: Equatable {
        var tense: Tense
        var person: Int
    }

    init(conjugation: Conjugation, examples: [ExampleSentence] = [], gloss: String = "", phrase: PhraseVerb? = nil, attached: Clitics.Match? = nil) {
        self.conjugation = conjugation
        self.examples = examples
        self.gloss = gloss
        self.phrase = phrase
        self.attached = attached
        let start = attached?.selection
        _selection = State(initialValue: Selection(tense: start?.tense ?? phrase?.start.tense ?? .present, person: start?.person ?? phrase?.start.person ?? 0))
    }

    @State private var selection: Selection
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
            if phrase == nil { exampleCard }
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
            nonFiniteChip("Infinitive", conjugation.infinitive, marked: attached?.kind == .infinitive, withPronouns: pronounForm(of: conjugation.infinitive))
            nonFiniteChip("Gerund", conjugation.gerund, marked: attached?.kind == .gerund, withPronouns: pronounForm(of: conjugation.gerund))
            nonFiniteChip("Participle", conjugation.participle, withPronouns: attached == nil || !showsPronouns ? nil : "never attached")
        }
    }

    /// Pronouns only attach to a plain verb: reflexive verbs and phrases ("darse cuenta") reorder them.
    private var showsPronouns: Bool { attached != nil && !conjugation.reflexive && conjugation.tail.isEmpty }

    private func pronounForm(of form: String) -> String? {
        guard showsPronouns, let attached else { return nil }
        return "→ " + SpanishStress.attach(form, pronouns: attached.pronouns, person: nil)
    }

    private func nonFiniteChip(_ title: String, _ value: String, marked: Bool = false, withPronouns: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if let withPronouns {
                Text(withPronouns)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.accentColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 10))
        .overlay { if marked { RoundedRectangle(cornerRadius: 10).stroke(Color.accentColor, lineWidth: 2) } }
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
            pronounLine(tense: tense, person: person)
            if let phrase {
                phraseMeaning(phrase)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(tense.mood.color.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .animation(.easeOut(duration: 0.15), value: selection)
    }

    /// The selected form with the pronouns, where Spanish allows it: attached to a command, in front of anything else.
    @ViewBuilder
    private func pronounLine(tense: Tense, person: Int) -> some View {
        if showsPronouns, let attached, let form = conjugation.forms[tense]?[person], !form.isEmpty {
            let list = attached.pronouns.joined(separator: " ")
            VStack(alignment: .leading, spacing: 3) {
                if tense == .imperative {
                    let joined = SpanishStress.attach(form, pronouns: attached.pronouns, person: person)
                    let plainJoin = form.lowercased() + attached.pronouns.joined()
                    let note = joined == plainJoin ? "Attached to the end of the command." : "Attached to the end of the command; the accent (or dropped letter) keeps the sound the same."
                    pronounRow("With \(list)", joined, note: note, highlight: joined.searchKey == attached.typed.searchKey)
                    if let negative = conjugation.forms[.subjunctivePresent]?[person] {
                        pronounRow("Negative", "no \(list) \(negative)", note: "In a negative command the pronouns go before the verb.")
                    }
                } else {
                    let reflexive = ["me", "te", "se", "nos", "os", "se"][person]
                    let echo = attached.pronouns.contains(reflexive) ? " Here “\(reflexive)” matches the subject, so it reads as reflexive (\(Clitics.reflexiveMeaning(of: reflexive)))." : ""
                    let isSearched = attached.selection.map { $0.tense == tense && $0.person == person } ?? false
                    pronounRow("With \(list)", "\(list) \(form)", note: "Pronouns go before a conjugated verb; attaching them (“\(form)\(attached.pronouns.joined())”) isn't used.\(echo)", highlight: isSearched)
                }
            }
            .padding(.top, 6)
        }
    }

    private func pronounRow(_ title: String, _ text: String, note: String, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title + ":").font(.caption).foregroundStyle(.secondary)
                Text(text).font(.callout.weight(.semibold))
                if highlight { Image(systemName: "checkmark.circle.fill").font(.caption).foregroundStyle(Color.accentColor) }
            }
            Text(note).font(.caption2).foregroundStyle(.secondary)
        }
    }

    /// The phrase's meaning, inflected for the chosen tense and person when it reads as a verb phrase ("I have just").
    @ViewBuilder
    private func phraseMeaning(_ phrase: PhraseVerb) -> some View {
        if let inflected = phrase.english(tense: selection.tense, person: selection.person) {
            Text(inflected)
                .font(.callout.weight(.medium))
            Text("Base meaning: \(phrase.baseMeaning)")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else if !phrase.baseMeaning.isEmpty {
            Text(phrase.baseMeaning)
                .font(.callout.weight(.medium))
            Text("Meaning of the base phrase")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Example sentence for the selected tense

    private var tenseExamples: [TenseExample] {
        TenseExamples.examples(for: selection.tense, person: selection.person, conjugation: conjugation, pool: examples)
    }

    @ViewBuilder
    private var exampleCard: some View {
        // With pronouns attached the real sentences wouldn't show them, so a made-up one takes over
        let real = showsPronouns ? [] : tenseExamples.filter(\.exactPerson)
        VStack(alignment: .leading, spacing: 4) {
            if !real.isEmpty {
                let match = real[exampleIndex % real.count]
                Text(WordLinks.linked(TenseExamples.highlight(match.sentence.spanish, tokens: [match.token])))
                    .font(.callout)
                    .tint(.primary)
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
            } else if let made = TenseExamples.generated(tense: selection.tense, person: selection.person, conjugation: conjugation, gloss: gloss,
                                                         pronouns: showsPronouns ? attached?.pronouns ?? [] : []),
                      let form = conjugation.attachedImperativeOrForm(selection.tense, selection.person) {
                let shown = showsPronouns && selection.tense == .imperative
                    ? SpanishStress.attach(form, pronouns: attached?.pronouns ?? [], person: selection.person) : form
                Text(WordLinks.linked(TenseExamples.highlight(made.spanish, tokens: [shown.lowercased()])))
                    .font(.callout)
                    .tint(.primary)
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
        if let phrase { form = phrase.spanish(core: form) }
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
