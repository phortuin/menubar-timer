import UserNotifications

enum Setting {
    static let notifications = "allowNotifications"
    static let sound = "allowSound"
}

/// Hands the time's-up notification to macOS when a timer starts, so it comes
/// on time whatever the app is doing, and passes on the buttons pressed on it.
@MainActor
final class Notifier: NSObject, UNUserNotificationCenterDelegate {
    enum Button {
        case addFive(message: String)
        case start(Preset)
    }

    var onButton: (Button) -> Void = { _ in }

    private let center = UNUserNotificationCenter.current()
    /// The identifier of the notification scheduled for the running timer.
    private var scheduled: String?
    private static let timesUp = "timesUp"
    private static let addFive = "addFive"

    override init() {
        super.init()
        UserDefaults.standard.register(defaults: [Setting.notifications: true, Setting.sound: true])
        center.delegate = self
        // Each notification has one button: start the preset offered next,
        // in a category named after that preset, or else +5 min.
        let addFive = UNNotificationAction(identifier: Self.addFive, title: "+5 min")
        var categories: Set = [UNNotificationCategory(identifier: Self.timesUp, actions: [addFive], intentIdentifiers: [])]
        for preset in Preset.all.compactMap({ Preset.with(id: $0.next) }) {
            let start = UNNotificationAction(identifier: preset.id, title: preset.title)
            categories.insert(UNNotificationCategory(identifier: preset.id, actions: [start], intentIdentifiers: []))
        }
        center.setNotificationCategories(categories)
    }

    func requestPermission() {
        guard UserDefaults.standard.bool(forKey: Setting.notifications) else { return }
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    /// Schedules "Time’s up" with the timer's message at `end`, replacing the
    /// one scheduled before, or cancels it when notifications are off.
    func schedule(at end: Date, message: String, next: Preset?) {
        cancel()
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: Setting.notifications), end > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = "Time’s up"
        content.subtitle = message
        content.categoryIdentifier = next?.id ?? Self.timesUp
        if defaults.bool(forKey: Setting.sound) {
            // A built-in sound from /System/Library/Sounds, found by its name.
            content.sound = UNNotificationSound(named: UNNotificationSoundName("Funk.aiff"))
        }
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
        let action = response.actionIdentifier
        let content = response.notification.request.content
        await press(action, message: content.subtitle)
    }

    private func press(_ action: String, message: String) {
        if action == Self.addFive {
            onButton(.addFive(message: message))
        } else if let preset = Preset.with(id: action) {
            onButton(.start(preset))
        }
    }
}
