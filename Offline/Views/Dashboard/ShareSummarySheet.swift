import SwiftUI

/// A shareable card summarizing the user's day — the unit that gets posted to
/// friends' feeds. Uses the system share sheet for now.
struct ShareSummarySheet: View {
    let user: User
    @Environment(\.dismiss) private var dismiss

    private var shareText: String {
        let used = user.todayUsage?.totalMinutes ?? 0
        let goal = user.dailyGoalMinutes
        let status = used <= goal ? "under my goal ✅" : "over my goal"
        return "My screen time today: \(used.asDuration) — \(status). Tracking less time on Offline 📵"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                summaryCard
                    .padding(.top)

                ShareLink(item: shareText) {
                    Label("Share to feed", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .foregroundStyle(.white)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Share your day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var summaryCard: some View {
        Card {
            VStack(spacing: 16) {
                HStack {
                    Avatar(user: user)
                    VStack(alignment: .leading) {
                        Text(user.name).font(.headline)
                        Text("@\(user.handle)").font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "moon.zzz.fill").foregroundStyle(Theme.accent)
                }
                UsageRing(
                    usedMinutes: user.todayUsage?.totalMinutes ?? 0,
                    goalMinutes: user.dailyGoalMinutes
                )
                .frame(height: 150)
                if let today = user.todayUsage {
                    CategoryBreakdown(breakdown: Array(today.breakdown.prefix(3)))
                }
            }
        }
    }
}

#Preview {
    ShareSummarySheet(user: SampleData.me)
}
