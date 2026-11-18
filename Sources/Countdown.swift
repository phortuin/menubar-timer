import Foundation
import Observation

/// The one running timer, counting down to an end time, and the end the until
/// timer would have if started now, for its menu item.
@MainActor @Observable
final class Countdown {
    private(set) var end: Date?
    private(set) var remaining = 0
    private(set) var until = nextUntil(after: .now)
    @ObservationIgnored private var message = ""
    @ObservationIgnored private var ticker: Timer!

    var isRunning: Bool { end != nil }

    init() {
        ticker = Timer(fire: until, interval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        // The common modes keep it ticking while the menu is open.
        RunLoop.main.add(ticker, forMode: .common)
        // The until time is the same moment in any whole-hour time zone, but
        // its menu item shows it in local time, so it is set again to redraw.
        NotificationCenter.default.addObserver(forName: .NSSystemTimeZoneDidChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.until = nextUntil(after: .now) }
        }
    }

    func start(seconds: Int, message: String) {
        start(until: .now.addingTimeInterval(TimeInterval(seconds)), message: message)
    }

    func start(until end: Date, message: String) {
        Notifier.requestPermission()
        self.end = end
        self.message = message
        // Ticks on the whole seconds before the end, so the countdown changes
        // and the timer finishes on time rather than up to a second late.
        let left = end.timeIntervalSinceNow
        ticker.fireDate = .now.addingTimeInterval(left - left.rounded(.down))
        tick()
    }

    func addFive() {
        end = end?.addingTimeInterval(5 * 60)
        tick()
    }

    func stop() {
        end = nil
        // With no timer running, the only change to show is the until time.
        ticker.fireDate = until
    }

    private func tick() {
        let now = Date.now
        let next = nextUntil(after: now)
        if next != until { until = next }
        guard let end else {
            ticker.fireDate = until
            return
        }
        let left = Int(end.timeIntervalSince(now).rounded(.up))
        if left <= 0 {
            Notifier.timeIsUp(message)
            stop()
        } else if left != remaining {
            remaining = left
        }
    }
}
