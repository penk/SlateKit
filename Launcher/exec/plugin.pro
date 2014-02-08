TEMPLATE = lib
CONFIG += qt plugin
QT += qml quick

DESTDIR = Exec  
TARGET  = qmlexecplugin

SOURCES += plugin.cpp

lib.files = Exec 
lib.path = $$[QT_INSTALL_QML]
INSTALLS += lib
