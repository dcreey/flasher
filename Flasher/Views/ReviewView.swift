import SwiftUI

struct ReviewView: View {
    @Environment(ProgressStore.self) private var store

    @State private var filter: Filter = .learning
    @State private var searchText: String = ""
    @State private var displayCount: Int = 50
    @State private var expandedIDs: Set<String> = []

    private let pageSize = 50

    enum Filter: String, CaseIterable, Identifiable {
        case learning    = "Learning"
        case learned     = "Learned"
        case alreadyKnow = "Already Know"
        var id: String { rawValue }
    }

    private var allWords: [Word] { SeedData.words }

    private var filteredWords: [(word: Word, progress: WordProgress)] {
        allWords.compactMap { word in
            let p = store.progressFor(word.spanish)
            let hasStruggled = p.totalWrongCount > 0 || p.learnWordCount > 0
            let matchesFilter: Bool = {
                switch filter {
                case .learning:    return hasStruggled && !p.effectivelyLearned
                case .learned:     return hasStruggled && p.effectivelyLearned
                case .alreadyKnow: return p.effectivelyLearned && !hasStruggled
                }
            }()
            guard matchesFilter else { return nil }
            if !searchText.isEmpty {
                let q = searchText.lowercased()
                guard word.spanish.lowercased().contains(q) || word.english.lowercased().contains(q)
                else { return nil }
            }
            return (word, p)
        }
    }

    private var sortedWords: [(word: Word, progress: WordProgress)] {
        filteredWords.sorted { a, b in
            let da = a.progress.lastReviewDate
            let db = b.progress.lastReviewDate
            if da != db { return da > db }
            return a.word.order < b.word.order
        }
    }

    private var displayedWords: [(word: Word, progress: WordProgress)] {
        Array(sortedWords.prefix(displayCount))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Controls
            VStack(spacing: 8) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Filter.allCases) { f in
                            Button {
                                filter = f
                                displayCount = pageSize
                            } label: {
                                Text(f.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(filter == f ? Color.accentColor : Color(.secondarySystemFill))
                                    .foregroundStyle(filter == f ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }

            }
            .padding(.vertical, 8)
            .background(.regularMaterial)

            if sortedWords.isEmpty {
                ContentUnavailableView(
                    "No words yet",
                    systemImage: "checkmark.seal",
                    description: Text("Words you encounter will appear here.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                        Section {
                            ForEach(displayedWords, id: \.word.spanish) { item in
                                ReviewRow(
                                    word: item.word,
                                    progress: item.progress,
                                    sentences: SeedData.sentencesByWord[item.word.spanish] ?? [],
                                    isExpanded: expandedIDs.contains(item.word.spanish)
                                ) {
                                    withAnimation(.easeInOut(duration: 0.22)) {
                                        if expandedIDs.contains(item.word.spanish) {
                                            expandedIDs.remove(item.word.spanish)
                                        } else {
                                            expandedIDs.insert(item.word.spanish)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                                Divider().padding(.horizontal)
                            }

                            if displayCount < sortedWords.count {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .onAppear { displayCount += pageSize }
                            }
                        } header: {
                            Text("\(sortedWords.count) word\(sortedWords.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(.regularMaterial)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Spanish or English")
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: filter)     { displayCount = pageSize }
        .onChange(of: searchText) { displayCount = pageSize }
    }
}

private struct ReviewRow: View {
    let word: Word
    let progress: WordProgress
    let sentences: [VocabSentence]
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header row
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(word.spanish)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Spacer()
                        if progress.lastReviewDate != .distantPast {
                            Text(relativeDate)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Text(word.english)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 10) {
                        if progress.totalWrongCount > 0 {
                            Label("\(progress.totalWrongCount) wrong", systemImage: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        if progress.learnWordCount > 0 {
                            Label("\(progress.learnWordCount) revealed", systemImage: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        if progress.effectivelyLearned {
                            Text("Learned")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        } else if progress.sessionCorrectCount > 0 {
                            Text("\(progress.sessionCorrectCount)/\(SeedData.neededSessions)")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.15))
                                .foregroundStyle(.orange)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            // Expandable sentences
            if isExpanded && !sentences.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(sentences.indices, id: \.self) { i in
                        VStack(alignment: .leading, spacing: 3) {
                            Text(sentences[i].full)
                                .font(.callout)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(sentences[i].translation)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 4)
    }

    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: progress.lastReviewDate, relativeTo: Date())
    }
}
