#include "trickitemdelegate.h"
#include "material/materialicons.h"

#include <QPainter>
#include <QPainterPath>
#include <QTimer>
#include <QScreen>

#include <QAsemanDevices>
#include <QAsemanApplication>
#include <QAsemanTools>
#include <QAsemanCalendarConverter>

#include <math.h>

TrickItemDelegate::TrickItemDelegate(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    mFont.setLetterSpacing(QFont::PercentageSpacing, 94);
    mForegroundColor = QColor(QStringLiteral("#000000"));

    mTagDelimiterIcon = MaterialIcons::mdi_chevron_right;
    mViewIcon = MaterialIcons::mdi_eye;
    mRetrickIcon = MaterialIcons::mdi_repeat;
    mReplyIcon = MaterialIcons::mdi_replay;
    mTagIcon = MaterialIcons::mdi_code_braces;

    mDatetime = QDateTime::currentDateTime();

    connect(this, &QQuickItem::widthChanged, this, &TrickItemDelegate::refreshWidth);

    setupLeftButtons();
    setupRightButtons();
    setAcceptHoverEvents(true);
    setAcceptedMouseButtons(Qt::LeftButton | Qt::RightButton);
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

    int height = mSpacing + mAvatarSize + mSpacing + doc->size().height() + mSpacing + mButtonsHeight + mSpacing;
    if (!mImage.isEmpty())
        height += calculateImageSize().height() + mSpacing;
    if (mIsRetrick && mStateHeader && !mCommentMode)
        height += mStateHeaderHeight;
    if (mParentId && mStateHeader && !mCommentMode && (mLinkId == 0 || mLinkId > mTrickId))
        height += mStateHeaderHeight;

    QRectF r;
    r.setX( (width() - mSceneWidth) / 2 );
    r.setY(mVerticalPadding);
    r.setWidth(mSceneWidth);
    r.setHeight(height);

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
    mImageDownloader->setImageSize(calculateImageSize() * std::max<qreal>(2, QAsemanDevices::deviceDensity()));
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

void TrickItemDelegate::setupLeftButtons()
{
    mLeftSideButtons.clear();

    Button rateBtn = {
        .rect = QRect(),
        .normalIcon = MaterialIcons::mdi_thumb_up_outline,
        .fillIcon = MaterialIcons::mdi_thumb_up,
        .action = RateButton,
        .counter = 0,
    };
    Button commentBtn = {
        .rect = QRect(),
        .normalIcon = MaterialIcons::mdi_comment_outline,
        .fillIcon = MaterialIcons::mdi_comment,
        .action = CommentButton,
        .counter = 0,
    };
    Button retrickBtn = {
        .rect = QRect(),
        .normalIcon = MaterialIcons::mdi_repeat,
        .fillIcon = MaterialIcons::mdi_repeat,
        .action = RetrickButton,
        .counter = 0,
    };

    mLeftSideButtons << rateBtn << commentBtn << retrickBtn;
}

void TrickItemDelegate::setupRightButtons()
{
    mRightSideButtons.clear();

    Button moreBtn = {
        .rect = QRect(),
        .normalIcon = MaterialIcons::mdi_dots_horizontal,
        .fillIcon = MaterialIcons::mdi_dots_horizontal,
        .action = MoreButton,
        .counter = 0,
    };
    Button favoriteBtn = {
        .rect = QRect(),
        .normalIcon = MaterialIcons::mdi_star_outline,
        .fillIcon = MaterialIcons::mdi_star,
        .action = FavoriteButton,
        .counter = 0,
    };
    Button tipBtn = {
        .rect = QRect(),
        .normalIcon = MaterialIcons::mdi_bitcoin,
        .fillIcon = MaterialIcons::mdi_bitcoin,
        .action = TipButton,
        .counter = 0,
    };

    mRightSideButtons << moreBtn << favoriteBtn << tipBtn;
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

QString TrickItemDelegate::dateToString(const QDateTime &date)
{
    auto secs = QDateTime::currentDateTime().toSecsSinceEpoch() - date.toSecsSinceEpoch();
    auto min_length = 60;
    auto hour_length = 60 * min_length;
    auto day_length = 24 * hour_length;
    auto week_length = 7 * day_length;
    auto month_length = 30 * day_length;
    auto year_length = 365 * day_length;

    struct Unit {
        int len;
        QString oneText;
        QString manyText;
        int next_len;
    };

    QList<Unit> array = {
        // Length, Unit Str, Many String, Max
        {1, tr("1 sec ago"), tr("%1 secs ago"), min_length},
        {min_length, tr("1 min ago"), tr("%1 mins ago"), hour_length},
        {hour_length, tr("1 hour ago"), tr("%1 hours ago"), day_length},
        {day_length, tr("1 day ago"), tr("%1 days ago"), week_length},
        {week_length, tr("1 week ago"), tr("%1 weeks ago"), month_length},
        {month_length, tr("1 month ago"), tr("%1 months ago"), year_length},
        {year_length, tr("1 year ago"), tr("%1 years ago"), 100 * year_length},
    };

    for (int i=0; i<array.length(); i++)
    {
        auto it = array.value(i);
        if (secs <= it.len)
            return it.oneText;
        if (secs < it.next_len)
            return it.manyText.arg( std::floor(secs/it.len) );
    }

    QAsemanCalendarConverter cal;
    return cal.convertDateTimeToLittleString(date.date());
}

QSize TrickItemDelegate::calculateImageSize() const
{
    return QSize(bodyRect().width(), bodyRect().width() * mImageSize.height() / mImageSize.width());
}

void TrickItemDelegate::mouseMoveEvent(QMouseEvent *e)
{
    QQuickPaintedItem::mouseMoveEvent(e);
}

void TrickItemDelegate::mousePressEvent(QMouseEvent *e)
{
    forceActiveFocus();
    setFocus(true);

    if (!mSelectedButton.rect.isNull())
        ;
    else
    if (mUserAreaRect.contains(e->pos()))
        ;
    else
    if (mImageRect.contains(e->pos()))
        ;
    else
    if (e->button() == Qt::LeftButton)
        mPressedPos = e->pos();

    if (!mPressAndHoldTimer)
    {
        mPressAndHoldTimer = new QTimer(this);
        mPressAndHoldTimer->setInterval(400);
        mPressAndHoldTimer->setSingleShot(true);
        connect(mPressAndHoldTimer, &QTimer::timeout, this, [this](){
            if (mPressedPos.isNull())
                return;

            Q_EMIT pressAndHold(mPressedPos);
            mPressAndHoldTimer->deleteLater();
            mPressAndHoldTimer = Q_NULLPTR;
            update();
        });
    }

    mPressAndHoldTimer->start();

    e->accept();
    update();
}

void TrickItemDelegate::mouseReleaseEvent(QMouseEvent *e)
{
    e->accept();

    mPressedPos = QPointF();
    update();

    if (mPressAndHoldTimer)
    {
        mPressAndHoldTimer->deleteLater();
        mPressAndHoldTimer = Q_NULLPTR;
    }
    else
        return;

    if (e->button() == Qt::RightButton)
        Q_EMIT contextMenuRequest(e->pos());
    else
    if (!mSelectedButton.rect.isNull())
        Q_EMIT buttonClicked(mSelectedButton.action, mSelectedButton.rect);
    else
    if (mUserAreaRect.contains(e->pos()))
        Q_EMIT userClicked();
    else
    if (mImageRect.contains(e->pos()))
        Q_EMIT imageClicked();
    else
        Q_EMIT clicked();
}

void TrickItemDelegate::hoverEnterEvent(QHoverEvent *e)
{
    mSelectedButton = Button();
    update();
    QQuickPaintedItem::hoverEnterEvent(e);
}

void TrickItemDelegate::hoverLeaveEvent(QHoverEvent *e)
{
    mSelectedButton = Button();
    update();
    QQuickPaintedItem::hoverLeaveEvent(e);
}

void TrickItemDelegate::hoverMoveEvent(QHoverEvent *e)
{
    const auto first_state = mSelectedButton;
    mSelectedButton = Button();
    for (const auto &b: mLeftSideButtons)
        if (b.rect.contains(e->posF()))
        {
            e->accept();
            mSelectedButton = b;
            break;
        }
    for (const auto &b: mRightSideButtons)
        if (b.rect.contains(e->posF()))
        {
            e->accept();
            mSelectedButton = b;
            break;
        }

    if (mSelectedButton != first_state)
        update();

    e->ignore();
    QQuickPaintedItem::hoverMoveEvent(e);
}

void TrickItemDelegate::mouseUngrabEvent()
{
    mPressedPos = QPointF();
    if (mPressAndHoldTimer)
    {
        mPressAndHoldTimer->deleteLater();
        mPressAndHoldTimer = Q_NULLPTR;
    }

    QQuickPaintedItem::mouseUngrabEvent();
    update();
}

TrickItemDelegate::Button *TrickItemDelegate::button(ButtonActions action)
{
    for (auto &b: mLeftSideButtons)
        if (b.action == action)
            return &b;
    for (auto &b: mRightSideButtons)
        if (b.action == action)
            return &b;
    return Q_NULLPTR;
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

QString TrickItemDelegate::originalBody() const
{
    return mOriginalBody;
}

bool TrickItemDelegate::quoteCodeFrameIsDark() const
{
    return mQuoteCodeFrameIsDark;
}

QSize TrickItemDelegate::quoteImageSize() const
{
    return mQuoteImageSize;
}

QUrl TrickItemDelegate::quoteImage() const
{
    return mQuoteImage;
}

QUrl TrickItemDelegate::quoteAvatar() const
{
    return mQuoteAvatar;
}

qint32 TrickItemDelegate::quoteUserId() const
{
    return mQuoteUserId;
}

QString TrickItemDelegate::quoteFullname() const
{
    return mQuoteFullname;
}

QString TrickItemDelegate::quoteUsername() const
{
    return mQuoteUsername;
}

qint32 TrickItemDelegate::quoteId() const
{
    return mQuoteId;
}

const QVariantList &TrickItemDelegate::quotedReferences() const
{
    return mQuotedReferences;
}

QString TrickItemDelegate::quote() const
{
    return mQuote;
}

QUrl TrickItemDelegate::retrickAvatar() const
{
    return mRetrickAvatar;
}

QString TrickItemDelegate::retrickFullname() const
{
    return mRetrickFullname;
}

QString TrickItemDelegate::retrickUsername() const
{
    return mRetrickUsername;
}

qint32 TrickItemDelegate::retrickUserId() const
{
    return mRetrickUserId;
}

qint32 TrickItemDelegate::retrickTrickId() const
{
    return mRetrickTrickId;
}

bool TrickItemDelegate::bookmarked() const
{
    return mBookmarked;
}

QString TrickItemDelegate::shareLink() const
{
    return mShareLink;
}

int TrickItemDelegate::tipState() const
{
    return mTipState;
}

bool TrickItemDelegate::rateState() const
{
    return mRateState;
}

void TrickItemDelegate::setRateState(bool rateState)
{
    if (rateState == mRateState)
        return;

    mRateState = rateState;

    auto btn = button(RateButton);
    if (btn)
        btn->highlighted = rateState;

    update();
    Q_EMIT rateStateChanged();
}

qint32 TrickItemDelegate::comments() const
{
    return mComments;
}

qint32 TrickItemDelegate::tipsSat() const
{
    return mTipsSat;
}

qint32 TrickItemDelegate::ratricks() const
{
    return mRatricks;
}

qint32 TrickItemDelegate::rates() const
{
    return mRates;
}

const QVariantList &TrickItemDelegate::references() const
{
    return mReferences;
}

QString TrickItemDelegate::code() const
{
    return mCode;
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

qint32 TrickItemDelegate::originalOwnerId() const
{
    return mOriginalOwnerId;
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

    mDatetime = m.value(QStringLiteral("datetime")).toDateTime();
    mViewCount = m.value(QStringLiteral("views")).toInt();

    mLanguage = m.value(QStringLiteral("programing_language")).toMap().value(QStringLiteral("name")).toString();

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

    mReferences = m.value(QStringLiteral("references")).toList();

    mRates = m.value(QStringLiteral("rates")).toInt();
    mRatricks = m.value(QStringLiteral("retricks")).toInt();
    mTipsSat = std::floor(m.value(QStringLiteral("tips")).toInt() / 1000);
    mComments = m.value(QStringLiteral("comments")).toInt();

    mRateState = m.value(QStringLiteral("rate_state")).toBool();
    auto btn = button(RateButton);
    if (btn)
    {
        btn->highlighted = mRateState;
        btn->counter = mRates;
    }

    mTipState = m.value(QStringLiteral("tip_state")).toInt();
    mShareLink = m.value(QStringLiteral("share_link")).toString();
    mTags = m.value(QStringLiteral("tags")).toStringList();
    mBookmarked = m.value(QStringLiteral("bookmarked")).toBool();

    mCode = m.value(QStringLiteral("code")).toString();
    mOriginalBody = m.value(QStringLiteral("body")).toString();
    mBody = styleText(mOriginalBody);

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
    if (m.value(QStringLiteral("retricker")).toMap().count())
    { // It's retrick
        const auto retricker = m.value(QStringLiteral("retricker")).toMap();
        mIsRetrick = true;
        mRetrickTrickId = m.value(QStringLiteral("retrick_trick_id")).toInt();
        mRetrickUserId = retricker.value(QStringLiteral("id")).toInt();
        mRetrickUsername = retricker.value(QStringLiteral("username")).toString();
        mRetrickFullname = retricker.value(QStringLiteral("fullname")).toString();
        mRetrickAvatar = retricker.value(QStringLiteral("avatar")).toString();
    }

    if (m.value(QStringLiteral("quote")).toMap().count())
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

    mRetrickText = tr("%1 (@%2) Retricked...").arg(mRetrickFullname, mRetrickUsername);
    mReplyText = mParentOwnerId? tr("In reply to %1's (@%2) trick...").arg(mParentOwnerFullName, mParentOwnerUsername) : tr("In reply to a deleted trick...");

    downloadImage();
    downloadAvatar();
    Q_EMIT itemDataChanged();
    Q_EMIT contentRectChanged();
}

bool TrickItemDelegate::isRetrick() const
{
    return mIsRetrick;
}

QString TrickItemDelegate::parentOwnerUsername() const
{
    return mParentOwnerUsername;
}

QString TrickItemDelegate::parentOwnerFullName() const
{
    return mParentOwnerFullName;
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

qint32 TrickItemDelegate::trickId() const
{
    return mTrickId;
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

qint32 TrickItemDelegate::parentId() const
{
    return mParentId;
}

QString TrickItemDelegate::retrickText() const
{
    return mRetrickText;
}

QString TrickItemDelegate::replyText() const
{
    return mReplyText;
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


    // Paint Background
    if (!mPressedPos.isNull())
    {
        color = mForegroundColor;
        color.setAlphaF(0.1);

        painter->fillRect(QRectF(0,0,width(), height()), color);
    }
    // End Background


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

    mUserAreaRect = avatarRect;
    mUserAreaRect.setRight(drawedRect.right());

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
    painter->drawText(rect, Qt::AlignRight | Qt::AlignVCenter, dateToString(mDatetime), &drawedRect);
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
    tagsList << mTags;
    if (!tagsList.contains(mLanguage, Qt::CaseInsensitive))
        tagsList.prepend(mLanguage);

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
    rect = TrickItemDelegate::bodyRect();
    delete doc;
    // End Body


    // Print Image
    if (mImageSize.height() > 1)
    {
        rect = QRectF(rect.bottomLeft(), QSizeF(rect.width(), rect.width() * mImageSize.height() / mImageSize.width()));
        rect.setY(rect.y() + mSpacing);

        if (!mCacheImage.isNull())
        {
            QPainterPath path;
            path.addRoundedRect(rect, mImageRoundness, mImageRoundness);

            painter->setClipPath(path);
            painter->drawImage(rect, mCacheImage);
            painter->setClipping(false);
        }
        else
        {
            color = mForegroundColor;
            color.setAlphaF(0.7);

            font = mFont;
            font.setPixelSize(mFont.pixelSize() * 8 / 9);

            painter->setPen(color);
            painter->setFont(font);
            painter->drawText(rect, Qt::AlignCenter, tr("Loading..."));
        }

        mImageRect = rect;
    }
    else
        mImageRect = QRectF();
    // End Image


    // Print Buttons
    if (!mSelectedButton.rect.isNull())
    {
        color = mForegroundColor;
        color.setAlphaF(0.1);

        QPainterPath path;
        path.addRoundedRect(mSelectedButton.rect, 4, 4);

        painter->fillPath(path, color);
    }

    rect = QRectF(rect.bottomLeft(), QSizeF(rect.width(), mButtonsHeight));
    rect.setTop(rect.top() + mSpacing);
    rect.setLeft(rect.left() + mSpacing);
    rect.setRight(rect.right() - mSpacing);

    fontIcon = mFontIcon;
    fontIcon.setPixelSize(fontIcon.pixelSize() * 12 / 9);

    font = mFont;
    font.setPixelSize(font.pixelSize() * 8 / 9);

    color = mForegroundColor;
    color.setAlphaF(0.7);

    for (auto &b: mLeftSideButtons)
    {
        fontIcon.setBold(b.highlighted && b.fillIcon == b.normalIcon);
        painter->setPen(b.highlighted? mHighlightColor : color);
        painter->setFont(fontIcon);
        painter->drawText(rect, Qt::AlignLeft | Qt::AlignVCenter, (b.highlighted? b.fillIcon : b.normalIcon), &drawedRect);

        b.rect = drawedRect.adjusted(-6, -6, 6, 6);

        if (b.counter)
        {
            rect.setLeft(drawedRect.right() + 4);

            painter->setFont(font);
            painter->drawText(rect, Qt::AlignLeft | Qt::AlignVCenter, QString::number(b.counter), &drawedRect);

            b.rect.setRight(drawedRect.right() + 6);
        }

        rect.setLeft(drawedRect.right() + 12);
    }

    for (auto &b: mRightSideButtons)
    {
        painter->setPen(b.highlighted? mHighlightColor : color);
        if (b.counter)
        {
            painter->setFont(font);
            painter->drawText(rect, Qt::AlignRight | Qt::AlignVCenter, QString::number(b.counter), &drawedRect);

            b.rect = drawedRect;

            rect.setRight(drawedRect.left() - 4);
        }

        fontIcon.setBold(b.highlighted && b.fillIcon == b.normalIcon);
        painter->setFont(fontIcon);
        painter->drawText(rect, Qt::AlignRight | Qt::AlignVCenter, (b.highlighted? b.fillIcon : b.normalIcon), &drawedRect);

        if (b.counter)
            drawedRect.setRight(b.rect.right());

        b.rect = drawedRect.adjusted(-6, -6, 6, 6);

        rect.setRight(drawedRect.left() - 12);
    }
    // End Buttons
}

QSize TrickItemDelegate::imageSize() const
{
    return mImageSize;
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

QString TrickItemDelegate::username() const
{
    return mUsername;
}

QDateTime TrickItemDelegate::datetime() const
{
    return mDatetime;
}

QFont TrickItemDelegate::fontIcon() const
{
    return mFontIcon;
}

void TrickItemDelegate::setFontIcon(const QFont &font)
{
    if (mFontIcon == font)
        return;

    mFontIcon = font;
    Q_EMIT fontChanged();
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

QString TrickItemDelegate::language() const
{
    return mLanguage;
}

qint32 TrickItemDelegate::viewCount() const
{
    return mViewCount;
}

QString TrickItemDelegate::body() const
{
    return mBody;
}

QUrl TrickItemDelegate::avatar() const
{
    return mAvatar;
}

QUrl TrickItemDelegate::image() const
{
    return mImage;
}

static void register_qml_trick_item_delegate() {
    qmlRegisterType<TrickItemDelegate>("Tricks", 1, 0, "TrickItem");
}

Q_COREAPP_STARTUP_FUNCTION(register_qml_trick_item_delegate)
