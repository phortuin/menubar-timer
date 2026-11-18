import Foundation
import Testing
@testable import MenubarTimer

struct TimingTests {
    let calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    func time(_ hour: Int, _ minute: Int, _ second: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: hour, minute: minute, second: second))!
    }

    @Test func beforeHalfPastEndsAt29() {
        #expect(nextUntil(after: time(12, 10), calendar: calendar) == time(12, 29))
    }

    @Test func duringMinute29EndsAt59() {
        #expect(nextUntil(after: time(12, 29, 30), calendar: calendar) == time(12, 59))
    }

    @Test func afterHalfPastEndsAt59() {
        #expect(nextUntil(after: time(12, 45), calendar: calendar) == time(12, 59))
    }

    @Test func duringMinute59EndsAt29OfTheNextHour() {
        #expect(nextUntil(after: time(12, 59, 30), calendar: calendar) == time(13, 29))
    }

    @Test func aFiveMinuteTimerStartsAtFiveMinutesAndFull() {
        let now = Date(timeIntervalSinceReferenceDate: 1000.4)
        let span = timerSpan(from: now, to: now.addingTimeInterval(5 * 60))
        let left = secondsLeft(until: span.end, at: now)
        #expect(left == 300)
        #expect(shareLeft(left, of: span) == 1)
    }

    @Test func countdownFormat() {
        #expect(formatCountdown(45 * 60) == "45:00")
        #expect(formatCountdown(9 * 60 + 5) == "9:05")
        #expect(formatCountdown(59) == "0:59")
    }
}
