#ifndef TRICKITEMDELEGATE_H
#define TRICKITEMDELEGATE_H

#include "tricksdownloaderengine.h"

#include <QQuickPaintedItem>
#include <QDateTime>
#include <QStringList>
#include <QTextDocument>
#include <QUrl>
#include <QMutex>
#include <QImage>
#include <QVariantMap>

class TrickItemDelegate : public QQuickPaintedItem
{
    Q_OBJECT
    Q_ENUMS(ButtonActions)
    Q_PROPERTY(QVariantMap itemData READ itemData WRITE setItemData NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 sceneWidth READ sceneWidth WRITE setSceneWidth NOTIFY sceneWidthChanged)
    Q_PROPERTY(qreal avatarSize READ avatarSize WRITE setAvatarSize NOTIFY avatarSizeChanged)
    Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
    Q_PROPERTY(QColor foregroundColor READ foregroundColor WRITE setForegroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(QString fullname READ fullname NOTIFY fullnameChanged)
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)
    Q_PROPERTY(QString datetime READ datetime NOTIFY datetimeChanged)
    Q_PROPERTY(QFont fontIcon READ fontIcon WRITE setFontIcon NOTIFY fontIconChanged)
    Q_PROPERTY(QColor highlightColor READ highlightColor WRITE setHighlightColor NOTIFY highlightColorChanged)
    Q_PROPERTY(QStringList tags READ tags NOTIFY tagsChanged)
    Q_PROPERTY(QString language READ language NOTIFY languageChanged)
    Q_PROPERTY(qint32 viewCount READ viewCount NOTIFY viewCountChanged)
    Q_PROPERTY(QString body READ body NOTIFY bodyChanged)
    Q_PROPERTY(QRectF bodyRect READ bodyRect NOTIFY bodyRectChanged)
    Q_PROPERTY(QRectF contentRect READ contentRect NOTIFY contentRectChanged)
    Q_PROPERTY(QUrl image READ image NOTIFY imageChanged)
    Q_PROPERTY(QUrl avatar READ avatar NOTIFY avatarChanged)
    Q_PROPERTY(QSize imageSize READ imageSize NOTIFY imageSizeChanged)
    Q_PROPERTY(QString cachePath READ cachePath WRITE setCachePath NOTIFY cachePathChanged)
    Q_PROPERTY(qreal imageRoundness READ imageRoundness WRITE setImageRoundness NOTIFY imageRoundnessChanged)
    Q_PROPERTY(QString replyText READ replyText NOTIFY replyTextChanged)
    Q_PROPERTY(QString retrickText READ retrickText NOTIFY retrickTextChanged)
    Q_PROPERTY(qint32 parentId READ parentId NOTIFY parentIdChanged)
    Q_PROPERTY(qint32 parentOwnerId READ parentOwnerId NOTIFY parentOwnerIdChanged)
    Q_PROPERTY(bool commentMode READ commentMode WRITE setCommentMode NOTIFY commentModeChanged)
    Q_PROPERTY(qint32 trickId READ trickId NOTIFY trickIdChanged)
    Q_PROPERTY(qint32 linkId READ linkId NOTIFY linkIdChanged)
    Q_PROPERTY(bool globalViewMode READ globalViewMode WRITE setGlobalViewMode NOTIFY globalViewModeChanged)
    Q_PROPERTY(QString parentOwnerFullName READ parentOwnerFullName NOTIFY parentOwnerFullNameChanged)
    Q_PROPERTY(QString parentOwnerUsername READ parentOwnerUsername NOTIFY parentOwnerUsernameChanged)
    Q_PROPERTY(bool isRetrick READ isRetrick NOTIFY isRetrickChanged)
    Q_PROPERTY(qint32 originalOwnerId READ originalOwnerId NOTIFY originalOwnerIdChanged)
    Q_PROPERTY(qint32 ownerId READ ownerId NOTIFY ownerIdChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress WRITE setServerAddress NOTIFY serverAddressChanged)
    Q_PROPERTY(QString code READ code NOTIFY codeChanged)
    Q_PROPERTY(QVariantList references READ references NOTIFY referencesChanged)
    Q_PROPERTY(qint32 rates READ rates NOTIFY ratesChanged)
    Q_PROPERTY(qint32 ratricks READ ratricks NOTIFY ratricksChanged)
    Q_PROPERTY(qint32 tipsSat READ tipsSat NOTIFY tipsSatChanged)
    Q_PROPERTY(qint32 comments READ comments NOTIFY commentsChanged)
    Q_PROPERTY(bool rateState READ rateState NOTIFY rateStateChanged)
    Q_PROPERTY(int tipState READ tipState NOTIFY tipStateChanged)
    Q_PROPERTY(QString shareLink READ shareLink NOTIFY shareLinkChanged)
    Q_PROPERTY(bool bookmarked READ bookmarked NOTIFY bookmarkedChanged)
    Q_PROPERTY(qint32 retrickTrickId READ retrickTrickId NOTIFY retrickTrickIdChanged)
    Q_PROPERTY(qint32 retrickUserId READ retrickUserId NOTIFY retrickUserIdChanged)
    Q_PROPERTY(QString retrickUsername READ retrickUsername NOTIFY retrickUsernameChanged)
    Q_PROPERTY(QString retrickFullname READ retrickFullname NOTIFY retrickFullnameChanged)
    Q_PROPERTY(QUrl retrickAvatar READ retrickAvatar NOTIFY retrickAvatarChanged)
    Q_PROPERTY(QString quote READ quote NOTIFY quoteChanged)
    Q_PROPERTY(QVariantList quotedReferences READ quotedReferences NOTIFY quotedReferencesChanged)
    Q_PROPERTY(qint32 quoteId READ quoteId NOTIFY quoteIdChanged)
    Q_PROPERTY(QString quoteUsername READ quoteUsername NOTIFY quoteUsernameChanged)
    Q_PROPERTY(QString quoteFullname READ quoteFullname NOTIFY quoteFullnameChanged)
    Q_PROPERTY(qint32 quoteUserId READ quoteUserId NOTIFY quoteUserIdChanged)
    Q_PROPERTY(QUrl quoteAvatar READ quoteAvatar NOTIFY quoteAvatarChanged)
    Q_PROPERTY(QUrl quoteImage READ quoteImage NOTIFY quoteImageChanged)
    Q_PROPERTY(QSize quoteImageSize READ quoteImageSize NOTIFY quoteImageSizeChanged)
    Q_PROPERTY(bool quoteCodeFrameIsDark READ quoteCodeFrameIsDark NOTIFY quoteCodeFrameIsDarkChanged)
    Q_PROPERTY(QString originalBody READ originalBody NOTIFY originalBodyChanged)

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

    QRectF bodyRect() const;
    QRectF contentRect() const;

    QString fullname() const;
    QString username() const;
    QString datetime() const;
    QStringList tags() const;
    QString language() const;
    qint32 viewCount() const;
    QString body() const;
    QUrl image() const;
    QUrl avatar() const;
    QSize imageSize() const;
    QString replyText() const;
    QString retrickText() const;
    qint32 parentId() const;
    qint32 parentOwnerId() const;
    qint32 trickId() const;
    qint32 linkId() const;
    QString parentOwnerFullName() const;
    QString parentOwnerUsername() const;
    bool isRetrick() const;
    qint32 originalOwnerId() const;
    qint32 ownerId() const;
    QString code() const;
    const QVariantList &references() const;
    qint32 rates() const;
    qint32 ratricks() const;
    qint32 tipsSat() const;
    qint32 comments() const;
    bool rateState() const;
    int tipState() const;
    QString shareLink() const;
    bool bookmarked() const;
    qint32 retrickTrickId() const;
    qint32 retrickUserId() const;
    QString retrickUsername() const;
    QString retrickFullname() const;
    QUrl retrickAvatar() const;
    QString quote() const;
    const QVariantList &quotedReferences() const;
    qint32 quoteId() const;
    QString quoteUsername() const;
    QString quoteFullname() const;
    qint32 quoteUserId() const;
    QUrl quoteAvatar() const;
    QUrl quoteImage() const;
    QSize quoteImageSize() const;
    bool quoteCodeFrameIsDark() const;
    QString originalBody() const;

    bool stateHeader() const;
    void setStateHeader(bool newStateHeader);

Q_SIGNALS:
    void buttonClicked(ButtonActions action, const QRectF &rect);
    void clicked();
    void sceneWidthChanged();
    void avatarSizeChanged();
    void fontChanged();
    void foregroundColorChanged();
    void fullnameChanged();
    void usernameChanged();
    void datetimeChanged();
    void fontIconChanged();
    void highlightColorChanged();
    void tagsChanged();
    void languageChanged();
    void viewCountChanged();
    void bodyChanged();
    void bodyRectChanged();
    void contentRectChanged();
    void imageChanged();
    void avatarChanged();
    void imageSizeChanged();
    void cachePathChanged();
    void imageRoundnessChanged();
    void replyTextChanged();
    void retrickTextChanged();
    void stateHeaderChanged();
    void parentIdChanged();
    void parentOwnerIdChanged();
    void commentModeChanged();
    void trickIdChanged();
    void linkIdChanged();
    void globalViewModeChanged();
    void parentOwnerFullNameChanged();
    void parentOwnerUsernameChanged();
    void isRetrickChanged();
    void itemDataChanged();
    void originalOwnerIdChanged();
    void ownerIdChanged();
    void serverAddressChanged();
    void codeChanged();
    void referencesChanged();
    void ratesChanged();
    void ratricksChanged();
    void tipsSatChanged();
    void commentsChanged();
    void rateStateChanged();
    void tipStateChanged();
    void shareLinkChanged();
    void bookmarkedChanged();
    void retrickTrickIdChanged();
    void retrickUserIdChanged();
    void retrickUsernameChanged();
    void retrickFullnameChanged();
    void retrickAvatarChanged();
    void quoteChanged();
    void quotedReferencesChanged();
    void quoteIdChanged();
    void quoteUsernameChanged();
    void quoteFullnameChanged();
    void quoteUserIdChanged();
    void quoteAvatarChanged();
    void quoteImageChanged();
    void quoteImageSizeChanged();
    void quoteCodeFrameIsDarkChanged();
    void originalBodyChanged();

private Q_SLOTS:
    void refreshWidth();
    void downloadImage();
    void downloadAvatar();

protected:
    void setupLeftButtons();
    void setupRightButtons();

    QTextDocument *createTextDocument() const;
    QString styleText(QString t) const;
    QSize calculateImageSize() const;

    void mouseMoveEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void mousePressEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void mouseReleaseEvent(QMouseEvent *event) Q_DECL_OVERRIDE;
    void hoverEnterEvent(QHoverEvent *event) Q_DECL_OVERRIDE;
    void hoverLeaveEvent(QHoverEvent *event) Q_DECL_OVERRIDE;
    void hoverMoveEvent(QHoverEvent *event) Q_DECL_OVERRIDE;

private:
    struct Button {
        QRectF rect;
        QString normalIcon;
        QString fillIcon;
        ButtonActions action = NoneButton;
        int counter = 0;

        bool operator==(const Button &b) const {
            return rect == b.rect && normalIcon == b.normalIcon &&
                   fillIcon == b.fillIcon && action == b.action &&
                   counter == b.counter;
        }
        bool operator!=(const Button &b) const {
            return !operator==(b);
        }
    };

    TricksDownloaderEngine *mImageDownloader = Q_NULLPTR;
    TricksDownloaderEngine *mAvatarDownloader = Q_NULLPTR;

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
    QImage mCacheImage;
    QImage mCacheAvatar;
    qreal mImageRoundness = 10;

    QList<Button> mLeftSideButtons;
    QList<Button> mRightSideButtons;

    QString mFullname;
    QString mUsername;
    QString mDatetime;
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
    QUrl mImage;
    QUrl mAvatar;
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
    QUrl mQuoteAvatar;

    QUrl mQuoteImage;
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
    QUrl mRetrickAvatar;
    bool mIsRetrick = false;
    bool mCommentLineTop = false;
    bool mCommentLineBottom = false;

    QVariantMap mItemData;

    Button mSelectedButton;
    Q_PROPERTY(bool stateHeader READ stateHeader WRITE setStateHeader NOTIFY stateHeaderChanged)
};

#endif // TRICKITEMDELEGATE_H
