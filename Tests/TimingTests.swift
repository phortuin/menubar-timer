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

    @Test func aFiveMinuteTimerStartsAtFiveMinutes() {
        let now = Date(timeIntervalSinceReferenceDate: 1000.4)
        let end = wholeSecond(now.addingTimeInterval(5 * 60))
        #expect(secondsLeft(until: end, at: now) == 300)
    }

    @Test func fiveMinutesAreTwentyPointsOnTheBar() {
        #expect(barWidth(5 * 60) == 20)
        #expect(barWidth(10 * 60) == 40)
        #expect(barWidth(30 * 60) == 120)
    }

    @Test func aSecondIsAFifteenthOfAPointOnTheBar() {
        #expect(barWidth(15) == 1)
        #expect(barWidth(3) == 0.2)
        #expect(barWidth(4 * 60 + 54) == 19.6)
        #expect(barWidth(0) == 0)
    }

    @Test func theBarIsNoWiderThanThirtyMinutes() {
        #expect(barWidth(29 * 60 + 45) == 119)
        #expect(barWidth(30 * 60 + 1) == 120)
        #expect(barWidth(60 * 60) == 120)
    }

    @Test func countdownFormat() {
        #expect(formatCountdown(45 * 60) == "45:00")
        #expect(formatCountdown(9 * 60 + 5) == "9:05")
        #expect(formatCountdown(59) == "0:59")
    }
}
