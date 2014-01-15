QT += quick
TEMPLATE = app
TARGET = Launcher
SOURCES += main.cpp

mac: {
    CONFIG-=app_bundle
}
