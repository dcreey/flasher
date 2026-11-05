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
        /// Which table: the simple tenses, the "-ing" tenses (estar + gerund) or the perfect tenses (haber + participle).
        var form: VerbForm = .infinitive
        var tense: Tense
        var person: Int
        /// A negative command ("no digas"): the imperative's second row, built from the present subjunctive.
        var negative = false
    }

    init(conjugation: Conjugation, examples: [ExampleSentence] = [], gloss: String = "", phrase: PhraseVerb? = nil, attached: Clitics.Match? = nil, focus: ConjugationFocus? = nil) {
        self.conjugation = conjugation
        self.examples = examples
        self.gloss = gloss
        self.phrase = phrase
        self.attached = attached
        let start = attached?.selection
        if let focus {
            _selection = State(initialValue: Selection(form: focus.form, tense: focus.tense, person: focus.person))
        } else if case .gerund? = attached?.kind {
            _selection = State(initialValue: Selection(form: .gerund, tense: .present, person: 0))
        } else {
            _selection = State(initialValue: Selection(tense: start?.tense ?? phrase?.start.tense ?? .present, person: start?.person ?? phrase?.start.person ?? 0))
        }
    }

    @State private var selection: Selection
    @State private var showFullForms = UserDefaults.standard.string(forKey: AppSettings.conjugationDisplayKey) == AppSettings.ConjugationDisplay.full.rawValue
    @State private var exampleIndex = 0
    @AppStorage(AppSettings.showVosotrosKey) private var showVosotros = true

    private let labelWidth: CGFloat = 68
    private let groupGap: CGFloat = 6
    private let cellSpacing: CGFloat = 2
    private let columnTitles = ["yo", "tú", "él", "nos.", "vos.", "ellos"]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            nonFiniteForms
            banner
            if selection.form != .infinitive {
                usageCard
            } else if phrase == nil, !selection.negative {
                exampleCard
            }
            drillButton
            if selection.form == .infinitive {
                Picker("Display", selection: $showFullForms) {
                    Text("Endings").tag(false)
                    Text("Full forms").tag(true)
                }
                .pickerStyle(.segmented)
                chart
            } else {
                compoundChart(selection.form)
            }
            footer
        }
        .onChange(of: showVosotros) { _, shown in
            if !shown && selection.person == 4 { selection.person = 0 }
        }
    }

    // MARK: - Infinitive, gerund, participle

    private var nonFiniteForms: some View {
        HStack(spacing: 8) {
            nonFiniteChip(.infinitive, conjugation.infinitive, withPronouns: pronounForm(of: conjugation.infinitive))
            nonFiniteChip(.gerund, conjugation.gerund, withPronouns: pronounForm(of: conjugation.gerund))
            nonFiniteChip(.participle, conjugation.participle, withPronouns: attached == nil || !showsPronouns ? nil : "never attached")
        }
    }

    /// Picking a form switches the table; a tense the new table doesn't have falls back to the present.
    private func choose(_ form: VerbForm) {
        guard form != selection.form else { return }
        selection = Selection(form: form, tense: form.supports(selection.tense) ? selection.tense : .present, person: selection.person)
        exampleIndex = 0
    }

    /// Pronouns only attach to a plain verb: reflexive verbs and phrases ("darse cuenta") reorder them.
    private var showsPronouns: Bool { attached != nil && !conjugation.reflexive && conjugation.tail.isEmpty }

    private func pronounForm(of form: String) -> String? {
        guard showsPronouns, let attached else { return nil }
        return "→ " + SpanishStress.attach(form, pronouns: attached.pronouns, person: nil)
    }

    private func nonFiniteChip(_ form: VerbForm, _ value: String, withPronouns: String? = nil) -> some View {
        let selected = selection.form == form
        return Button { choose(form) } label: { nonFiniteLabel(form.title, value, selected: selected, withPronouns: withPronouns) }
            .buttonStyle(.plain)
            .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func nonFiniteLabel(_ title: String, _ value: String, selected: Bool, withPronouns: String?) -> some View {
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
        .background(selected ? Color.accentColor.opacity(0.14) : Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 10))
        .overlay { RoundedRectangle(cornerRadius: 10).stroke(selected ? Color.accentColor : Color.clear, lineWidth: 2) }
    }

    // MARK: - Selected form

    private var banner: some View {
        let tense = selection.tense
        let person = selection.person
        let subject = tense == .imperative ? Conjugation.imperativePronouns[person] : bannerPronouns[person]
        let form = selection.form
        return VStack(alignment: .leading, spacing: 4) {
            Text(selection.negative ? "Imperative · Negative command = no + present subjunctive" : "\(tense.mood.title) · \(form.title(of: tense)) (\(form.gloss(of: tense)))")
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
            if form == .infinitive { pronounLine(tense: tense, person: person) }
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
        if selection.form == .infinitive, let inflected = phrase.english(tense: selection.tense, person: selection.person) {
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

    // MARK: - Drill queue

    /// The drill for the table and tense on screen, nil when the drill can't build sentences for this verb in it.
    private var drillForSelection: DrillTense? {
        guard phrase == nil, !selection.negative else { return nil }
        guard let drill = DrillTense.forWordPage(form: selection.form, tense: selection.tense) else { return nil }
        guard !DrillSentences.subjects(for: conjugation.infinitive, drill).isEmpty else { return nil }
        return drill
    }

    /// Adds this verb in this tense to the front of the Drill queue, or takes it back out.
    @ViewBuilder
    private var drillButton: some View {
        if let drill = drillForSelection {
            let queued = DrillProgress.shared.isQueued(conjugation.infinitive, drill)
            Button {
                if queued { DrillProgress.shared.unqueue(conjugation.infinitive, drill) }
                else { DrillProgress.shared.queue(conjugation.infinitive, drill) }
            } label: {
                Label(queued ? "In drill queue · \(DrillProgress.shared.item(conjugation.infinitive, drill).queuedCorrect ?? 0) of \(DrillProgress.queuePractices)" : "Add to drill queue", systemImage: queued ? "checkmark" : "plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(queued ? .green : .accentColor)
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
        if selection.negative {
            let pronouns = commandPronouns(person).joined(separator: " ")
            form = ["no", pronouns, conjugation.form(.subjunctivePresent, person) ?? "–"].filter { !$0.isEmpty }.joined(separator: " ")
        } else if selection.form != .infinitive {
            form = CompoundForms.form(of: conjugation, selection.form, tense, person) ?? "–"
            if conjugation.reflexive { form = Conjugation.reflexivePronouns[person] + " " + form }
        } else if tense == .imperative, let attached = conjugation.attachedImperative {
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

    // MARK: - Gerund and participle tables

    /// What the selected "-ing" or perfect tense is for.
    private var usageCard: some View {
        Text(.init(selection.form.usage(of: selection.tense)))
            .font(.callout)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 12))
    }

    /// The helper verb's forms in each tense with the gerund or participle fixed at the end, so a cell only shows what changes: he, has, ha…
    private func compoundChart(_ form: VerbForm) -> some View {
        let fixed = form == .gerund ? conjugation.gerund : conjugation.participle
        return VStack(spacing: 6) {
            HStack(spacing: 0) {
                Color.clear.frame(width: labelWidth, height: 1)
                columns { i in
                    VStack(spacing: 0) {
                        Text(columnTitles[i])
                        if conjugation.reflexive {
                            Text(Conjugation.reflexivePronouns[i]).foregroundStyle(.tertiary)
                        }
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                }
            }
            ForEach(Mood.allCases) { mood in
                let tenses = form.tenses.filter { $0.mood == mood }
                if !tenses.isEmpty {
                    VStack(spacing: 3) {
                        moodBand(mood)
                        ForEach(tenses) { tense in compoundRow(form, tense, fixed: fixed) }
                    }
                }
            }
        }
    }

    private func compoundRow(_ form: VerbForm, _ tense: Tense, fixed: String) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(form.title(of: tense))
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text("+ " + fixed)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(width: labelWidth, alignment: .leading)
            columns { person in compoundCell(form, tense, person) }
        }
    }

    private func compoundCell(_ form: VerbForm, _ tense: Tense, _ person: Int) -> some View {
        let selected = Selection(form: form, tense: tense, person: person)
        let isSelected = selection == selected
        let color = tense.mood.color
        return Button {
            selection = selected
        } label: {
            Text(CompoundForms.auxiliary(form, tense, person) ?? "–")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 1)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(color.opacity(0.07), in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(isSelected ? color : Color.clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(form.title(of: tense)), \(Conjugation.pronouns[person]): \(CompoundForms.form(of: conjugation, form, tense, person) ?? "none")")
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
                        if tense == .imperative { tenseRow(tense, negative: true) }
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

    /// The pronouns shown with commands: the ones searched for, or the verb's own reflexive pronoun.
    private func commandPronouns(_ person: Int) -> [String] {
        if showsPronouns, let attached { return attached.pronouns }
        return conjugation.reflexive ? [Conjugation.reflexivePronouns[person]] : []
    }

    /// `negative` draws the imperative's second row: "no" + the present subjunctive, with pronouns in front.
    private func tenseRow(_ tense: Tense, negative: Bool = false) -> some View {
        let source: Tense = negative ? .subjunctivePresent : tense
        let rowStem = conjugation.rowStem(source)
        let changed = conjugation.stemChangedPersons(source)
        let stemIsIrregular = rowStem != conjugation.regularRowStem(source)
        let isCommand = tense == .imperative
        return HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text(isCommand ? "\(negative ? "✗" : "✓") \(tense.title)" : tense.title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isCommand ? (negative ? Color.red : Color.green) : Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if negative {
                    Text("(subjunctive)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Mood.subjunctive.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Text(rowStem.isEmpty ? " " : rowStem + "-")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(stemIsIrregular ? Color.orange : Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(width: labelWidth, alignment: .leading)
            columns { person in cell(tense, person, rowStem: rowStem, changed: changed.contains(person), negative: negative) }
        }
    }

    private func cell(_ tense: Tense, _ person: Int, rowStem: String, changed: Bool, negative: Bool = false) -> some View {
        let selected = Selection(tense: tense, person: person, negative: negative)
        let isSelected = selection == selected
        let color = negative ? Color.red : tense.mood.color
        return Button {
            if selected == selection { exampleIndex += 1 } else { selection = selected; exampleIndex = 0 }
        } label: {
            cellText(tense, person, rowStem: rowStem, changed: changed, negative: negative)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(
                    (changed ? Color.orange.opacity(0.18) : color.opacity(0.07)),
                    in: RoundedRectangle(cornerRadius: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(negative ? "Negative " : "")\(tense.title), \(Conjugation.pronouns[person]): \(conjugation.form(negative ? .subjunctivePresent : tense, person) ?? "none")")
    }

    @ViewBuilder
    private func cellText(_ tense: Tense, _ person: Int, rowStem: String, changed: Bool, negative: Bool = false) -> some View {
        if negative {
            // There is no negative command for "yo"
            if person == 0 { Text("–").font(.system(size: 12)).foregroundStyle(.tertiary) }
            else if let parts = conjugation.parts(.subjunctivePresent, person) {
                let prefix = (["no"] + commandPronouns(person)).joined(separator: " ")
                VStack(spacing: 0) {
                    Text(prefix)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color.red.opacity(0.85))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text(styled(parts, tense: .subjunctivePresent, changed: changed, color: Mood.subjunctive.color))
                        .font(.system(size: 12, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .padding(.horizontal, 1)
            } else { Text("–").font(.system(size: 12)).foregroundStyle(.tertiary) }
        } else if tense == .imperative, showsPronouns, let attached, let form = conjugation.form(.imperative, person), !form.isEmpty {
            // With the pronouns searched for, the affirmative cell is the whole attached word: dímelo
            Text(SpanishStress.attach(form, pronouns: attached.pronouns, person: person))
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(tense.mood.color)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 1)
        } else if tense == .imperative, let attached = conjugation.attachedImperative, let form = attached[person] {
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

    private func styled(_ parts: (stem: String, ending: String, regularEnding: Bool), tense: Tense, changed: Bool, color: Color? = nil) -> AttributedString {
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
        ending.foregroundColor = color ?? tense.mood.color
        ending.inlinePresentationIntent = .stronglyEmphasized
        result += ending
        return result
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(alignment: .leading, spacing: 8) {
            if selection.form == .infinitive {
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
            }
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
        if selection.form == .gerund { lines = ["The “-ing” tenses use estar + \(conjugation.gerund): estoy \(conjugation.gerund), estaba \(conjugation.gerund)…"] }
        if selection.form != .infinitive { return lines.joined(separator: "\n") }
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
