import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var store
    @State private var studyVM: StudyViewModel?
    @State private var placementVM: PlacementViewModel?
    @State private var showStudy = false
    @State private var showPlacement = false
    @State private var showAchievements = false

    private var allWords: [Word] { SeedData.words }
    private var totalWords: Int { allWords.count }
    private var learnedCount: Int { store.learnedCount(in: allWords) }
    private var inProgressCount: Int { store.inProgressCount(in: allWords) }
    private var hasWordsLeft: Bool { learnedCount < totalWords }

    // The level (0–9) the user is actively working in
    private var activeLevel: Int {
        for lvl in 0..<10 {
            if SeedData.wordsInLevel(lvl).contains(where: { !store.isEffectivelyLearned($0.spanish) }) {
                return lvl
            }
        }
        return 9
    }

    private var activeLevelWords: [Word] { SeedData.wordsInLevel(activeLevel) }
    private var activeLevelLearned: Int { activeLevelWords.filter { store.isEffectivelyLearned($0.spanish) }.count }
    private var activeLevelInProgress: Int {
        activeLevelWords.filter {
            let p = store.progressFor($0.spanish)
            return !p.effectivelyLearned && p.sessionCorrectCount > 0
        }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                overallProgressCard
                currentLevelCard
                if inProgressCount > 0 {
                    inProgressCard
                }
                actionsSection
            }
            .padding()
        }
        .navigationTitle("El Pie")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showAchievements = true
                } label: {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(store.unlockedAchievements.isEmpty ? Color.secondary : Color.yellow)
                }
            }
        }
        .navigationDestination(isPresented: $showStudy) {
            if let vm = studyVM { StudyView(vm: vm) }
        }
        .navigationDestination(isPresented: $showPlacement) {
            if let vm = placementVM {
                PlacementQuizView(vm: vm, onComplete: { showPlacement = false })
            }
        }
        .navigationDestination(isPresented: $showAchievements) {
            AchievementsView()
        }
    }

    // MARK: - Overall progress card

    private var overallProgressCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Overall Progress")
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(learnedCount) / \(totalWords) learned")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    if inProgressCount > 0 {
                        Text("\(inProgressCount) in progress")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }

            // Stacked bar: learned (green) + in-progress (orange)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5).fill(Color(.systemFill))
                        .frame(height: 14)
                    // in-progress layer (wider, dimmer)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.orange.opacity(0.45))
                        .frame(width: totalWords == 0 ? 0 :
                               geo.size.width * CGFloat(learnedCount + inProgressCount) / CGFloat(totalWords),
                               height: 14)
                    // learned layer
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.green)
                        .frame(width: totalWords == 0 ? 0 :
                               geo.size.width * CGFloat(learnedCount) / CGFloat(totalWords),
                               height: 14)
                }
            }
            .frame(height: 14)
            .animation(.spring(response: 0.5), value: learnedCount)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Current level card (zoomed 10% band)

    private var currentLevelCard: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Current Level")
                        .font(.headline)
                    Text("Level \(activeLevel + 1) of 10  ·  \(activeLevel * 10)%–\((activeLevel + 1) * 10)%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(activeLevelLearned) / \(activeLevelWords.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // Word-dot bar showing status of each word in this level
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6).fill(Color(.systemFill))
                        .frame(height: 22)

                    // Learned fill (gradient)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing))
                        .frame(width: activeLevelWords.isEmpty ? 0 :
                               geo.size.width * CGFloat(activeLevelLearned) / CGFloat(activeLevelWords.count),
                               height: 22)
                        .animation(.spring(response: 0.5), value: activeLevelLearned)

                    // Per-word dots (only when few enough to be visible)
                    if activeLevelWords.count <= 50 {
                        HStack(spacing: 0) {
                            ForEach(activeLevelWords) { word in
                                let p = store.progressFor(word.spanish)
                                Circle()
                                    .fill(dotColor(for: p))
                                    .frame(width: 7, height: 7)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(width: geo.size.width)
                    }
                }
            }
            .frame(height: 22)

            // Legend
            HStack(spacing: 16) {
                legendDot(.green, "Learned")
                legendDot(.orange, "In progress")
                legendDot(.white.opacity(0.3), "Not started")
                Spacer()
            }
            .font(.caption2)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func dotColor(for progress: WordProgress) -> Color {
        if progress.effectivelyLearned { return .white.opacity(0.7) }
        if progress.sessionCorrectCount > 0 { return .orange.opacity(0.8) }
        return .white.opacity(0.2)
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).foregroundStyle(.secondary)
        }
    }

    // MARK: - In-progress card

    private var inProgressCard: some View {
        let breakdown = store.inProgressBreakdown(in: allWords)
        let needed = SeedData.neededSessions

        return VStack(spacing: 10) {
            HStack {
                Text("Still Learning")
                    .font(.headline)
                Spacer()
                Text("\(inProgressCount) word\(inProgressCount == 1 ? "" : "s")")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            // One row per progress level that has words
            ForEach(1..<needed, id: \.self) { level in
                if let count = breakdown[level], count > 0 {
                    HStack(spacing: 10) {
                        // Progress dots
                        HStack(spacing: 3) {
                            ForEach(0..<needed, id: \.self) { i in
                                Circle()
                                    .fill(i < level ? Color.green : Color(.systemFill))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        Text("\(level)/\(needed) correct")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(count) word\(count == 1 ? "" : "s")")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            if hasWordsLeft {
                Button {
                    studyVM = StudyViewModel()
                    showStudy = true
                } label: {
                    Label("Study Session  (\(StudyViewModel.sessionSize) words)",
                          systemImage: "brain.head.profile")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                // Session info
                Text("Words need \(SeedData.neededSessions) correct sessions to be learned.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                allLearnedBanner
            }

        }
    }

    private var allLearnedBanner: some View {
        VStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.largeTitle)
                .foregroundStyle(.green)
            Text("All \(totalWords) words mastered!")
                .font(.headline)
            Button("Reset & Start Over") { store.resetAll() }
                .buttonStyle(.bordered)
                .tint(.red)
        }
        .padding()
    }
}
