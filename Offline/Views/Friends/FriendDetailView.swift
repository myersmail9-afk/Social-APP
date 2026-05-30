import SwiftUI

/// A friend's shared usage in detail — their ring, week trend, and breakdown.
/// This is what "see your friends' usage by category" looks like.
struct FriendDetailView: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                Card {
                    VStack(spacing: 16) {
                        UsageRing(
                            usedMinutes: user.todayUsage?.totalMinutes ?? 0,
                            goalMinutes: user.dailyGoalMinutes
                        )
                        .frame(height: 170)
                        HStack(spacing: 12) {
                            StatPill(icon: "flame.fill", tint: Theme.warn,
                                     value: "\(user.goalStreak)", label: "streak")
                            StatPill(icon: "chart.bar.fill", tint: Theme.accent,
                                     value: user.weeklyUsage.averageDailyMinutes.asDuration, label: "daily avg")
                        }
                    }
                }
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week").font(.headline)
                        WeeklyTrendChart(usage: user.weeklyUsage, goalMinutes: user.dailyGoalMinutes)
                    }
                }
                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Their categories").font(.headline)
                        CategoryBreakdown(breakdown: user.weeklyUsage.aggregatedBreakdown)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(spacing: 8) {
            Avatar(user: user, size: 72)
            Text(user.name).font(.title3.weight(.bold))
            Text("@\(user.handle)").font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }
}

#Preview {
    NavigationStack {
        FriendDetailView(user: SampleData.friends[0])
    }
}
