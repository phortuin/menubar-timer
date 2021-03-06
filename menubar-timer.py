from datetime import datetime

import rumps
rumps.debug_mode(True)

# Icon font:
# https://fonts.google.com/icons?selected=Material%20Icons%3Atimer
config = {
    'app_name': "MenubarTimer",
    'app_icon': 'menubar-icon.png',
    'button_until': "Start timer until ",
    'button_add_five': "Add 5 mins to timer",
    'button_stop': "Stop & clear timer",
    'setting_notifications': "Allow notifications",
    'setting_sound': "Allow sound",
    'notification_until': "Yep, it’s that fucking late already",
}


basic_timer_config = [
    {
        'title': "Start 5 min break",
        'duration': 300,  # 5 minutes
        'notification': "Back to work you fucking slacker",
    },
    {
        'title': "Start 25 min work",
        'duration': 1500,  # 25 minutes
        'notification': "Slow it down motherfucker",
    },
    {
        'title': "Start eval talk",
        'duration': 2700,  # 45 minutes
        'notification': "Wrap it up!",
    }
]


def get_next_until():
    now = datetime.now()
    uur = now.replace(second=0, minute=59)
    halfuur = now.replace(second=0, minute=29)
    return uur if now > halfuur else halfuur


class MenubarTimerApp():
    def __init__(self):
        self.app = rumps.App(
            name=config['app_name'],
            icon=config['app_icon'],
            template=True  # Automagic support for light & dark mode
        )
        self.buttons_basic_timers = []
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
        for basic_timer in basic_timer_config:
            menu_item = rumps.MenuItem(
                title=basic_timer['title']
            )
            menu_item.duration = basic_timer['duration']
            menu_item.notification = basic_timer['notification']
            self.buttons_basic_timers.append(menu_item)
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
            *self.buttons_basic_timers,
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
        for button in self.buttons_basic_timers:
            button.set_callback(self.handle_basic_timers)
        self.button_until.set_callback(self.handle_button_until)
        self.button_add_five.set_callback(None)
        self.button_stop.set_callback(None)
        self.app.icon = config['app_icon']
        self.app.title = None

    def set_until_button(self):
        self.button_until.title = config['button_until'] + \
            get_next_until().strftime('%H:%M')

    def handle_basic_timers(self, sender):
        self.notification = sender.notification
        self.start_timer(sender.duration)

    def handle_button_until(self, _):
        self.notification = config['notification_until']
        seconds_until_next_hour = (
            get_next_until() - datetime.now()
        ).total_seconds()
        self.start_timer(seconds_until_next_hour)

    def start_timer(self, duration):
        for button in self.buttons_basic_timers:
            button.set_callback(None)
        self.button_until.set_callback(None)
        self.button_add_five.set_callback(self.handle_button_add_five)
        self.button_stop.set_callback(self.handle_button_stop)
        self.app.title = ' '
        self.app.icon = None
        self.timer.ticks = 0
        self.timer.duration = int(duration)
        self.timer.start()

    def handle_button_add_five(self, _):
        self.timer.duration += 300  # 5 minutes

    def update_setting_notifications(self, sender):
        sender.state = not sender.state
        if sender.state == 0:
            self.setting_sound.set_callback(None)
            if self.setting_sound.state == 1:
                self.setting_sound.state = -1
        if sender.state == 1:
            self.setting_sound.set_callback(self.update_setting_sound)
            if (self.setting_sound.state == -1):
                self.setting_sound.state = 1

    def update_setting_sound(self, sender):
        sender.state = not sender.state

    def handle_button_stop(self, _):
        self.stop_timer()

    def stop_timer(self):
        self.timer.stop()
        self.reset_menu()

    def on_tick(self, sender):
        time_left = sender.duration - sender.ticks
        if time_left <= 0:
            if self.setting_notifications.state:
                rumps.notification(
                    "Time’s up",
                    subtitle=self.notification,
                    message='',
                    sound=bool(self.setting_sound.state)
                )
            self.stop_timer()
        else:
            self.app.title = self.get_pretty_time(time_left)
        sender.ticks += 1

    def on_update_tick(self, _):
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
