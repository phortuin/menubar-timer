import SwiftUI
import UserNotifications

struct Preset: Identifiable {
    let title: String
    let seconds: Int
    let message: String

    var id: String { title }

    static let all = [
        Preset(title: "Start 5 min break", seconds: 5 * 60, message: "Back to work you fucking slacker"),
        Preset(title: "Start 25 min work", seconds: 25 * 60, message: "Slow it down motherfucker"),
        Preset(title: "Start eval talk", seconds: 45 * 60, message: "Wrap it up!"),
    ]
}

@main
struct MenubarTimerApp: App {
    @State private var countdown = Countdown()
    @AppStorage(Setting.notifications) private var allowNotifications = true
    @AppStorage(Setting.sound) private var allowSound = true

    private static let clock: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()

    init() {
        UserDefaults.standard.register(defaults: [Setting.notifications: true, Setting.sound: true])
        UNUserNotificationCenter.current().delegate = Notifier.shared
    }

    var body: some Scene {
        MenuBarExtra {
            Group {
                ForEach(Preset.all) { preset in
                    Button(preset.title) {
                        countdown.start(seconds: preset.seconds, message: preset.message)
                    }
                }
                Button("Start timer until \(Self.clock.string(from: countdown.until))") {
                    // The menu item may show a moment that has just passed.
                    countdown.start(until: nextUntil(after: .now), message: "Yep, it’s that fucking late already")
                }
            }
            .disabled(countdown.isRunning)
            Button("Add 5 mins to timer") { countdown.addFive() }
                .disabled(!countdown.isRunning)
            Divider()
            Toggle("Allow notifications", isOn: $allowNotifications)
            Toggle("Allow sound", isOn: $allowSound)
                .disabled(!allowNotifications)
            Divider()
            Button("Stop & clear timer") { countdown.stop() }
                .disabled(!countdown.isRunning)
            Divider()
            Button("About MenubarTimer") {
                NSApp.activate()
                NSApp.orderFrontStandardAboutPanel()
            }
            Button("Quit") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        } label: {
            if countdown.isRunning {
                Text(formatCountdown(countdown.remaining))
                    .monospacedDigit()
            } else {
                Image(systemName: "timer")
            }
        }
    }
}
