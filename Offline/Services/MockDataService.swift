import Foundation

/// An in-memory `DataService` backed by `SampleData`. Swap this out for a real
/// backend implementation without changing any UI code.
@MainActor
final class MockDataService: DataService {
    private var me = SampleData.me
    private var friendList = SampleData.friends
    private var activities: [Activity] = []

    init() {
        activities = SampleData.feed(me: me, friends: friendList)
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

    /// Simulate a little network latency so loading states are exercised.
    private func fakeLatency() async throws {
        try await Task.sleep(nanoseconds: 250_000_000)
    }
}
