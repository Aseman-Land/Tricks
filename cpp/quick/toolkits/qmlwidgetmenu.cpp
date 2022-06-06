#include "qmlwidgetmenu.h"

#include <QCursor>
#include <QQuickItem>

QmlWidgetMenu::QmlWidgetMenu(QObject *parent) :
    QObject(parent),
    mVisible(false),
    mX(0),
    mY(0),
    mOrigin(QQuickItem::TopLeft),
    mMenu(Q_NULLPTR)
{
}

QmlWidgetMenu::~QmlWidgetMenu()
{
}

bool QmlWidgetMenu::visible() const
{
    return mVisible;
}

void QmlWidgetMenu::setVisible(bool newVisible)
{
    if (mVisible == newVisible)
        return;
    if (mMenu)
    {
        delete mMenu;
        mMenu = Q_NULLPTR;
    }

    mVisible = newVisible;
    if (mVisible)
    {
        mMenu = new QMenu;
        for (auto item: mItems)
        {
            if (!item->visible())
                continue;

            auto name = item->text();
            if (!name.isEmpty())
            {
                auto act = mMenu->addAction(name, item, &QmlWidgetMenuItem::click);
                act->setEnabled(item->enabled());
                if (item->shortcut().length())
                    act->setShortcut(item->shortcut());
            }
            else
                mMenu->addSeparator();
        }

        connect(mMenu, &QMenu::aboutToHide, this, [this](){
            mVisible = false;
            mMenu->deleteLater();
            mMenu = Q_NULLPTR;
            Q_EMIT visibleChanged();
        });

        auto parentItem = qobject_cast<QQuickItem*>(parent());
        auto position = QCursor::pos();
        mMenu->move(position);
        mMenu->show();

        if (parentItem)
        {
            auto point = parentItem->mapToGlobal(QPointF(mX, mY));
            position = point.toPoint();
        }

        switch (static_cast<int>(mOrigin))
        {
        case QQuickItem::Left:
            position.setY( position.y() - mMenu->height()/2 );
            break;
        case QQuickItem::TopLeft:
            break;
        case QQuickItem::Top:
            position.setX( position.x() - mMenu->width()/2 );
            break;
        case QQuickItem::TopRight:
            position.setX( position.x() - mMenu->width() );
            break;
        case QQuickItem::Right:
            position.setX( position.x() - mMenu->width() );
            position.setY( position.y() - mMenu->height()/2 );
            break;
        case QQuickItem::BottomRight:
            position.setX( position.x() - mMenu->width() );
            position.setY( position.y() - mMenu->height() );
            break;
        case QQuickItem::Bottom:
            position.setX( position.x() - mMenu->width()/2 );
            position.setY( position.y() - mMenu->height() );
            break;
        case QQuickItem::BottomLeft:
            position.setY( position.y() - mMenu->height() );
            break;
        }

        mMenu->move(position);
    }

    Q_EMIT visibleChanged();
}

QQmlListProperty<QmlWidgetMenuItem> QmlWidgetMenu::items()
{
    return QQmlListProperty<QmlWidgetMenuItem>(this, &mItems, QQmlListProperty<QmlWidgetMenuItem>::AppendFunction(append),
                                               QQmlListProperty<QmlWidgetMenuItem>::CountFunction(count),
                                               QQmlListProperty<QmlWidgetMenuItem>::AtFunction(at),
                                               QQmlListProperty<QmlWidgetMenuItem>::ClearFunction(clear) );
}

void QmlWidgetMenu::append(QQmlListProperty<QmlWidgetMenuItem> *p, QmlWidgetMenuItem *v)
{
    QmlWidgetMenu *aobj = static_cast<QmlWidgetMenu*>(p->object);
    aobj->mItems.append(v);
    Q_EMIT aobj->itemsChanged();
}

int QmlWidgetMenu::count(QQmlListProperty<QmlWidgetMenuItem> *p)
{
    QmlWidgetMenu *aobj = static_cast<QmlWidgetMenu*>(p->object);
    return aobj->mItems.count();
}

QmlWidgetMenuItem *QmlWidgetMenu::at(QQmlListProperty<QmlWidgetMenuItem> *p, int idx)
{
    QmlWidgetMenu *aobj = static_cast<QmlWidgetMenu*>(p->object);
    return aobj->mItems.at(idx);
}

void QmlWidgetMenu::clear(QQmlListProperty<QmlWidgetMenuItem> *p)
{
    QmlWidgetMenu *aobj = static_cast<QmlWidgetMenu*>(p->object);
    aobj->mItems.clear();
    Q_EMIT aobj->itemsChanged();
}

const QQuickItem::TransformOrigin &QmlWidgetMenu::origin() const
{
    return mOrigin;
}

void QmlWidgetMenu::setOrigin(const QQuickItem::TransformOrigin &newOrigin)
{
    if (mOrigin == newOrigin)
        return;
    mOrigin = newOrigin;
    Q_EMIT originChanged();
}

qreal QmlWidgetMenu::y() const
{
    return mY;
}

void QmlWidgetMenu::setY(qreal newY)
{
    if (qFuzzyCompare(mY, newY))
        return;
    mY = newY;
    Q_EMIT yChanged();
}

qreal QmlWidgetMenu::x() const
{
    return mX;
}

void QmlWidgetMenu::setX(qreal newX)
{
    if (qFuzzyCompare(mX, newX))
        return;
    mX = newX;
    Q_EMIT xChanged();
}

static void register_qml_widget_menus() {
    qmlRegisterType<QmlWidgetMenu>("AsemanQml.Labs", 2, 0, "QmlWidgetMenu");
    qmlRegisterType<QmlWidgetMenuItem>("AsemanQml.Labs", 2, 0, "QmlWidgetMenuItem");
}

Q_COREAPP_STARTUP_FUNCTION(register_qml_widget_menus)
