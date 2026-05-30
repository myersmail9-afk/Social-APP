import SwiftUI

/// Weekly Wrapped — a bold, shareable recap of the user's week. This is the
/// app's growth loop: people post it, friends see it, friends join. Also a
/// re-engagement hook (a reason to come back every week).
struct WeeklyWrappedView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private var me: User { store.me ?? SampleData.me }

    private var avg: Int { me.weeklyUsage.averageDailyMinutes }
    private var best: DailyUsage? { me.weeklyUsage.min(by: { $0.totalMinutes < $1.totalMinutes }) }
    private var daysUnderGoal: Int {
        me.weeklyUsage.filter { $0.totalMinutes <= me.dailyGoalMinutes }.count
    }
    private var topCategory: UsageCategory? {
        me.weeklyUsage.aggregatedBreakdown.first?.category
    }

    private var shareText: String {
        "My week on Offline 📵 — \(avg.asDuration)/day average, \(daysUnderGoal)/7 days under goal, \(store.standing.wins) duels won. Think you can beat me?"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    wrappedCard
                    ShareLink(item: shareText) {
                        Label("Share my Wrapped", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .foregroundStyle(.white)
                    }
                    Text("Posting your Wrapped is how friends find their next rival.")
                        .font(.caption).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Weekly Wrapped")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    /// The shareable hero card — deliberately bold and screenshot-friendly.
    private var wrappedCard: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR WEEK").font(.caption.weight(.bold)).foregroundStyle(.white.opacity(0.7))
                    Text("Wrapped").font(.system(size: 32, weight: .bold, design: .rounded)).foregroundStyle(.white)
                }
                Spacer()
                Avatar(user: me, size: 52)
            }

            VStack(spacing: 14) {
                wrappedStat(value: avg.asDuration, label: "daily average")
                wrappedStat(value: "\(daysUnderGoal)/7", label: "days under goal")
                if let best {
                    wrappedStat(value: best.totalMinutes.asDuration, label: "your best day")
                }
                wrappedStat(value: "\(store.standing.wins)", label: "duels won")
                if let topCategory {
                    wrappedStat(value: topCategory.title, label: "biggest pull")
                }
            }

            Text("OFFLINE 📵")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Theme.accent, Color(hex: 0xFF5C8A)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }

    private func wrappedStat(value: String, label: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    WeeklyWrappedView()
        .environment(previewStore())
}
