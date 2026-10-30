import SwiftUI

struct WordDetailView: View {
    @Environment(ProgressStore.self) private var store
    let word: Word
    /// Set when the user searched for an -ito/-ita form of this word; otherwise resolved from the word itself.
    var diminutive: Diminutive?

    @State private var confirmation: String?

    private var progress: WordProgress { store.progressFor(word.spanish) }
    private var sentences: [VocabSentence] { SeedData.sentencesByWord[word.spanish] ?? [] }
    private var shownDiminutive: Diminutive? { diminutive ?? DiminutiveResolver.resolve(word.spanish) }
    private var synonyms: [String] { SeedData.synonyms[word.spanish]?.sorted() ?? [] }
    private var conjugation: Conjugation? { word.partOfSpeech == .infinitive ? Conjugator.conjugate(word.spanish) : nil }
    private var relatedWords: [Word] { RelatedForms.find(for: word) }
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
                if let shownDiminutive { diminutiveCard(shownDiminutive) }
                actions
                if !mexicanMeanings.isEmpty { mexicanCard }
                if showsMeanings { meaningsSection }
                if !relatedWords.isEmpty { relatedSection }
                if let conjugation { conjugationSection(conjugation) }
                if !synonyms.isEmpty { synonymsSection }
                if !sentences.isEmpty { usagesSection }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
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
            Text(word.english)
                .font(.title3)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                tag(partOfSpeechLabel)
                statusTag
            }
        }
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

    private var actions: some View {
        let inQueue = progress.priorityDate != nil
        let alreadyRelearning = progress.flaggedForRelearn && !progress.effectivelyLearned

        return VStack(spacing: 10) {
            if inQueue {
                queueBanner("Already in your queue", detail: "First card in your next study session.", icon: "checkmark.circle.fill")
                Button {
                    store.removeFromQueue(wordID: word.spanish)
                    confirm("Removed from the front of the queue")
                } label: {
                    Label("Remove from queue", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    store.moveToTopOfQueue(wordID: word.spanish)
                    confirm("Moved to the top of your next study session")
                } label: {
                    Label("Study next", systemImage: "arrow.up.to.line")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }

            if !inQueue && alreadyRelearning {
                queueBanner("Flagged to learn again", detail: "It will come up in your normal study sessions.", icon: "flag.fill")
            }

            if !inQueue && !alreadyRelearning {
                Button {
                    store.flagForRelearning(wordID: word.spanish)
                    confirm("Flagged to learn again")
                } label: {
                    Label("Learn again", systemImage: "flag")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .controlSize(.large)
    }

    private func queueBanner(_ title: String, detail: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold))
                Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
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
                    Text(meaning.text)
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
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(!mexicanMeanings.isEmpty ? "Other meanings" : (meanings.count > 1 ? "Meanings" : "Meaning"))
            ForEach(meanings, id: \.self) { meaning in
                VStack(alignment: .leading, spacing: 6) {
                    if meanings.count > 1 {
                        Text(label(for: meaning))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    ForEach(Array(meaning.senses.enumerated()), id: \.offset) { index, sense in
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            if meaning.senses.count > 1 {
                                Text("\(index + 1).")
                                    .font(.body.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            Text(sense.text)
                                .font(.body)
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
                ForEach(relatedWords) { related in
                    NavigationLink(value: SearchHit(word: related, diminutive: nil)) {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 1) {
                                Text(related.spanish)
                                    .font(.headline)
                                Text(related.english)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(related.partOfSpeech.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if related.id != relatedWords.last?.id { Divider() }
                }
            }
        }
    }

    private func conjugationSection(_ conjugation: Conjugation) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle("Conjugation")
            ConjugationView(conjugation: conjugation)
        }
    }

    private var synonymsSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionTitle("Similar words")
            Text(synonyms.joined(separator: ", "))
                .font(.body)
        }
    }

    private var usagesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Usage")
            ForEach(sentences) { sentence in
                VStack(alignment: .leading, spacing: 3) {
                    Text(highlighted(sentence.full))
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(sentence.translation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
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

    /// Bolds the headword when it appears verbatim; conjugated forms are left as plain text.
    private func highlighted(_ sentence: String) -> AttributedString {
        var text = AttributedString(sentence)
        if let range = text.range(of: word.spanish, options: [.caseInsensitive, .diacriticInsensitive]) {
            text[range].font = .body.bold()
        }
        return text
    }
}
