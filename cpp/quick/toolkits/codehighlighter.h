#ifndef CODEHIGHLIGHTER_H
#define CODEHIGHLIGHTER_H

#include <QObject>
#include <QQuickTextDocument>
#include <QPointer>
#include <QColor>

#ifdef KSYNTAX_HIGHLIGHTER
#include <SyntaxHighlighter>
#include <Repository>
#include <Definition>
#include <Theme>
#endif

class CodeHighlighter : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument * textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QString frame READ frame WRITE setFrame NOTIFY frameChanged)
    Q_PROPERTY(QString definition READ definition WRITE setDefinition NOTIFY definitionChanged)
    Q_PROPERTY(QStringList themes READ themes NOTIFY fakeSignal)
    Q_PROPERTY(QStringList definitions READ definitions NOTIFY fakeSignal)
    Q_PROPERTY(QColor background READ background NOTIFY backgroundChanged)
    Q_PROPERTY(bool darkMode READ darkMode NOTIFY darkModeChanged)

public:
    CodeHighlighter(QObject *parent = nullptr);
    virtual ~CodeHighlighter();

    QQuickTextDocument *textDocument() const;
    void setTextDocument(QQuickTextDocument *newTextDocument);

    static QStringList themes();
    static QStringList definitions();
    static QMap<QString, QString> frames();

   QString theme() const;
    void setTheme(const QString &newTheme);

   QString frame() const;
    void setFrame(const QString &newFrame);

   QString definition() const;
    void setDefinition(const QString &newDefinition);

    bool darkMode() const;

    QColor background() const;

Q_SIGNALS:
    void textDocumentChanged();
    void themeChanged();
    void frameChanged();
    void definitionChanged();
    void fakeSignal();
    void refreshRequest();
    void darkModeChanged();
    void backgroundChanged();

protected:
    void reloadTheme();
    void reloadDefinition();

private:
    QPointer<QQuickTextDocument> mTextDocument;

#ifdef KSYNTAX_HIGHLIGHTER
    QPointer<KSyntaxHighlighting::SyntaxHighlighter> mHighlighter;
    KSyntaxHighlighting::Repository mRepo;
#endif

    QString mTheme;
    QString mFrame;
    QString mDefinition;
    bool mDarkMode = false;
    QColor mBackground;
};

#endif // CODEHIGHLIGHTER_H
