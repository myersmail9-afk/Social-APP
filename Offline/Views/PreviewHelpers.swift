import Foundation

/// Builds an `AppStore` pre-populated with sample data for SwiftUI previews.
/// Marked `@MainActor` because `AppStore` is.
@MainActor
func previewStore() -> AppStore {
    let store = AppStore()
    store.me = SampleData.me
    store.friends = SampleData.friends
    store.feed = SampleData.feed(me: SampleData.me, friends: SampleData.friends)
    store.loadState = .loaded
    return store
}
