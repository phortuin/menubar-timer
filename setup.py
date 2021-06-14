from setuptools import setup

setup(
    app=['menubar-timer.py'],
    name='MenubarTimer',
    options={'py2app': {
        'iconfile': 'app-icon.png',
        'resources': 'menubar-icon.png',
        'plist': {
            'LSUIElement': True,
        },
    }},
    setup_requires=['py2app'],
    install_requires=['rumps']
)
