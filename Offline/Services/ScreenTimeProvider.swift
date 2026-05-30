import Foundation

/// Abstraction over *where the user's own raw usage comes from*.
///
/// Right now `me`'s usage is sample data. When you're ready to ship real
/// tracking, implement this with Apple's Screen Time frameworks:
///
///   • `FamilyControls`   — request authorization (`AuthorizationCenter`)
///   • `DeviceActivity`   — schedule monitoring windows
///   • `ManagedSettings`  — (optional) enforce limits/shields
///   • `DeviceActivityReport` — render Apple's usage report UI
///
/// IMPORTANT PRIVACY CONSTRAINT: Apple intentionally does **not** hand your app
/// raw per-app minutes that you can freely upload to a server. Usage data is
/// surfaced inside a sandboxed `DeviceActivityReport` extension. To power the
/// social/sharing feature you will typically:
///   1. Compute category totals *inside* the report extension, then
///   2. Persist only the aggregate numbers (e.g. via an App Group + shared
///      container), which the main app reads and shares.
/// You also need the "Family Controls" entitlement (request it from Apple).
///
/// Keeping this behind a protocol means none of that complexity leaks into the
/// UI — the views just ask for `DailyUsage` values.
protocol ScreenTimeProvider {
    /// Whether the user has granted Screen Time authorization.
    var isAuthorized: Bool { get }

    /// Request Screen Time authorization from the user.
    func requestAuthorization() async throws

    /// The last 7 days of the current device's usage, oldest first.
    func weeklyUsage() async throws -> [DailyUsage]
}

/// Stand-in provider used until the real Screen Time integration lands.
struct MockScreenTimeProvider: ScreenTimeProvider {
    var isAuthorized: Bool { true }
    func requestAuthorization() async throws {}
    func weeklyUsage() async throws -> [DailyUsage] { SampleData.me.weeklyUsage }
}
