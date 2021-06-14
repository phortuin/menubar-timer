from datetime import datetime, timedelta
from enum import Enum

import rumps
rumps.debug_mode(True)

class TimerType(Enum):
    BREAK = 1
    WORK = 2
    UNTIL = 3
    EVAL = 4


config = {
    'app_name': "MenubarTimer",
    'app_icon': 'menubar-icon.png',  # https://fonts.google.com/icons?selected=Material%20Icons%3Atimer
    'button_break': "Start 5 min break",
    'button_work': "Start 25 min work",
    'button_eval': "Start eval talk",
    'button_until': "Start timer until ",
    'button_add_five': "Add 5 mins to timer",
    'button_stop': "Stop & clear timer",
    'button_stop_icon': 'timer-off.png',
    'setting_notifications': "Allow notifications",
    'setting_sound': "Allow sound",
    'notifications': {
        TimerType.BREAK: "Back to work you fucking slacker",
        TimerType.WORK: "Slow it down motherfucker",
        TimerType.EVAL: "Wrap it up!",
        TimerType.UNTIL: "Yep it’s that fucking late already"
    },
    'duration_break': 300, # 5 minutes
    'duration_work': 1500, # 25 minutes
    'duration_eval': 2700  # 45 minutes
}


def get_next_hour():
    return datetime.now().replace(second=0, minute=0) - timedelta(hours=-1)


# refactor:
# 1. run_timer krijgt type of timer mee en duration
# 2. decorator voor break en work, want je kan de type of timer en duration als
# properties meegeven aan de menuitems? self.button_break.timer_type = ...etc
# 3. timer.count en end is allemaal zelf bedacht door de auteur van dat artikel.
# een timer is niks anders dan een ticker. je kan ook self.end en self.count
# doen of whatever waar je zin in hebt

class MenubarTimerApp():
    def __init__(self):
        self.app = rumps.App(
            name=config['app_name'],
            icon=config['app_icon'],
            template=True  # Automagic support for light & dark mode
        )
        self.type_of_timer = None
        self.timer = rumps.Timer(
            callback=self.on_tick,
            interval=1
        )
        self.update_timer = rumps.Timer(
            callback=self.on_update_tick,
            interval=60  # Update menu every 60s, to display right 'time until'
        )
        self.update_timer.start()
        self.init_menu()

    def init_menu(self):
        self.button_break = rumps.MenuItem(
            title=config['button_break']
        )
        self.button_work = rumps.MenuItem(
            title=config['button_work']
        )
        self.button_eval = rumps.MenuItem(
            title=config['button_eval']
        )
        self.button_until = rumps.MenuItem(
            title=config['button_until']
        )
        self.button_add_five = rumps.MenuItem(
            title=config['button_add_five']
        )
        self.setting_notifications = rumps.MenuItem(
            title=config['setting_notifications'],
            callback=self.update_setting_notifications
        )
        self.setting_notifications.state = 1
        self.setting_sound = rumps.MenuItem(
            title=config['setting_sound'],
            callback=self.update_setting_sound
        )
        self.setting_sound.state = 1
        self.button_stop = rumps.MenuItem(
            title=config['button_stop']
        )
        self.app.menu = [
            self.button_break,
            self.button_work,
            self.button_eval,
            self.button_until,
            self.button_add_five,
            None,
            self.setting_notifications,
            self.setting_sound,
            None,
            self.button_stop,
            None
        ]
        self.reset_menu()

    def reset_menu(self):
        self.set_until_button()
        self.button_break.set_callback(self.handle_button_break)
        self.button_work.set_callback(self.handle_button_work)
        self.button_eval.set_callback(self.handle_button_eval)
        self.button_until.set_callback(self.handle_button_until)
        self.button_add_five.set_callback(None)
        self.button_stop.set_callback(None)
        self.app.icon = config['app_icon']
        self.app.title = None

    def set_until_button(self):
        self.button_until.title = config['button_until'] + \
            get_next_hour().strftime('%H:%M')

    def handle_button_break(self, sender):
        self.type_of_timer = TimerType.BREAK
        self.run_timer(config['duration_break'])

    def handle_button_work(self, sender):
        self.type_of_timer = TimerType.WORK
        self.run_timer(config['duration_work'])

    def handle_button_eval(self, sender):
        self.type_of_timer = TimerType.EVAL
        self.run_timer(config['duration_eval'])

    def handle_button_until(self, sender):
        self.type_of_timer = TimerType.UNTIL
        seconds_until_next_hour = (
            get_next_hour() - datetime.now()
        ).total_seconds()
        self.run_timer(seconds_until_next_hour)

    def run_timer(self, duration):
        self.button_break.set_callback(None)
        self.button_work.set_callback(None)
        self.button_eval.set_callback(None)
        self.button_until.set_callback(None)
        self.button_add_five.set_callback(self.handle_button_add_five)
        self.button_stop.set_callback(self.handle_button_stop)
        self.timer.count = 0
        self.timer.end = int(duration)
        # Prevent displaying app name; a timer will appear after the next tick
        self.app.title = ' '
        self.app.icon = None
        self.timer.start()

    def handle_button_add_five(self, sender):
        self.timer.end = self.timer.end + config['duration_break']

    def update_setting_notifications(self, sender):
        sender.state = not sender.state
        if sender.state == 0:
            self.setting_sound.set_callback(None)
            if self.setting_sound.state == 1:
                self.setting_sound.state = -1
        if sender.state == 1:
            self.setting_sound.set_callback(self.set_sound)
            if (self.setting_sound.state == -1):
                self.setting_sound.state = 1

    def update_setting_sound(self, sender):
        sender.state = not sender.state

    def handle_button_stop(self, sender):
        self.stop_timer()

    def stop_timer(self):
        self.timer.stop()
        self.timer.count = 0
        self.reset_menu()

    def on_tick(self, sender):
        time_left = sender.end - sender.count
        if time_left <= 0:
            if self.setting_notifications.state:
                rumps.notification(
                    "Time’s up",
                    subtitle=config["notifications"][self.type_of_timer],
                    message='',
                    sound=bool(self.setting_sound.state)
                )
            self.stop_timer()
        else:
            self.app.title = self.get_pretty_time(time_left)
        sender.count += 1

    def on_update_tick(self, sender):
        if not self.timer.is_alive():
            self.set_until_button()

    def get_pretty_time(self, time_left):
        mins = time_left // 60
        secs = time_left % 60
        return '{:2d}:{:02d}'.format(mins, secs)

    def run(self):
        self.app.run()


if __name__ == '__main__':
    app = MenubarTimerApp()
    app.run()
