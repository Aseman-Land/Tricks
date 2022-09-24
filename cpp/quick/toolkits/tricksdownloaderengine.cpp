#include "tricksdownloaderengine.h"

#include <QDate>
#include <QDir>
#include <QMutexLocker>
#include <QCryptographicHash>
#include <QImageReader>
#include <QSize>

#define SIZE_TO_STRING(S) QStringLiteral("%1x%2").arg(S.width()).arg(S.height())
#define STRING_TO_SIZE(S) [](const QString &s){ \
        auto l = s.split('x'); \
        return QSize(l.first().toInt(), l.last().toInt()); \
    }(S)

QHash<QUrl, TricksDownloaderEngine::DownloadUnit> TricksDownloaderEngine::mDownloadUnits;
QRecursiveMutex TricksDownloaderEngine::mMutex;
QThreadPool *TricksDownloaderEngine::mThreadPool = Q_NULLPTR;

TricksDownloaderEngine::TricksDownloaderEngine(QObject *parent)
    : QObject(parent)
{
    mStartTimer = new QTimer(this);
    mStartTimer->setSingleShot(false);
    mStartTimer->setInterval(10);

    connect(mStartTimer, &QTimer::timeout, this, &TricksDownloaderEngine::doStart);
}

TricksDownloaderEngine::~TricksDownloaderEngine()
{
    stop();
}

QString TricksDownloaderEngine::cachePath() const
{
    return mCachePath;
}

void TricksDownloaderEngine::setCachePath(const QString &newCachePath)
{
    if (mCachePath == newCachePath)
        return;
    mCachePath = newCachePath;
    Q_EMIT cachePathChanged();
}

QVariantMap TricksDownloaderEngine::headers() const
{
    return mHeaders;
}

void TricksDownloaderEngine::setHeaders(const QVariantMap &newHeaders)
{
    if (mHeaders == newHeaders)
        return;
    mHeaders = newHeaders;
    Q_EMIT headersChanged();
}

QUrl TricksDownloaderEngine::url() const
{
    return mUrl;
}

void TricksDownloaderEngine::setUrl(const QUrl &newUrl)
{
    if (mUrl == newUrl)
        return;
    mUrl = newUrl;
    Q_EMIT urlChanged();
}

bool TricksDownloaderEngine::downloading() const
{
    return mDownloading;
}

void TricksDownloaderEngine::setDownloading(bool newDownloading)
{
    if (mDownloading == newDownloading)
        return;
    mDownloading = newDownloading;
    Q_EMIT downloadingChanged();
}

qint32 TricksDownloaderEngine::totalSize() const
{
    return mTotalSize;
}

void TricksDownloaderEngine::start()
{
    mStartTimer->stop();
    mStartTimer->start();
}

void TricksDownloaderEngine::doStart()
{
    stop();
    mStartedUrl = mUrl;

    if (mUrl.isEmpty() || !mUrl.isValid())
        return;

    const auto url = mUrl;
    QMutexLocker lock(&mMutex);
    if (mDownloadUnits.contains(mUrl))
    {
        auto &u = mDownloadUnits[mUrl];
        if (!u.engines.contains(this))
        {
            u.engines << this;
            connect(this, &TricksDownloaderEngine::destroyed, this, [url, this](){
                if (!mDownloadUnits.contains(url))
                    return;

                auto &u = mDownloadUnits[url];
                u.engines.remove(this);
            });
        }
        return;
    }

    const auto current_days = QDate::currentDate().toJulianDay();
    const auto current_folder = QString::number(current_days);
    const auto root_path = mCachePath + "/downloader-engine/";

    for (const auto &d: QDir(root_path).entryList(QDir::Dirs | QDir::NoDotAndDotDot))
    {
        // Delete old cache directories
        if (d.toInt() >= current_days-1)
            continue;

        QDir(d).removeRecursively();
    }

    auto url_string = mUrl.toString();
    const auto question_idx = url_string.indexOf('?');
    if (question_idx > 0)
        url_string = url_string.left(question_idx);
    const auto hash_idx = url_string.indexOf('#');
    if (hash_idx > 0)
        url_string = url_string.left(hash_idx);

    QString suffix;
    const auto suffix_idx = url_string.lastIndexOf('.');
    if (suffix_idx > 0)
        suffix = url_string.mid(suffix_idx+1);
    if (suffix.length())
        suffix = '.' + suffix;

    const auto current_file = QCryptographicHash::hash(url_string.toUtf8(), QCryptographicHash::Md5).toHex() + suffix;
    const auto file_parent = root_path + '/' + current_folder;
    const auto file_path = file_parent + '/' + current_file;

    if (QFileInfo::exists(file_path))
    {
        TricksDownloaderEngine::emitFinished({this}, file_path);
        return;
    }

    QDir().mkpath(file_parent);

    auto &u = mDownloadUnits[mUrl];
    u.engines << this;
    u.url = mUrl;
    u.am = new QNetworkAccessManager;
    u.file = new QFile(file_parent + '/' + QUuid::createUuid().toString(QUuid::WithoutBraces) + suffix);
    u.file->open(QFile::WriteOnly);

    QNetworkRequest req;
    req.setUrl(mUrl);

    QMapIterator<QString, QVariant> i(mHeaders);
    while (i.hasNext())
    {
        i.next();
        req.setRawHeader(i.key().toUtf8(), i.value().toString().toUtf8());
    }

    u.reply = u.am->get(req);
    connect(this, &TricksDownloaderEngine::destroyed, this, [url, this](){
        if (!mDownloadUnits.contains(url))
            return;

        auto &u = mDownloadUnits[url];
        u.engines.remove(this);
    });
    connect(u.reply, &QNetworkReply::readyRead, [u](){
        u.file->write(u.reply->readAll());
    });
    connect(u.reply, &QNetworkReply::finished, [u, file_path](){
        if (!u.file)
            return;

        u.file->close();
        QFile::rename(u.file->fileName(), file_path);
        TricksDownloaderEngine::emitFinished(mDownloadUnits.value(u.url).engines, file_path);
        TricksDownloaderEngine::deleteUnit(u.url);
    });
    connect(u.reply, &QNetworkReply::downloadProgress, [u, file_path](qint64 bytesReceived, qint64 bytesTotal){
        QMutexLocker lock(&mMutex);
        auto new_u = mDownloadUnits.value(u.url);
        for (auto e: new_u.engines)
        {
            e->setTotalSize(bytesTotal);
            e->setDownloaded(bytesReceived);
        }
    });
    connect(u.reply, static_cast<void(QNetworkReply::*)(QNetworkReply::NetworkError)>(&QNetworkReply::error), [u](){
        if (!u.file)
            return;

        u.file->close();
        u.file->remove();

        QMutexLocker lock(&mMutex);
        auto new_u = mDownloadUnits.value(u.url);
        for (auto e: new_u.engines)
            e->setError(u.reply->errorString());
    });
}

void TricksDownloaderEngine::stop()
{
    mStartTimer->stop();
    if (mStartedUrl.isEmpty() || !mStartedUrl.isValid())
        return;

    QMutexLocker lock(&mMutex);
    if (!mDownloadUnits.contains(mStartedUrl))
        return;

    auto u = mDownloadUnits[mStartedUrl];
    if (!u.engines.contains(this))
        return;

    disconnect(this, &QObject::destroyed, this, &TricksDownloaderEngine::stop);

    mStartedUrl = QUrl();

    u.engines.remove(this);
    mDownloadUnits[mStartedUrl] = u;

    if (u.engines.isEmpty())
        TricksDownloaderEngine::deleteUnit(u.url);
}

void TricksDownloaderEngine::setTotalSize(qint32 newTotalSize)
{
    if (mTotalSize == newTotalSize)
        return;
    mTotalSize = newTotalSize;
    Q_EMIT totalSizeChanged();
}

void TricksDownloaderEngine::emitFinished(const QSet<TricksDownloaderEngine *> &engines, const QString &path)
{
    QHash<QString, QSet<TricksDownloaderEngine*>> sizes;
    for(auto e: engines)
    {
        const auto s = e->imageSize();
        if (!s.isNull())
            sizes[SIZE_TO_STRING(s)].insert(e);
        Q_EMIT e->finished(path);
    }

    if (!mThreadPool)
        mThreadPool = new QThreadPool;

    QHashIterator<QString, QSet<TricksDownloaderEngine*>> i(sizes);
    while (i.hasNext())
    {
        i.next();
        const auto size = i.key();

        auto finisher = new TricksDownloaderEngineFinisher;
        for (auto e: i.value())
            connect(finisher, &TricksDownloaderEngineFinisher::finished, e, &TricksDownloaderEngine::finishedImage, Qt::QueuedConnection);
        connect(finisher, &TricksDownloaderEngineFinisher::finished,
                finisher, &TricksDownloaderEngineFinisher::deleteLater, Qt::QueuedConnection);

        auto runnable = [size, finisher, path]() {
            QImageReader r(path);

            const auto request_size = STRING_TO_SIZE(size);
            const auto size = r.size();

            r.setScaledSize(size.scaled(request_size, Qt::KeepAspectRatioByExpanding));

            const auto &img = r.read();
            QMetaObject::invokeMethod(finisher, "finished", Qt::QueuedConnection, Q_ARG(QImage, img));
        };

        mThreadPool->start(runnable);
    }
}

void TricksDownloaderEngine::deleteUnit(const QUrl &url)
{
    QMutexLocker lock(&mMutex);
    auto u = mDownloadUnits.value(url);

    if (u.reply) u.reply->deleteLater();
    if (u.am) u.am->deleteLater();
    if (u.file) {
        u.file->close();
        u.file->remove();
        u.file->deleteLater();
    }

    mDownloadUnits.remove(url);
}

QString TricksDownloaderEngine::error() const
{
    return mError;
}

void TricksDownloaderEngine::setError(const QString &newError)
{
    if (mError == newError)
        return;
    mError = newError;
    Q_EMIT errorChanged();
}

QSize TricksDownloaderEngine::imageSize() const
{
    return mImageSize;
}

void TricksDownloaderEngine::setImageSize(const QSize &newImageSize)
{
    if (mImageSize == newImageSize)
        return;
    mImageSize = newImageSize;
    Q_EMIT imageSizeChanged();
}

qint32 TricksDownloaderEngine::downloaded() const
{
    return mDownloaded;
}

void TricksDownloaderEngine::setDownloaded(qint32 newDownloaded)
{
    if (mDownloaded == newDownloaded)
        return;
    mDownloaded = newDownloaded;
    Q_EMIT downloadedChanged();
}
