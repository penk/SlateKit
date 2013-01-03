TEMPLATE = lib
CONFIG += qt plugin
QT += qml quick

DESTDIR = Zinnia
TARGET  = qmlzinniaplugin

SOURCES += plugin.cpp

unix {
    CONFIG += link_pkgconfig
    PKGCONFIG += zinnia
}
