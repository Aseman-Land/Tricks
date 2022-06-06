#include "codehighlighter.h"

#include <QCoreApplication>
#include <QDir>

CodeHighlighter::CodeHighlighter(QObject *parent)
    : QObject(parent)
{
    setTheme("Breeze Dark");
}

CodeHighlighter::~CodeHighlighter()
{

}

QQuickTextDocument *CodeHighlighter::textDocument() const
{
    return mTextDocument;
}

void CodeHighlighter::setTextDocument(QQuickTextDocument *newTextDocument)
{
    if (mTextDocument == newTextDocument)
        return;
#ifdef KSYNTAX_HIGHLIGHTER
    if (mHighlighter)
        delete mHighlighter;
#endif

    mTextDocument = newTextDocument;
#ifdef KSYNTAX_HIGHLIGHTER
    if (mTextDocument)
        mHighlighter = new KSyntaxHighlighting::SyntaxHighlighter(newTextDocument->textDocument());
#endif

    reloadTheme();
    reloadDefinition();

    Q_EMIT textDocumentChanged();
}

QStringList CodeHighlighter::themes()
{
    QStringList res;
#ifdef KSYNTAX_HIGHLIGHTER
    KSyntaxHighlighting::Repository repo;
    auto themes = repo.themes();
    for (const auto &t: themes)
        res << t.name();
#endif
    return res;
}

QStringList CodeHighlighter::definitions()
{
    QStringList res;
#ifdef KSYNTAX_HIGHLIGHTER
    KSyntaxHighlighting::Repository repo;
    auto definitions = repo.definitions();
    for (const auto &d: definitions)
        res << d.name();
#endif

    res.sort();
    return res;
}

QMap<QString, QString> CodeHighlighter::frames()
{
    QStringList framesRootDirectories = {
        "/usr/share/" + QCoreApplication::applicationName() + "/frames",
        QCoreApplication::applicationDirPath() + "/frames",
        QCoreApplication::applicationDirPath() + "/share/frames",
        QCoreApplication::applicationDirPath() + "/../share/frames",
        QDir::homePath() + "/.local/share/" + QCoreApplication::applicationName() + "/frames",
    };

    QMap<QString, QString> res;
    for (const auto &f: framesRootDirectories)
    {
        QStringList list = QDir(f).entryList({"*.json"}, QDir::Files);
        for (const auto &l: list)
            res[l.mid(0, l.length()-5)] = f + "/" + l;
    }

    return res;
}

QString CodeHighlighter::theme() const
{
    return mTheme;
}

void CodeHighlighter::setTheme(const QString &newTheme)
{
    if (mTheme == newTheme)
        return;

    mTheme = newTheme;
    reloadTheme();

    Q_EMIT themeChanged();
}

QString CodeHighlighter::frame() const
{
    return mFrame;
}

void CodeHighlighter::setFrame(const QString &newFrame)
{
    if (mFrame == newFrame)
        return;
    mFrame = newFrame;
    Q_EMIT frameChanged();
}

QString CodeHighlighter::definition() const
{
    return mDefinition;
}

void CodeHighlighter::setDefinition(const QString &newDefinition)
{
    if (mDefinition == newDefinition)
        return;

    mDefinition = newDefinition;
    reloadDefinition();

    Q_EMIT definitionChanged();
}

void CodeHighlighter::reloadTheme()
{
#ifdef KSYNTAX_HIGHLIGHTER
    if (!mHighlighter)
        return;

    const auto t = mRepo.theme(mTheme);
    const QColor back = t.editorColor(KSyntaxHighlighting::Theme::BackgroundColor);

    mDarkMode = ((back.redF() + back.greenF() + back.blueF()) / 3 < 0.5);

    mHighlighter->setTheme(t);
    mHighlighter->rehighlight();
#else
    mDarkMode = mTheme.toLower().contains("dark");
#endif
    Q_EMIT darkModeChanged();
    Q_EMIT refreshRequest();
}

void CodeHighlighter::reloadDefinition()
{
#ifdef KSYNTAX_HIGHLIGHTER
    if (!mHighlighter)
        return;

    auto definitions = mRepo.definitions();
    for (const auto &d: definitions)
        if (d.name().toLower() == mDefinition.toLower())
        {
            mHighlighter->setDefinition(d);
            break;
        }

    mHighlighter->rehighlight();
#endif
    Q_EMIT refreshRequest();
}

bool CodeHighlighter::darkMode() const
{
    return mDarkMode;
}

static void register_qml_code_highlighter() {
    qmlRegisterType<CodeHighlighter>("AsemanQml.Labs", 2, 0, "CodeHighlighter");
}

Q_COREAPP_STARTUP_FUNCTION(register_qml_code_highlighter)
