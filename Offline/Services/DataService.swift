import Foundation

/// The single seam between the app and where its data lives.
///
/// Today this is backed by `MockDataService`. Tomorrow it can be backed by
/// Supabase, Firebase, CloudKit, or a custom API — without touching any view
/// or view-model. Keep all networking/persistence behind this protocol.
protocol DataService {
    /// The signed-in user, including their own weekly usage.
    func currentUser() async throws -> User

    /// The user's friends, including each friend's shared usage.
    func friends() async throws -> [User]

    /// The social activity feed, newest first.
    func feed() async throws -> [Activity]

    /// Add a friend by handle. Returns the newly added user.
    func addFriend(handle: String) async throws -> User

    /// Cheer on a feed item. Returns the updated cheer count.
    func cheer(activityID: UUID) async throws -> Int
}

/// Errors surfaced from the data layer.
enum DataError: LocalizedError {
    case notFound
    case alreadyFriends

    var errorDescription: String? {
        switch self {
        case .notFound: return "We couldn't find anyone with that handle."
        case .alreadyFriends: return "You're already friends with them."
        }
    }
}
