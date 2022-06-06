#include "qmlwidgetmenuitem.h"

QmlWidgetMenuItem::QmlWidgetMenuItem(QObject *parent) :
    QObject(parent),
    mVisible(true),
    mEnabled(true)
{
}

QmlWidgetMenuItem::~QmlWidgetMenuItem()
{
}

QString QmlWidgetMenuItem::text() const
{
    return mText;
}

void QmlWidgetMenuItem::setText(const QString &newText)
{
    if (mText == newText)
        return;
    mText = newText;
    Q_EMIT textChanged();
}

bool QmlWidgetMenuItem::visible() const
{
    return mVisible;
}

void QmlWidgetMenuItem::setVisible(bool newVisible)
{
    if (mVisible == newVisible)
        return;
    mVisible = newVisible;
    Q_EMIT visibleChanged();
}

const QString &QmlWidgetMenuItem::shortcut() const
{
    return mShortcut;
}

void QmlWidgetMenuItem::setShortcut(const QString &newShortcut)
{
    if (mShortcut == newShortcut)
        return;
    mShortcut = newShortcut;
    emit shortcutChanged();
}

bool QmlWidgetMenuItem::enabled() const
{
    return mEnabled;
}

void QmlWidgetMenuItem::setEnabled(bool newEnable)
{
    if (mEnabled == newEnable)
        return;
    mEnabled = newEnable;
    emit enabledChanged();
}
