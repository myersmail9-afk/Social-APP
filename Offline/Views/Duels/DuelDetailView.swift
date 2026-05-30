import SwiftUI

/// Full head-to-head view for a single duel: the score, time progress, your
/// improvement vs. your own baseline, and motivating rivalry framing.
struct DuelDetailView: View {
    let duel: Duel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Card {
                    VStack(spacing: 16) {
                        HStack {
                            PeriodBadge(period: duel.period)
                            Spacer()
                            Text(duel.timeRemainingLabel)
                                .font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                        }
                        ScoreBar(duel: duel)
                        ProgressView(value: duel.timeProgress)
                            .tint(Theme.accent)
                        if duel.hasStakes {
                            Label("\(duel.pot)-coin pot · +\(duel.pointsAtStake) pts if you win",
                                  systemImage: "circle.hexagongrid.fill")
                                .font(.caption).foregroundStyle(Theme.warn)
                        } else {
                            Text("+\(duel.pointsAtStake) points if you win")
                                .font(.caption).foregroundStyle(Theme.accent)
                        }
                    }
                }

                if let alert = duel.rivalryAlert {
                    Card {
                        HStack(spacing: 10) {
                            Image(systemName: duel.isWinning ? "checkmark.circle.fill" : "flame.fill")
                                .font(.title3)
                                .foregroundStyle(duel.isWinning ? Theme.good : Theme.warn)
                            Text(alert).font(.subheadline)
                            Spacer()
                        }
                    }
                }

                if let improvement = duel.improvementPercent {
                    Card {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Your progress").font(.headline)
                            if improvement > 0 {
                                Text("You're down \(improvement)% vs. your usual — win or lose, that's a real win. 💪")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            } else {
                                Text("Steady so far. A quieter evening and you'll pull ahead. 🔥")
                                    .font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("vs \(duel.opponent.name)")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DuelDetailView(duel: SampleData.activeDuels(friends: SampleData.friends)[0])
    }
}
