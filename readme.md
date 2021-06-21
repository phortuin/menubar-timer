# MenubarTimer

> Small timer app that lives in menubar

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
