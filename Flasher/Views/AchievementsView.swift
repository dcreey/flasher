import SwiftUI

struct AchievementsView: View {
    @Environment(ProgressStore.self) private var store

    private var unlocked: Int { store.unlockedAchievements.count }
    private var total: Int { AchievementMessages.all.count }

    // Group definitions by trigger (nil = random)
    private var byTrigger: [(trigger: AchievementTrigger, defs: [AchievementDefinition])] {
        AchievementTrigger.allCases.map { trigger in
            (trigger, AchievementMessages.all.filter { $0.trigger == trigger })
        }
    }
    private var randomDefs: [AchievementDefinition] {
        AchievementMessages.all.filter { $0.trigger == nil }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(unlocked) of \(total) collected")
                            .font(.headline)
                        ProgressView(value: Double(unlocked), total: Double(total))
                            .tint(.yellow)
                    }
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.yellow)
                }
                .padding(.vertical, 4)
            }

            ForEach(byTrigger, id: \.trigger) { group in
                let groupUnlocked = group.defs.filter { store.unlockedAchievements.contains($0.name) }.count
                Section {
                    ForEach(group.defs) { def in
                        AchievementRow(def: def, isUnlocked: store.unlockedAchievements.contains(def.name))
                    }
                } header: {
                    HStack {
                        Text(group.trigger.displayName)
                        Spacer()
                        Text("\(groupUnlocked)/\(group.defs.count)")
                            .foregroundStyle(.secondary)
                    }
                }
            }

            let randomUnlocked = randomDefs.filter { store.unlockedAchievements.contains($0.name) }.count
            Section {
                ForEach(randomDefs) { def in
                    AchievementRow(def: def, isUnlocked: store.unlockedAchievements.contains(def.name))
                }
            } header: {
                HStack {
                    Text("Encouragement")
                    Spacer()
                    Text("\(randomUnlocked)/\(randomDefs.count)")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.large)
    }
}

private struct AchievementRow: View {
    let def: AchievementDefinition
    let isUnlocked: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: isUnlocked ? "trophy.fill" : "lock.fill")
                .font(.title2)
                .foregroundStyle(isUnlocked ? .yellow : .secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(def.name)
                    .font(.headline)
                    .foregroundStyle(isUnlocked ? .primary : .secondary)

                if isUnlocked {
                    Text(def.flavor)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text("Not yet discovered")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .italic()
                }
            }
        }
        .padding(.vertical, 4)
        .opacity(isUnlocked ? 1 : 0.5)
    }
}
