#ifndef TRICKITEMCACHEENGINE_H
#define TRICKITEMCACHEENGINE_H

#include <QObject>
#include <QHash>
#include <QImage>
#include <QSet>
#include <QUrl>
#include <QMutex>

class TrickItemCacheEngine : public QObject
{
    Q_OBJECT
public:
    TrickItemCacheEngine(QObject *parent = nullptr);
    virtual ~TrickItemCacheEngine();

    QImage check(const QUrl &url);
    void cache(const QUrl &url, const QImage &img);
    void release();

private:
    QUrl mCurrentUrl;

    struct Unit {
        QImage image;
        QSet<TrickItemCacheEngine*> objects;
        QTimer *timer = Q_NULLPTR;
    };

    static QHash<QUrl, Unit> mCache;
    static QRecursiveMutex mMutex;
};

#endif // TRICKITEMCACHEENGINE_H
