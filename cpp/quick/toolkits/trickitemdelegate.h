#ifndef TRICKITEMDELEGATE_H
#define TRICKITEMDELEGATE_H

#include "tricksdownloaderengine.h"
#include "trickitemcacheengine.h"

#include <QQuickPaintedItem>
#include <QDateTime>
#include <QStringList>
#include <QTextDocument>
#include <QString>
#include <QMutex>
#include <QImage>
#include <QVariantMap>
#include <QTimer>

class TrickItemDelegate : public QQuickPaintedItem
{
    Q_OBJECT
    Q_ENUMS(ButtonActions)
    Q_PROPERTY(QVariantMap itemData READ itemData WRITE setItemData NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 sceneWidth READ sceneWidth WRITE setSceneWidth NOTIFY sceneWidthChanged)
    Q_PROPERTY(qreal avatarSize READ avatarSize WRITE setAvatarSize NOTIFY avatarSizeChanged)
    Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
    Q_PROPERTY(QColor foregroundColor READ foregroundColor WRITE setForegroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(QString fullname READ fullname NOTIFY itemDataChanged)
    Q_PROPERTY(QString username READ username NOTIFY itemDataChanged)
    Q_PROPERTY(QDateTime datetime READ datetime NOTIFY itemDataChanged)
    Q_PROPERTY(QFont fontIcon READ fontIcon WRITE setFontIcon NOTIFY fontIconChanged)
    Q_PROPERTY(QColor highlightColor READ highlightColor WRITE setHighlightColor NOTIFY highlightColorChanged)
    Q_PROPERTY(QStringList tags READ tags NOTIFY itemDataChanged)
    Q_PROPERTY(QString language READ language NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 viewCount READ viewCount NOTIFY itemDataChanged)
    Q_PROPERTY(QString body READ body NOTIFY itemDataChanged)
    Q_PROPERTY(QRectF bodyRect READ bodyRect NOTIFY bodyRectChanged)
    Q_PROPERTY(QRectF contentRect READ contentRect NOTIFY contentRectChanged)
    Q_PROPERTY(QString image READ image NOTIFY itemDataChanged)
    Q_PROPERTY(QString avatar READ avatar NOTIFY itemDataChanged)
    Q_PROPERTY(QSizeF quoteSize READ quoteSize NOTIFY quoteSizeChanged)
    Q_PROPERTY(QSize imageSize READ imageSize NOTIFY itemDataChanged)
    Q_PROPERTY(QString cachePath READ cachePath WRITE setCachePath NOTIFY cachePathChanged)
    Q_PROPERTY(qreal imageRoundness READ imageRoundness WRITE setImageRoundness NOTIFY imageRoundnessChanged)
    Q_PROPERTY(QString replyText READ replyText NOTIFY itemDataChanged)
    Q_PROPERTY(QString retrickText READ retrickText NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 parentId READ parentId WRITE setParentId NOTIFY parentIdChanged)
    Q_PROPERTY(qint32 parentOwnerId READ parentOwnerId NOTIFY itemDataChanged)
    Q_PROPERTY(bool commentMode READ commentMode WRITE setCommentMode NOTIFY commentModeChanged)
    Q_PROPERTY(qint32 trickId READ trickId NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 linkId READ linkId NOTIFY itemDataChanged)
    Q_PROPERTY(bool globalViewMode READ globalViewMode WRITE setGlobalViewMode NOTIFY globalViewModeChanged)
    Q_PROPERTY(QString parentOwnerFullName READ parentOwnerFullName NOTIFY itemDataChanged)
    Q_PROPERTY(QString parentOwnerUsername READ parentOwnerUsername NOTIFY itemDataChanged)
    Q_PROPERTY(bool isRetrick READ isRetrick NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 originalOwnerId READ originalOwnerId NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 ownerId READ ownerId NOTIFY itemDataChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress WRITE setServerAddress NOTIFY serverAddressChanged)
    Q_PROPERTY(QString code READ code NOTIFY itemDataChanged)
    Q_PROPERTY(QVariantList references READ references NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 rates READ rates NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 ratricks READ ratricks NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 tipsSat READ tipsSat NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 comments READ comments NOTIFY itemDataChanged)
    Q_PROPERTY(bool rateState READ rateState WRITE setRateState NOTIFY rateStateChanged)
    Q_PROPERTY(int tipState READ tipState NOTIFY itemDataChanged)
    Q_PROPERTY(QString shareLink READ shareLink NOTIFY itemDataChanged)
    Q_PROPERTY(bool bookmarked READ bookmarked WRITE setBookmarked NOTIFY bookmarkedChanged)
    Q_PROPERTY(qint32 retrickTrickId READ retrickTrickId NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 retrickUserId READ retrickUserId NOTIFY itemDataChanged)
    Q_PROPERTY(QString retrickUsername READ retrickUsername NOTIFY itemDataChanged)
    Q_PROPERTY(QString retrickFullname READ retrickFullname NOTIFY itemDataChanged)
    Q_PROPERTY(QString retrickAvatar READ retrickAvatar NOTIFY itemDataChanged)
    Q_PROPERTY(QString quote READ quote NOTIFY itemDataChanged)
    Q_PROPERTY(QVariantList quotedReferences READ quotedReferences NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 quoteId READ quoteId NOTIFY itemDataChanged)
    Q_PROPERTY(QString quoteUsername READ quoteUsername NOTIFY itemDataChanged)
    Q_PROPERTY(QString quoteFullname READ quoteFullname NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 quoteUserId READ quoteUserId NOTIFY itemDataChanged)
    Q_PROPERTY(QString quoteAvatar READ quoteAvatar NOTIFY itemDataChanged)
    Q_PROPERTY(QString quoteImage READ quoteImage NOTIFY itemDataChanged)
    Q_PROPERTY(QSize quoteImageSize READ quoteImageSize NOTIFY itemDataChanged)
    Q_PROPERTY(bool quoteCodeFrameIsDark READ quoteCodeFrameIsDark NOTIFY itemDataChanged)
    Q_PROPERTY(QString originalBody READ originalBody NOTIFY itemDataChanged)
    Q_PROPERTY(bool stateHeader READ stateHeader WRITE setStateHeader NOTIFY stateHeaderChanged)
    Q_PROPERTY(QColor favoriteColor READ favoriteColor WRITE setFavoriteColor NOTIFY favoriteColorChanged)
    Q_PROPERTY(QColor rateColor READ rateColor WRITE setRateColor NOTIFY rateColorChanged)
    Q_PROPERTY(bool commentLineTop READ commentLineTop WRITE setCommentLineTop NOTIFY commentLineTopChanged)
    Q_PROPERTY(bool commentLineBottom READ commentLineBottom WRITE setCommentLineBottom NOTIFY commentLineBottomChanged)

public:
    enum ButtonActions {
        NoneButton = 0,
        RateButton = 1000,
        CommentButton,
        RetrickButton,
        TipButton,
        FavoriteButton,
        MoreButton
    };

    TrickItemDelegate(QQuickItem *parent = Q_NULLPTR);
    virtual ~TrickItemDelegate();

    void paint(QPainter *painter) Q_DECL_OVERRIDE;

    qreal sceneWidth() const;
    void setSceneWidth(qreal newSceneWidth);

    qreal avatarSize() const;
    void setAvatarSize(qreal newAvatarSize);

    QFont font() const;
    void setFont(const QFont &newFont);

    QColor foregroundColor() const;
    void setForegroundColor(const QColor &newForegroundColor);

    QColor highlightColor() const;
    void setHighlightColor(const QColor &newHighlightColor);

    QString cachePath() const;
    void setCachePath(const QString &newCachePath);

    qreal imageRoundness() const;
    void setImageRoundness(qreal newImageRoundness);

    bool commentMode() const;
    void setCommentMode(bool newCommentMode);

    bool globalViewMode() const;
    void setGlobalViewMode(bool newGlobalViewMode);

    QVariantMap itemData() const;
    void setItemData(const QVariantMap &newItemData);

    QString serverAddress() const;
    void setServerAddress(const QString &newServerAddress);

    QFont fontIcon() const;
    void setFontIcon(const QFont &font);

    bool rateState() const;
    void setRateState(bool rateState);

    bool bookmarked() const;
    void setBookmarked(bool bookmarked);

    qint32 parentId() const;
    void setParentId(qint32 parentId);

    QRectF bodyRect() const;
    QSizeF quoteSize() const;
    QRectF contentRect() const;

    QString fullname() const;
    QString username() const;
    QDateTime datetime() const;
    QStringList tags() const;
    QString language() const;
    qint32 viewCount() const;
    QString body() const;
    QString image() const;
    QString avatar() const;
    QSize imageSize() const;
    QString replyText() const;
    QString retrickText() const;
    qint32 parentOwnerId() const;
    qint32 trickId() const;
    qint32 linkId() const;
    QString parentOwnerFullName() const;
    QString parentOwnerUsername() const;
    bool isRetrick() const;
    qint32 originalOwnerId() const;
    qint32 ownerId() const;
    QString code() const;
    QVariantList references() const;
    qint32 rates() const;
    qint32 ratricks() const;
    qint32 tipsSat() const;
    qint32 comments() const;
    int tipState() const;
    QString shareLink() const;
    qint32 retrickTrickId() const;
    qint32 retrickUserId() const;
    QString retrickUsername() const;
    QString retrickFullname() const;
    QString retrickAvatar() const;
    QString quote() const;
    QVariantList quotedReferences() const;
    qint32 quoteId() const;
    QString quoteUsername() const;
    QString quoteFullname() const;
    qint32 quoteUserId() const;
    QString quoteAvatar() const;
    QString quoteImage() const;
    QSize quoteImageSize() const;
    bool quoteCodeFrameIsDark() const;
    QString originalBody() const;

    bool stateHeader() const;
    void setStateHeader(bool newStateHeader);

    QColor favoriteColor() const;
    void setFavoriteColor(const QColor &newFavoriteColor);

    QColor rateColor() const;
    void setRateColor(const QColor &newRateColor);

    bool commentLineTop() const;
    void setCommentLineTop(bool newCommentLineTop);

    bool commentLineBottom() const;
    void setCommentLineBottom(bool newCommentLineBottom);

Q_SIGNALS:
    void buttonClicked(ButtonActions action, const QRectF &rect);
    void userClicked();
    void clicked();
    void pressAndHold(const QPointF &point);
    void contextMenuRequest(const QPointF &point);
    void imageClicked();
    void sceneWidthChanged();
    void avatarSizeChanged();
    void fontChanged();
    void foregroundColorChanged();
    void itemDataChanged();
    void fontIconChanged();
    void highlightColorChanged();
    void bodyRectChanged();
    void bookmarkedChanged();
    void contentRectChanged();
    void cachePathChanged();
    void imageRoundnessChanged();
    void stateHeaderChanged();
    void commentModeChanged();
    void globalViewModeChanged();
    void serverAddressChanged();
    void rateStateChanged();
    void favoriteColorChanged();
    void rateColorChanged();
    void commentLineTopChanged();
    void commentLineBottomChanged();
    void parentIdChanged();
    void quoteSizeChanged();

private Q_SLOTS:
    void refreshWidth();
    void downloadImage();
    void downloadAvatar();

protected:
    void setupLeftButtons();
    void setupRightButtons();

    QTextDocument *createBodyTextDocument() const;
    QTextDocument *createQuoteTextDocument() const;
    QString styleText(QString t) const;
    QString dateToString(const QDateTime &dateTime);
    QSize calculateImageSize() const;
    QSize calculateQuoteImageSize() const;

    void mouseMoveEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void mousePressEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void mouseReleaseEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void hoverEnterEvent(QHoverEvent *event) Q_DECL_OVERRIDE;
    void hoverLeaveEvent(QHoverEvent *event) Q_DECL_OVERRIDE;
    void hoverMoveEvent(QHoverEvent *event) Q_DECL_OVERRIDE;
    void mouseUngrabEvent() Q_DECL_OVERRIDE;

private:
    struct Button {
        QRectF rect;
        QString normalIcon;
        QString fillIcon;
        ButtonActions action = NoneButton;
        int counter = 0;
        bool highlighted = false;
        QColor highlightColor;

        bool operator==(const Button &b) const {
            return rect == b.rect && normalIcon == b.normalIcon &&
                   fillIcon == b.fillIcon && action == b.action &&
                   counter == b.counter;
        }
        bool operator!=(const Button &b) const {
            return !operator==(b);
        }
    };

    Button *button(ButtonActions action);

    TricksDownloaderEngine *mImageDownloader = Q_NULLPTR;
    TricksDownloaderEngine *mAvatarDownloader = Q_NULLPTR;

    QTimer *mPressAndHoldTimer = Q_NULLPTR;
    QPointF mPressedPos;

    QMutex mMutex;

    qreal mSceneWidth = 450;
    qreal mSceneHeight = 450;
    qreal mAvatarSize = 42;
    qreal mVerticalPadding = 16;
    qreal mSpacing = 10;
    qreal mStateHeaderHeight = 32;
    qreal mButtonsHeight = 32;
    QFont mFont;
    QFont mFontIcon;
    QColor mForegroundColor;
    QColor mHighlightColor;
    QString mServerAddress;
    QString mCachePath;
    TrickItemCacheEngine *mCacheImage = Q_NULLPTR;
    TrickItemCacheEngine *mCacheAvatar = Q_NULLPTR;
    qreal mImageRoundness = 10;

    QList<Button> mLeftSideButtons;
    QList<Button> mRightSideButtons;

    QColor mFavoriteColor;
    QColor mRateColor;

    QString mFullname;
    QString mUsername;
    QDateTime mDatetime;
    QString mTagIcon;
    QStringList mTags;
    QString mLanguage;
    QString mTagDelimiterIcon;
    qint32 mViewCount = 0;
    QString mViewIcon;
    qint32 mRates = 0;
    qint32 mRatricks = 0;
    qint32 mTipsSat = 0;
    qint32 mComments = 0;
    bool mRateState = false;
    int mTipState = 0;
    QString mBody;
    QString mOriginalBody;
    QString mImage;
    QString mAvatar;
    QRectF mUserAreaRect;
    QRectF mImageRect;
    QSize mImageSize;
    QString mCode;
    QVariantList mReferences;
    QString mShareLink;
    bool mBookmarked = false;

    QString mReplyIcon;
    QString mReplyText;
    QString mRetrickIcon;
    QString mRetrickText;
    QString mCodeIcon;
    QString mRoleIcon;

    QString mQuote;
    QVariantList mQuotedReferences;
    qint32 mQuoteId = 0;
    QString mQuoteUsername;
    QString mQuoteFullname;
    qint32 mQuoteUserId = 0;
    QString mQuoteAvatar;

    QString mQuoteImage;
    QSize mQuoteImageSize;
    bool mQuoteCodeFrameIsDark = false;

    bool mStateHeader = false;
    qint32 mOwnerId = 0;
    qint32 mOriginalOwnerId = 0;
    qint32 mParentId = 0;
    qint32 mParentOwnerId = 0;
    bool mCommentMode = false;
    bool mCodeFrameIsDark = false;
    qint32 mOwnerRole = 0;
    qint32 mTrickId = 0;
    qint32 mLinkId = 0;
    bool mGlobalViewMode = false;
    QString mParentOwnerFullName;
    QString mParentOwnerUsername;
    qint32 mRetrickTrickId = 0;
    qint32 mRetrickUserId = 0;
    QString mRetrickUsername;
    QString mRetrickFullname;
    QString mRetrickAvatar;
    bool mIsRetrick = false;
    bool mCommentLineTop = false;
    bool mCommentLineBottom = false;

    QVariantMap mItemData;

    Button mSelectedButton;
};

#endif // TRICKITEMDELEGATE_H
