import SwiftUI

struct StudyView: View {
    @Bindable var vm: StudyViewModel
    @FocusState private var inputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SessionProgressView(done: vm.sessionProgress.done, total: vm.sessionProgress.total)

            Spacer()

            if vm.sessionComplete {
                SessionCompleteView(
                    done: vm.sessionProgress.done,
                    total: vm.sessionProgress.total,
                    onDone: { dismiss() }
                )
            } else if let card = vm.currentCard {
                if vm.isShowingResult, let result = vm.lastResult {
                    ResultView(card: card, result: result, userInput: vm.userInput, achievementShowing: vm.pendingAchievement != nil) {
                        vm.next()
                        inputFocused = true
                    }
                    .transition(.opacity)
                } else {
                    FlashcardView(
                        card: card,
                        userInput: $vm.userInput,
                        inputFocused: $inputFocused,
                        synonymHint: vm.synonymHint,
                        sessionCorrectCount: vm.currentCardSessionCorrectCount,
                        wasIncorrectThisSession: vm.currentCardWasIncorrectThisSession,
                        onSubmit: { vm.submit() },
                        onLearn: { vm.learnWord() },
                        onSkip: { vm.skipWord() }
                    )
                    .transition(.opacity)
                }
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: vm.isShowingResult)
        .animation(.easeInOut(duration: 0.2), value: vm.sessionComplete)
        .navigationTitle("Study Session")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { inputFocused = true }
        .overlay {
            if vm.pendingAchievement != nil {
                AchievementToastView(toast: vm.pendingAchievement!) {
                    vm.pendingAchievement = nil
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.pendingAchievement != nil)
        .onChange(of: vm.pendingAchievement != nil) { _, isShowing in
            if isShowing {
                inputFocused = false
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

struct SessionProgressView: View {
    let done: Int
    let total: Int

    private var fraction: Double { min(1, Double(done) / Double(max(total, 1))) }

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemFill))
                    Capsule()
                        .fill(Color.green)
                        .frame(width: max(fraction > 0 ? 8 : 0, geo.size.width * fraction))
                }
            }
            .frame(height: 8)
            .animation(.easeInOut(duration: 0.3), value: fraction)
            .padding(.horizontal)
            Text("\(done) of \(total) words")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}
