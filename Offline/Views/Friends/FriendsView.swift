import SwiftUI

/// "Friends" tab — a leaderboard of you + your friends ranked by today's screen
/// time (least first). Tapping a friend opens their detailed breakdown.
struct FriendsView: View {
    @Environment(AppStore.self) private var store
    @State private var showAddFriend = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(store.leaderboard.enumerated()), id: \.element.id) { index, user in
                        NavigationLink {
                            FriendDetailView(user: user)
                        } label: {
                            LeaderboardRow(rank: index + 1, user: user,
                                           isMe: user.id == store.me?.id)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddFriend = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
            .sheet(isPresented: $showAddFriend) {
                AddFriendView()
            }
        }
    }
}

private struct LeaderboardRow: View {
    let rank: Int
    let user: User
    let isMe: Bool

    private var todayMinutes: Int { user.todayUsage?.totalMinutes ?? 0 }
    private var underGoal: Bool { todayMinutes <= user.dailyGoalMinutes }

    var body: some View {
        HStack(spacing: 14) {
            Text("\(rank)")
                .font(.headline.weight(.bold))
                .foregroundStyle(rank <= 3 ? Theme.accent : .secondary)
                .frame(width: 24)

            Avatar(user: user, size: 46)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(isMe ? "You" : user.name).font(.headline)
                    if user.goalStreak >= 3 {
                        Text("🔥\(user.goalStreak)").font(.caption.weight(.semibold))
                    }
                }
                Text("@\(user.handle)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(todayMinutes.asDuration)
                    .font(.headline)
                    .foregroundStyle(underGoal ? Theme.good : Theme.over)
                Text("today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cardCornerRadius, style: .continuous)
                        .strokeBorder(isMe ? Theme.accent.opacity(0.5) : .clear, lineWidth: 2)
                )
        )
    }
}

#Preview {
    FriendsView()
        .environment(previewStore())
}
