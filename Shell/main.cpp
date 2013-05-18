#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>
#include "private/qquickwebview_p.h"
#include "private/qquickflickable_p.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickView view;

    //QQuickWebViewExperimental::setFlickableViewportEnabled(false);
    view.setSource(QUrl("./qml/Shell.qml"));
    //view.setMinimumSize(QSize(480, 320));
    view.show();

    return app.exec();
}
