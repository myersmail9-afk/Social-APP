import SwiftUI

/// The app's tab bar: Friends · Feed · You · Profile.
struct RootView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        TabView {
            FriendsView()
                .tabItem { Label("Friends", systemImage: "person.2.fill") }

            DuelsView()
                .tabItem { Label("Duels", systemImage: "bolt.fill") }

            FeedView()
                .tabItem { Label("Feed", systemImage: "sparkles") }

            DashboardView()
                .tabItem { Label("You", systemImage: "chart.pie.fill") }

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(Theme.accent)
        .task {
            if case .idle = store.loadState { await store.load() }
        }
        .overlay {
            if case .failed(let message) = store.loadState {
                ContentUnavailableView {
                    Label("Couldn't load", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") { Task { await store.load() } }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}

#Preview {
    RootView()
        .environment(previewStore())
}
