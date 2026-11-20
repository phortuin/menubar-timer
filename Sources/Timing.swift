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

/// The time a full progress bar stands for.
let fullBarSeconds = 30 * 60

/// The width in points of the inside of a full progress bar.
let fullBarPoints = 120

/// The width in points that `seconds` take on the progress bar, where
/// `fullBarSeconds` take `fullBarPoints`, and never more than a full bar.
/// It is not rounded: drawn as the fill, a width that ends partway a pixel
/// shows that pixel partly transparent, so the fill's last pixel fades out
/// second by second.
func barWidth(_ seconds: Int) -> Double {
    min(Double(seconds * fullBarPoints) / Double(fullBarSeconds), Double(fullBarPoints))
}

/// The widths in points of the two parts of the progress bar's fill, with
/// `seconds` left of which the last `waiting` are added time that has not
/// begun. Together they are as wide as `seconds`. When that is more than a
/// full bar, the solid part, the time counting down, keeps its width and the
/// waiting part gets the room that is left.
func fillWidths(left seconds: Int, waiting: Int) -> (waiting: Double, solid: Double) {
    let solid = barWidth(seconds - waiting)
    return (barWidth(seconds) - solid, solid)
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
