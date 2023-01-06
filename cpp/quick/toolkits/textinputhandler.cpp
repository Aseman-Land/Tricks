#include "textinputhandler.h"

#include <QDebug>
#include <QtQml>

#ifdef Q_OS_WASM
EMSCRIPTEN_BINDINGS(test_module) {
    function("qasm_inputContextCallback", &TextInputHandler::inputCallback);
    function("qasm_focusContextCallback", &TextInputHandler::focusCallback);
    function("qasm_blurContextCallback", &TextInputHandler::blurCallback);
}
#endif

QSet<TextInputHandler*> TextInputHandler::mObjects;

TextInputHandler::TextInputHandler(QObject *parent)
    : QObject{parent}
{
    mObjects.insert(this);

#ifdef Q_OS_WASM
    mApiIsAvailable = true;

    emscripten::val document = emscripten::val::global("document");
    mInputElement = document.call<emscripten::val>("createElement", std::string("input"));
    mInputElement.set("type", "text");
    mInputElement.set("contenteditable","true");

    restyle();

    emscripten::val body = document["body"];
    body.call<void>("appendChild", mInputElement);

    mInputElement.call<void>("addEventListener", std::string("input"),
                              emscripten::val::module_property("qasm_inputContextCallback"));
    mInputElement.call<void>("addEventListener", std::string("focus"),
                             emscripten::val::module_property("qasm_focusContextCallback"));
    mInputElement.call<void>("addEventListener", std::string("blur"),
                             emscripten::val::module_property("qasm_blurContextCallback"));
    mInputElement.set("data-context",
                       emscripten::val(quintptr(reinterpret_cast<void *>(this))));
#endif
}

TextInputHandler::~TextInputHandler()
{
    mObjects.remove(this);

#ifdef Q_OS_WASM
    emscripten::val document = emscripten::val::global("document");
    emscripten::val body = document["body"];
    body.call<void>("removeChild", mInputElement);
#endif
}

#ifdef Q_OS_WASM
void TextInputHandler::inputCallback(emscripten::val event)
{
    auto dis = findObject(event);
    if (!dis)
        return;

    const auto target = event["target"];
    emscripten::val _incomingCharVal = target["value"];

    if (_incomingCharVal == emscripten::val::undefined() || _incomingCharVal == emscripten::val::null())
        return;

    dis->mText = QString::fromStdString(_incomingCharVal.as<std::string>());
    Q_EMIT dis->textChanged();
}

void TextInputHandler::focusCallback(emscripten::val event)
{
    auto dis = findObject(event);
    if (!dis)
        return;

    dis->mFocused = true;
    Q_EMIT dis->focusedChanged();
}

void TextInputHandler::blurCallback(emscripten::val event)
{
    auto dis = findObject(event);
    if (!dis)
        return;

    dis->mFocused = false;
    Q_EMIT dis->focusedChanged();
}

TextInputHandler *TextInputHandler::findObject(emscripten::val event)
{
    const auto target = event["target"];
    for (const auto &obj: TextInputHandler::mObjects)
        if (obj->mInputElement == target)
        {
            return obj;
            break;
        }
    return nullptr;
}
#endif

QString TextInputHandler::text() const
{
    return mText;
}

void TextInputHandler::setText(const QString &newText)
{
    if (mText == newText)
        return;
    mText = newText;
#ifdef Q_OS_WASM
    mInputElement.set("value", mText.toStdString());
#endif
    Q_EMIT textChanged();
}

qreal TextInputHandler::x() const
{
    return mX;
}

void TextInputHandler::setX(qreal newX)
{
    if (qFuzzyCompare(mX, newX))
        return;
    mX = newX;
    restyle();
    Q_EMIT xChanged();
}

qreal TextInputHandler::y() const
{
    return mY;
}

void TextInputHandler::setY(qreal newY)
{
    if (qFuzzyCompare(mY, newY))
        return;
    mY = newY;
    restyle();
    Q_EMIT yChanged();
}

void TextInputHandler::restyle()
{
#ifdef Q_OS_WASM
    auto style = QStringLiteral("position:absolute;");
    style += QStringLiteral("left:%1px;").arg(mLeftPadding + mX);
    style += QStringLiteral("top:%1px;").arg(mY);
    style += QStringLiteral("width:%1px;").arg(mWidth - mLeftPadding*2 - mRightPadding);
    style += QStringLiteral("height:%1px;").arg(mHeight - mTopPadding - mBottomPaddding);
    style += QStringLiteral("font-size:%1px;").arg(mFont.pixelSize());
    style += QStringLiteral("font-family: %1;").arg(mFont.family());
//    style += QStringLiteral("letter-spacing:%1em;").arg(mFont.letterSpacing());
    style += QStringLiteral("border: 0px solid;");
    style += QStringLiteral("outline: none;");
    style += QStringLiteral("background: transparent;");
    style += QStringLiteral("color: #%1;").arg(mColor.name());
    style += QStringLiteral("padding-top: %1px;").arg(mTopPadding);
    style += QStringLiteral("padding-bottom: %1px;").arg(mBottomPaddding);
    if (!mVisible)
        style += QStringLiteral("display: none;");

    switch (mHorizonalAlignment)
    {
    case Qt::AlignCenter:
    case Qt::AlignHCenter:
        style += QStringLiteral("text-align: center;");
        break;
    case Qt::AlignRight:
        style += QStringLiteral("text-align: right;");
        break;
    default:
    case Qt::AlignLeft:
        style += QStringLiteral("text-align: left;");
        break;
    }

    mInputElement.set("style", style.toStdString().c_str());
#endif
}

bool TextInputHandler::apiIsAvailable() const
{
    return mApiIsAvailable;
}

int TextInputHandler::horizonalAlignment() const
{
    return mHorizonalAlignment;
}

void TextInputHandler::setHorizonalAlignment(int newHorizonalAlignment)
{
    if (mHorizonalAlignment == newHorizonalAlignment)
        return;
    mHorizonalAlignment = newHorizonalAlignment;
    restyle();
    Q_EMIT horizonalAlignmentChanged();
}

bool TextInputHandler::focused() const
{
    return mFocused;
}

bool TextInputHandler::visible() const
{
    return mVisible;
}

void TextInputHandler::setVisible(bool newVisible)
{
    if (mVisible == newVisible)
        return;
    mVisible = newVisible;
    restyle();
#ifdef Q_OS_WASM
    if (!mVisible)
        mInputElement.call<void>("blur");
#endif

    Q_EMIT visibleChanged();
}

void TextInputHandler::focus()
{
#ifdef Q_OS_WASM
    mInputElement.call<void>("focus");
#endif
}

int TextInputHandler::echoMode() const
{
    return mEchoMode;
}

void TextInputHandler::setEchoMode(int newEchoMode)
{
    if (mEchoMode == newEchoMode)
        return;
    mEchoMode = newEchoMode;
#ifdef Q_OS_WASM
    mInputElement.set("type", mEchoMode? "password" : "text");
#endif
    Q_EMIT echoModeChanged();
}

QColor TextInputHandler::color() const
{
    return mColor;
}

void TextInputHandler::setColor(const QColor &newColor)
{
    if (mColor == newColor)
        return;
    mColor = newColor;
    restyle();
    Q_EMIT colorChanged();
}

qreal TextInputHandler::rightPadding() const
{
    return mRightPadding;
}

void TextInputHandler::setRightPadding(qreal newRightPadding)
{
    if (qFuzzyCompare(mRightPadding, newRightPadding))
        return;
    mRightPadding = newRightPadding;
    restyle();
    Q_EMIT rightPaddingChanged();
}

qreal TextInputHandler::bottomPaddding() const
{
    return mBottomPaddding;
}

void TextInputHandler::setBottomPaddding(qreal newBottomPaddding)
{
    if (qFuzzyCompare(mBottomPaddding, newBottomPaddding))
        return;
    mBottomPaddding = newBottomPaddding;
    restyle();
    Q_EMIT bottomPadddingChanged();
}

qreal TextInputHandler::topPadding() const
{
    return mTopPadding;
}

void TextInputHandler::setTopPadding(qreal newTopPadding)
{
    if (qFuzzyCompare(mTopPadding, newTopPadding))
        return;
    mTopPadding = newTopPadding;
    restyle();
    Q_EMIT topPaddingChanged();
}

qreal TextInputHandler::leftPadding() const
{
    return mLeftPadding;
}

void TextInputHandler::setLeftPadding(qreal newLeftPadding)
{
    if (qFuzzyCompare(mLeftPadding, newLeftPadding))
        return;
    mLeftPadding = newLeftPadding;
    restyle();
    Q_EMIT leftPaddingChanged();
}

QFont TextInputHandler::font() const
{
    return mFont;
}

void TextInputHandler::setFont(const QFont &newFont)
{
    if (mFont == newFont)
        return;
    mFont = newFont;
    restyle();
    Q_EMIT fontChanged();
}

qreal TextInputHandler::height() const
{
    return mHeight;
}

void TextInputHandler::setHeight(qreal newHeight)
{
    if (qFuzzyCompare(mHeight, newHeight))
        return;
    mHeight = newHeight;
    restyle();
    Q_EMIT heightChanged();
}

qreal TextInputHandler::width() const
{
    return mWidth;
}

void TextInputHandler::setWidth(qreal newWidth)
{
    if (qFuzzyCompare(mWidth, newWidth))
        return;
    mWidth = newWidth;
    restyle();
    Q_EMIT widthChanged();
}

static void register_qml_trick_text_input_handler() {
    qmlRegisterType<TextInputHandler>("Tricks", 1, 0, "TextInputHandlerCore");
}

Q_COREAPP_STARTUP_FUNCTION(register_qml_trick_text_input_handler)
