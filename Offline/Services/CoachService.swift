import Foundation

/// The seam for coaching intelligence. Today `MockCoachService` generates
/// insights from local heuristics; tomorrow a real implementation can call the
/// Claude API to produce personalized, conversational coaching — without any
/// UI changes. Keep all "AI" behind this protocol.
protocol CoachService {
    /// Personalized insights given the user's usage, duels, and standing.
    func insights(me: User, friends: [User], duels: [Duel]) async -> [CoachInsight]

    /// The toolkit of practical "use your phone less" tactics.
    func toolkit() async -> [ToolkitTip]
}

/// Heuristic coach: inspects real usage patterns and produces supportive,
/// never-shaming insights. Mirrors what an AI coach would say, so swapping in
/// the Claude API later is a drop-in.
struct MockCoachService: CoachService {

    func insights(me: User, friends: [User], duels: [Duel]) async -> [CoachInsight] {
        var result: [CoachInsight] = []

        let today = me.todayUsage?.totalMinutes ?? 0
        let avg = me.weeklyUsage.averageDailyMinutes

        // Celebrate improvement vs. the weekly average.
        if avg > 0, today < avg {
            let saved = avg - today
            result.append(CoachInsight(
                tone: .win,
                title: "You're ahead of your average",
                message: "Today is \(saved.asDuration) under your weekly average. That's real progress — keep the momentum."
            ))
        }

        // Goal streak recognition.
        if me.goalStreak >= 3 {
            result.append(CoachInsight(
                tone: .win,
                title: "\(me.goalStreak)-day streak 🔥",
                message: "You've been under goal \(me.goalStreak) days running. Streaks are how habits stick."
            ))
        }

        // Spot the heaviest category and suggest one small change.
        if let top = me.weeklyUsage.aggregatedBreakdown.first, !top.category.isProductive {
            result.append(CoachInsight(
                tone: .tip,
                title: "Your biggest pull: \(top.category.title)",
                message: "It's your top category this week. Try a 30-minute app limit on it — small caps beat willpower."
            ))
        }

        // Rivalry nudge from the closest active duel.
        if let close = duels.filter({ $0.isActive }).min(by: { $0.marginMinutes < $1.marginMinutes }) {
            let name = close.opponent.name.split(separator: " ").first.map(String.init) ?? close.opponent.name
            if close.isWinning {
                result.append(CoachInsight(
                    tone: .rivalry,
                    title: "Hold your lead on \(name)",
                    message: "You're \(close.marginMinutes.asDuration) ahead with \(close.timeRemainingLabel.lowercased()). One calm evening locks it in."
                ))
            } else {
                result.append(CoachInsight(
                    tone: .rivalry,
                    title: "Comeback on \(name) is on",
                    message: "Only \(close.marginMinutes.asDuration) behind. Swap one scroll session for a walk and you flip it."
                ))
            }
        }

        // A gentle general nudge if usage is running high today.
        if today > me.dailyGoalMinutes {
            result.append(CoachInsight(
                tone: .nudge,
                title: "A little over today",
                message: "You're past goal, but tomorrow resets the board. Pick one tip from your Toolkit to set up an easier day."
            ))
        }

        // Always leave them with at least one supportive note.
        if result.isEmpty {
            result.append(CoachInsight(
                tone: .tip,
                title: "Steady as she goes",
                message: "Nothing jumps out today — a good sign. Start a duel to keep things interesting."
            ))
        }

        return result
    }

    func toolkit() async -> [ToolkitTip] {
        SampleData.toolkit
    }
}
