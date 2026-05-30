import SwiftUI

/// "Profile" tab — your identity, daily goal, and the controls that will host
/// the real Screen Time permission flow and privacy/sharing settings.
struct ProfileView: View {
    @Environment(AppStore.self) private var store
    @State private var goal: Double = 180

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let me = store.me {
                        header(me)
                        goalCard
                        screenTimeCard
                        privacyCard
                    } else {
                        ProgressView().padding(.top, 80)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .onAppear { goal = Double(store.me?.dailyGoalMinutes ?? 180) }
        }
    }

    private func header(_ me: User) -> some View {
        VStack(spacing: 8) {
            Avatar(user: me, size: 80)
            Text(me.name).font(.title2.weight(.bold))
            Text("@\(me.handle)").font(.subheadline).foregroundStyle(.secondary)
            HStack(spacing: 20) {
                stat("\(store.friends.count)", "friends")
                stat("\(me.goalStreak)", "day streak")
                stat(me.weeklyUsage.averageDailyMinutes.asDuration, "daily avg")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private var goalCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Daily goal", systemImage: "target")
                        .font(.headline)
                    Spacer()
                    Text(Int(goal).asDuration)
                        .font(.headline)
                        .foregroundStyle(Theme.accent)
                }
                Slider(value: $goal, in: 30...480, step: 15)
                    .tint(Theme.accent)
                Text("We'll nudge you when you're close, and celebrate when you finish under budget.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var screenTimeCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Label("Screen Time access", systemImage: "hourglass")
                    .font(.headline)
                Text("Currently showing sample data. Connect Apple Screen Time to track your real usage automatically.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button {
                    // Hook up FamilyControls AuthorizationCenter here.
                } label: {
                    Text("Connect Screen Time")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Theme.accentSoft, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundStyle(Theme.accent)
                }
                .padding(.top, 4)
            }
        }
    }

    private var privacyCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Label("Sharing & privacy", systemImage: "lock.fill")
                    .font(.headline)
                row("Share daily summary with friends", isOn: true)
                row("Show category breakdown", isOn: true)
                row("Appear on leaderboard", isOn: true)
            }
        }
    }

    private func row(_ title: String, isOn: Bool) -> some View {
        HStack {
            Text(title).font(.subheadline)
            Spacer()
            // Static for now — wire to per-user privacy settings in the backend.
            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
                .tint(Theme.accent)
        }
    }
}

#Preview {
    ProfileView()
        .environment(previewStore())
}
