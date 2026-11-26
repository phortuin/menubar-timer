import AppKit
import Observation

/// The one running timer, counting down to an end time, and the end the until
/// timer would have if started now, for its menu item.
@MainActor @Observable
final class Countdown {
    private(set) var end: Date?
    private(set) var remaining = 0
    /// The seconds the running timer lasts in all, add fives included.
    private(set) var length = 0
    private(set) var until = nextUntil(after: .now)
    @ObservationIgnored private var message = ""
    @ObservationIgnored private let notifier = Notifier()
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
        // The ticker counts the time the Mac is awake, so a sleep or a change
        // of the clock leaves it out of step with the clock: a Mac that sleeps
        // from 11:00 to 12:18 would still offer Until 11:29, and a running
        // countdown would change a fraction of a second late from then on.
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.catchUp() }
        }
        NotificationCenter.default.addObserver(forName: .NSSystemClockDidChange, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.catchUp() }
        }
        // A time's up scheduled with macOS would still come after the app quit.
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification, object: nil, queue: .main) { [weak self] _ in
            MainActor.assumeIsolated { self?.notifier.cancel() }
        }
        notifier.requestPermission()
        notifier.onAddFive = { [weak self] message in
            // As in the menu, a timer can only start while none runs, so the
            // button on an earlier time's up can't replace the running timer.
            guard let self, !self.isRunning else { return }
            start(seconds: 5 * 60, message: message)
        }
    }

    func start(_ preset: Preset) {
        start(seconds: preset.seconds, message: preset.message)
    }

    func start(seconds: Int, message: String) {
        start(until: .now.addingTimeInterval(TimeInterval(seconds)), message: message)
    }

    func start(until end: Date, message: String) {
        // On a whole second, because macOS shows the time's up to the second.
        let end = wholeSecond(end)
        self.end = end
        length = secondsLeft(until: end, at: .now)
        self.message = message
        notifier.schedule(at: end, message: message)
        alignTicker(to: end)
        tick()
    }

    /// Ticks the ticker on the whole seconds before `end`, so the countdown
    /// changes and the timer finishes on time rather than up to a second late.
    private func alignTicker(to end: Date) {
        let left = end.timeIntervalSinceNow
        ticker.fireDate = .now.addingTimeInterval(left - left.rounded(.down))
    }

    private func catchUp() {
        if let end { alignTicker(to: end) }
        tick()
    }

    func addFive() {
        guard let end else { return }
        let later = end.addingTimeInterval(5 * 60)
        self.end = later
        length += 5 * 60
        notifier.schedule(at: later, message: message)
        tick()
    }

    func clear() {
        notifier.cancel()
        reset()
    }

    private func reset() {
        end = nil
        // With no timer running, the only change to show is the until time.
        ticker.fireDate = until
    }

    private func tick() {
        let now = Date.now
        let latest = nextUntil(after: now)
        if latest != until { until = latest }
        guard let end else {
            ticker.fireDate = until
            return
        }
        let left = secondsLeft(until: end, at: now)
        if left <= 0 {
            // macOS shows the time's-up notification by itself at the end.
            reset()
        } else if left != remaining {
            remaining = left
        }
    }
}
