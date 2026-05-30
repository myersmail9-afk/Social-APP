import Foundation

/// A single item in the social feed — the heart of the "share to stay
/// accountable" loop.
struct Activity: Identifiable, Codable, Hashable {
    enum Kind: String, Codable {
        case beatGoal          // came in under their daily goal
        case streak            // hit a multi-day streak
        case bigImprovement    // big drop vs. their average
        case sharedSummary     // shared a daily/weekly summary
        case cheered           // cheered a friend on
    }

    var id: UUID = UUID()
    var userID: UUID
    var userName: String
    var userAvatarSymbol: String
    var userAvatarColorHex: Int
    var kind: Kind
    var date: Date
    /// Optional headline number, e.g. minutes saved or streak length.
    var value: Int?
    var cheers: Int

    var headline: String {
        switch kind {
        case .beatGoal:
            return "beat their daily goal"
        case .streak:
            return "is on a \(value ?? 0)-day streak 🔥"
        case .bigImprovement:
            return "cut \(value ?? 0) min vs. their average"
        case .sharedSummary:
            return "shared today's screen time"
        case .cheered:
            return "cheered on a friend"
        }
    }
}
