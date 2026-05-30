import SwiftUI

/// "You" tab — the user's own screen time at a glance: today's ring, this
/// week's trend, and the category breakdown they asked for.
struct DashboardView: View {
    @Environment(AppStore.self) private var store
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if let me = store.me {
                    VStack(spacing: 16) {
                        todayCard(for: me)
                        streakCard(for: me)
                        weekCard(for: me)
                        breakdownCard(for: me)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                } else {
                    ProgressView().padding(.top, 80)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let me = store.me { ShareSummarySheet(user: me) }
            }
        }
    }

    private func todayCard(for me: User) -> some View {
        Card {
            VStack(spacing: 16) {
                UsageRing(
                    usedMinutes: me.todayUsage?.totalMinutes ?? 0,
                    goalMinutes: me.dailyGoalMinutes
                )
                .frame(height: 180)
                .padding(.top, 4)

                let used = me.todayUsage?.totalMinutes ?? 0
                let remaining = me.dailyGoalMinutes - used
                Text(remaining >= 0
                     ? "\(remaining.asDuration) left in your budget today"
                     : "\((-remaining).asDuration) over — tomorrow's a fresh start")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func streakCard(for me: User) -> some View {
        HStack(spacing: 12) {
            StatPill(icon: "flame.fill", tint: Theme.warn,
                     value: "\(me.goalStreak)", label: "day streak")
            StatPill(icon: "chart.bar.fill", tint: Theme.accent,
                     value: me.weeklyUsage.averageDailyMinutes.asDuration, label: "daily avg")
            StatPill(icon: "checkmark.seal.fill", tint: Theme.good,
                     value: (me.todayUsage?.productiveMinutes ?? 0).asDuration, label: "well spent")
        }
    }

    private func weekCard(for me: User) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text("This Week")
                    .font(.headline)
                WeeklyTrendChart(usage: me.weeklyUsage, goalMinutes: me.dailyGoalMinutes)
            }
        }
    }

    private func breakdownCard(for me: User) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("Where your time went")
                    .font(.headline)
                CategoryBreakdown(breakdown: me.weeklyUsage.aggregatedBreakdown)
            }
        }
    }
}

/// Small stat chip used in the dashboard summary row.
struct StatPill: View {
    let icon: String
    let tint: Color
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    DashboardView()
        .environment(previewStore())
}
