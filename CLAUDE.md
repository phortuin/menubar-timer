# MenubarTimer — project notes

A menu bar timer for macOS 27, SwiftUI (`MenuBarExtra`), no Dock icon. Built
from `project.yml` with XcodeGen; the `.xcodeproj` is generated and not in
git. Signed to run locally (no Apple ID). Until v0.2.1 it was a Python app
on rumps; that version lives in the git history.

## Vocabulary

- **Progress bar**: the time left and an outlined bar in the menu bar while a
  timer runs. The bar is as long as the timer: 20 points for 5 minutes, for
  every timer, up to 120 points for 30 minutes or more. It is never shorter
  than 5 minutes: a shorter until timer starts partly gone. Its fill has two
  parts on that same scale: the time left, solid, and right of it the time
  gone, faint, so the bar is never empty. A timer longer than 30 minutes
  stays all solid until 30 are left. The solid part gets shorter every
  second, and its last pixel fades rather than going at once. Add five makes
  the bar and the solid part 5 minutes longer. When nothing runs, the menu
  bar shows the timer icon instead.
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
  sleeps doesn't stretch it.
- `Timing.swift` has the pure functions, covered by
  `Tests/TimingTests.swift`: `nextUntil` (the until timer's end),
  `wholeSecond` and `secondsLeft` (the rounding of a timer's end and of
  the countdown), `barWidth` (how long the progress bar and the time left
  on it are) and `formatCountdown`.
- `ProgressBar.swift` draws the progress bar, time included, as one template
  image.
- `Notifier` schedules the time's up with macOS and handles its +5 min
  button.
- The texts of the 5 min break and the until timer come word for word from
  the Python version.
