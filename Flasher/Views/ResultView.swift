import SwiftUI

struct ResultView: View {
    let card: CardItem
    let result: CardResult
    let userInput: String
    let onNext: () -> Void

    @State private var confirmInput: String = ""
    @FocusState private var confirmFocused: Bool

    private var isCorrect: Bool { result == .correct }

    private var confirmMatches: Bool {
        normalize(confirmInput) == normalize(card.word.spanish)
    }

    var body: some View {
        VStack(spacing: 24) {
            // Outcome banner
            HStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.title2)
                Text(headline)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(bannerColor)
            .padding()
            .frame(maxWidth: .infinity)
            .background(bannerColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)

            // Full sentence + translation
            VStack(spacing: 8) {
                Text("Full sentence:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(card.sentence.full)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Text(card.sentence.translation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal)

            // Correct answer + English
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text("Spanish:")
                        .foregroundStyle(.secondary)
                    Text(card.word.spanish)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                HStack(spacing: 4) {
                    Text("English:")
                        .foregroundStyle(.secondary)
                    Text(card.word.english)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
            }
            .font(.body)

            // What they typed (only if wrong and they typed something)
            if result == .incorrect, !userInput.trimmingCharacters(in: .whitespaces).isEmpty {
                Text("You wrote: \"\(userInput)\"")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // For wrong/revealed: require typing before continuing
            if result == .incorrect || result == .revealed {
                VStack(spacing: 10) {
                    Text("Type the word to continue")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField(card.word.spanish, text: $confirmInput)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($confirmFocused)
                        .onSubmit { if confirmMatches { onNext() } }
                        .padding(.horizontal)

                    Button(action: onNext) {
                        Text("Continue")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(result == .revealed ? .orange : .red)
                    .disabled(!confirmMatches)
                    .padding(.horizontal)
                }
                .onAppear { confirmFocused = true }
            } else {
                Button(action: onNext) {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(isCorrect ? .green : .red)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }

    private func normalize(_ s: String) -> String {
        s.lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var iconName: String {
        switch result {
        case .correct: "checkmark.circle.fill"
        case .incorrect: "xmark.circle.fill"
        case .revealed: "lightbulb.fill"
        }
    }

    private var headline: String {
        switch result {
        case .correct: "Correct!"
        case .incorrect: "Not quite — type it to continue"
        case .revealed: "Word revealed — type it to continue"
        }
    }

    private var bannerColor: Color {
        switch result {
        case .correct: .green
        case .incorrect: .red
        case .revealed: .orange
        }
    }
}
