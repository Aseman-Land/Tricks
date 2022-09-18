#include "trickitemdelegate.h"

#include <QPainter>
#include <QPainterPath>
#include <QTimer>
#include <QScreen>

#include <QAsemanDevices>
#include <QAsemanApplication>

TrickItemDelegate::TrickItemDelegate(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    mFont.setLetterSpacing(QFont::PercentageSpacing, 94);
    mForegroundColor = QColor("#000000");

    mDatetime = "2 Days ago";

    connect(this, &QQuickItem::widthChanged, this, &TrickItemDelegate::refreshWidth);
}

TrickItemDelegate::~TrickItemDelegate()
{
}

QRectF TrickItemDelegate::bodyRect() const
{
    auto doc = createTextDocument();

    QRectF r;
    r.setX( (width() - mSceneWidth) / 2 + mAvatarSize + mSpacing );
    r.setY(mVerticalPadding + mAvatarSize + mSpacing);
    r.setSize(doc->size());

    delete doc;
    return r;
}

QRectF TrickItemDelegate::contentRect() const
{
    auto doc = createTextDocument();

    QRectF r;
    r.setX( (width() - mSceneWidth) / 2 );
    r.setY(mVerticalPadding);
    r.setWidth(mSceneWidth);
    r.setHeight( doc->size().height() + mAvatarSize + mSpacing);

    delete doc;
    return r;
}

void TrickItemDelegate::refreshWidth()
{
    Q_EMIT bodyRectChanged();
    Q_EMIT contentRectChanged();
}

void TrickItemDelegate::downloadImage()
{
    if (!mImageDownloader)
    {
        mImageDownloader = new TricksDownloaderEngine(this);
        connect(mImageDownloader, &TricksDownloaderEngine::finishedImage, this, [this](const QImage &img){
            qDebug() << "Finished Image" << this << img.size();
            mCacheImage = img;
            update();
        });
    }

    mImageDownloader->stop();
    if (mImageSize.isNull() || mImage.isEmpty() || mCachePath.isEmpty())
        return;

    mImageDownloader->setCachePath(mCachePath);
    mImageDownloader->setImageSize(QSize(bodyRect().width(), bodyRect().width() * mImageSize.height() / mImageSize.width()) * std::max<qreal>(2, QAsemanDevices::deviceDensity()));
    mImageDownloader->setUrl(mImage);
    mImageDownloader->start();
}

void TrickItemDelegate::downloadAvatar()
{
    if (!mAvatarDownloader)
    {
        mAvatarDownloader = new TricksDownloaderEngine(this);
        connect(mAvatarDownloader, &TricksDownloaderEngine::finishedImage, this, [this](const QImage &img){
            qDebug() << "Finished Avatar" << this << img.size();
            mCacheAvatar = img;
            update();
        });
    }

    mAvatarDownloader->stop();
    if (mAvatar.isEmpty() || mCachePath.isEmpty())
        return;

    mAvatarDownloader->setCachePath(mCachePath);
    mAvatarDownloader->setImageSize(QSize(mAvatarSize, mAvatarSize) * std::max<qreal>(2, QAsemanDevices::deviceDensity()));
    mAvatarDownloader->setUrl(mAvatar);
    mAvatarDownloader->start();
}

QTextDocument *TrickItemDelegate::createTextDocument() const
{
    auto doc = new QTextDocument();
    doc->setUseDesignMetrics(true);
    doc->setDefaultFont(mFont);
    doc->setDocumentMargin(0);
    doc->setTextWidth(mSceneWidth - mAvatarSize - mSpacing);
    doc->setHtml(mBody);
    return doc;
}

qreal TrickItemDelegate::imageRoundness() const
{
    return mImageRoundness;
}

void TrickItemDelegate::setImageRoundness(qreal newImageRoundness)
{
    if (qFuzzyCompare(mImageRoundness, newImageRoundness))
        return;
    mImageRoundness = newImageRoundness;
    emit imageRoundnessChanged();
}

QString TrickItemDelegate::cachePath() const
{
    return mCachePath;
}

void TrickItemDelegate::setCachePath(const QString &newCachePath)
{
    if (mCachePath == newCachePath)
        return;
    mCachePath = newCachePath;
    emit cachePathChanged();
}

void TrickItemDelegate::paint(QPainter *painter)
{
    QMutexLocker locker(&mMutex);
    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setRenderHint(QPainter::SmoothPixmapTransform, true);

    mSceneHeight = height() - 2*mVerticalPadding;

    const auto sidePadding = (width() - mSceneWidth)/2;
    const auto fullRect = QRectF(sidePadding, mVerticalPadding, mSceneWidth, mSceneHeight);

    QRectF drawedRect, rect;
    QColor color;
    QFont font, fontIcon;

    // Paint Avatar
    const auto avatarRect = QRectF(fullRect.left(), fullRect.top(), mAvatarSize, mAvatarSize);

    QPainterPath avatar;
    avatar.addRoundedRect(avatarRect, mAvatarSize/2, mAvatarSize/2);

    painter->fillPath(avatar, mHighlightColor);

    if (!mCacheAvatar.isNull())
    {
        painter->setClipPath(avatar);
        painter->drawImage(avatarRect, mCacheAvatar);
        painter->setClipping(false);
    }
    // End Avatar


    // Paint Fullname
    rect = QRectF(avatarRect.topRight(), QPointF(fullRect.right(), fullRect.top()+30));
    rect.setLeft(rect.left() + mSpacing);

    font = mFont;
    font.setBold(true);

    painter->setPen(mForegroundColor);
    painter->setFont(font);
    painter->drawText(rect, Qt::AlignLeft, mFullname, &drawedRect);
    // End Fullname


    // Paint Username
    rect = QRectF(drawedRect.topRight(), QPointF(fullRect.right(), drawedRect.bottom()));
    rect.setLeft(rect.left() + 4);

    color = mForegroundColor;
    color.setAlphaF(0.7);

    painter->setPen(color);
    painter->setFont(mFont);
    painter->drawText(rect, Qt::AlignLeft | Qt::AlignVCenter, '@' + mUsername, &drawedRect);
    // End Username


    // Paint DateTime
    rect = QRectF(drawedRect.topRight(), QPointF(fullRect.right(), drawedRect.bottom()));
    color = mForegroundColor;
    color.setAlphaF(0.7);

    font = mFont;
    font.setPixelSize(mFont.pixelSize() * 8 / 9);

    painter->setPen(color);
    painter->setFont(font);
    painter->drawText(rect, Qt::AlignRight | Qt::AlignVCenter, mDatetime, &drawedRect);
    // End DateTime


    // Paint Tags
    rect = QRectF(QPointF(avatarRect.right() + mSpacing, avatarRect.bottom() - 30), QPointF(fullRect.right(), avatarRect.bottom()));

    fontIcon = mFontIcon;
    fontIcon.setPixelSize(mFontIcon.pixelSize() * 8 / 9);

    painter->setPen(mHighlightColor);
    painter->setFont(fontIcon);
    painter->drawText(rect, Qt::AlignLeft | Qt::AlignBottom, mTagIcon, &drawedRect);

    color = mForegroundColor;
    color.setAlphaF(0.7);

    font = mFont;
    font.setPixelSize(mFont.pixelSize() * 8 / 9);

    bool first_one = true;

    QStringList tagsList;
    tagsList << mLanguage;
    tagsList << mTags;

    for (const auto &t: tagsList)
    {
        if (t.isEmpty())
            continue;

        if (!first_one)
        {
            rect = QRectF(drawedRect.topRight(), QPointF(fullRect.right(), drawedRect.bottom()));

            painter->setPen(mHighlightColor);
            painter->setFont(fontIcon);
            painter->drawText(rect, Qt::AlignLeft | Qt::AlignVCenter, mTagDelimiterIcon, &drawedRect);
        }

        rect = QRectF(drawedRect.topRight(), QPointF(fullRect.right(), drawedRect.bottom()));
        if (first_one)
        {
            rect.setLeft(rect.left() + 4);
            first_one = false;
        }

        painter->setPen(color);
        painter->setFont(font);
        painter->drawText(rect, Qt::AlignLeft | Qt::AlignVCenter, t[0].toUpper() + t.mid(1).toLower(), &drawedRect);
    }
    // End Tags


    // Paint Views
    rect = QRectF(drawedRect.topRight(), QPointF(fullRect.right(), drawedRect.bottom()));
    color = mForegroundColor;
    color.setAlphaF(0.7);

    font = mFont;
    font.setPixelSize(mFont.pixelSize() * 8 / 9);

    painter->setPen(color);
    painter->setFont(font);
    painter->drawText(rect, Qt::AlignRight | Qt::AlignVCenter, QString::number(mViewCount), &drawedRect);

    rect.setRight(drawedRect.left() - 4);

    painter->setPen(mHighlightColor);
    painter->setFont(fontIcon);
    painter->drawText(rect, Qt::AlignRight | Qt::AlignVCenter, mViewIcon, &drawedRect);
    // End Views


    // Paint Body
    rect = QRectF(avatarRect.bottomRight(), fullRect.bottomRight());
    rect.setTop(rect.top() + mSpacing);
    rect.setLeft(rect.left() + mSpacing);

    font = mFont;
    color = mForegroundColor;

    painter->setPen(color);
    painter->setFont(font);

    painter->translate(rect.topLeft());

    auto doc = createTextDocument();
    doc->drawContents(painter);

    painter->translate(rect.topLeft() * -1);
    auto bodyRect = TrickItemDelegate::bodyRect();
    delete doc;
    // End Body


    // Print Image
    rect = QRectF(bodyRect.bottomLeft(), QSizeF(bodyRect.width(), bodyRect.width() * mImageSize.height() / mImageSize.width()));
    rect.setTop(rect.top() + mSpacing);

    if (!mCacheImage.isNull())
    {
        QPainterPath path;
        path.addRoundedRect(rect, mImageRoundness, mImageRoundness);

        painter->setClipPath(path);
        painter->drawImage(rect, mCacheImage);
        painter->setClipping(false);
    }
    // End Image
}

QSize TrickItemDelegate::imageSize() const
{
    return mImageSize;
}

void TrickItemDelegate::setImageSize(const QSize &newImageSize)
{
    if (mImageSize == newImageSize)
        return;
    mImageSize = newImageSize;
    downloadImage();
    Q_EMIT imageSizeChanged();
}

qreal TrickItemDelegate::sceneWidth() const
{
    return mSceneWidth;
}

void TrickItemDelegate::setSceneWidth(qreal newSceneWidth)
{
    if (mSceneWidth == newSceneWidth)
        return;

    QMutexLocker locker(&mMutex);
    mSceneWidth = newSceneWidth;
    Q_EMIT sceneWidthChanged();
    Q_EMIT bodyRectChanged();
    Q_EMIT contentRectChanged();
}

qreal TrickItemDelegate::avatarSize() const
{
    return mAvatarSize;
}

void TrickItemDelegate::setAvatarSize(qreal newAvatarSize)
{
    if (qFuzzyCompare(mAvatarSize, newAvatarSize))
        return;

    QMutexLocker locker(&mMutex);
    mAvatarSize = newAvatarSize;
    Q_EMIT avatarSizeChanged();
}

QFont TrickItemDelegate::font() const
{
    return mFont;
}

void TrickItemDelegate::setFont(const QFont &newFont)
{
    if (mFont == newFont)
        return;

    QMutexLocker locker(&mMutex);
    mFont = newFont;
    Q_EMIT fontChanged();
}

QColor TrickItemDelegate::foregroundColor() const
{
    return mForegroundColor;
}

void TrickItemDelegate::setForegroundColor(const QColor &newForegroundColor)
{
    if (mForegroundColor == newForegroundColor)
        return;

    QMutexLocker locker(&mMutex);
    mForegroundColor = newForegroundColor;
    Q_EMIT foregroundColorChanged();
}

QString TrickItemDelegate::fullname() const
{
    return mFullname;
}

void TrickItemDelegate::setFullname(const QString &newFullname)
{
    if (mFullname == newFullname)
        return;

    QMutexLocker locker(&mMutex);
    mFullname = newFullname;
    Q_EMIT fullnameChanged();
}

QString TrickItemDelegate::username() const
{
    return mUsername;
}

void TrickItemDelegate::setUsername(const QString &newUsername)
{
    if (mUsername == newUsername)
        return;

    QMutexLocker locker(&mMutex);
    mUsername = newUsername;
    Q_EMIT usernameChanged();
}

QString TrickItemDelegate::datetime() const
{
    return mDatetime;
}

void TrickItemDelegate::setDatetime(const QString &newDatetime)
{
    if (mDatetime == newDatetime)
        return;

    QMutexLocker locker(&mMutex);
    mDatetime = newDatetime;
    Q_EMIT datetimeChanged();
}

QFont TrickItemDelegate::fontIcon() const
{
    return mFontIcon;
}

void TrickItemDelegate::setFontIcon(const QFont &newFontIcon)
{
    if (mFontIcon == newFontIcon)
        return;

    QMutexLocker locker(&mMutex);
    mFontIcon = newFontIcon;
    Q_EMIT fontIconChanged();
}

QString TrickItemDelegate::tagIcon() const
{
    return mTagIcon;
}

void TrickItemDelegate::setTagIcon(const QString &newTagIcon)
{
    if (mTagIcon == newTagIcon)
        return;

    QMutexLocker locker(&mMutex);
    mTagIcon = newTagIcon;
    Q_EMIT tagIconChanged();
}

QColor TrickItemDelegate::highlightColor() const
{
    return mHighlightColor;
}

void TrickItemDelegate::setHighlightColor(const QColor &newHighlightColor)
{
    if (mHighlightColor == newHighlightColor)
        return;

    QMutexLocker locker(&mMutex);
    mHighlightColor = newHighlightColor;
    Q_EMIT highlightColorChanged();
}

QStringList TrickItemDelegate::tags() const
{
    return mTags;
}

void TrickItemDelegate::setTags(const QStringList &newTags)
{
    if (mTags == newTags)
        return;

    QMutexLocker locker(&mMutex);
    mTags = newTags;
    Q_EMIT tagsChanged();
}

QString TrickItemDelegate::tagDelimiterIcon() const
{
    return mTagDelimiterIcon;
}

void TrickItemDelegate::setTagDelimiterIcon(const QString &newTagDelimiterIcon)
{
    if (mTagDelimiterIcon == newTagDelimiterIcon)
        return;

    QMutexLocker locker(&mMutex);
    mTagDelimiterIcon = newTagDelimiterIcon;
    Q_EMIT tagDelimiterIconChanged();
}

QString TrickItemDelegate::language() const
{
    return mLanguage;
}

void TrickItemDelegate::setLanguage(const QString &newLanguage)
{
    if (mLanguage == newLanguage)
        return;

    QMutexLocker locker(&mMutex);
    mLanguage = newLanguage;
    Q_EMIT languageChanged();
}

qint32 TrickItemDelegate::viewCount() const
{
    return mViewCount;
}

void TrickItemDelegate::setViewCount(qint32 newViewCount)
{
    if (mViewCount == newViewCount)
        return;

    QMutexLocker locker(&mMutex);
    mViewCount = newViewCount;
    Q_EMIT viewCountChanged();
}

QString TrickItemDelegate::viewIcon() const
{
    return mViewIcon;
}

void TrickItemDelegate::setViewIcon(const QString &newViewIcon)
{
    if (mViewIcon == newViewIcon)
        return;

    QMutexLocker locker(&mMutex);
    mViewIcon = newViewIcon;
    Q_EMIT viewIconChanged();
}

QString TrickItemDelegate::body() const
{
    return mBody;
}

void TrickItemDelegate::setBody(const QString &newBody)
{
    if (mBody == newBody)
        return;

    QMutexLocker locker(&mMutex);
    mBody = newBody;
    Q_EMIT bodyChanged();
}

QUrl TrickItemDelegate::avatar() const
{
    return mAvatar;
}

void TrickItemDelegate::setAvatar(const QUrl &newAvatar)
{
    if (mAvatar == newAvatar)
        return;

    QMutexLocker locker(&mMutex);
    mAvatar = newAvatar;
    downloadAvatar();
    Q_EMIT avatarChanged();
}

QUrl TrickItemDelegate::image() const
{
    return mImage;
}

void TrickItemDelegate::setImage(const QUrl &newImage)
{
    if (mImage == newImage)
        return;

    QMutexLocker locker(&mMutex);
    mImage = newImage;
    downloadImage();
    Q_EMIT imageChanged();
}

static void register_qml_trick_item_delegate() {
    qmlRegisterType<TrickItemDelegate>("Tricks", 1, 0, "TrickItem");
}

Q_COREAPP_STARTUP_FUNCTION(register_qml_trick_item_delegate)
