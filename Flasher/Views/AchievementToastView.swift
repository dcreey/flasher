import SwiftUI

struct AchievementToastView: View {
    let toast: AchievementToast
    let onDismiss: () -> Void

    @State private var appeared = false
    @State private var sparkle = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 28) {
                ZStack {
                    ForEach(0..<8, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: CGFloat.random(in: 10...20)))
                            .foregroundStyle(.yellow.opacity(0.7))
                            .offset(
                                x: sparkle ? cos(Double(i) / 8 * .pi * 2) * 80 : 0,
                                y: sparkle ? sin(Double(i) / 8 * .pi * 2) * 80 : 0
                            )
                            .opacity(sparkle ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.5)
                                    .delay(Double(i) * 0.04),
                                value: sparkle
                            )
                    }

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.yellow)
                        .shadow(color: .yellow.opacity(0.6), radius: 20)
                        .scaleEffect(appeared ? 1 : 0.3)
                        .animation(.spring(response: 0.5, dampingFraction: 0.55), value: appeared)
                }
                .frame(height: 160)

                VStack(spacing: 4) {
                    Text("Achievement Unlocked")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .tracking(2)
                        .foregroundStyle(.yellow.opacity(0.8))
                        .textCase(.uppercase)
                        .opacity(appeared ? 1 : 0)
                        .animation(.easeOut(duration: 0.4).delay(0.2), value: appeared)

                    Text(toast.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                        .animation(.easeOut(duration: 0.4).delay(0.3), value: appeared)
                }

                Text(toast.flavor)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.easeOut(duration: 0.4).delay(0.45), value: appeared)

                Spacer()

                Text("Tap anywhere to continue")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.4).delay(0.7), value: appeared)
            }
            .padding(.top, 80)
            .padding(.bottom, 40)
        }
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                sparkle = true
            }
        }
    }
}
