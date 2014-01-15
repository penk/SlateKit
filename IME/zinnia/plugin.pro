TEMPLATE = lib
CONFIG += qt plugin
QT += qml quick

DESTDIR = Zinnia
TARGET  = qmlzinniaplugin

SOURCES += plugin.cpp

lib.files = Zinnia 
lib.path = $$[QT_INSTALL_QML]
INSTALLS += lib

unix {
    #INCLUDEPATH += "/usr/local/include"
    #LIBS += "-L/usr/local/lib -lzinnia -lstdc++"
    CONFIG += link_pkgconfig
    PKGCONFIG += zinnia
}
