import SwiftUI

/// "Feed" tab — the social heartbeat. Friends' wins, streaks, and shared
/// summaries, with a tap-to-cheer interaction to keep it fun and supportive.
struct FeedView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(store.feed) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Feed")
        }
    }
}

private struct ActivityCard: View {
    @Environment(AppStore.self) private var store
    let activity: Activity
    @State private var didCheer = false

    var body: some View {
        Card {
            HStack(alignment: .top, spacing: 12) {
                Avatar(symbol: activity.userAvatarSymbol,
                       colorHex: activity.userAvatarColorHex, size: 44)

                VStack(alignment: .leading, spacing: 6) {
                    (Text(activity.userName).font(.subheadline.weight(.semibold))
                     + Text(" \(activity.headline)").font(.subheadline))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(activity.date, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Button(action: cheer) {
                        Label("\(activity.cheers)", systemImage: didCheer ? "hands.clap.fill" : "hands.clap")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(didCheer ? Theme.accent : .secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule().fill(didCheer ? Theme.accentSoft : Color(.tertiarySystemFill))
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 2)
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func cheer() {
        guard !didCheer else { return }
        didCheer = true
        Task { await store.cheer(activity) }
    }
}

#Preview {
    FeedView()
        .environment(previewStore())
}
