#ifndef TEXTINPUTHANDLER_H
#define TEXTINPUTHANDLER_H

#include <QFont>
#include <QObject>
#include <QSet>
#include <QColor>

#ifdef Q_OS_WASM
#include <emscripten/bind.h>
#include <emscripten/html5.h>
#include <emscripten/emscripten.h>
#endif

class TextInputHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(qreal x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(qreal y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(qreal width READ width WRITE setWidth NOTIFY widthChanged)
    Q_PROPERTY(qreal height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(QFont font READ font WRITE setFont NOTIFY fontChanged)
    Q_PROPERTY(qreal leftPadding READ leftPadding WRITE setLeftPadding NOTIFY leftPaddingChanged)
    Q_PROPERTY(qreal topPadding READ topPadding WRITE setTopPadding NOTIFY topPaddingChanged)
    Q_PROPERTY(qreal bottomPaddding READ bottomPaddding WRITE setBottomPaddding NOTIFY bottomPadddingChanged)
    Q_PROPERTY(qreal rightPadding READ rightPadding WRITE setRightPadding NOTIFY rightPaddingChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(int echoMode READ echoMode WRITE setEchoMode NOTIFY echoModeChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool focused READ focused NOTIFY focusedChanged)
    Q_PROPERTY(int horizonalAlignment READ horizonalAlignment WRITE setHorizonalAlignment NOTIFY horizonalAlignmentChanged)
    Q_PROPERTY(bool apiIsAvailable READ apiIsAvailable NOTIFY apiIsAvailableChanged)

public:
    TextInputHandler(QObject *parent = nullptr);
    virtual ~TextInputHandler();

#ifdef Q_OS_WASM
    static void inputCallback(emscripten::val event);
    static void focusCallback(emscripten::val event);
    static void blurCallback(emscripten::val event);
    static TextInputHandler *findObject(emscripten::val event);
#endif

    QString text() const;
    void setText(const QString &newText);

    qreal x() const;
    void setX(qreal newX);

    qreal y() const;
    void setY(qreal newY);

    qreal width() const;
    void setWidth(qreal newWidth);

    qreal height() const;
    void setHeight(qreal newHeight);

    QFont font() const;
    void setFont(const QFont &newFont);

    qreal leftPadding() const;
    void setLeftPadding(qreal newLeftPadding);

    qreal topPadding() const;
    void setTopPadding(qreal newTopPadding);

    qreal bottomPaddding() const;
    void setBottomPaddding(qreal newBottomPaddding);

    qreal rightPadding() const;
    void setRightPadding(qreal newRightPadding);

    QColor color() const;
    void setColor(const QColor &newColor);

    int echoMode() const;
    void setEchoMode(int newEchoMode);

    bool visible() const;
    void setVisible(bool newVisible);

    bool focused() const;

    int horizonalAlignment() const;
    void setHorizonalAlignment(int newHorizonalAlignment);

    bool apiIsAvailable() const;

public Q_SLOTS:
    void focus();

Q_SIGNALS:
    void textChanged();
    void xChanged();
    void yChanged();
    void widthChanged();
    void heightChanged();
    void fontChanged();
    void leftPaddingChanged();
    void topPaddingChanged();
    void bottomPadddingChanged();
    void rightPaddingChanged();
    void colorChanged();
    void echoModeChanged();
    void visibleChanged();
    void focusedChanged();
    void horizonalAlignmentChanged();
    void apiIsAvailableChanged();

protected:
    void restyle();

private:
    static QSet<TextInputHandler*> mObjects;
#ifdef Q_OS_WASM
    emscripten::val mInputElement = emscripten::val::null();
#endif

    QString mText;
    qreal mX = 0;
    qreal mY = 0;
    qreal mWidth = 10;
    qreal mHeight = 10;
    qreal mLeftPadding = 0;
    qreal mTopPadding = 0;
    qreal mBottomPaddding = 0;
    qreal mRightPadding = 0;
    QFont mFont;
    QColor mColor;
    int mHorizonalAlignment = 0;
    int mEchoMode = 0;
    bool mVisible = true;
    bool mFocused = false;
    bool mApiIsAvailable = false;
};

#endif // TEXTINPUTHANDLER_H
