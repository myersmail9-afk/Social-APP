import Foundation

/// An in-memory `DataService` backed by `SampleData`. Swap this out for a real
/// backend implementation without changing any UI code.
@MainActor
final class MockDataService: DataService {
    private var me = SampleData.me
    private var friendList = SampleData.friends
    private var activities: [Activity] = []
    private var duels: [Duel] = []
    private var history: [Duel] = []
    private var standing: DuelStanding = SampleData.standing

    init() {
        activities = SampleData.feed(me: me, friends: friendList)
        duels = SampleData.activeDuels(friends: friendList)
        history = SampleData.duelHistory(friends: friendList)
    }

    func currentUser() async throws -> User {
        try await fakeLatency()
        return me
    }

    func friends() async throws -> [User] {
        try await fakeLatency()
        return friendList.sorted { $0.todayUsage?.totalMinutes ?? 0 < $1.todayUsage?.totalMinutes ?? 0 }
    }

    func feed() async throws -> [Activity] {
        try await fakeLatency()
        return activities
    }

    func addFriend(handle: String) async throws -> User {
        try await fakeLatency()
        let normalized = handle.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "@", with: "")
            .lowercased()

        if friendList.contains(where: { $0.handle == normalized }) {
            throw DataError.alreadyFriends
        }
        guard let found = SampleData.discoverable.first(where: { $0.handle == normalized }) else {
            throw DataError.notFound
        }
        friendList.append(found)
        return found
    }

    func cheer(activityID: UUID) async throws -> Int {
        guard let index = activities.firstIndex(where: { $0.id == activityID }) else {
            throw DataError.notFound
        }
        activities[index].cheers += 1
        return activities[index].cheers
    }

    // MARK: - Duels

    func activeDuels() async throws -> [Duel] {
        try await fakeLatency()
        return duels.sorted { $0.endDate < $1.endDate }
    }

    func duelHistory() async throws -> [Duel] {
        try await fakeLatency()
        return history.sorted { $0.endDate > $1.endDate }
    }

    func duelStanding() async throws -> DuelStanding {
        try await fakeLatency()
        return standing
    }

    func startDuel(opponentID: UUID?, period: Duel.Period) async throws -> Duel {
        try await fakeLatency()

        // Friends not already locked in an active duel make eligible rivals.
        let busy = Set(duels.map { $0.opponent.id })
        let available = friendList.filter { !busy.contains($0.id) }

        let opponent: User
        if let opponentID {
            guard let chosen = friendList.first(where: { $0.id == opponentID }) else {
                throw DataError.notFound
            }
            opponent = chosen
        } else {
            guard let random = available.randomElement() ?? friendList.randomElement() else {
                throw DataError.noOpponentsAvailable
            }
            opponent = random
        }

        let now = Date()
        let end = Calendar.current.date(byAdding: period.calendarComponent, value: 1, to: now) ?? now
        let baseline = me.weeklyUsage.averageDailyMinutes * windowDays(for: period)

        let duel = Duel(
            opponent: opponent,
            period: period,
            startDate: now,
            endDate: end,
            myMinutes: 0,
            opponentMinutes: 0,
            wasRandomMatch: opponentID == nil,
            myBaselineMinutes: baseline
        )
        duels.append(duel)
        return duel
    }

    private func windowDays(for period: Duel.Period) -> Int {
        switch period {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .year: return 365
        }
    }

    /// Simulate a little network latency so loading states are exercised.
    private func fakeLatency() async throws {
        try await Task.sleep(nanoseconds: 250_000_000)
    }
}
