#ifndef QMLWIDGETMENUITEM_H
#define QMLWIDGETMENUITEM_H

#include <QObject>

class QmlWidgetMenuItem : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QString shortcut READ shortcut WRITE setShortcut NOTIFY shortcutChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    QmlWidgetMenuItem(QObject *parent = nullptr);
    virtual ~QmlWidgetMenuItem();

    QString text() const;
    void setText(const QString &newText);

    bool visible() const;
    void setVisible(bool newVisible);

    const QString &shortcut() const;
    void setShortcut(const QString &newShortcut);

    bool enabled() const;
    void setEnabled(bool newEnabled);

public Q_SLOTS:
    void click() {
        Q_EMIT clicked();
    }

Q_SIGNALS:
    void textChanged();
    void clicked();
    void visibleChanged();
    void shortcutChanged();
    void enabledChanged();

private:
    QString mText;
    QString mShortcut;
    bool mVisible;
    bool mEnabled;
};

#endif // QMLWIDGETMENUITEM_H
