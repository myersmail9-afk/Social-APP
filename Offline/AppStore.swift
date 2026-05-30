import SwiftUI
import Observation

/// App-wide observable state. Views read from this; it talks to `DataService`.
/// Injected via the SwiftUI environment so anything can reach it.
@MainActor
@Observable
final class AppStore {
    enum LoadState {
        case idle, loading, loaded, failed(String)
    }

    private let service: DataService

    var me: User?
    var friends: [User] = []
    var feed: [Activity] = []
    var loadState: LoadState = .idle

    init(service: DataService = MockDataService()) {
        self.service = service
    }

    /// Everyone — you and your friends — ranked by today's total screen time
    /// (lowest first). Powers the leaderboard.
    var leaderboard: [User] {
        var all = friends
        if let me { all.append(me) }
        return all.sorted {
            ($0.todayUsage?.totalMinutes ?? .max) < ($1.todayUsage?.totalMinutes ?? .max)
        }
    }

    func load() async {
        loadState = .loading
        do {
            async let user = service.currentUser()
            async let friendsList = service.friends()
            async let feedItems = service.feed()
            me = try await user
            friends = try await friendsList
            feed = try await feedItems
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }

    @discardableResult
    func addFriend(handle: String) async throws -> User {
        let friend = try await service.addFriend(handle: handle)
        friends = try await service.friends()
        return friend
    }

    func cheer(_ activity: Activity) async {
        guard let newCount = try? await service.cheer(activityID: activity.id) else { return }
        if let index = feed.firstIndex(where: { $0.id == activity.id }) {
            feed[index].cheers = newCount
        }
    }
}
