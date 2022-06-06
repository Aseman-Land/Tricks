#include "textdirectionhandler.h"
#include "trickstools.h"

#include <QTextOption>
#include <QAbstractTextDocumentLayout>

TextDirectionHandler::TextDirectionHandler(QObject *parent)
    : QObject(parent)
{
}

TextDirectionHandler::~TextDirectionHandler()
{
}

QQuickTextDocument *TextDirectionHandler::textDocument() const
{
    return mTextDocument;
}

void TextDirectionHandler::setTextDocument(QQuickTextDocument *newTextDocument)
{
    if (mTextDocument == newTextDocument)
        return;
    mTextDocument = newTextDocument;
    refresh();
    Q_EMIT textDocumentChanged();
}

QString TextDirectionHandler::currentText() const
{
    return mCurrentText;
}

void TextDirectionHandler::setCurrentText(const QString &newCurrentText)
{
    if (mCurrentText == newCurrentText)
        return;
    mCurrentText = newCurrentText;
    refresh();
    Q_EMIT currentTextChanged();
}

void TextDirectionHandler::refresh()
{
    if (!mTextDocument)
        return;

    auto doc = mTextDocument->textDocument();
    auto direction = TricksTools::directionOf(mCurrentText);
    switch (direction)
    {
    case Qt::LeftToRight:
    {
        auto opt = doc->defaultTextOption();
        opt.setTextDirection(Qt::LeftToRight);
        opt.setAlignment(Qt::AlignLeft);
        doc->setDefaultTextOption(opt);
    }
        break;
    case Qt::RightToLeft:
    {
        auto opt = doc->defaultTextOption();
        opt.setTextDirection(Qt::RightToLeft);
        opt.setAlignment(Qt::AlignLeft);
        doc->setDefaultTextOption(opt);
    }
        break;
    }
}

static void register_qml_text_direction_Handler() {
    qmlRegisterType<TextDirectionHandler>("AsemanQml.Labs", 2, 0, "TextDirectionHandler");
}

Q_COREAPP_STARTUP_FUNCTION(register_qml_text_direction_Handler)
