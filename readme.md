# MenubarTimer

> Small timer app that lives in menubar

![](screenshot.png)

- Counts down from 5, 25, or 45 minutes
- Counts down until the next whole hour
- Add extra 5 minutes to timer when running
- Optionally displays OS notification with/without sound after countdown is done
- When running, shows only the countdown (like `13:03`) and no icon
- Works with dark/light color scheme

Hat tip to [Camillo Visini](https://github.com/visini) for [this blog post](https://camillovisini.com/article/create-macos-menu-bar-app-pomodoro/) that I based my app on.

## Setup

This is a Python3 app built with [Rumps](https://rumps.readthedocs.io/en/latest/index.html).

```bash
$ python3 -m venv env
$ source env/bin/activate
$ pip3 install -r requirements.txt
$ python3 menubar-timer.py
```

## Build MacOS app

```bash
$ python3 setup.py py2app
```

## Todo

- [ ] Make actual `.icns` file so that menubar icon will look good in notification
- [ ] Turn sound back on after Eval Talk timer is finished/gets stopped
- [ ] Get version info in app file
- [ ] Find a way to build properly on ARM architecture. Workaround to get running on M1/2 is downloading .app file from GitHub, which builds for Intel architecture, and runs via Rosetta

## License

[MIT](license)
