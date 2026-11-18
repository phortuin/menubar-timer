# MenubarTimer — project notes

A menu bar timer for macOS 27, SwiftUI (`MenuBarExtra`), no Dock icon. Built
from `project.yml` with XcodeGen; the `.xcodeproj` is generated and not in
git. Signed to run locally (no Apple ID). Until v0.2.1 it was a Python app
on rumps; that version lives in the git history.

## Vocabulary

- **Countdown**: the minutes and seconds in the menu bar while a timer runs.
  When nothing runs, the menu bar shows the timer icon instead.
- **Preset timers**: Start 5 min break, Start 25 min work, Start eval talk.
  Each has its own notification text.
- **Until timer**: Start timer until HH:MM, counting down to the next :29 or
  :59, so there's a minute to spare before the half or full hour.
- **Add five**: Add 5 mins to timer. **Stop**: Stop & clear timer. Both only
  while a timer runs; the preset timers and the until timer only while none
  runs.
- **Notification setting** / **sound setting**: Allow notifications, Allow
  sound. The sound setting is disabled while notifications are off.
- **Time's up**: the notification at the end of a timer, with the timer's
  text as subtitle and the Funk sound. It is handed to macOS when the timer
  starts, so it comes on time whatever the app is doing.
- **Notification button**: the one button on time's up. Start 5 min break
  after 25 min work, Start 25 min work after 5 min break, +5 min after the
  others (a new 5-minute timer with the same text).
- **End time**: "Ends at HH:MM" in the menu while a timer runs.

## Code

- `Countdown` holds the one running timer as an end time, so a Mac that
  sleeps doesn't stretch it.
- `Timing.swift` has the pure functions (`nextUntil`, `formatCountdown`),
  covered by `Tests/TimingTests.swift`.
- Menu texts are kept word for word from the Python version.
