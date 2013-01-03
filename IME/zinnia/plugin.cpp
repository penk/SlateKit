#include <QDebug>
#include <QtQuick>
#include <QtQml/qqml.h>
#include <QtQml/QQmlExtensionPlugin>

#include <zinnia.h>

class ZinniaModel : public QObject
{
	Q_OBJECT

public:
	ZinniaModel(QObject *parent=0) : QObject(parent)
	{
		recognizer = zinnia::Recognizer::create();
		if (!recognizer->open("/usr/share/tegaki/models/zinnia/handwriting-zh_TW.model"))
			qDebug("can't load model file");
		else qDebug("model \"handwriting-zh_TW.model\" loaded");

		character = zinnia::Character::create();
		character->clear();

		character->set_width(300);
		character->set_height(300);
	}

	~ZinniaModel()
	{
	}

	Q_INVOKABLE void clear() {
		qDebug() << "character cleared";
		character->clear();
	}

	Q_INVOKABLE QString query(int s, int x, int y) {

		str = QString("");
		character->add(s, x, y);

		result = recognizer->classify(*character, 8);
		if (!result) qDebug("can't find resule");

		for (size_t i = 0; i < result->size(); ++i) {
			str.append(result->value(i)).append(" ");
			//qDebug() << result->value(i);
		}

		return str;
	}

public: 
	zinnia::Recognizer *recognizer;
	zinnia::Character *character;
	zinnia::Result *result;
	QString str;
};

class ZinniaPlugin : public QQmlExtensionPlugin
{
	Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.slatekit.Zinnia" FILE "zinnia.json")

public:
	 void registerTypes(const char *uri)
	 {
		qmlRegisterType<ZinniaModel>(uri, 1, 0, "Zinnia");
	 }

};

#include "plugin.moc"
