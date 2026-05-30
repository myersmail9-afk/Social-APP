import Foundation
import UserNotifications

/// Local notifications for the two moments that keep people engaged:
/// 1. Celebrating screen-time improvements (positive reinforcement).
/// 2. Warning when you're closing in on — or about to lose to — a rival.
///
/// Uses local notifications only; a real backend would add server push for
/// live opponent updates. All copy is encouraging, never shaming.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    /// Ask permission. Safe to call repeatedly; the system only prompts once.
    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    var authorizationStatus: UNAuthorizationStatus {
        get async { await center.notificationSettings().authorizationStatus }
    }

    /// Celebrate an improvement vs. the user's average.
    func celebrateImprovement(savedMinutes: Int) {
        guard savedMinutes > 0 else { return }
        schedule(
            id: "improvement",
            title: "Nice — you're trending down 📉",
            body: "You're \(savedMinutes.asDuration) under your average today. Keep it rolling."
        )
    }

    /// Warn the user they're approaching a rival's total in an active duel.
    func rivalryWarning(opponentName: String, marginMinutes: Int, isWinning: Bool) {
        let firstName = opponentName.split(separator: " ").first.map(String.init) ?? opponentName
        let title: String
        let body: String
        if isWinning {
            title = "Lead under threat ⚔️"
            body = "\(firstName) is only \(marginMinutes.asDuration) behind. Put it down to stay on top."
        } else {
            title = "Comeback time 🔥"
            body = "You're \(marginMinutes.asDuration) behind \(firstName). One quiet evening flips this duel."
        }
        schedule(id: "rivalry", title: title, body: body)
    }

    /// Schedule a near-immediate local notification. Replaces any pending one
    /// with the same id so we don't spam.
    private func schedule(id: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.removePendingNotificationRequests(withIdentifiers: [id])
        center.add(request)
    }
}
