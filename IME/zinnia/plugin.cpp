#include <QtDeclarative/QDeclarativeExtensionPlugin>
#include <QtDeclarative/qdeclarative.h>
#include <QProcess>
#include <qdebug.h>
#include <qapplication.h>

#include <QTextCodec>
#include <zinnia.h>


 class TimeModel : public QObject
 {
     Q_OBJECT

 public:
     TimeModel(QObject *parent=0) : QObject(parent)
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

     ~TimeModel()
     {
     }

    Q_INVOKABLE void clear() {
        qDebug() << "character cleared";
        character->clear();
    }


Q_INVOKABLE QString query(int s, int x, int y) {

    QTextCodec::setCodecForCStrings(QTextCodec::codecForName("UTF-8"));

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

 class QZinniaQmlPlugin : public QDeclarativeExtensionPlugin
 {
     Q_OBJECT
 public:
     void registerTypes(const char *uri)
     {
         Q_ASSERT(uri == QLatin1String("org.slatekit.Zinnia"));
         qmlRegisterType<TimeModel>(uri, 1, 0, "Zinnia");
     }
 };

 #include "plugin.moc"

 Q_EXPORT_PLUGIN2(qmlzinniaplugin, QZinniaQmlPlugin);
