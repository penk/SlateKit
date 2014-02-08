#include <QDebug>
#include <QtQuick>
#include <QtQml/qqml.h>
#include <QtQml/QQmlExtensionPlugin>

class ExecModel : public QObject
{
	Q_OBJECT

public:
	ExecModel(QObject *parent=0) : QObject(parent)
	{
	}

	~ExecModel()
	{
	}

	Q_INVOKABLE void cmd(const QString &s) {
		qDebug() << s;
                QProcess::startDetached(s);
	}
};

class ExecPlugin : public QQmlExtensionPlugin
{
	Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.slatekit.Exec" FILE "exec.json")

public:
	 void registerTypes(const char *uri)
	 {
		qmlRegisterType<ExecModel>(uri, 1, 0, "Exec");
	 }

};

#include "plugin.moc"
