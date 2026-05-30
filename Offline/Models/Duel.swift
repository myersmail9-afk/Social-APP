import Foundation

/// A head-to-head screen-time duel between you and one opponent over a fixed
/// window. Lowest total screen time wins. The competitive heart of the app —
/// but framed to motivate, never to shame.
struct Duel: Identifiable, Codable, Hashable {

    /// How long a duel runs. Longer commitments are worth more points.
    enum Period: String, Codable, CaseIterable, Identifiable {
        case day, week, month, year
        var id: String { rawValue }

        var title: String {
            switch self {
            case .day: return "Day"
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            }
        }

        /// Points awarded for a win. Bigger commitment, bigger reward.
        var points: Int {
            switch self {
            case .day: return 10
            case .week: return 50
            case .month: return 250
            case .year: return 1500
            }
        }

        var calendarComponent: Calendar.Component {
            switch self {
            case .day: return .day
            case .week: return .weekOfYear
            case .month: return .month
            case .year: return .year
            }
        }

        var tagline: String {
            switch self {
            case .day: return "Quick, scrappy, winner by midnight."
            case .week: return "The classic. Seven days to prove it."
            case .month: return "A real test of willpower."
            case .year: return "Legends only."
            }
        }
    }

    /// Where a duel stands once the clock runs out.
    enum Outcome: String, Codable { case pending, won, lost, tied }

    var id: UUID = UUID()
    /// Snapshot of the opponent (denormalized so the duel renders offline).
    var opponent: User
    var period: Period
    var startDate: Date
    var endDate: Date
    /// Total screen-time minutes accrued in the duel window so far.
    var myMinutes: Int
    var opponentMinutes: Int
    /// True if you were auto-matched rather than hand-picking a rival.
    var wasRandomMatch: Bool
    /// Your typical minutes for a window this size, before the duel — the
    /// baseline we measure improvement against.
    var myBaselineMinutes: Int

    // MARK: - Status

    var isActive: Bool { Date() < endDate }
    var isFinished: Bool { !isActive }

    /// How the duel resolves. While active, who's currently ahead.
    var outcome: Outcome {
        if myMinutes < opponentMinutes { return isActive ? .pending : .won }
        if myMinutes > opponentMinutes { return isActive ? .pending : .lost }
        return isActive ? .pending : .tied
    }

    /// Whether you're currently ahead (lower screen time).
    var isWinning: Bool { myMinutes < opponentMinutes }
    var isTied: Bool { myMinutes == opponentMinutes }

    /// The gap between you and your rival, in minutes.
    var marginMinutes: Int { abs(myMinutes - opponentMinutes) }

    /// Points you'd earn (or earned) for winning this duel.
    var pointsAtStake: Int { period.points }

    /// How far through the duel window we are, 0...1.
    var timeProgress: Double {
        let total = endDate.timeIntervalSince(startDate)
        guard total > 0 else { return 1 }
        let elapsed = Date().timeIntervalSince(startDate)
        return min(max(elapsed / total, 0), 1)
    }

    /// Improvement vs. your own baseline, as a percentage drop (positive = better).
    /// Lets you "win" against your past self even if you're losing the duel.
    var improvementPercent: Int? {
        guard myBaselineMinutes > 0 else { return nil }
        let drop = Double(myBaselineMinutes - myMinutes) / Double(myBaselineMinutes) * 100
        return Int(drop.rounded())
    }

    /// A short, motivating rivalry line. Competitive when you're ahead,
    /// encouraging (never shaming) when you're behind.
    var rivalryAlert: String? {
        guard isActive else { return nil }
        let firstName = opponent.name.split(separator: " ").first.map(String.init) ?? opponent.name
        if isTied {
            return "Dead heat with \(firstName). Next move decides it."
        }
        if isWinning {
            if marginMinutes <= 20 {
                return "\(firstName) is only \(marginMinutes.asDuration) behind — don't slip now."
            }
            return "You're \(marginMinutes.asDuration) ahead of \(firstName). Keep it up. 😤"
        } else {
            if marginMinutes <= 30 {
                return "So close — \(marginMinutes.asDuration) behind \(firstName). One quiet evening flips this. 🔥"
            }
            return "\(marginMinutes.asDuration) behind \(firstName). Comeback starts now."
        }
    }

    /// A human label for time left, e.g. "3 days left" / "Final hours".
    var timeRemainingLabel: String {
        guard isActive else { return "Finished" }
        let seconds = endDate.timeIntervalSince(Date())
        let hours = Int(seconds / 3600)
        if hours < 1 { return "Final minutes" }
        if hours < 24 { return hours == 1 ? "1 hour left" : "\(hours) hours left" }
        let days = hours / 24
        return days == 1 ? "1 day left" : "\(days) days left"
    }
}

/// Your overall duel career: record, points, streaks, and a fun rank tier.
struct DuelStanding: Codable, Hashable {
    var wins: Int = 0
    var losses: Int = 0
    var ties: Int = 0
    var points: Int = 0
    var currentWinStreak: Int = 0
    var bestWinStreak: Int = 0

    var totalDuels: Int { wins + losses + ties }

    var winRate: Double {
        guard totalDuels > 0 else { return 0 }
        return Double(wins) / Double(totalDuels)
    }

    var winRatePercent: Int { Int((winRate * 100).rounded()) }

    /// A gamified, slightly rebellious rank earned through points.
    var tier: String {
        switch points {
        case ..<100: return "Rookie"
        case ..<500: return "Challenger"
        case ..<1500: return "Contender"
        case ..<4000: return "Pro"
        default: return "Legend"
        }
    }

    /// Points needed to reach the next tier (nil if maxed out).
    var pointsToNextTier: Int? {
        let thresholds = [100, 500, 1500, 4000]
        return thresholds.first(where: { $0 > points }).map { $0 - points }
    }

    static let empty = DuelStanding()
}
