import Foundation

/// The next half past or full hour minus one minute (:29 or :59, at zero
/// seconds) strictly after `date`: the end of the until timer.
func nextUntil(after date: Date, calendar: Calendar = .current) -> Date {
    let hour = calendar.dateInterval(of: .hour, for: date)!.start
    let minute = calendar.component(.minute, from: date)
    let minutes = minute < 29 ? 29 : minute < 59 ? 59 : 60 + 29
    return hour.addingTimeInterval(TimeInterval(minutes * 60))
}

/// Seconds as `m:ss`. Single-digit minutes are padded with a figure space,
/// which is as wide as a digit, so the countdown keeps its width.
func formatCountdown(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let padding = minutes < 10 ? "\u{2007}" : ""
    return padding + String(format: "%d:%02d", minutes, seconds % 60)
}
