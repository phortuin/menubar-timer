# MenubarTimer — project notes

A menu bar timer for macOS 27, SwiftUI (`MenuBarExtra`), no Dock icon. Built
from `project.yml` with XcodeGen; the `.xcodeproj` is generated and not in
git. Signed to run locally (no Apple ID). Until v0.2.1 it was a Python app
on rumps; that version lives in the git history.

## Vocabulary

- **Progress bar**: the time left and an outlined bar in the menu bar while a
  timer runs. The bar is as long as the timer: 20 points for 5 minutes, for
  every timer, up to 120 points for 30 minutes or more. It is never shorter
  than 5 minutes: a shorter until timer starts partly empty. Its fill is the
  time left on the same scale, so the empty part is the time gone, and a
  timer longer than 30 minutes stays full until 30 are left. The fill gets
  shorter every second, and its last pixel fades out rather than going at
  once. When nothing runs, the menu bar shows the timer icon instead.
- **Added time**: the minutes from add five. Add five makes the bar longer
  by its 5 minutes, and the added time waits at the left of the fill, half
  transparent; more add fives make that part longer. The solid part, right
  of it, is what is counting down. When it has run out, all the waiting
  added time begins as one stretch and turns solid over a second. An add
  five after that waits again. In a full bar the solid part keeps its
  width and the waiting part gets the room that is left.
- **Preset timers**: 5 min break (to wander, but not for too long), 30 min
  meeting, 60 min meeting, at the top of the menu while no timer runs. The break
  says "Back to work you fucking slacker", both meetings "Wrap it up!".
- **Until timer**: Until HH:MM, below the preset timers, counting
  down to the next :29 or :59, so there's a minute to spare before the half
  or full hour.
- **Add five**: Add 5 minutes. **Clear**: Clear timer. Both only while a
  timer runs, below its end time; the timers to start only while none runs.
- **Time's up**: the notification at the end of a timer, with the timer's
  text as subtitle and the Funk sound. It is handed to macOS when the timer
  starts, so it comes on time whatever the app is doing.
- **+5 min**: the button on time's up, starting a new 5-minute timer with
  the same text. Notifications and sound are always on: macOS mutes them
  when needed.
- **End time**: "Stops at HH:MM", the greyed-out top line of the menu while a
  timer runs.

## Code

- `Countdown` holds the one running timer as an end time, so a Mac that
  sleeps doesn't stretch it, and how much of it is added time waiting.
- `Timing.swift` has the pure functions, covered by
  `Tests/TimingTests.swift`: `nextUntil` (the until timer's end),
  `wholeSecond` and `secondsLeft` (the rounding of a timer's end and of
  the countdown), `barWidth` and `fillWidths` (how long the progress bar and the
  parts of its fill are) and
  `formatCountdown`.
- `ProgressBar.swift` draws the progress bar, time included, as one template
  image.
- `Notifier` schedules the time's up with macOS and handles its +5 min
  button.
- The texts of the 5 min break and the until timer come word for word from
  the Python version.
