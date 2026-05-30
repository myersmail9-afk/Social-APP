import SwiftUI

/// Offline — track your screen time, share it with friends, and motivate each
/// other to put the phone down.
@main
@MainActor
struct OfflineApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
