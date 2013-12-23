TEMPLATE = app
TARGET = slatekit

QT += qml quick quick quick-private webkit webkit-private
SOURCES += main.cpp
RESOURCES += resources.qrc

mac: {
    #CONFIG -= app_bundle
    QMAKE_POST_LINK += macdeployqt slatekit.app -qmldir=qml/
}
