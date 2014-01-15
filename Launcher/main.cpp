#include <QGuiApplication>
#include <QQuickView>
#include <QQuickItem>
#include <QDebug>

class Launcher: public QGuiApplication {
    Q_OBJECT
public: 
      Launcher(int argc, char* argv[]): QGuiApplication(argc,argv) {
          view.setSource(QUrl("./main.qml"));
          view.show();
          view.installEventFilter(this);
      };
      QQuickView view;

protected:
    bool eventFilter(QObject *obj, QEvent *event) {
        QKeyEvent *keyEvent = (QKeyEvent *)event;
        if (event->type() == QEvent::KeyRelease) {
            QVariant keycode = keyEvent->key();
            QMetaObject::invokeMethod(view.rootObject(), "handleKey",  Q_ARG(QVariant, keycode));
        }
        return QObject::eventFilter(obj, event);
    };
};

int main(int argc, char* argv[]) {
    Launcher app(argc,argv);
    return app.exec();
}

#include "main.moc"
