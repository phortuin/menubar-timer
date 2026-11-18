import UserNotifications

/// Hands the time's-up notification to macOS when a timer starts, so it comes
/// on time whatever the app is doing, and passes on its +5 min button.
@MainActor
final class Notifier: NSObject, UNUserNotificationCenterDelegate {
    /// Called with the message of the time's up whose +5 min was pressed.
    var onAddFive: (String) -> Void = { _ in }

    private let center = UNUserNotificationCenter.current()
    /// The identifier of the notification scheduled for the running timer.
    private var scheduled: String?
    nonisolated private static let timesUp = "timesUp"
    nonisolated private static let addFive = "addFive"

    override init() {
        super.init()
        center.delegate = self
        // A starting app has no timer, so a time's up still scheduled is left
        // from an app that was killed (a crash or Force Quit) before it could
        // cancel it, and would otherwise arrive without a timer.
        center.removeAllPendingNotificationRequests()
        let addFive = UNNotificationAction(identifier: Self.addFive, title: "+5 min")
        center.setNotificationCategories([
            UNNotificationCategory(identifier: Self.timesUp, actions: [addFive], intentIdentifiers: []),
        ])
    }

    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Schedules "Time’s up" with the timer's message at `end`, replacing the
    /// one scheduled before.
    func schedule(at end: Date, message: String) {
        cancel()
        guard end > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = "Time’s up"
        content.subtitle = message
        content.categoryIdentifier = Self.timesUp
        // A built-in sound from /System/Library/Sounds, found by its name.
        content.sound = UNNotificationSound(named: UNNotificationSoundName("Funk.aiff"))
        // At the end time itself, like the countdown, so a Mac that sleeps
        // in between doesn't delay it.
        let when = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: end)
        let trigger = UNCalendarNotificationTrigger(dateMatching: when, repeats: false)
        // A new identifier each time: macOS silently updates a notification
        // still in Notification Center that has the same one, without a
        // banner or sound.
        let id = UUID().uuidString
        scheduled = id
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    func cancel() {
        guard let scheduled else { return }
        center.removePendingNotificationRequests(withIdentifiers: [scheduled])
        self.scheduled = nil
    }

    // macOS hides notifications from the frontmost app, which this app is
    // right after its About panel was opened.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            didReceive response: UNNotificationResponse) async {
        guard response.actionIdentifier == Self.addFive else { return }
        await pressAddFive(response.notification.request.content.subtitle)
    }

    private func pressAddFive(_ message: String) {
        onAddFive(message)
    }
}
