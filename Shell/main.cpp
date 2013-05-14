#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickView view;

    view.setSource(QUrl("./Shell.qml"));
//    view.setMinimumSize(QSize(480, 320));
    view.show();

    return app.exec();
}
