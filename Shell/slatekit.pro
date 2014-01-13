TEMPLATE = app
TARGET = SlateKit

QT += qml quick 
SOURCES += main.cpp
RESOURCES += resources.qrc

mac: {
    #CONFIG -= app_bundle
    ICON = icon.icns 
    OTHER_FILES += Info.plist
    QMAKE_INFO_PLIST = Info.plist
    #QMAKE_POST_LINK += macdeployqt slatekit.app -qmldir=qml/
}
