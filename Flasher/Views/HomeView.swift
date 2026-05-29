import SwiftUI

struct HomeView: View {
    @Environment(ProgressStore.self) private var store
    @State private var studyVM: StudyViewModel?
    @State private var placementVM: PlacementViewModel?
    @State private var showStudy = false
    @State private var showPlacement = false
    @State private var showAchievements = false
    @State private var showReview = false
    @State private var showRaptorRoom = false

    private static let mongoIcon: UIImage = {
        let size = CGSize(width: 28, height: 28)
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { _ in
            ("🦖" as NSString).draw(
                at: CGPoint(x: 0, y: 1),
                withAttributes: [.font: UIFont.systemFont(ofSize: 24)]
            )
        }
        return img.withRenderingMode(.alwaysTemplate)
    }()

    private var allWords: [Word] { SeedData.words }
    private var totalWords: Int { allWords.count }
    private var learnedCount: Int { store.learnedCount(in: allWords) }
    private var inProgressCount: Int { store.inProgressCount(in: allWords) }
    private var skippedCount: Int { store.skippedCount(in: allWords) }
    private var learnableTotal: Int { totalWords - skippedCount }
    private var hasWordsLeft: Bool {
        allWords.contains(where: { !store.isEffectivelyLearned($0.spanish) && !store.isPermanentlySkipped($0.spanish) })
    }

    // The level (0–9) the user is actively working in
    private var activeLevel: Int {
        for lvl in 0..<10 {
            if SeedData.wordsInLevel(lvl).contains(where: {
                !store.isEffectivelyLearned($0.spanish) && !store.isPermanentlySkipped($0.spanish)
            }) {
                return lvl
            }
        }
        return 9
    }

    private var activeLevelWords: [Word] { SeedData.wordsInLevel(activeLevel) }
    private var activeLevelLearned: Int { activeLevelWords.filter { store.isEffectivelyLearned($0.spanish) }.count }
    private var activeLevelSkipped: Int { activeLevelWords.filter { store.isPermanentlySkipped($0.spanish) }.count }
    private var activeLevelLearnable: Int { activeLevelWords.count - activeLevelSkipped }
    private var activeLevelInProgress: Int {
        activeLevelWords.filter {
            let p = store.progressFor($0.spanish)
            return !p.permanentlySkipped && !p.effectivelyLearned && p.sessionCorrectCount > 0
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
                HStack(spacing: 4) {
                    Button { showRaptorRoom = true } label: {
                        Image(uiImage: Self.mongoIcon)
                            .foregroundStyle(.blue)
                            .accessibilityLabel("Mongo's Room")
                    }
                    Button { showAchievements = true } label: {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(store.unlockedAchievements.isEmpty ? Color.secondary : Color.yellow)
                    }
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
        .navigationDestination(isPresented: $showReview) {
            ReviewView()
        }
        .navigationDestination(isPresented: $showRaptorRoom) {
            RaptorRoomView()
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
                    Text("\(learnedCount) / \(learnableTotal) learned")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    if inProgressCount > 0 {
                        Text("\(inProgressCount) in progress")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    if skippedCount > 0 {
                        Text("\(skippedCount) skipped")
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }
            }

            // Segmented bar: [learned][in-progress][remaining][skipped]
            GeometryReader { geo in
                let total = CGFloat(max(totalWords, 1))
                let greenW   = geo.size.width * CGFloat(learnedCount) / total
                let orangeW  = geo.size.width * CGFloat(inProgressCount) / total
                let redW     = geo.size.width * CGFloat(skippedCount) / total
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5).fill(Color(.systemFill)).frame(height: 14)
                    if skippedCount > 0 {
                        HStack {
                            Spacer()
                            Color.red.opacity(0.45).frame(width: redW, height: 14)
                        }
                    }
                    if learnedCount > 0 || inProgressCount > 0 {
                        HStack(spacing: 0) {
                            Color.green.frame(width: greenW, height: 14)
                            Color.orange.frame(width: orangeW, height: 14)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                }
            }
            .frame(height: 14)
            .animation(.spring(response: 0.5), value: learnedCount)
            .animation(.spring(response: 0.5), value: inProgressCount)
            .animation(.spring(response: 0.5), value: skippedCount)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture { showReview = true }
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
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(activeLevelLearned) / \(activeLevelLearnable)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    if activeLevelSkipped > 0 {
                        Text("\(activeLevelSkipped) skipped")
                            .font(.caption)
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }
            }

            // Word-dot bar showing status of each word in this level
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    let total = CGFloat(max(activeLevelWords.count, 1))
                    let learnedW  = geo.size.width * CGFloat(activeLevelLearned) / total
                    let inProgW   = geo.size.width * CGFloat(inProgressCount) / total
                    let skippedW  = geo.size.width * CGFloat(activeLevelSkipped) / total

                    // Gray background
                    RoundedRectangle(cornerRadius: 6).fill(Color(.systemFill)).frame(height: 22)

                    // Skipped fill (red from right)
                    if activeLevelSkipped > 0 {
                        HStack {
                            Spacer()
                            Color.red.opacity(0.35).frame(width: skippedW, height: 22)
                        }
                        .animation(.spring(response: 0.5), value: skippedW)
                    }

                    // Learned (blue/teal) + in-progress (orange) from left
                    if activeLevelLearned > 0 || inProgressCount > 0 {
                        HStack(spacing: 0) {
                            LinearGradient(colors: [.blue, .teal], startPoint: .leading, endPoint: .trailing)
                                .frame(width: learnedW, height: 22)
                            Color.orange.frame(width: inProgW, height: 22)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .animation(.spring(response: 0.5), value: learnedW)
                        .animation(.spring(response: 0.5), value: inProgW)
                    }

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
                legendDot(.teal, "Learned")
                legendDot(.orange, "In progress")
                legendDot(Color(.systemFill), "Not started")
                legendDot(.red.opacity(0.5), "Skipped")
                Spacer()
            }
            .font(.caption2)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func dotColor(for progress: WordProgress) -> Color {
        if progress.permanentlySkipped { return .red.opacity(0.5) }
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
        .onTapGesture { showReview = true }
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
