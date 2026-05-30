import SwiftUI

/// "Duels" tab — the competitive heart. Your record and rank up top, live
/// head-to-heads in the middle, and past results below. Tone is competitive
/// and a little rebellious, but never shaming.
struct DuelsView: View {
    @Environment(AppStore.self) private var store
    @State private var showStartDuel = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    StandingCard(standing: store.standing)

                    Button {
                        showStartDuel = true
                    } label: {
                        Label("Start a Duel", systemImage: "bolt.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .foregroundStyle(.white)
                    }

                    if !store.duels.isEmpty {
                        SectionHeader(title: "Live Duels", systemImage: "flame.fill")
                        ForEach(store.duels) { duel in
                            NavigationLink {
                                DuelDetailView(duel: duel)
                            } label: {
                                DuelCard(duel: duel)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        EmptyDuelsPrompt()
                    }

                    if !store.duelHistory.isEmpty {
                        SectionHeader(title: "Past Results", systemImage: "clock.arrow.circlepath")
                        VStack(spacing: 10) {
                            ForEach(store.duelHistory) { duel in
                                DuelHistoryRow(duel: duel)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Duels")
            .sheet(isPresented: $showStartDuel) {
                StartDuelView()
            }
        }
    }
}

// MARK: - Standing (record + rank)

private struct StandingCard: View {
    let standing: DuelStanding

    var body: some View {
        Card {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(standing.tier.uppercased())
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Theme.accent)
                        Text("\(standing.points) pts")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                    }
                    Spacer()
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(Theme.warn)
                }

                if let toNext = standing.pointsToNextTier {
                    Text("\(toNext) pts to the next rank")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Divider()

                HStack {
                    StatColumn(value: "\(standing.wins)", label: "Wins", tint: Theme.good)
                    StatColumn(value: "\(standing.losses)", label: "Losses", tint: .secondary)
                    StatColumn(value: "\(standing.winRatePercent)%", label: "Win rate", tint: Theme.accent)
                    StatColumn(value: "🔥\(standing.currentWinStreak)", label: "Streak", tint: Theme.warn)
                }
            }
        }
    }
}

private struct StatColumn: View {
    let value: String
    let label: String
    let tint: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.headline).foregroundStyle(tint)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Live duel card

private struct DuelCard: View {
    let duel: Duel

    var body: some View {
        Card {
            VStack(spacing: 14) {
                HStack {
                    Avatar(user: duel.opponent, size: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("vs \(duel.opponent.name)").font(.headline)
                        HStack(spacing: 6) {
                            PeriodBadge(period: duel.period)
                            if duel.wasRandomMatch {
                                Text("• random match").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(duel.timeRemainingLabel).font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("+\(duel.pointsAtStake) pts").font(.caption2).foregroundStyle(Theme.accent)
                    }
                }

                ScoreBar(duel: duel)

                if let alert = duel.rivalryAlert {
                    HStack(spacing: 8) {
                        Image(systemName: duel.isWinning ? "checkmark.circle.fill" : "flame.fill")
                            .foregroundStyle(duel.isWinning ? Theme.good : Theme.warn)
                        Text(alert).font(.caption).foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
        }
    }
}

/// The you-vs-them score row, color-coded by who's currently ahead.
struct ScoreBar: View {
    let duel: Duel

    var body: some View {
        HStack {
            side(label: "You", minutes: duel.myMinutes, leading: duel.isWinning)
            Text("vs").font(.caption2.weight(.bold)).foregroundStyle(.secondary)
            side(label: duel.opponent.name.split(separator: " ").first.map(String.init) ?? "Them",
                 minutes: duel.opponentMinutes, leading: !duel.isWinning && !duel.isTied)
        }
    }

    private func side(label: String, minutes: Int, leading: Bool) -> some View {
        VStack(spacing: 2) {
            Text(minutes.asDuration)
                .font(.title3.weight(.bold))
                .foregroundStyle(leading ? Theme.good : .primary)
            Text(label).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(leading ? Theme.good.opacity(0.12) : Color(.tertiarySystemFill))
        )
    }
}

// MARK: - History row

private struct DuelHistoryRow: View {
    let duel: Duel

    private var won: Bool { duel.outcome == .won }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: won ? "checkmark.seal.fill" : (duel.outcome == .tied ? "equal.circle.fill" : "xmark.seal.fill"))
                .foregroundStyle(won ? Theme.good : (duel.outcome == .tied ? .secondary : Theme.over))
            VStack(alignment: .leading, spacing: 2) {
                Text("vs \(duel.opponent.name)").font(.subheadline.weight(.medium))
                Text("\(duel.period.title) • \(duel.myMinutes.asDuration) – \(duel.opponentMinutes.asDuration)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(won ? "+\(duel.pointsAtStake)" : "—")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(won ? Theme.good : .secondary)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemBackground)))
    }
}

// MARK: - Small shared bits

struct PeriodBadge: View {
    let period: Duel.Period
    var body: some View {
        Text(period.title.uppercased())
            .font(.caption2.weight(.bold))
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Theme.accentSoft, in: Capsule())
            .foregroundStyle(Theme.accent)
    }
}

private struct SectionHeader: View {
    let title: String
    let systemImage: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage).foregroundStyle(Theme.accent)
            Text(title).font(.headline)
            Spacer()
        }
        .padding(.top, 4)
    }
}

private struct EmptyDuelsPrompt: View {
    var body: some View {
        Card {
            VStack(spacing: 8) {
                Image(systemName: "bolt.slash.fill").font(.title).foregroundStyle(.secondary)
                Text("No live duels").font(.headline)
                Text("Challenge a friend — or get randomly matched — and put your screen time on the line.")
                    .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    DuelsView()
        .environment(previewStore())
}
