import Foundation

/// The next half past or full hour minus one minute (:29 or :59, at zero
/// seconds) strictly after `date`: the end of the until timer.
func nextUntil(after date: Date, calendar: Calendar = .current) -> Date {
    let hour = calendar.dateInterval(of: .hour, for: date)!.start
    let minute = calendar.component(.minute, from: date)
    let minutes = minute < 29 ? 29 : minute < 59 ? 59 : 60 + 29
    return hour.addingTimeInterval(TimeInterval(minutes * 60))
}

/// `date` on the whole second at or before it.
func wholeSecond(_ date: Date) -> Date {
    Date(timeIntervalSinceReferenceDate: date.timeIntervalSinceReferenceDate.rounded(.down))
}

/// A timer started at `now` and ending at `end`, both on whole seconds
/// because macOS shows the time's up to the second. Its countdown starts at
/// its full length, its share left at 1, and it ends at most a second early.
func timerSpan(from now: Date, to end: Date) -> DateInterval {
    DateInterval(start: wholeSecond(now), end: wholeSecond(end))
}

/// The share of `span` left with `seconds` to go: 1 at its start, 0 at its end.
func shareLeft(_ seconds: Int, of span: DateInterval) -> Double {
    Double(seconds) / max(span.duration, 1)
}

/// The whole seconds left until `end`, counting a started second as a whole
/// one, so the countdown shows 0:00 only when time is up.
func secondsLeft(until end: Date, at date: Date) -> Int {
    Int(end.timeIntervalSince(date).rounded(.up))
}

/// Seconds as `m:ss`.
func formatCountdown(_ seconds: Int) -> String {
    String(format: "%d:%02d", seconds / 60, seconds % 60)
}
