import Foundation

/// Deterministic-ish sample data so the app looks alive in previews and demos.
enum SampleData {

    /// Build a week of usage ending today, shaped by a per-category daily
    /// "typical minutes" profile plus a little day-to-day variation.
    static func weeklyUsage(profile: [UsageCategory: Int], seed: Int) -> [DailyUsage] {
        var generator = SeededGenerator(seed: UInt64(seed))
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let breakdown: [CategoryUsage] = profile.compactMap { category, typical in
                guard typical > 0 else { return nil }
                let variance = Int.random(in: -typical/3...typical/3, using: &generator)
                let minutes = max(0, typical + variance)
                return CategoryUsage(category: category, minutes: minutes)
            }
            .sorted { $0.minutes > $1.minutes }
            return DailyUsage(date: date, breakdown: breakdown)
        }
    }

    static let me = User(
        name: "You",
        handle: "you",
        avatarSymbol: "person.fill",
        avatarColorHex: 0x6C5CE7,
        dailyGoalMinutes: 180,
        weeklyUsage: weeklyUsage(
            profile: [
                .social: 52, .entertainment: 41, .productivity: 38,
                .music: 25, .games: 15, .education: 12, .other: 9
            ],
            seed: 1
        )
    )

    static let friends: [User] = [
        User(
            name: "Maya Chen", handle: "mayac",
            avatarSymbol: "leaf.fill", avatarColorHex: 0x22C55E,
            dailyGoalMinutes: 150,
            weeklyUsage: weeklyUsage(
                profile: [.productivity: 60, .education: 35, .social: 28, .music: 30, .health: 18],
                seed: 2)
        ),
        User(
            name: "Liam Park", handle: "liampark",
            avatarSymbol: "bolt.fill", avatarColorHex: 0xF59E0B,
            dailyGoalMinutes: 200,
            weeklyUsage: weeklyUsage(
                profile: [.games: 85, .entertainment: 70, .social: 60, .music: 20],
                seed: 3)
        ),
        User(
            name: "Sofia Reyes", handle: "sofiar",
            avatarSymbol: "sparkles", avatarColorHex: 0xFF5C8A,
            dailyGoalMinutes: 160,
            weeklyUsage: weeklyUsage(
                profile: [.social: 70, .entertainment: 45, .productivity: 30, .health: 22],
                seed: 4)
        ),
        User(
            name: "Noah Kim", handle: "noahk",
            avatarSymbol: "book.fill", avatarColorHex: 0x14B8A6,
            dailyGoalMinutes: 120,
            weeklyUsage: weeklyUsage(
                profile: [.education: 55, .productivity: 40, .music: 25, .social: 18],
                seed: 5)
        )
    ]

    /// A pool of handles the user could "discover" and add.
    static let discoverable: [User] = [
        User(name: "Ava Singh", handle: "avasingh",
             avatarSymbol: "moon.stars.fill", avatarColorHex: 0x8B5CF6,
             dailyGoalMinutes: 140,
             weeklyUsage: weeklyUsage(profile: [.social: 40, .productivity: 45, .music: 30], seed: 6)),
        User(name: "Ethan Brooks", handle: "ethanb",
             avatarSymbol: "flame.fill", avatarColorHex: 0xEF4444,
             dailyGoalMinutes: 180,
             weeklyUsage: weeklyUsage(profile: [.entertainment: 60, .games: 50, .social: 35], seed: 7))
    ]

    static func feed(me: User, friends: [User]) -> [Activity] {
        let calendar = Calendar.current
        let now = Date()
        func ago(_ hours: Int) -> Date { calendar.date(byAdding: .hour, value: -hours, to: now)! }

        var items: [Activity] = []
        if let maya = friends.first(where: { $0.handle == "mayac" }) {
            items.append(Activity(userID: maya.id, userName: maya.name,
                                  userAvatarSymbol: maya.avatarSymbol, userAvatarColorHex: maya.avatarColorHex,
                                  kind: .streak, date: ago(2), value: 5, cheers: 8))
        }
        if let noah = friends.first(where: { $0.handle == "noahk" }) {
            items.append(Activity(userID: noah.id, userName: noah.name,
                                  userAvatarSymbol: noah.avatarSymbol, userAvatarColorHex: noah.avatarColorHex,
                                  kind: .bigImprovement, date: ago(5), value: 47, cheers: 12))
        }
        if let sofia = friends.first(where: { $0.handle == "sofiar" }) {
            items.append(Activity(userID: sofia.id, userName: sofia.name,
                                  userAvatarSymbol: sofia.avatarSymbol, userAvatarColorHex: sofia.avatarColorHex,
                                  kind: .beatGoal, date: ago(9), value: nil, cheers: 4))
        }
        items.append(Activity(userID: me.id, userName: me.name,
                              userAvatarSymbol: me.avatarSymbol, userAvatarColorHex: me.avatarColorHex,
                              kind: .sharedSummary, date: ago(20), value: nil, cheers: 6))
        if let liam = friends.first(where: { $0.handle == "liampark" }) {
            items.append(Activity(userID: liam.id, userName: liam.name,
                                  userAvatarSymbol: liam.avatarSymbol, userAvatarColorHex: liam.avatarColorHex,
                                  kind: .cheered, date: ago(26), value: nil, cheers: 1))
        }
        return items.sorted { $0.date > $1.date }
    }
}

// MARK: - Duels

extension SampleData {
    /// A believable in-progress duel record to make the feature feel alive.
    static let standing = DuelStanding(
        wins: 7, losses: 4, ties: 1,
        points: 540,
        currentWinStreak: 2, bestWinStreak: 4,
        coins: 240
    )

    /// One or two live duels so the Duels tab has something to show on launch.
    static func activeDuels(friends: [User]) -> [Duel] {
        let cal = Calendar.current
        let now = Date()
        var result: [Duel] = []

        // A close week-long duel where you're narrowly ahead.
        if let liam = friends.first(where: { $0.handle == "liampark" }) {
            let start = cal.date(byAdding: .day, value: -4, to: now)!
            let end = cal.date(byAdding: .day, value: 3, to: now)!
            result.append(Duel(
                opponent: liam, period: .week,
                startDate: start, endDate: end,
                myMinutes: 612, opponentMinutes: 640,
                wasRandomMatch: false, myBaselineMinutes: 1300,
                wager: 50
            ))
        }

        // A random-matched day duel where you're a touch behind (comeback framing).
        if let maya = friends.first(where: { $0.handle == "mayac" }) {
            let start = cal.startOfDay(for: now)
            let end = cal.date(byAdding: .day, value: 1, to: start)!
            result.append(Duel(
                opponent: maya, period: .day,
                startDate: start, endDate: end,
                myMinutes: 96, opponentMinutes: 78,
                wasRandomMatch: true, myBaselineMinutes: 192
            ))
        }

        return result
    }

    /// A short history so the win/loss record reads as earned.
    static func duelHistory(friends: [User]) -> [Duel] {
        let cal = Calendar.current
        let now = Date()
        var result: [Duel] = []

        func finished(_ handle: String, period: Duel.Period, daysAgo: Int,
                      mine: Int, theirs: Int, random: Bool, baseline: Int) {
            guard let opp = friends.first(where: { $0.handle == handle }) else { return }
            let end = cal.date(byAdding: .day, value: -daysAgo, to: now)!
            let start = cal.date(byAdding: period.calendarComponent, value: -1, to: end)!
            result.append(Duel(
                opponent: opp, period: period,
                startDate: start, endDate: end,
                myMinutes: mine, opponentMinutes: theirs,
                wasRandomMatch: random, myBaselineMinutes: baseline
            ))
        }

        finished("mayac", period: .week, daysAgo: 3, mine: 980, theirs: 1120, random: false, baseline: 1300)
        finished("noahk", period: .day, daysAgo: 6, mine: 145, theirs: 120, random: true, baseline: 190)
        finished("sofiar", period: .week, daysAgo: 11, mine: 1040, theirs: 1010, random: false, baseline: 1300)
        finished("liampark", period: .month, daysAgo: 20, mine: 3900, theirs: 4600, random: false, baseline: 5200)

        return result
    }
}

/// A tiny seedable RNG so sample data is stable across launches.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed &* 0x9E3779B97F4A7C15 &+ 1 }
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
