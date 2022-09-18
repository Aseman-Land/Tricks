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

class TrickItemDelegate : public QQuickPaintedItem
{
    Q_OBJECT
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

private Q_SLOTS:
    void refreshWidth();
    void downloadImage();
    void downloadAvatar();

protected:
    QTextDocument *createTextDocument() const;

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
    qint32 mViewCount;
    QString mViewIcon;
    QString mBody;
    QUrl mImage;
    QUrl mAvatar;
    QSize mImageSize;
};

#endif // TRICKITEMDELEGATE_H
