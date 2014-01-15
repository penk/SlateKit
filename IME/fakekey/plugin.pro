TEMPLATE = lib
CONFIG += qt plugin
QT += qml quick

DESTDIR = Fakekey
TARGET  = qmlfakekeyplugin
SOURCES += plugin.cpp

lib.files = Fakekey
lib.path = $$[QT_INSTALL_QML]

INSTALLS += lib
