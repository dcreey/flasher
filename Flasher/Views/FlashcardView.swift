import SwiftUI

struct FlashcardView: View {
    let card: CardItem
    @Binding var userInput: String
    var inputFocused: FocusState<Bool>.Binding
    let synonymHint: Character?
    let sessionCorrectCount: Int
    let wasIncorrectThisSession: Bool
    let onSubmit: () -> Void
    let onLearn: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Top badge row: POS tag + optional re-review badge
            HStack(spacing: 8) {
                Text(card.word.partOfSpeech.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.teal.opacity(0.15))
                    .foregroundStyle(.teal)
                    .clipShape(Capsule())

                if wasIncorrectThisSession {
                    Label("Re-review", systemImage: "arrow.uturn.left")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.15))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                }

                Spacer()

                // Progress dots: how many sessions correct out of neededSessions
                HStack(spacing: 4) {
                    ForEach(0..<SeedData.neededSessions, id: \.self) { i in
                        Circle()
                            .fill(i < sessionCorrectCount ? Color.green : Color(.systemFill))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .padding(.horizontal)

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
            .background(.blue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)

            // Synonym hint banner
            if let hint = synonymHint {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("That's a synonym — close!")
                            .fontWeight(.semibold)
                        Text("The word we want starts with '\(String(hint).uppercased())'")
                            .font(.caption)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }

            TextField("Type in Spanish…", text: $userInput)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused(inputFocused)
                .onSubmit(onSubmit)
                .padding(.horizontal)

            // Sentence translation
            if !card.sentence.translation.isEmpty {
                Text(card.sentence.translation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            HStack(spacing: 16) {
                Button(action: onLearn) {
                    Label("Learn Word", systemImage: "lightbulb")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.orange)

                Button(action: onSubmit) {
                    Label("Check", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .animation(.spring(response: 0.3), value: synonymHint != nil)
    }
}

struct SentenceView: View {
    let template: String

    var body: some View {
        Text(attributedSentence)
            .frame(maxWidth: .infinity, alignment: .center)
            .multilineTextAlignment(.center)
    }

    private var attributedSentence: AttributedString {
        let parts = template.components(separatedBy: "___")
        guard parts.count == 2 else { return AttributedString(template) }

        var result = AttributedString(parts[0])
        result.font = .title3

        var blank = AttributedString("_____")
        blank.font = .title3.bold()
        blank.foregroundColor = .accentColor

        var after = AttributedString(parts[1])
        after.font = .title3

        return result + blank + after
    }
}
