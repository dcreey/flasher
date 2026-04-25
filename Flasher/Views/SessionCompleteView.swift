import SwiftUI

struct SessionCompleteView: View {
    let done: Int
    let total: Int
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            VStack(spacing: 8) {
                Text("Session Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("\(done) of \(total) words resolved.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Button("Done", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .font(.title3)
        }
        .padding()
    }
}
