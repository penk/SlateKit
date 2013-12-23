#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>
#include "private/qquickwebview_p.h"
#include "private/qquickflickable_p.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickView view;

    view.setSource(QUrl("qrc:///qml/Shell.qml"));
    view.show();

    return app.exec();
}
