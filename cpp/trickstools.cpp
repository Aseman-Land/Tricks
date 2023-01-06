#include "trickstools.h"
#include <QRegularExpression>
#include <QTimer>

#ifdef Q_OS_MACX
#include "objective-c/macmanager.h"
#endif
#ifdef Q_OS_IOS
#include "objective-c/iosmanager.h"
#endif

TricksTools::TricksTools(QObject *parent) :
    QObject(parent)
{

}

QColor TricksTools::fromColor(int code)
{
    return QColor(code);
}

int TricksTools::colorToInt(QColor color)
{
    return color.rgb();
}

void TricksTools::setupWindowColor(QColor color)
{
#ifdef Q_OS_MACX
    QTimer::singleShot(100, [color](){
        MacManager::removeTitlebarFromWindow(color.redF(), color.greenF(), color.blueF());
    });
#else
    Q_UNUSED(color)
#endif
}

QVariantList TricksTools::stringLinks(const QString &str)
{
    QVariantList links;
    QRegularExpression links_rxp(QStringLiteral("((?:(?:\\w\\S*\\/\\S*|\\/\\S+|\\:\\/)(?:\\/\\S*\\w|\\w|\\/+))|(?:\\w+\\.(?:com|org|co|net)\\/*))"));
    auto i = links_rxp.globalMatch(str);
    while (i.hasNext())
    {
        auto mi = i.next();
        QString link = mi.captured(1);

        QVariantMap m;
        m[QStringLiteral("link")] = link;
        m[QStringLiteral("name")] = linkName(link);

        if(link.indexOf(QRegularExpression(QStringLiteral("\\w+\\:\\/\\/"))) == -1)
            m[QStringLiteral("fixed")] = QStringLiteral("http://") + link;
        else
            m[QStringLiteral("fixed")] = link;

        links << m;
    }

    return links;
}

QString TricksTools::removeTagsAndLinks(const QString &_text, const QStringList &tags, const QVariantList &links)
{
    auto text = _text;
    for (auto i=0; i<tags.length(); i++)
    {
        auto t = '#' + tags.at(i).toLower();
        auto idx = text.length() - t.length();
        if (text.toLower().mid(idx) == t)
        {
            text = text.mid(0, idx).trimmed();
            i = -1;
        }
    }

    auto i = 0;
    for (auto l: links)
    {
        text = QString(text).replace(l.toMap().value(QStringLiteral("link")).toString(), QStringLiteral("[r:%1]").arg(i));
        i++;
    };

    return text;
}

QString TricksTools::linkName(const QString &text)
{
    auto startIdx = (text.mid(0,4) == QStringLiteral("http")? text.indexOf('/')+2 : 0);
    auto endIdx = text.indexOf('/', startIdx+2);
    if (endIdx < 0) endIdx = text.length();
    return text.mid(startIdx, endIdx - startIdx);
}

int TricksTools::directionOf(const QString &str)
{
    Qt::LayoutDirection res = Qt::LeftToRight;
    if( str.isEmpty() )
        return res;

    int ltr = 0;
    int rtl = 0;

    for(const QChar &ch: str)
    {
        QChar::Direction dir = ch.direction();
        switch( static_cast<int>(dir) )
        {
        case QChar::DirL:
        case QChar::DirLRE:
        case QChar::DirLRO:
        case QChar::DirEN:
            ltr++;
            break;

        case QChar::DirR:
        case QChar::DirRLE:
        case QChar::DirRLO:
        case QChar::DirAL:
            rtl++;
            break;
        }
    }

    if( ltr >= rtl * 3 )
        res = Qt::LeftToRight;
    else
        res = Qt::RightToLeft;

    return res;
}

bool TricksTools::iosOpenUrl(const QString &url)
{
#ifdef Q_OS_IOS
    return IOSManager::openUrlInSafari(url);
#else
    Q_UNUSED(url)
    return false;
#endif

}
