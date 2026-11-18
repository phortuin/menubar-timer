import SwiftUI

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

    var body: some Scene {
        MenuBarExtra {
            Group {
                ForEach(Preset.all) { preset in
                    Button(preset.title) { countdown.start(preset) }
                }
                Button("Start timer until \(Self.clock.string(from: countdown.until))") {
                    // The menu item may show a moment that has just passed.
                    countdown.start(until: nextUntil(after: .now), message: "Yep, it’s that fucking late already", next: nil)
                }
            }
            .disabled(countdown.isRunning)
            Button("Add 5 mins to timer") { countdown.addFive() }
                .disabled(!countdown.isRunning)
            Divider()
            Toggle("Allow notifications", isOn: setting($allowNotifications))
            Toggle("Allow sound", isOn: setting($allowSound))
                .disabled(!allowNotifications)
            Divider()
            if let end = countdown.end {
                Text("Ends at \(Self.clock.string(from: end))")
            }
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

    /// The setting's binding, telling the countdown about each change so the
    /// time's-up notification it has scheduled follows the new setting.
    private func setting(_ value: Binding<Bool>) -> Binding<Bool> {
        Binding(get: { value.wrappedValue }, set: {
            value.wrappedValue = $0
            countdown.settingsChanged()
        })
    }
}
