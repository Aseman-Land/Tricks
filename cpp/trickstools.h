#ifndef TRICKSTOOLS_H
#define TRICKSTOOLS_H

#include <QObject>
#include <QColor>
#include <QVariant>

class TricksTools : public QObject
{
    Q_OBJECT
public:
    TricksTools(QObject *parent = Q_NULLPTR);

public Q_SLOTS:
    QColor fromColor(int code);
    int colorToInt(QColor code);
    void setupWindowColor(QColor color);

    QVariantList stringLinks(const QString &str);
    QString removeTagsAndLinks(const QString &text, const QStringList &tags, const QVariantList &links);
    static int directionOf(const QString &str);

    bool iosOpenUrl(const QString &url);

protected:
    QString linkName(const QString &name);
};

#endif // TRICKSTOOLS_H
