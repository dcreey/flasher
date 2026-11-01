import SwiftUI

struct WordDetailView: View {
    @Environment(ProgressStore.self) private var store
    let word: Word
    /// Set when the user searched for an -ito/-ita form of this word; otherwise resolved from the word itself.
    var diminutive: Diminutive?
    /// Set when the user arrived through a verb with pronouns attached ("vernos", "dímelo").
    var attached: Clitics.Match?

    @State private var confirmation: String?

    private var progress: WordProgress { store.progressFor(word.spanish) }
    private var sentences: [VocabSentence] { SeedData.sentencesByWord[word.spanish] ?? [] }
    private var shownDiminutive: Diminutive? { diminutive ?? DiminutiveResolver.resolve(word.spanish) }
    private var synonyms: [String] { SeedData.synonyms[word.spanish]?.sorted() ?? [] }
    private var conjugation: Conjugation? { word.partOfSpeech == .infinitive ? Conjugator.conjugate(word.spanish) : nil }
    private var phraseVerb: PhraseVerb? { PhraseVerb.find(for: word) }
    private var relatedWords: [Word] { RelatedForms.find(for: word) }
    private var wikiExamples: [Extras.Example] { Extras.shared.examples(for: word) }
    private var origin: String? { Extras.shared.etymology[word.spanish] }

    private struct FormRow: Identifiable {
        let label: String
        let singular: String?
        let plural: String
        var id: String { label }
    }

    /// Singular and plural for each sex, e.g. "el profesor · los profesores" and "la profesora · las profesoras".
    private var nounFormRows: [FormRow] {
        guard word.partOfSpeech == .noun, let forms = Extras.shared.nounForms[word.spanish] else { return [] }
        func join(_ article: String, _ items: [String]) -> String? {
            items.isEmpty ? nil : items.map { "\(article) \($0)" }.joined(separator: " / ")
        }
        var masculine: (s: [String], p: [String]) = (forms.masculine, forms.masculinePlural)
        var feminine: (s: [String], p: [String]) = (forms.feminine, forms.femininePlural)
        switch word.gender {
        case "m": masculine = ([word.spanish], forms.plural)
        case "f": feminine = ([word.spanish], forms.plural)
        default: // one form for both sexes (el/la estudiante)
            if masculine.s.isEmpty && feminine.s.isEmpty { masculine = ([word.spanish], forms.plural); feminine = masculine }
        }
        var rows: [FormRow] = []
        if let plural = join("los", masculine.p) { rows.append(FormRow(label: "Masculine", singular: join("el", masculine.s), plural: plural)) }
        if let plural = join("las", feminine.p) { rows.append(FormRow(label: "Feminine", singular: join("la", feminine.s), plural: plural)) }
        return rows
    }

    private var nounFormsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Plural & gender")
            VStack(spacing: 0) {
                ForEach(nounFormRows) { row in
                    HStack(alignment: .firstTextBaseline) {
                        Text(row.label).font(.caption).foregroundStyle(.secondary).frame(width: 76, alignment: .leading)
                        VStack(alignment: .leading, spacing: 2) {
                            if let singular = row.singular { Text(singular).font(.body.weight(.semibold)) }
                            Text(row.plural).font(.body)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    if row.id != nounFormRows.last?.id { Divider() }
                }
            }
        }
    }

    private struct RelatedItem: Identifiable {
        let text: String
        let english: String?
        let linked: Word?
        let tag: String
        let color: Color
        var id: String { tag + "·" + text }
    }

    /// Word forms, synonyms, opposites and word families, each tagged with how it relates.
    private var relatedItems: [RelatedItem] {
        var items: [RelatedItem] = []
        var seen: Set<String> = [word.spanish]
        func add(_ text: String, tag: String, color: Color, limit: Int) {
            guard !seen.contains(text), items.filter({ $0.tag == tag }).count < limit else { return }
            seen.insert(text)
            let linked = Lexicon.shared.wordsByID[text]
            items.append(RelatedItem(text: text, english: linked?.english, linked: linked, tag: tag, color: color))
        }
        for related in relatedWords {
            let isParticiple = related.spanish == conjugation?.participle
            add(related.spanish, tag: isParticiple ? "participle" : related.partOfSpeech.rawValue, color: .indigo, limit: 6)
        }
        let seedSynonyms = SeedData.synonyms[word.spanish]?.sorted() ?? []
        for synonym in seedSynonyms + (Extras.shared.synonyms[word.spanish] ?? []) { add(synonym, tag: "synonym", color: .teal, limit: 8) }
        for antonym in Extras.shared.antonyms[word.spanish] ?? [] { add(antonym, tag: "antonym", color: .red, limit: 4) }
        for derived in Extras.shared.derived[word.spanish] ?? [] { add(derived, tag: "derived", color: .orange, limit: 6) }
        for related in Extras.shared.related[word.spanish] ?? [] { add(related, tag: "related", color: .gray, limit: 5) }
        return items
    }
    private var mexicanMeanings: [MexicanMeaning] { Lexicon.shared.mexicanMeanings(for: word) }
    /// Everything except the Mexican meanings, which get their own card above.
    private var meanings: [Meaning] {
        Lexicon.shared.meanings(for: word.spanish).compactMap { block in
            let rest = block.senses.filter { !$0.isMexican }
            return rest.isEmpty ? nil : Meaning(partOfSpeech: block.partOfSpeech, gender: block.gender, senses: rest)
        }
    }
    /// Dictionary-only words always list their meanings; flashcard words only when there is more than the headline gloss.
    private var showsMeanings: Bool {
        guard let first = meanings.first else { return false }
        return word.order >= SeedData.words.count || !mexicanMeanings.isEmpty || meanings.count > 1 || first.senses.count > 1
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                if let attached { attachedCard(attached) }
                if let shownDiminutive { diminutiveCard(shownDiminutive) }
                if !nounFormRows.isEmpty { nounFormsSection }
                if let conjugation { conjugationSection(conjugation) }
                if let phraseVerb { phraseSection(phraseVerb) }
                if !mexicanMeanings.isEmpty { mexicanCard }
                if showsMeanings { meaningsSection }
                if !usageSentences.isEmpty { usagesSection }
                if !relatedItems.isEmpty { relatedSection }
                if let origin { originSection(origin) }
            }
            .padding()
        }
        .opensWordLinks()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItemGroup(placement: .topBarTrailing) { queueButtons } }
        .onAppear { RecentWords.shared.record(word) }
        .overlay(alignment: .bottom) {
            if let confirmation {
                Text(confirmation)
                    .font(.subheadline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thickMaterial, in: Capsule())
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(word.spanish)
                .font(.largeTitle.bold())
            let parts = word.english.components(separatedBy: " — ")
            Text(parts[0])
                .font(.title3)
                .foregroundStyle(.secondary)
            if parts.count > 1 {
                Text(WordLinks.linked(parts.dropFirst().joined(separator: " — ")))
                    .font(.callout)
                    .italic()
                    .tint(.primary)
            }
            if word.spanish.contains(" ") {
                Text(WordLinks.linked(word.spanish))
                    .font(.callout)
                    .tint(.secondary)
                Text("Tap a word to look it up")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            HStack(spacing: 8) {
                if let conjugation {
                    verbTags(conjugation)
                } else {
                    tag(partOfSpeechLabel)
                }
                statusTag
            }
        }
    }

    /// Verbs get a solid "VERB" badge plus what kind of verb it is (-ar/-er/-ir, regular or not, reflexive).
    @ViewBuilder
    private func verbTags(_ conjugation: Conjugation) -> some View {
        let irregular = conjugation.forms != conjugation.regularForms
        Label("VERB", systemImage: "bolt.fill")
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.indigo, in: Capsule())
            .foregroundStyle(.white)
        tag("-\(conjugation.infinitive.suffix(2)) verb", color: .indigo)
        tag(irregular ? "irregular" : "regular", color: irregular ? .orange : .indigo)
        if conjugation.reflexive { tag("reflexive", color: .indigo) }
    }

    private var partOfSpeechLabel: String {
        switch word.gender {
        case "m": "\(word.partOfSpeech.rawValue) · masculine"
        case "f": "\(word.partOfSpeech.rawValue) · feminine"
        default:  word.partOfSpeech.rawValue
        }
    }

    @ViewBuilder
    private var statusTag: some View {
        if progress.priorityDate != nil {
            tag("Next in queue", color: .blue)
        } else if progress.effectivelyLearned {
            tag("Learned", color: .green)
        } else if progress.permanentlySkipped {
            tag("Skipped", color: .red)
        } else if progress.sessionCorrectCount > 0 {
            tag("Learning \(progress.sessionCorrectCount)/\(SeedData.neededSessions)", color: .orange)
        } else if progress.flaggedForRelearn {
            tag("Flagged to learn", color: .orange)
        }
    }

    private func tag(_ text: String, color: Color = .secondary) -> some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    // MARK: - Diminutive

    private func attachedCard(_ match: Clitics.Match) -> some View {
        let readings = match.readings
        return VStack(alignment: .leading, spacing: 6) {
            Text("\(match.typed) = \(match.title)")
                .font(.subheadline.weight(.semibold))
            if let note = match.correctionNote {
                Label { Text(note).font(.footnote) } icon: { Image(systemName: "exclamationmark.triangle") }
                    .foregroundStyle(.orange)
            }
            if let first = readings.first {
                Text("“\(first.english)”").font(.title3)
                ForEach(readings.dropFirst(), id: \.self) { reading in
                    Text("also “\(reading.english)” (\(reading.label))").font(.subheadline)
                }
            }
            if let idiom = match.idiom {
                Label { Text(idiom).font(.footnote) } icon: { Image(systemName: "text.bubble") }
                    .padding(.top, 2)
            }
            Text(match.built)
                .font(.footnote)
            Text(match.rule)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }

    private func diminutiveCard(_ d: Diminutive) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if d.inDictionary {
                // This page is the -ito/-ita word itself: point back to what it is built from.
                Text("From \(d.base.spanish) (\(d.base.english)) + \(d.ending)")
                    .font(.subheadline.weight(.semibold))
                if let meaning = d.meaning {
                    Text("Literally “\(meaning)”.").font(.subheadline)
                }
            } else {
                // User searched an -ito/-ita form; this page is its base word.
                Text("\(d.form) = \(d.base.spanish) + \(d.ending)")
                    .font(.subheadline.weight(.semibold))
                if let meaning = d.meaning {
                    Text("“\(meaning)”\(d.isPlural ? " (plural)" : "")")
                        .font(.subheadline)
                }
            }
            Text(d.explanation)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Actions

    /// Small icon buttons in the top-right corner: move to the front of the queue, flag to learn again.
    @ViewBuilder
    private var queueButtons: some View {
        let inQueue = progress.priorityDate != nil
        let relearning = progress.flaggedForRelearn && !progress.effectivelyLearned

        Button {
            if inQueue {
                store.removeFromQueue(wordID: word.spanish)
                confirm("Removed from the front of the queue")
            } else {
                store.moveToTopOfQueue(wordID: word.spanish)
                confirm("Moved to the top of your next study session")
            }
        } label: {
            Image(systemName: inQueue ? "arrow.up.to.line.circle.fill" : "arrow.up.to.line")
                .foregroundStyle(inQueue ? Color.blue : Color.primary)
        }
        .accessibilityLabel(inQueue ? "Remove from queue" : "Study next")

        Button {
            if relearning || inQueue {
                confirm(inQueue ? "Already first in your queue" : "Already flagged to learn again")
            } else {
                store.flagForRelearning(wordID: word.spanish)
                confirm("Flagged to learn again")
            }
        } label: {
            Image(systemName: relearning || inQueue ? "flag.fill" : "flag")
                .foregroundStyle(relearning || inQueue ? Color.orange : Color.primary)
        }
        .accessibilityLabel("Learn again")
    }

    private func confirm(_ message: String) {
        withAnimation { confirmation = message }
        Task {
            try? await Task.sleep(for: .seconds(2))
            withAnimation { confirmation = nil }
        }
    }

    // MARK: - Content

    private var mexicanCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("🇲🇽")
                Text("In Mexico")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            }
            ForEach(mexicanMeanings, id: \.self) { meaning in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(Lexicon.flagged(meaning.text))
                        .font(.body.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                    if let pos = meaning.partOfSpeech, pos != word.partOfSpeech {
                        Text(pos.rawValue)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private var meaningsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle(!mexicanMeanings.isEmpty ? "Other meanings" : (meanings.count > 1 ? "Meanings" : "Meaning"))
            ForEach(meanings, id: \.self) { meaning in
                VStack(alignment: .leading, spacing: 2) {
                    if meanings.count > 1 {
                        Text(label(for: meaning))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    ForEach(Array(meaning.senses.enumerated()), id: \.offset) { index, sense in
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            if meaning.senses.count > 1 {
                                Text("\(index + 1).")
                                    .font(.footnote.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            Text(Lexicon.flagged(sense.text))
                                .font(.footnote)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    private func label(for meaning: Meaning) -> String {
        switch meaning.gender {
        case "m": "\(meaning.partOfSpeech.rawValue) · masculine"
        case "f": "\(meaning.partOfSpeech.rawValue) · feminine"
        case "mf": "\(meaning.partOfSpeech.rawValue) · masculine or feminine"
        default: meaning.partOfSpeech.rawValue
        }
    }

    private var relatedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Related words")
            VStack(spacing: 0) {
                ForEach(relatedItems) { item in
                    if let linked = item.linked {
                        NavigationLink(value: SearchHit(word: linked, diminutive: nil)) {
                            relatedRow(item, showsChevron: true)
                        }
                        .buttonStyle(.plain)
                    } else {
                        relatedRow(item, showsChevron: false)
                    }
                    if item.id != relatedItems.last?.id { Divider() }
                }
            }
        }
    }

    private func relatedRow(_ item: RelatedItem, showsChevron: Bool) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text(item.text).font(.headline)
                if let english = item.english {
                    Text(english).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
                }
            }
            Spacer()
            Text(item.tag)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 7)
                .padding(.vertical, 2)
                .background(item.color.opacity(0.15), in: Capsule())
                .foregroundStyle(item.color)
            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    private func originSection(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle("Origin")
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func conjugationSection(_ conjugation: Conjugation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Conjugation")
            ConjugationView(conjugation: conjugation, examples: TenseExamples.pool(for: word), gloss: word.english, attached: attached)
        }
    }

    private func phraseSection(_ phrase: PhraseVerb) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Conjugate this phrase")
            ConjugationView(conjugation: phrase.conjugation, phrase: phrase)
        }
    }

    private var usageSentences: [ExampleSentence] {
        var all = sentences.map { ExampleSentence(spanish: $0.full, english: $0.translation) }
        all += wikiExamples.map { ExampleSentence(spanish: $0.spanish, english: $0.english) }
        var seen = Set<String>()
        return all.filter { seen.insert($0.spanish).inserted }
    }

    private var usagesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Usage")
            ForEach(usageSentences, id: \.self) { sentence in
                VStack(alignment: .leading, spacing: 3) {
                    Text(WordLinks.linked(highlighted(sentence.spanish)))
                        .font(.body)
                        .tint(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    if !sentence.english.isEmpty {
                        Text(sentence.english)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }

    /// Bolds the headword, or every conjugated form of a verb, wherever it appears in the sentence.
    private func highlighted(_ sentence: String) -> AttributedString {
        if let conjugation {
            return TenseExamples.highlight(sentence, tokens: Set(TenseExamples.formIndex(conjugation).keys))
        }
        var text = AttributedString(sentence)
        if let range = text.range(of: word.spanish, options: [.caseInsensitive, .diacriticInsensitive]) {
            text[range].font = .body.bold()
        }
        return text
    }
}
