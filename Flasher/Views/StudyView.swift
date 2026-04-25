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
                    ResultView(card: card, result: result, userInput: vm.userInput) {
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
                        onLearn: { vm.learnWord() }
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
    }
}

struct SessionProgressView: View {
    let done: Int
    let total: Int

    var body: some View {
        VStack(spacing: 4) {
            ProgressView(value: Double(done), total: Double(max(total, 1)))
                .tint(.green)
                .padding(.horizontal)
            Text("\(done) / \(total) words this session")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}
