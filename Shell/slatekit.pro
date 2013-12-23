TEMPLATE = app
TARGET = slatekit

QT += qml quick quick quick-private webkit webkit-private
SOURCES += main.cpp
RESOURCES += resources.qrc

mac: {
    #CONFIG -= app_bundle
    ICON = icon.icns 
    OTHER_FILES += Info.plist
    QMAKE_INFO_PLIST = Info.plist
    QMAKE_POST_LINK += macdeployqt slatekit.app -qmldir=qml/
}
