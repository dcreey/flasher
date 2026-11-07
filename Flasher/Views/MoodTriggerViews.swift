import SwiftUI

/// A small label for what a word does to the mood after it: "+ subjunctive", "subjunctive with no"…
struct MoodTriggerTag: View {
    let behavior: MoodTrigger.Behavior
    var body: some View {
        Text(behavior.tag)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .overlay(Capsule().strokeBorder(behavior.color.opacity(0.6), lineWidth: 1))
            .foregroundStyle(behavior.color)
    }
}

/// The word page's card: what the word does to the mood, with an example in each mood it takes.
struct MoodTriggerCard: View {
    let triggers: [MoodTrigger]
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Indicative or subjunctive").font(.headline)
            ForEach(triggers) { MoodTriggerSummary(trigger: $0) }
        }
    }
}

/// One trigger written out: phrase, tag, rule and examples.
struct MoodTriggerSummary: View {
    let trigger: MoodTrigger
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trigger.phrase).font(.body.weight(.semibold))
                MoodTriggerTag(behavior: trigger.behavior)
            }
            Text(trigger.rule).font(.subheadline).foregroundStyle(.secondary)
            if let ind = trigger.indicative { example("Indicative", ind) }
            if let subj = trigger.subjunctive { example("Subjunctive", subj) }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(trigger.behavior.color.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
    }

    private func example(_ label: String, _ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(label).font(.caption.weight(.semibold)).foregroundStyle(.secondary).frame(width: 82, alignment: .leading)
            Text(text).font(.subheadline).italic()
        }
    }
}

/// Every word and phrase that decides the mood, grouped by what it does, with a filter for each kind.
struct TriggerWordsView: View {
    @State private var filter: MoodTrigger.Behavior?
    @State private var search = ""

    private var shown: [MoodTrigger] {
        let key = search.searchKey
        return MoodTriggers.all.filter { trigger in
            (filter == nil || trigger.behavior == filter)
                && (key.isEmpty || trigger.phrase.searchKey.contains(key) || trigger.english.searchKey.contains(key))
        }
    }

    var body: some View {
        List {
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        chip("All", color: .secondary, selected: filter == nil) { filter = nil }
                        ForEach(MoodTrigger.Behavior.allCases) { b in
                            chip(b.tag, color: b.color, selected: filter == b) { filter = filter == b ? nil : b }
                        }
                    }
                    .padding(.vertical, 2)
                }
                .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .listRowBackground(Color.clear)
            }
            ForEach(MoodTrigger.Behavior.allCases) { behavior in
                let group = shown.filter { $0.behavior == behavior }
                if !group.isEmpty {
                    Section {
                        ForEach(group) { trigger in
                            NavigationLink { TriggerDetailView(trigger: trigger) } label: { row(trigger) }
                        }
                    } header: {
                        Text(behavior.title).foregroundStyle(behavior.color)
                    } footer: {
                        Text(behavior.explanation)
                    }
                }
            }
        }
        .overlay { if shown.isEmpty { ContentUnavailableView.search(text: search) } }
        .searchable(text: $search, prompt: "Find a word")
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .navigationTitle("Trigger words")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ trigger: MoodTrigger) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(trigger.phrase).font(.body.weight(.semibold))
            Text(trigger.english).font(.subheadline).foregroundStyle(.secondary)
        }
    }

    private func chip(_ title: String, color: Color, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(selected ? color.opacity(0.18) : Color(.secondarySystemGroupedBackground), in: Capsule())
                .foregroundStyle(selected ? color : .primary)
        }
        .buttonStyle(.plain)
    }
}

/// One trigger with its rule, examples and a way to practise the step that teaches it.
private struct TriggerDetailView: View {
    let trigger: MoodTrigger
    @State private var round: MoodRoundSetup?
    private var progress: MoodMapProgress { .shared }

    var body: some View {
        let step = MoodMap.byID[trigger.node]
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(trigger.phrase).font(.title2.weight(.bold))
                Text(trigger.english).foregroundStyle(.secondary)
                MoodTriggerSummary(trigger: trigger)
                Text(trigger.behavior.explanation).font(.footnote).foregroundStyle(.secondary)
                if let step {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Taught in").font(.caption.weight(.semibold)).foregroundStyle(.purple).textCase(.uppercase)
                        Text(step.title).font(.body.weight(.semibold))
                        Text(step.rule).font(.subheadline).foregroundStyle(.secondary)
                        if progress.unlocked(step) {
                            Button { round = MoodRoundSetup(focus: step.id) } label: {
                                Text("Practice this").font(.headline).frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .background(Color.purple, in: RoundedRectangle(cornerRadius: 12)).foregroundStyle(.white)
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        } else {
                            Text("Opens as you work through the Learn course").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $round) { MoodSessionView(setup: $0) }
    }
}
