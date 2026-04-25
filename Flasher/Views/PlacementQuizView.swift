import SwiftUI

struct PlacementQuizView: View {
    @Bindable var vm: PlacementViewModel
    let onComplete: () -> Void
    @FocusState private var inputFocused: Bool

    var body: some View {
        Group {
            if vm.isComplete {
                PlacementFinishedView(placedAtLevel: vm.placedAtLevel, onDone: onComplete)
            } else if let card = vm.currentCard {
                VStack(spacing: 0) {
                    placementHeader
                    Spacer()
                    if vm.isShowingResult {
                        PlacementResultCard(card: card, correct: vm.lastCorrect) {
                            vm.next()
                            if !vm.isComplete { inputFocused = true }
                        }
                        .transition(.opacity)
                    } else {
                        PlacementCardView(
                            card: card,
                            userInput: $vm.userInput,
                            inputFocused: $inputFocused,
                            onSubmit: vm.submit,
                            onDontKnow: vm.dontKnow
                        )
                        .transition(.opacity)
                    }
                    Spacer()
                }
                .animation(.easeInOut(duration: 0.2), value: vm.isShowingResult)
            }
        }
        .navigationTitle("Placement Quiz")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { inputFocused = true }
        .onChange(of: vm.isComplete) { _, complete in
            if complete { /* handled by if vm.isComplete above */ }
        }
    }

    private var placementHeader: some View {
        VStack(spacing: 6) {
            // Overall level progress
            HStack {
                Text("Level \(vm.overallLevel) of 10")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
                Spacer()
                Text("\(vm.missesThisLevel) miss\(vm.missesThisLevel == 1 ? "" : "es") (stop at 3)")
                    .font(.caption)
                    .foregroundStyle(vm.missesThisLevel >= 2 ? .red : .secondary)
            }
            .padding(.horizontal)

            // Within-level progress
            ProgressView(value: Double(vm.levelProgress.current - 1),
                         total: Double(max(vm.levelProgress.total, 1)))
                .tint(.orange)
                .padding(.horizontal)

            Text("Question \(vm.levelProgress.current) of \(vm.levelProgress.total) in this level")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}

// MARK: - Placement card (question)

private struct PlacementCardView: View {
    let card: CardItem
    @Binding var userInput: String
    var inputFocused: FocusState<Bool>.Binding
    let onSubmit: () -> Void
    let onDontKnow: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(card.word.partOfSpeech.rawValue.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.orange.opacity(0.15))
                .foregroundStyle(.orange)
                .clipShape(Capsule())

            SentenceView(template: card.sentence.template)
                .padding(.horizontal)

            VStack(spacing: 4) {
                Text("Missing word in English:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(card.word.english)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.orange.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            TextField("Type in Spanish…", text: $userInput)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused(inputFocused)
                .onSubmit(onSubmit)
                .padding(.horizontal)

            HStack(spacing: 16) {
                Button(action: onDontKnow) {
                    Label("Don't Know", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)

                Button(action: onSubmit) {
                    Label("Check", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

// MARK: - Per-card result

private struct PlacementResultCard: View {
    let card: CardItem
    let correct: Bool
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                Text(correct ? "Correct!" : "Incorrect")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(correct ? .green : .red)
            .padding()
            .frame(maxWidth: .infinity)
            .background((correct ? Color.green : Color.red).opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)

            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text("Spanish:").foregroundStyle(.secondary)
                    Text(card.word.spanish).fontWeight(.bold)
                }
                HStack(spacing: 4) {
                    Text("English:").foregroundStyle(.secondary)
                    Text(card.word.english).fontWeight(.medium)
                }
                Text(card.sentence.full)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
            .font(.body)
            .padding(.horizontal)

            Button("Next", action: onNext)
                .buttonStyle(.borderedProminent)
                .tint(correct ? .green : .red)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
    }
}

// MARK: - Final result

private struct PlacementFinishedView: View {
    let placedAtLevel: Int
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            VStack(spacing: 12) {
                Text("Placement Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if placedAtLevel == 0 {
                    Text("Starting from the very beginning — all words are new to you.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else if placedAtLevel >= 10 {
                    Text("Impressive! You've already mastered all the core vocabulary.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("You placed into **Level \(placedAtLevel + 1) of 10**.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                    Text("The first \(placedAtLevel * 10)% of words have been skipped.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)

            Button("Start Studying", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .font(.headline)
        }
        .padding()
    }
}
