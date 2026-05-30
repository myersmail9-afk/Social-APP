import Foundation

/// A person in the app — either the signed-in user or a friend.
struct User: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var name: String
    var handle: String
    /// SF Symbol used as a stand-in avatar until real photos are wired up.
    var avatarSymbol: String
    /// Hex color backing the avatar.
    var avatarColorHex: Int
    /// The user's own day-goal for total screen time, in minutes.
    var dailyGoalMinutes: Int = 180

    /// The last 7 days of usage, oldest first.
    var weeklyUsage: [DailyUsage]

    var todayUsage: DailyUsage? { weeklyUsage.last }

    /// A short "streak" of consecutive recent days under goal.
    var goalStreak: Int {
        var streak = 0
        for day in weeklyUsage.reversed() {
            if day.totalMinutes <= dailyGoalMinutes { streak += 1 } else { break }
        }
        return streak
    }
}
