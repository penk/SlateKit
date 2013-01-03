#include <QDebug>
#include <QtQuick>
#include <QtQml/qqml.h>
#include <QtQml/QQmlExtensionPlugin>

#include <X11/Xlib.h>
#include <fakekey/fakekey.h>

class FakekeyModel : public QObject
{
	Q_OBJECT

public:
	FakekeyModel(QObject *parent=0) : QObject(parent)
	{
		display = XOpenDisplay(NULL);
		fakekey = fakekey_init(display);
	}

	~FakekeyModel()
	{
	}

	Q_INVOKABLE int sendKey(const QString &msg) {

		if(msg.startsWith(":enter")){
			fakekey_press_keysym(fakekey, XK_Return, 0);
			fakekey_release(fakekey);
			return 0;
    	}

		if(msg.startsWith(":backspace")){
			fakekey_press_keysym(fakekey, XK_BackSpace, 0);
			fakekey_release(fakekey);
			return 0;
		}

		QByteArray array = msg.toUtf8();
		fakekey_press(fakekey, (unsigned char *)(array.constData()), array.length(), 0);
		fakekey_release(fakekey);
		return 0;
	}

public: 
	Display* display;
	FakeKey *fakekey;
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
