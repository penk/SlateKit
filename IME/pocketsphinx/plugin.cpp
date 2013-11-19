#include <QtDeclarative/QDeclarativeExtensionPlugin>
#include <QtDeclarative/qdeclarative.h>
#include <QProcess>
#include <qdebug.h>
#include <qapplication.h>

#include <QGlib/Error>
#include <QGlib/Connect>
#include <QGst/Init>
#include <QGst/ElementFactory>
#include <QGst/ChildProxy>
#include <QGst/PropertyProbe>
#include <QGst/Pipeline>
#include <QGst/Pad>
#include <QGst/Event>
#include <QGst/Message>
#include <QGst/Bus>

class SphinxModel: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString recognitionResult
             READ recognitionResult
             WRITE setRecognitionResult
             NOTIFY recognitionResultChanged)

public:
    SphinxModel(QObject *parent=0) : QObject(parent)
    {
QGst::init();


m_pipeline = QGst::Pipeline::create();
    try {
        audioBin = QGst::Bin::fromDescription("alsasrc ! audioconvert ! vader name=vad auto_threshold=true ! "
						"pocketsphinx name=asr ! fdsink fd=1");
    } catch (const QGlib::Error & error) {
        qCritical() << "Failed to create audio source bin:" << error;
    } 

	if(!audioBin) { qCritical() << "Can't create bin"; } 

m_pipeline->add(audioBin);


QGst::ElementPtr asr = audioBin->getElementByName("asr");


// parameters for English dict 
//asr->setProperty("lm", "./model/lm/wsj/wlist5o.3e-7.vp.tg.lm.DMP");
//asr->setProperty("dict", "./model/lm/wsj/wlist5o.dic");
//asr->setProperty("hmm", "./model/hmm/wsj1");
asr->setProperty("samprate", 8000);
asr->setProperty("cmn", "prior");
asr->setProperty("nfft", 256);
asr->setProperty("fwdflat", false);
asr->setProperty("bestpath", false);
asr->setProperty("maxhmmpf", 1000);
asr->setProperty("maxwpf", 10);

QGlib::connect(asr, "result", this, &SphinxModel::setRecognitionResult); 

m_pipeline->setState(QGst::StatePlaying);
    }

    ~SphinxModel()
    {
    }

Q_INVOKABLE void start() {
        qDebug() << "PocketPhinx started";
        m_pipeline->setState(QGst::StatePlaying);
    }

Q_INVOKABLE void pause() {
        qDebug() << "PocketPhinx paused";
        m_pipeline->setState(QGst::StatePaused);
    }

void setRecognitionResult(const QString &c) {
	qDebug() << c;
         if (c != m_result) {
             m_result = c;
             emit recognitionResultChanged(c);
         }
     }

     QString recognitionResult() const {
         return m_result;
     }

signals:
     void recognitionResultChanged(const QString &result);

private:
     QString m_result;

public: 
    QGst::PipelinePtr m_pipeline;
    QGst::BinPtr audioBin;
};

class QPocketSphinxQmlPlugin : public QDeclarativeExtensionPlugin
{
     Q_OBJECT
 public:
     void registerTypes(const char *uri)
     {
         Q_ASSERT(uri == QLatin1String("net.sourceforge.cmusphinx"));
         qmlRegisterType<SphinxModel>(uri, 1, 0, "PocketSphinx");
     }
};

#include "plugin.moc"

Q_EXPORT_PLUGIN2(qmlpocketsphinxplugin, QPocketSphinxQmlPlugin);
