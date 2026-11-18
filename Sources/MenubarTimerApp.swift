import SwiftUI

@main
struct MenubarTimerApp: App {
    @State private var countdown = Countdown()

    private static let clock: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .autoupdatingCurrent
        return formatter
    }()

    var body: some Scene {
        MenuBarExtra {
            if let end = countdown.end {
                Text("Stops at \(Self.clock.string(from: end))")
                Divider()
                Button("Add 5 minutes") { countdown.addFive() }
                Button("Clear timer") { countdown.clear() }
            } else {
                ForEach(Preset.all) { preset in
                    Button(preset.title) { countdown.start(preset) }
                }
                Button("Until \(Self.clock.string(from: countdown.until))") {
                    // The menu item may show a moment that has just passed.
                    countdown.start(until: nextUntil(after: .now), message: "Yep, it’s that fucking late already")
                }
            }
            Divider()
            Button("About MenubarTimer") {
                NSApp.activate()
                NSApp.orderFrontStandardAboutPanel()
            }
            Button("Quit") { NSApp.terminate(nil) }
                .keyboardShortcut("q")
        } label: {
            if countdown.isRunning {
                Image(nsImage: progressBar(time: formatCountdown(countdown.remaining), left: countdown.shareLeft))
                    .accessibilityLabel("\(formatCountdown(countdown.remaining)) left")
            } else {
                Image(systemName: "timer")
            }
        }
    }
}
