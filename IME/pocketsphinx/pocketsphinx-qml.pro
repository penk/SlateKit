TEMPLATE = lib
CONFIG += qt plugin
QT += declarative

DESTDIR = net/sourceforge/cmusphinx 
TARGET  = qmlpocketsphinxplugin

SOURCES += plugin.cpp

unix {
    CONFIG += link_pkgconfig
    PKGCONFIG += QtGStreamer-0.10 QtGStreamerUi-0.10
}
