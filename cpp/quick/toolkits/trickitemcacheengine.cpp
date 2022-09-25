#include "trickitemcacheengine.h"

#include <QPointer>
#include <QTimer>

QHash<QUrl, TrickItemCacheEngine::Unit> TrickItemCacheEngine::mCache;
QRecursiveMutex TrickItemCacheEngine::mMutex;

TrickItemCacheEngine::TrickItemCacheEngine(QObject *parent)
    : QObject(parent)
{
}

TrickItemCacheEngine::~TrickItemCacheEngine()
{
    release();
}

QImage TrickItemCacheEngine::check(const QUrl &url)
{
    QMutexLocker lock(&mMutex);
    release();
    mCurrentUrl = url;
    if (!mCache.contains(mCurrentUrl))
        return QImage();

    auto &u = mCache[mCurrentUrl];
    u.objects.insert(this);

    return u.image;
}

void TrickItemCacheEngine::cache(const QUrl &url, const QImage &img)
{
    QMutexLocker lock(&mMutex);
    release();
    if (url.isEmpty())
        return;

    mCurrentUrl = url;
    auto &u = mCache[mCurrentUrl];
    u.image = img;
    u.objects.insert(this);

    if (u.timer)
    {
        QMetaObject::invokeMethod(u.timer, &QTimer::deleteLater, Qt::QueuedConnection);
        u.timer = Q_NULLPTR;
    }
}

void TrickItemCacheEngine::release()
{
    QMutexLocker lock(&mMutex);
    if (!mCache.contains(mCurrentUrl))
        return;

    auto &u = mCache[mCurrentUrl];
    u.objects.remove(this);
    if (u.objects.isEmpty())
    {
        u.timer = new QTimer;
        u.timer->setInterval(5000);
        u.timer->setSingleShot(true);
        u.timer->start();

        auto url = mCurrentUrl;
        auto timer = u.timer;
        connect(u.timer, &QTimer::timeout, [url, timer](){
            QMutexLocker lock(&mMutex);
            timer->deleteLater();
            if (mCache.value(url).objects.isEmpty())
                mCache.remove(url);
            else
                mCache[url].timer = Q_NULLPTR;
        });
    }
}
