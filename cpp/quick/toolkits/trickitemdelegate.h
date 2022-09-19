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
    Q_PROPERTY(QVariantMap itemData READ itemData WRITE setItemData NOTIFY itemDataChanged)
    Q_PROPERTY(qint32 sceneWidth READ sceneWidth WRITE setSceneWidth NOTIFY sceneWidthChanged)
    Q_PROPERTY(qreal avatarSize READ avatarSize WRITE setAvatarSize NOTIFY avatarSizeChanged)
    Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
    Q_PROPERTY(QColor foregroundColor READ foregroundColor WRITE setForegroundColor NOTIFY foregroundColorChanged)
    Q_PROPERTY(QString fullname READ fullname WRITE setFullname NOTIFY fullnameChanged)
    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged)
    Q_PROPERTY(QString datetime READ datetime WRITE setDatetime NOTIFY datetimeChanged)
    Q_PROPERTY(QFont fontIcon READ fontIcon WRITE setFontIcon NOTIFY fontIconChanged)
    Q_PROPERTY(QString tagIcon READ tagIcon WRITE setTagIcon NOTIFY tagIconChanged)
    Q_PROPERTY(QColor highlightColor READ highlightColor WRITE setHighlightColor NOTIFY highlightColorChanged)
    Q_PROPERTY(QStringList tags READ tags WRITE setTags NOTIFY tagsChanged)
    Q_PROPERTY(QString tagDelimiterIcon READ tagDelimiterIcon WRITE setTagDelimiterIcon NOTIFY tagDelimiterIconChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(qint32 viewCount READ viewCount WRITE setViewCount NOTIFY viewCountChanged)
    Q_PROPERTY(QString viewIcon READ viewIcon WRITE setViewIcon NOTIFY viewIconChanged)
    Q_PROPERTY(QString body READ body WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(QRectF bodyRect READ bodyRect NOTIFY bodyRectChanged)
    Q_PROPERTY(QRectF contentRect READ contentRect NOTIFY contentRectChanged)
    Q_PROPERTY(QUrl image READ image WRITE setImage NOTIFY imageChanged)
    Q_PROPERTY(QUrl avatar READ avatar WRITE setAvatar NOTIFY avatarChanged)
    Q_PROPERTY(QSize imageSize READ imageSize WRITE setImageSize NOTIFY imageSizeChanged)
    Q_PROPERTY(QString cachePath READ cachePath WRITE setCachePath NOTIFY cachePathChanged)
    Q_PROPERTY(qreal imageRoundness READ imageRoundness WRITE setImageRoundness NOTIFY imageRoundnessChanged)
    Q_PROPERTY(QString replyIcon READ replyIcon WRITE setReplyIcon NOTIFY replyIconChanged)
    Q_PROPERTY(QString replyText READ replyText WRITE setReplyText NOTIFY replyTextChanged)
    Q_PROPERTY(QString retrickIcon READ retrickIcon WRITE setRetrickIcon NOTIFY retrickIconChanged)
    Q_PROPERTY(QString retrickText READ retrickText WRITE setRetrickText NOTIFY retrickTextChanged)
    Q_PROPERTY(bool stateHeader READ stateHeader WRITE setStateHeader NOTIFY stateHeaderChanged)
    Q_PROPERTY(qint32 parentId READ parentId WRITE setParentId NOTIFY parentIdChanged)
    Q_PROPERTY(qint32 parentOwnerId READ parentOwnerId WRITE setParentOwnerId NOTIFY parentOwnerIdChanged)
    Q_PROPERTY(bool commentMode READ commentMode WRITE setCommentMode NOTIFY commentModeChanged)
    Q_PROPERTY(qint32 trickId READ trickId WRITE setTrickId NOTIFY trickIdChanged)
    Q_PROPERTY(qint32 linkId READ linkId WRITE setLinkId NOTIFY linkIdChanged)
    Q_PROPERTY(bool globalViewMode READ globalViewMode WRITE setGlobalViewMode NOTIFY globalViewModeChanged)
    Q_PROPERTY(QString parentOwnerFullName READ parentOwnerFullName WRITE setParentOwnerFullName NOTIFY parentOwnerFullNameChanged)
    Q_PROPERTY(QString parentOwnerUsername READ parentOwnerUsername WRITE setParentOwnerUsername NOTIFY parentOwnerUsernameChanged)
    Q_PROPERTY(bool isRetrick READ isRetrick WRITE setIsRetrick NOTIFY isRetrickChanged)
    Q_PROPERTY(qint32 originalOwnerId READ originalOwnerId WRITE setOriginalOwnerId NOTIFY originalOwnerIdChanged)
    Q_PROPERTY(qint32 ownerId READ ownerId WRITE setOwnerId NOTIFY ownerIdChanged)
    Q_PROPERTY(QString serverAddress READ serverAddress WRITE setServerAddress NOTIFY serverAddressChanged)
    Q_PROPERTY(QString code READ code WRITE setCode NOTIFY codeChanged)
    Q_PROPERTY(QVariantList references READ references WRITE setReferences NOTIFY referencesChanged)
    Q_PROPERTY(qint32 rates READ rates WRITE setRates NOTIFY ratesChanged)
    Q_PROPERTY(qint32 ratricks READ ratricks WRITE setRatricks NOTIFY ratricksChanged)
    Q_PROPERTY(qint32 tipsSat READ tipsSat WRITE setTipsSat NOTIFY tipsSatChanged)
    Q_PROPERTY(qint32 comments READ comments WRITE setComments NOTIFY commentsChanged)
    Q_PROPERTY(bool rateState READ rateState WRITE setRateState NOTIFY rateStateChanged)
    Q_PROPERTY(int tipState READ tipState WRITE setTipState NOTIFY tipStateChanged)
    Q_PROPERTY(QString shareLink READ shareLink WRITE setShareLink NOTIFY shareLinkChanged)
    Q_PROPERTY(bool bookmarked READ bookmarked WRITE setBookmarked NOTIFY bookmarkedChanged)
    Q_PROPERTY(QString codeIcon READ codeIcon WRITE setCodeIcon NOTIFY codeIconChanged)
    Q_PROPERTY(QString roleIcon READ roleIcon WRITE setRoleIcon NOTIFY roleIconChanged)
    Q_PROPERTY(qint32 retrickTrickId READ retrickTrickId WRITE setRetrickTrickId NOTIFY retrickTrickIdChanged)
    Q_PROPERTY(qint32 retrickUserId READ retrickUserId WRITE setRetrickUserId NOTIFY retrickUserIdChanged)
    Q_PROPERTY(QString retrickUsername READ retrickUsername WRITE setRetrickUsername NOTIFY retrickUsernameChanged)
    Q_PROPERTY(QString retrickFullname READ retrickFullname WRITE setRetrickFullname NOTIFY retrickFullnameChanged)
    Q_PROPERTY(QUrl retrickAvatar READ retrickAvatar WRITE setRetrickAvatar NOTIFY retrickAvatarChanged)
    Q_PROPERTY(QString quote READ quote WRITE setQuote NOTIFY quoteChanged)
    Q_PROPERTY(QVariantList quotedReferences READ quotedReferences WRITE setQuotedReferences NOTIFY quotedReferencesChanged)
    Q_PROPERTY(qint32 quoteId READ quoteId WRITE setQuoteId NOTIFY quoteIdChanged)
    Q_PROPERTY(QString quoteUsername READ quoteUsername WRITE setQuoteUsername NOTIFY quoteUsernameChanged)
    Q_PROPERTY(QString quoteFullname READ quoteFullname WRITE setQuoteFullname NOTIFY quoteFullnameChanged)
    Q_PROPERTY(qint32 quoteUserId READ quoteUserId WRITE setQuoteUserId NOTIFY quoteUserIdChanged)
    Q_PROPERTY(QUrl quoteAvatar READ quoteAvatar WRITE setQuoteAvatar NOTIFY quoteAvatarChanged)
    Q_PROPERTY(QUrl quoteImage READ quoteImage WRITE setQuoteImage NOTIFY quoteImageChanged)
    Q_PROPERTY(QSize quoteImageSize READ quoteImageSize WRITE setQuoteImageSize NOTIFY quoteImageSizeChanged)
    Q_PROPERTY(bool quoteCodeFrameIsDark READ quoteCodeFrameIsDark WRITE setQuoteCodeFrameIsDark NOTIFY quoteCodeFrameIsDarkChanged)

public:
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

    QString fullname() const;
    void setFullname(const QString &newFullname);

    QString username() const;
    void setUsername(const QString &newUsername);

    QString datetime() const;
    void setDatetime(const QString &newDatetime);

    QFont fontIcon() const;
    void setFontIcon(const QFont &newFontIcon);

    QString tagIcon() const;
    void setTagIcon(const QString &newTagIcon);

    QColor highlightColor() const;
    void setHighlightColor(const QColor &newHighlightColor);

    QStringList tags() const;
    void setTags(const QStringList &newTags);

    QString tagDelimiterIcon() const;
    void setTagDelimiterIcon(const QString &newTagDelimiterIcon);

    QString language() const;
    void setLanguage(const QString &newLanguage);

    qint32 viewCount() const;
    void setViewCount(qint32 newViewCount);

    QString viewIcon() const;
    void setViewIcon(const QString &newViewIcon);

    QString body() const;
    void setBody(const QString &newBody);

    QRectF bodyRect() const;
    QRectF contentRect() const;

    QUrl image() const;
    void setImage(const QUrl &newImage);

    QUrl avatar() const;
    void setAvatar(const QUrl &newAvatar);

    QSize imageSize() const;
    void setImageSize(const QSize &newImageSize);

    QString cachePath() const;
    void setCachePath(const QString &newCachePath);

    qreal imageRoundness() const;
    void setImageRoundness(qreal newImageRoundness);

    QString replyIcon() const;
    void setReplyIcon(const QString &newReplyIcon);

    QString replyText() const;
    void setReplyText(const QString &newReplyText);

    QString retrickIcon() const;
    void setRetrickIcon(const QString &newRetrickIcon);

    QString retrickText() const;
    void setRetrickText(const QString &newRetrickText);

    bool stateHeader() const;
    void setStateHeader(bool newStateHeader);

    qint32 parentId() const;
    void setParentId(qint32 newParentId);

    qint32 parentOwnerId() const;
    void setParentOwnerId(qint32 newParentOwnerId);

    bool commentMode() const;
    void setCommentMode(bool newCommentMode);

    qint32 trickId() const;
    void setTrickId(qint32 newTrickId);

    qint32 linkId() const;
    void setLinkId(qint32 newLinkId);

    bool globalViewMode() const;
    void setGlobalViewMode(bool newGlobalViewMode);

    QString parentOwnerFullName() const;
    void setParentOwnerFullName(const QString &newParentOwnerFullName);

    QString parentOwnerUsername() const;
    void setParentOwnerUsername(const QString &newParentOwnerUsername);

    bool isRetrick() const;
    void setIsRetrick(bool newIsRetrick);

    QVariantMap itemData() const;
    void setItemData(const QVariantMap &newItemData);

    qint32 originalOwnerId() const;
    void setOriginalOwnerId(qint32 newOriginalOwnerId);

    qint32 ownerId() const;
    void setOwnerId(qint32 newOwnerId);

    QString serverAddress() const;
    void setServerAddress(const QString &newServerAddress);

    QString code() const;
    void setCode(const QString &newCode);

    const QVariantList &references() const;
    void setReferences(const QVariantList &newReferences);

    qint32 rates() const;
    void setRates(qint32 newRates);

    qint32 ratricks() const;
    void setRatricks(qint32 newRatricks);

    qint32 tipsSat() const;
    void setTipsSat(qint32 newTipsSat);

    qint32 comments() const;
    void setComments(qint32 newComments);

    bool rateState() const;
    void setRateState(bool newRateState);

    int tipState() const;
    void setTipState(int newTipState);

    QString shareLink() const;
    void setShareLink(const QString &newShareLink);

    bool bookmarked() const;
    void setBookmarked(bool newBookmarked);

    QString codeIcon() const;
    void setCodeIcon(const QString &newCodeIcon);

    QString roleIcon() const;
    void setRoleIcon(const QString &newRoleIcon);

    qint32 retrickTrickId() const;
    void setRetrickTrickId(qint32 newRetrickTrickId);

    qint32 retrickUserId() const;
    void setRetrickUserId(qint32 newRetrickUserId);

    QString retrickUsername() const;
    void setRetrickUsername(const QString &newRetrickUsername);

    QString retrickFullname() const;
    void setRetrickFullname(const QString &newRetrickFullname);

    QUrl retrickAvatar() const;
    void setRetrickAvatar(const QUrl &newRetrickAvatar);

    QString quote() const;
    void setQuote(const QString &newQuote);

    const QVariantList &quotedReferences() const;
    void setQuotedReferences(const QVariantList &newQuotedReferences);

    qint32 quoteId() const;
    void setQuoteId(qint32 newQuoteId);

    QString quoteUsername() const;
    void setQuoteUsername(const QString &newQuoteUsername);

    QString quoteFullname() const;
    void setQuoteFullname(const QString &newQuoteFullname);

    qint32 quoteUserId() const;
    void setQuoteUserId(qint32 newQuoteUserId);

    QUrl quoteAvatar() const;
    void setQuoteAvatar(const QUrl &newQuoteAvatar);

    QUrl quoteImage() const;
    void setQuoteImage(const QUrl &newQuoteImage);

    QSize quoteImageSize() const;
    void setQuoteImageSize(const QSize &newQuoteImageSize);

    bool quoteCodeFrameIsDark() const;
    void setQuoteCodeFrameIsDark(bool newQuoteCodeFrameIsDark);

Q_SIGNALS:
    void sceneWidthChanged();
    void avatarSizeChanged();
    void fontChanged();
    void foregroundColorChanged();
    void fullnameChanged();
    void usernameChanged();
    void datetimeChanged();
    void fontIconChanged();
    void tagIconChanged();
    void highlightColorChanged();
    void tagsChanged();
    void tagDelimiterIconChanged();
    void languageChanged();
    void viewCountChanged();
    void viewIconChanged();
    void bodyChanged();
    void bodyRectChanged();
    void contentRectChanged();
    void imageChanged();
    void avatarChanged();
    void imageSizeChanged();
    void cachePathChanged();
    void imageRoundnessChanged();
    void replyIconChanged();
    void replyTextChanged();
    void retrickIconChanged();
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
    void codeIconChanged();
    void roleIconChanged();
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

private Q_SLOTS:
    void refreshWidth();
    void downloadImage();
    void downloadAvatar();

protected:
    QTextDocument *createTextDocument() const;
    QString styleText(QString t) const;

private:
    TricksDownloaderEngine *mImageDownloader = Q_NULLPTR;
    TricksDownloaderEngine *mAvatarDownloader = Q_NULLPTR;

    QMutex mMutex;

    qreal mSceneWidth = 450;
    qreal mSceneHeight = 450;
    qreal mAvatarSize = 42;
    qreal mVerticalPadding = 16;
    qreal mSpacing = 10;
    QFont mFont;
    QFont mFontIcon;
    QColor mForegroundColor;
    QColor mHighlightColor;
    QString mServerAddress;
    QString mCachePath;
    QImage mCacheImage;
    QImage mCacheAvatar;
    qreal mImageRoundness = 10;

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
};

#endif // TRICKITEMDELEGATE_H
