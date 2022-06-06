#ifndef QMLWIDGETMENU_H
#define QMLWIDGETMENU_H

#include <QObject>
#include <QQmlListProperty>
#include <QMenu>
#include <QQuickItem>

#include "qmlwidgetmenuitem.h"

class QmlWidgetMenu : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(qreal x READ x WRITE setX NOTIFY xChanged)
    Q_PROPERTY(qreal y READ y WRITE setY NOTIFY yChanged)
    Q_PROPERTY(QQuickItem::TransformOrigin origin READ origin WRITE setOrigin NOTIFY originChanged)

    Q_PROPERTY(QQmlListProperty<QmlWidgetMenuItem> items READ items NOTIFY itemsChanged)
    Q_CLASSINFO("DefaultProperty", "items")

public:
    QmlWidgetMenu(QObject *parent = nullptr);
    virtual ~QmlWidgetMenu();

    bool visible() const;
    void setVisible(bool newVisible);

    QQmlListProperty<QmlWidgetMenuItem> items();

    qreal x() const;
    void setX(qreal newX);

    qreal y() const;
    void setY(qreal newY);

    const QQuickItem::TransformOrigin &origin() const;
    void setOrigin(const QQuickItem::TransformOrigin &newOrigin);

public Q_SLOTS:
    void open() { setVisible(true); }
    void close() { setVisible(false); }
    void show() { setVisible(true); }
    void hide() { setVisible(false); }

Q_SIGNALS:
    void visibleChanged();
    void itemsChanged();
    void xChanged();
    void yChanged();
    void originChanged();

private:
    static void append(QQmlListProperty<QmlWidgetMenuItem> *p, QmlWidgetMenuItem *v);
    static int count(QQmlListProperty<QmlWidgetMenuItem> *p);
    static QmlWidgetMenuItem *at(QQmlListProperty<QmlWidgetMenuItem> *p, int idx);
    static void clear(QQmlListProperty<QmlWidgetMenuItem> *p);

private:
    bool mVisible;
    qreal mX;
    qreal mY;
    QQuickItem::TransformOrigin mOrigin;

    QList<QmlWidgetMenuItem*> mItems;
    QMenu *mMenu;
};

#endif // QMLWIDGETMENU_H
