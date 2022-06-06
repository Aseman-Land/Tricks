#ifndef TEXTDIRECTIONHANDLER_H
#define TEXTDIRECTIONHANDLER_H

#include <QObject>
#include <QPointer>
#include <QQuickTextDocument>

class TextDirectionHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickTextDocument *textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
    Q_PROPERTY(QString currentText READ currentText WRITE setCurrentText NOTIFY currentTextChanged)

public:
    TextDirectionHandler(QObject *parent = nullptr);
    virtual ~TextDirectionHandler();

    QQuickTextDocument *textDocument() const;
    void setTextDocument(QQuickTextDocument *newTextDocument);

    QString currentText() const;
    void setCurrentText(const QString &newCurrentText);

public Q_SLOTS:
    void refresh();

Q_SIGNALS:
    void textDocumentChanged();
    void currentTextChanged();

private:
    QPointer<QQuickTextDocument> mTextDocument;
    QString mCurrentText;
};

#endif // TEXTDIRECTIONHANDLER_H
