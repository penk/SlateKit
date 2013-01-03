TEMPLATE = lib
CONFIG += qt plugin
QT += qml quick

DESTDIR = Fakekey
TARGET  = qmlfakekeyplugin

SOURCES += plugin.cpp

unix {
    CONFIG += link_pkgconfig
    PKGCONFIG += libfakekey x11
}
