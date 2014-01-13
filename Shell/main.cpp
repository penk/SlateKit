#include <QtQuick/QQuickView>
#include <QtGui/QGuiApplication>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickView view;

    view.setSource(QUrl("qrc:///qml/Shell.qml"));
    view.show();

    return app.exec();
}
