import UserNotifications

enum Setting {
    static let notifications = "allowNotifications"
    static let sound = "allowSound"
}

final class Notifier: NSObject, UNUserNotificationCenterDelegate, Sendable {
    static let shared = Notifier()

    static func requestPermission() {
        guard UserDefaults.standard.bool(forKey: Setting.notifications) else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Posts "Time’s up" with the timer's message, if the settings allow it.
    static func timeIsUp(_ message: String) {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: Setting.notifications) else { return }
        let content = UNMutableNotificationContent()
        content.title = "Time’s up"
        content.subtitle = message
        if defaults.bool(forKey: Setting.sound) {
            content.sound = .default
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    // macOS hides notifications from the frontmost app, which this app is
    // right after its About panel was opened.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
