#ifndef TRICKSDOWNLOADERENGINE_H
#define TRICKSDOWNLOADERENGINE_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QMutex>
#include <QFile>
#include <QSize>
#include <QPointer>
#include <QTimer>

#ifndef Q_OS_WASM
#include <QThread>
#include <QThreadPool>
#endif

class TricksDownloaderEngineFinisher: public QObject
{
    Q_OBJECT
public:
    TricksDownloaderEngineFinisher(QObject *parent = nullptr) : QObject(parent) {}
    virtual ~TricksDownloaderEngineFinisher() {}

Q_SIGNALS:
    void finished(const QImage &img);
};

class TricksDownloaderEngine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString cachePath READ cachePath WRITE setCachePath NOTIFY cachePathChanged)
    Q_PROPERTY(QVariantMap headers READ headers WRITE setHeaders NOTIFY headersChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(bool downloading READ downloading NOTIFY downloadingChanged)
    Q_PROPERTY(qint32 downloaded READ downloaded NOTIFY downloadedChanged)
    Q_PROPERTY(qint32 totalSize READ totalSize NOTIFY totalSizeChanged)
    Q_PROPERTY(QSize imageSize READ imageSize WRITE setImageSize NOTIFY imageSizeChanged)
    Q_PROPERTY(QString error READ error WRITE setError NOTIFY errorChanged)

public:
    TricksDownloaderEngine(QObject *parent = nullptr);
    virtual ~TricksDownloaderEngine();

    QString cachePath() const;
    void setCachePath(const QString &newCachePath);

    QVariantMap headers() const;
    void setHeaders(const QVariantMap &newHeaders);

    QUrl url() const;
    void setUrl(const QUrl &newUrl);

    bool downloading() const;
    qint32 downloaded() const;
    qint32 totalSize() const;

    QSize imageSize() const;
    void setImageSize(const QSize &newImageSize);

    QString error() const;

public Q_SLOTS:
    void start();
    void stop();

Q_SIGNALS:
    void cachePathChanged();
    void headersChanged();
    void urlChanged();
    void downloadingChanged();
    void downloadedChanged();
    void totalSizeChanged();
    void finished(const QString &path);
    void finishedImage(const QImage &image);
    void imageSizeChanged();
    void errorChanged();

protected:
    void setDownloading(bool newDownloading);
    void setDownloaded(qint32 newDownloaded);
    void setTotalSize(qint32 newTotalSize);
    void setError(const QString &newError);
    void doStart();

    static void emitFinished(const QSet<TricksDownloaderEngine*> &engines, const QString &path);
    static void deleteUnit(const QUrl &url);

private:
    QString mCachePath;
    QVariantMap mHeaders;
    QUrl mUrl;
    bool mDownloading = false;
    qint32 mDownloaded = 0;
    qint32 mTotalSize = 0;
    QSize mImageSize;
    QString mError;

    QTimer *mStartTimer;

    struct DownloadUnit {
        QPointer<QFile> file;
        QPointer<QNetworkAccessManager> am;
        QUrl url;
        QPointer<QNetworkReply> reply;
        QSet<TricksDownloaderEngine*> engines;
    };

    QUrl mStartedUrl;

    static QHash<QUrl, DownloadUnit> mDownloadUnits;
    static QRecursiveMutex mMutex;
#ifndef Q_OS_WASM
    static QThreadPool *mThreadPool;
#endif
};

#endif // TRICKSDOWNLOADERENGINE_H
