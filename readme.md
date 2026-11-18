# MenubarTimer

> Small timer app that lives in menubar

![](screenshot.png)

- Counts down a 5 min break, or a 30 or 60 min meeting
- Counts down until the next :29 or :59, a minute before the half or full hour
- Add extra 5 minutes to timer when running
- Shows when the running timer ends in the menu
- Notifies you when time is up, with the Funk sound and a +5 min button
- When running, shows the time left and a progress bar instead of the icon
- Works with dark/light color scheme

Hat tip to [Camillo Visini](https://github.com/visini) for [this blog post](https://camillovisini.com/article/create-macos-menu-bar-app-pomodoro/) that the first, Python version was based on.

## Download

Get `MenubarTimer.app.zip` from the [latest release](https://github.com/phortuin/menubar-timer/releases/latest), unzip it and move the app to Applications. It needs macOS 27.

The app isn't notarized by Apple, so macOS blocks it the first time you open it. Go to System Settings → Privacy & Security, scroll down to the message about MenubarTimer and choose Open Anyway. After that it opens normally.

## Build

A native SwiftUI app for macOS 27. The Xcode project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```bash
$ brew install xcodegen
$ xcodegen
$ xcodebuild -scheme MenubarTimer -configuration Release -derivedDataPath build
$ cp -R build/Build/Products/Release/MenubarTimer.app /Applications/
```

To publish a release, raise `MARKETING_VERSION` in `project.yml`, commit and push, then run `scripts/release.sh`. It builds the app and creates the GitHub release with the zip, which needs the [GitHub CLI](https://cli.github.com).

Run the tests with `xcodebuild test -scheme MenubarTimer -destination 'platform=macOS'`. The app icon is drawn in code: `swift design/icon.swift` renders it into the asset catalog.

## Todo

- [ ] A readme screenshot of the current menu and progress bar, over a plain desktop

## License

[MIT](license)
