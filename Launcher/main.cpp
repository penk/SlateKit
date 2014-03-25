#include <QGuiApplication>
#include <QQuickView>
#include <QQuickItem>
#include <QDebug>
#if defined(ENABLE_COMPOSITING)
#include <QOpenGLContext>
#include "QtQuick/private/qsgcontext_p.h"
#endif
class Launcher: public QGuiApplication {
    Q_OBJECT
public: 
      Launcher(int argc, char* argv[]): QGuiApplication(argc,argv) {
          view.setSource(QUrl("./main.qml"));
          view.show();
          view.installEventFilter(this);

          // Necessary for Screen.orientation (from import QtQuick.Window 2.0) to work
          QGuiApplication::primaryScreen()->setOrientationUpdateMask(
            Qt::PortraitOrientation |
            Qt::LandscapeOrientation |
            Qt::InvertedPortraitOrientation |
            Qt::InvertedLandscapeOrientation);

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
#if defined(ENABLE_COMPOSITING)
    QOpenGLContext glcontext;
    glcontext.create();
    QSGContext::setSharedOpenGLContext(&glcontext);
#endif
    return app.exec();
}

#include "main.moc"
