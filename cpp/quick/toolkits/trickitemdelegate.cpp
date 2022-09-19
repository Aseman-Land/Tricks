#include "trickitemdelegate.h"
#include "material/materialicons.h"

#include <QPainter>
#include <QPainterPath>
#include <QTimer>
#include <QScreen>

#include <QAsemanDevices>
#include <QAsemanApplication>
#include <QAsemanTools>

#include <math.h>

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

QString TrickItemDelegate::styleText(QString text) const
{
    Qt::TextFormat textFormat = Qt::RichText;
    const auto &tags = QAsemanTools::stringRegExp(text, QStringLiteral("\\#[\\w\\+\\-\\#]+"), false);
    for (const auto &v: tags)
    {
        const auto &t = v.toString();
        if (textFormat == Qt::MarkdownText)
            text = QAsemanTools::stringReplace(text, t, '[' + t + QStringLiteral("](go:/") + t + ')');
        else
            text = QAsemanTools::stringReplace(text, t, QStringLiteral("<a href=\"go:/%1\">").arg(t) + t + QStringLiteral("</a>"));
    }

    const auto &mentions = QAsemanTools::stringRegExp(text, QStringLiteral("\\@\\w+"), false);
    for (const auto &v: mentions)
    {
        const auto &t = v.toString();
        if (textFormat == Qt::MarkdownText)
            text = QAsemanTools::stringReplace(text, t, QStringLiteral("[") + QString(t).remove('@') + QStringLiteral("](user:/") + t + ')');
        else
            text = QAsemanTools::stringReplace(text, t, QStringLiteral("<a href=\"user:/%1\">").arg(QString(t).remove('@')) + t + QStringLiteral("</a>"));
    }

    return text;
}

bool TrickItemDelegate::quoteCodeFrameIsDark() const
{
    return mQuoteCodeFrameIsDark;
}

void TrickItemDelegate::setQuoteCodeFrameIsDark(bool newQuoteCodeFrameIsDark)
{
    if (mQuoteCodeFrameIsDark == newQuoteCodeFrameIsDark)
        return;
    mQuoteCodeFrameIsDark = newQuoteCodeFrameIsDark;
    Q_EMIT quoteCodeFrameIsDarkChanged();
}

QSize TrickItemDelegate::quoteImageSize() const
{
    return mQuoteImageSize;
}

void TrickItemDelegate::setQuoteImageSize(const QSize &newQuoteImageSize)
{
    if (mQuoteImageSize == newQuoteImageSize)
        return;
    mQuoteImageSize = newQuoteImageSize;
    Q_EMIT quoteImageSizeChanged();
}

QUrl TrickItemDelegate::quoteImage() const
{
    return mQuoteImage;
}

void TrickItemDelegate::setQuoteImage(const QUrl &newQuoteImage)
{
    if (mQuoteImage == newQuoteImage)
        return;
    mQuoteImage = newQuoteImage;
    Q_EMIT quoteImageChanged();
}

QUrl TrickItemDelegate::quoteAvatar() const
{
    return mQuoteAvatar;
}

void TrickItemDelegate::setQuoteAvatar(const QUrl &newQuoteAvatar)
{
    if (mQuoteAvatar == newQuoteAvatar)
        return;
    mQuoteAvatar = newQuoteAvatar;
    Q_EMIT quoteAvatarChanged();
}

qint32 TrickItemDelegate::quoteUserId() const
{
    return mQuoteUserId;
}

void TrickItemDelegate::setQuoteUserId(qint32 newQuoteUserId)
{
    if (mQuoteUserId == newQuoteUserId)
        return;
    mQuoteUserId = newQuoteUserId;
    Q_EMIT quoteUserIdChanged();
}

QString TrickItemDelegate::quoteFullname() const
{
    return mQuoteFullname;
}

void TrickItemDelegate::setQuoteFullname(const QString &newQuoteFullname)
{
    if (mQuoteFullname == newQuoteFullname)
        return;
    mQuoteFullname = newQuoteFullname;
    Q_EMIT quoteFullnameChanged();
}

QString TrickItemDelegate::quoteUsername() const
{
    return mQuoteUsername;
}

void TrickItemDelegate::setQuoteUsername(const QString &newQuoteUsername)
{
    if (mQuoteUsername == newQuoteUsername)
        return;
    mQuoteUsername = newQuoteUsername;
    Q_EMIT quoteUsernameChanged();
}

qint32 TrickItemDelegate::quoteId() const
{
    return mQuoteId;
}

void TrickItemDelegate::setQuoteId(qint32 newQuoteId)
{
    if (mQuoteId == newQuoteId)
        return;
    mQuoteId = newQuoteId;
    Q_EMIT quoteIdChanged();
}

const QVariantList &TrickItemDelegate::quotedReferences() const
{
    return mQuotedReferences;
}

void TrickItemDelegate::setQuotedReferences(const QVariantList &newQuotedReferences)
{
    if (mQuotedReferences == newQuotedReferences)
        return;
    mQuotedReferences = newQuotedReferences;
    Q_EMIT quotedReferencesChanged();
}

QString TrickItemDelegate::quote() const
{
    return mQuote;
}

void TrickItemDelegate::setQuote(const QString &newQuote)
{
    if (mQuote == newQuote)
        return;
    mQuote = newQuote;
    Q_EMIT quoteChanged();
}

QUrl TrickItemDelegate::retrickAvatar() const
{
    return mRetrickAvatar;
}

void TrickItemDelegate::setRetrickAvatar(const QUrl &newRetrickAvatar)
{
    if (mRetrickAvatar == newRetrickAvatar)
        return;
    mRetrickAvatar = newRetrickAvatar;
    Q_EMIT retrickAvatarChanged();
}

QString TrickItemDelegate::retrickFullname() const
{
    return mRetrickFullname;
}

void TrickItemDelegate::setRetrickFullname(const QString &newRetrickFullname)
{
    if (mRetrickFullname == newRetrickFullname)
        return;
    mRetrickFullname = newRetrickFullname;
    Q_EMIT retrickFullnameChanged();
}

QString TrickItemDelegate::retrickUsername() const
{
    return mRetrickUsername;
}

void TrickItemDelegate::setRetrickUsername(const QString &newRetrickUsername)
{
    if (mRetrickUsername == newRetrickUsername)
        return;
    mRetrickUsername = newRetrickUsername;
    Q_EMIT retrickUsernameChanged();
}

qint32 TrickItemDelegate::retrickUserId() const
{
    return mRetrickUserId;
}

void TrickItemDelegate::setRetrickUserId(qint32 newRetrickUserId)
{
    if (mRetrickUserId == newRetrickUserId)
        return;
    mRetrickUserId = newRetrickUserId;
    Q_EMIT retrickUserIdChanged();
}

qint32 TrickItemDelegate::retrickTrickId() const
{
    return mRetrickTrickId;
}

void TrickItemDelegate::setRetrickTrickId(qint32 newRetrickTrickId)
{
    if (mRetrickTrickId == newRetrickTrickId)
        return;
    mRetrickTrickId = newRetrickTrickId;
    Q_EMIT retrickTrickIdChanged();
}

QString TrickItemDelegate::roleIcon() const
{
    return mRoleIcon;
}

void TrickItemDelegate::setRoleIcon(const QString &newRoleIcon)
{
    if (mRoleIcon == newRoleIcon)
        return;
    mRoleIcon = newRoleIcon;
    Q_EMIT roleIconChanged();
}

QString TrickItemDelegate::codeIcon() const
{
    return mCodeIcon;
}

void TrickItemDelegate::setCodeIcon(const QString &newCodeIcon)
{
    if (mCodeIcon == newCodeIcon)
        return;
    mCodeIcon = newCodeIcon;
    Q_EMIT codeIconChanged();
}

bool TrickItemDelegate::bookmarked() const
{
    return mBookmarked;
}

void TrickItemDelegate::setBookmarked(bool newBookmarked)
{
    if (mBookmarked == newBookmarked)
        return;
    mBookmarked = newBookmarked;
    Q_EMIT bookmarkedChanged();
}

QString TrickItemDelegate::shareLink() const
{
    return mShareLink;
}

void TrickItemDelegate::setShareLink(const QString &newShareLink)
{
    if (mShareLink == newShareLink)
        return;
    mShareLink = newShareLink;
    Q_EMIT shareLinkChanged();
}

int TrickItemDelegate::tipState() const
{
    return mTipState;
}

void TrickItemDelegate::setTipState(int newTipState)
{
    if (mTipState == newTipState)
        return;
    mTipState = newTipState;
    Q_EMIT tipStateChanged();
}

bool TrickItemDelegate::rateState() const
{
    return mRateState;
}

void TrickItemDelegate::setRateState(bool newRateState)
{
    if (mRateState == newRateState)
        return;
    mRateState = newRateState;
    Q_EMIT rateStateChanged();
}

qint32 TrickItemDelegate::comments() const
{
    return mComments;
}

void TrickItemDelegate::setComments(qint32 newComments)
{
    if (mComments == newComments)
        return;
    mComments = newComments;
    Q_EMIT commentsChanged();
}

qint32 TrickItemDelegate::tipsSat() const
{
    return mTipsSat;
}

void TrickItemDelegate::setTipsSat(qint32 newTipsSat)
{
    if (mTipsSat == newTipsSat)
        return;
    mTipsSat = newTipsSat;
    Q_EMIT tipsSatChanged();
}

qint32 TrickItemDelegate::ratricks() const
{
    return mRatricks;
}

void TrickItemDelegate::setRatricks(qint32 newRatricks)
{
    if (mRatricks == newRatricks)
        return;
    mRatricks = newRatricks;
    Q_EMIT ratricksChanged();
}

qint32 TrickItemDelegate::rates() const
{
    return mRates;
}

void TrickItemDelegate::setRates(qint32 newRates)
{
    if (mRates == newRates)
        return;
    mRates = newRates;
    Q_EMIT ratesChanged();
}

const QVariantList &TrickItemDelegate::references() const
{
    return mReferences;
}

void TrickItemDelegate::setReferences(const QVariantList &newReferences)
{
    if (mReferences == newReferences)
        return;
    mReferences = newReferences;
    Q_EMIT referencesChanged();
}

QString TrickItemDelegate::code() const
{
    return mCode;
}

void TrickItemDelegate::setCode(const QString &newCode)
{
    if (mCode == newCode)
        return;
    mCode = newCode;
    Q_EMIT codeChanged();
}

QString TrickItemDelegate::serverAddress() const
{
    return mServerAddress;
}

void TrickItemDelegate::setServerAddress(const QString &newServerAddress)
{
    if (mServerAddress == newServerAddress)
        return;
    mServerAddress = newServerAddress;
    Q_EMIT serverAddressChanged();
}

qint32 TrickItemDelegate::ownerId() const
{
    return mOwnerId;
}

void TrickItemDelegate::setOwnerId(qint32 newOwnerId)
{
    if (mOwnerId == newOwnerId)
        return;
    mOwnerId = newOwnerId;
    Q_EMIT ownerIdChanged();
}

qint32 TrickItemDelegate::originalOwnerId() const
{
    return mOriginalOwnerId;
}

void TrickItemDelegate::setOriginalOwnerId(qint32 newOriginalOwnerId)
{
    if (mOriginalOwnerId == newOriginalOwnerId)
        return;
    mOriginalOwnerId = newOriginalOwnerId;
    Q_EMIT originalOwnerIdChanged();
}

QVariantMap TrickItemDelegate::itemData() const
{
    return mItemData;
}

void TrickItemDelegate::setItemData(const QVariantMap &m)
{
    if (mItemData == m)
        return;

    mItemData = m;

    const auto owner = m.value(QStringLiteral("owner")).toMap();
    const auto owner_details = owner.value(QStringLiteral("details")).toMap();
    const auto type = m.value(QStringLiteral("type")).toMap();
    const auto frame = m.value(QStringLiteral("code_frame")).toMap();

    mTrickId = m.value(QStringLiteral("id")).toInt();
    mFullname = owner.value(QStringLiteral("fullname")).toString();
    mUsername = owner.value(QStringLiteral("username")).toString();
    mOwnerId = owner.value(QStringLiteral("id")).toInt();
    mOriginalOwnerId = owner.value(QStringLiteral("id")).toInt();
    auto avatar = owner.value(QStringLiteral("avatar")).toString();
    if (!avatar.isEmpty())
        mAvatar = mServerAddress + '/' + avatar;
    else
        mAvatar.clear();

    mDatetime = m.value(QStringLiteral("datetime")).toString();
    mViewCount = m.value(QStringLiteral("views")).toInt();

    mLanguage = m.value(QStringLiteral("programing_language")).toMap().value(QStringLiteral("name")).toString();

    mOriginalBody = m.value(QStringLiteral("body")).toString();
    mBody = styleText(mOriginalBody);

    auto image = m.value(QStringLiteral("filename")).toString();
    if (!avatar.isEmpty())
        mImage = mServerAddress + '/' + image;
    else
        mImage.clear();

    auto imageSize = m.value("image_size").toMap();
    mImageSize = QSize(imageSize.value("width", 1000).toInt(), imageSize.value("height", 1).toInt());

    mLinkId = m.value("link_id").toInt();
    if (mLinkId == 0)
    {
        if (mLinkId < mTrickId)
            mCommentLineTop = true;
        if (mLinkId > mTrickId)
            mCommentLineBottom = true;
    }

    mCode = m.value(QStringLiteral("code")).toString();
    mReferences = m.value(QStringLiteral("references")).toList();

    mRates = m.value(QStringLiteral("rates")).toInt();
    mRatricks = m.value(QStringLiteral("retricks")).toInt();
    mTipsSat = std::floor(m.value(QStringLiteral("tips")).toInt() / 1000);
    mComments = m.value(QStringLiteral("comments")).toInt();
    mRateState = m.value(QStringLiteral("rate_state")).toBool();
    mTipState = m.value(QStringLiteral("tip_state")).toInt();
    mShareLink = m.value(QStringLiteral("share_link")).toString();
    mTags = m.value(QStringLiteral("tags")).toStringList();
    mBookmarked = m.value(QStringLiteral("bookmarked")).toBool();

    const auto type_id = type.value(QStringLiteral("id")).toInt();
    if (type_id > 100000)
    {
        mLanguage = type.value(QStringLiteral("name")).toString();
        switch (type_id - 100000)
        {
        case 1:
            mCodeIcon = MaterialIcons::mdi_bug;
            break;
        case 2:
            mCodeIcon = MaterialIcons::mdi_pen;
            break;
        case 3:
            mCodeIcon = MaterialIcons::mdi_chess_queen;
            break;
        }
    }

    mCodeFrameIsDark = frame.value(QStringLiteral("id")).toInt() == 1;
    mOwnerRole = owner_details.value(QStringLiteral("role")).toInt();
    if (mOwnerRole & 1)
        mRoleIcon = MaterialIcons::mdi_check_decagram;

    mIsRetrick = false;
    if (m.contains(QStringLiteral("retricker")))
    { // It's retrick
        const auto retricker = m.value(QStringLiteral("retricker")).toMap();
        mIsRetrick = true;
        mRetrickTrickId = m.value(QStringLiteral("retrick_trick_id")).toInt();
        mRetrickUserId = retricker.value(QStringLiteral("id")).toInt();
        mRetrickUsername = retricker.value(QStringLiteral("username")).toString();
        mRetrickFullname = retricker.value(QStringLiteral("fullname")).toString();
        mRetrickAvatar = retricker.value(QStringLiteral("avatar")).toString();
    }

    if (m.contains(QStringLiteral("quote")))
    { // It's quote
        const auto trk = m.value(QStringLiteral("quote")).toMap();
        mQuote = styleText(m.value(QStringLiteral("body")).toString());
        mQuotedReferences = m.value(QStringLiteral("references")).toList();

        mQuoteId = trk.value(QStringLiteral("id")).toInt();
        mQuoteUsername = trk.value(QStringLiteral("username")).toString();
        mQuoteFullname = trk.value(QStringLiteral("fullname")).toString();
        mQuoteUserId = trk.value(QStringLiteral("owner")).toInt();
        mQuoteAvatar = trk.value(QStringLiteral("avatar")).toString();

        mQuoteImage = mImage;
        mQuoteImageSize = mImageSize;
        mQuoteCodeFrameIsDark = mCodeFrameIsDark;

        if (trk.value(QStringLiteral("filename")).toString().count())
        {
            mImage = trk.value(QStringLiteral("filename")).toString();
            const auto trk_imageSize = trk.value("image_size").toMap();
            mImageSize = QSize(trk_imageSize.value("width", 1000).toInt(), trk_imageSize.value("height", 1).toInt());

            const auto trk_frame = trk.value(QStringLiteral("code_frame")).toMap();
            mCodeFrameIsDark = trk_frame.value(QStringLiteral("id")).toInt() == 1;
        } else {
            mImage.clear();
            mImageSize = QSize(1000, 1);
            mCodeFrameIsDark = 0;
        }

        mOriginalBody = trk.value(QStringLiteral("body")).toString();
        mBody = styleText(mOriginalBody);
        mReferences = trk.value(QStringLiteral("references")).toList();
    }

    const auto parent_owner = m.value(QStringLiteral("parent_owner")).toMap();
    mParentId = m.value(QStringLiteral("parent_id")).toInt();
    mParentOwnerId = parent_owner.value(QStringLiteral("id")).toInt();
    mParentOwnerFullName = parent_owner.value(QStringLiteral("fullname")).toString();
    mParentOwnerUsername = parent_owner.value(QStringLiteral("username")).toString();

    Q_EMIT itemDataChanged();
}

bool TrickItemDelegate::isRetrick() const
{
    return mIsRetrick;
}

void TrickItemDelegate::setIsRetrick(bool newIsRetrick)
{
    if (mIsRetrick == newIsRetrick)
        return;
    mIsRetrick = newIsRetrick;
    Q_EMIT isRetrickChanged();
}

QString TrickItemDelegate::parentOwnerUsername() const
{
    return mParentOwnerUsername;
}

void TrickItemDelegate::setParentOwnerUsername(const QString &newParentOwnerUsername)
{
    if (mParentOwnerUsername == newParentOwnerUsername)
        return;
    mParentOwnerUsername = newParentOwnerUsername;
    Q_EMIT parentOwnerUsernameChanged();
}

QString TrickItemDelegate::parentOwnerFullName() const
{
    return mParentOwnerFullName;
}

void TrickItemDelegate::setParentOwnerFullName(const QString &newParentOwnerFullName)
{
    if (mParentOwnerFullName == newParentOwnerFullName)
        return;
    mParentOwnerFullName = newParentOwnerFullName;
    Q_EMIT parentOwnerFullNameChanged();
}

bool TrickItemDelegate::globalViewMode() const
{
    return mGlobalViewMode;
}

void TrickItemDelegate::setGlobalViewMode(bool newGlobalViewMode)
{
    if (mGlobalViewMode == newGlobalViewMode)
        return;
    mGlobalViewMode = newGlobalViewMode;
    Q_EMIT globalViewModeChanged();
}

qint32 TrickItemDelegate::linkId() const
{
    return mLinkId;
}

void TrickItemDelegate::setLinkId(qint32 newLinkId)
{
    if (mLinkId == newLinkId)
        return;
    mLinkId = newLinkId;
    Q_EMIT linkIdChanged();
}

qint32 TrickItemDelegate::trickId() const
{
    return mTrickId;
}

void TrickItemDelegate::setTrickId(qint32 newTrickId)
{
    if (mTrickId == newTrickId)
        return;
    mTrickId = newTrickId;
    Q_EMIT trickIdChanged();
}

bool TrickItemDelegate::commentMode() const
{
    return mCommentMode;
}

void TrickItemDelegate::setCommentMode(bool newCommentMode)
{
    if (mCommentMode == newCommentMode)
        return;
    mCommentMode = newCommentMode;
    Q_EMIT commentModeChanged();
}

qint32 TrickItemDelegate::parentOwnerId() const
{
    return mParentOwnerId;
}

void TrickItemDelegate::setParentOwnerId(qint32 newParentOwnerId)
{
    if (mParentOwnerId == newParentOwnerId)
        return;
    mParentOwnerId = newParentOwnerId;
    Q_EMIT parentOwnerIdChanged();
}

qint32 TrickItemDelegate::parentId() const
{
    return mParentId;
}

void TrickItemDelegate::setParentId(qint32 newParentId)
{
    if (mParentId == newParentId)
        return;
    mParentId = newParentId;
    Q_EMIT parentIdChanged();
}

bool TrickItemDelegate::stateHeader() const
{
    return mStateHeader;
}

void TrickItemDelegate::setStateHeader(bool newStateHeader)
{
    if (mStateHeader == newStateHeader)
        return;
    mStateHeader = newStateHeader;
    Q_EMIT stateHeaderChanged();
}

QString TrickItemDelegate::retrickText() const
{
    return mRetrickText;
}

void TrickItemDelegate::setRetrickText(const QString &newRetrickText)
{
    if (mRetrickText == newRetrickText)
        return;
    mRetrickText = newRetrickText;
    Q_EMIT retrickTextChanged();
}

QString TrickItemDelegate::retrickIcon() const
{
    return mRetrickIcon;
}

void TrickItemDelegate::setRetrickIcon(const QString &newRetrickIcon)
{
    if (mRetrickIcon == newRetrickIcon)
        return;
    mRetrickIcon = newRetrickIcon;
    Q_EMIT retrickIconChanged();
}

QString TrickItemDelegate::replyText() const
{
    return mReplyText;
}

void TrickItemDelegate::setReplyText(const QString &newReplyText)
{
    if (mReplyText == newReplyText)
        return;
    mReplyText = newReplyText;
    Q_EMIT replyTextChanged();
}

QString TrickItemDelegate::replyIcon() const
{
    return mReplyIcon;
}

void TrickItemDelegate::setReplyIcon(const QString &newReplyIcon)
{
    if (mReplyIcon == newReplyIcon)
        return;
    mReplyIcon = newReplyIcon;
    Q_EMIT replyIconChanged();
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
    Q_EMIT imageRoundnessChanged();
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
    Q_EMIT cachePathChanged();
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


    // Paint State Header
    if (mIsRetrick && mStateHeader && !mCommentMode)
    {
        rect = QRectF(fullRect.topLeft(), QPointF(fullRect.right(), 32));

        color = mHighlightColor;
        fontIcon = mFontIcon;
        fontIcon.setPixelSize(fontIcon.pixelSize() * 12 / 9);

        painter->setFont(fontIcon);
        painter->setPen(color);
        painter->drawText(rect, Qt::AlignVCenter, mRetrickIcon, &drawedRect);

        rect.setLeft(drawedRect.right() + 4);

        color = mForegroundColor;
        color.setAlphaF(0.4);

        font = mFont;
        font.setBold(true);
        font.setPixelSize(font.pixelSize() * 8 / 9);

        painter->setFont(font);
        painter->setPen(color);
        painter->drawText(rect, Qt::AlignVCenter, mRetrickText, &drawedRect);

        painter->translate(0, 28);
    }

    if (mParentId && mStateHeader && !mCommentMode && (mLinkId == 0 || mLinkId > mTrickId))
    {
        rect = QRectF(fullRect.topLeft(), QPointF(fullRect.right(), 32));

        color = mHighlightColor;
        fontIcon = mFontIcon;
        fontIcon.setPixelSize(fontIcon.pixelSize() * 12 / 9);

        painter->setFont(fontIcon);
        painter->setPen(color);
        painter->drawText(rect, Qt::AlignVCenter, mReplyIcon, &drawedRect);

        rect.setLeft(drawedRect.right() + 4);

        color = mForegroundColor;
        color.setAlphaF(0.4);

        font = mFont;
        font.setBold(true);
        font.setPixelSize(font.pixelSize() * 8 / 9);

        painter->setFont(font);
        painter->setPen(color);
        painter->drawText(rect, Qt::AlignVCenter, mReplyText, &drawedRect);

        painter->translate(0, 28);
    }
    // End State Header


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
