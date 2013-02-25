#include <QDebug>
#include <QtQuick>
#include <QtQml/qqml.h>
#include <QtQml/QQmlExtensionPlugin>

#include <QGuiApplication>
#include <QQuickItem>
#include <QQuickWindow>

class FakekeyModel : public QObject
{
Q_OBJECT

public:
  FakekeyModel(QObject *parent=0) : QObject(parent) {
}

~FakekeyModel() {
}

Q_INVOKABLE int sendKey(const QString &msg) {

    QQuickItem * receiver = qobject_cast<QQuickItem *>(QGuiApplication::focusObject());
    if (!receiver) { 
        qDebug() << "simulateKeyPressEvent(): GuiApplication::focusObject() is 0 or not a QQuickItem."; 
        return 1; 
    }

    if(msg.startsWith(":enter")){
        QKeyEvent pressEvent = QKeyEvent(QEvent::KeyPress, Qt::Key_Return, Qt::NoModifier);
        QKeyEvent releaseEvent = QKeyEvent(QEvent::KeyRelease, Qt::Key_Return, Qt::NoModifier);
        receiver->window()->sendEvent(receiver, &pressEvent);
        receiver->window()->sendEvent(receiver, &releaseEvent);
        return 0;
    }

    if(msg.startsWith(":backspace")){
        QKeyEvent pressEvent = QKeyEvent(QEvent::KeyPress, Qt::Key_Backspace, Qt::NoModifier);
        QKeyEvent releaseEvent = QKeyEvent(QEvent::KeyRelease, Qt::Key_Backspace, Qt::NoModifier);
        receiver->window()->sendEvent(receiver, &pressEvent);
        receiver->window()->sendEvent(receiver, &releaseEvent);
        return 0;
    }

    QKeyEvent pressEvent = QKeyEvent(QEvent::KeyPress, 0, Qt::NoModifier, QString(msg));
    QKeyEvent releaseEvent = QKeyEvent(QEvent::KeyRelease, 0, Qt::NoModifier, QString(msg));
    receiver->window()->sendEvent(receiver, &pressEvent);
    receiver->window()->sendEvent(receiver, &releaseEvent);
    return 0;
}

public: 
QQuickItem *receiver;
};

class FakekeyPlugin : public QQmlExtensionPlugin
{
Q_OBJECT
  Q_PLUGIN_METADATA(IID "org.slatekit.Fakekey" FILE "fakekey.json")

public:
  void registerTypes(const char *uri)
  {
      qmlRegisterType<FakekeyModel>(uri, 1, 0, "Fakekey");
  }

};

#include "plugin.moc"
