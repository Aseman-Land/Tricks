#ifndef SYSTEMCOLORS_H
#define SYSTEMCOLORS_H

#include <QObject>
#include <QWindow>
#include <QPointer>
#include <QAsemanTitleBarColorGrabber>

class SystemColors : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QColor defaultColor READ defaultColor WRITE setDefaultColor NOTIFY defaultColorChanged)
    Q_PROPERTY(QColor autoColor READ autoColor NOTIFY autoColorChanged)
    Q_PROPERTY(bool defaultLightHeader READ defaultLightHeader NOTIFY defaultLightHeaderChanged)
    Q_PROPERTY(QColor defaultLightColor READ defaultLightColor NOTIFY defaultLightColorChanged)
    Q_PROPERTY(QColor defaultLightInactiveColor READ defaultLightInactiveColor NOTIFY defaultLightInactiveColorChanged)
    Q_PROPERTY(QColor defaultDarkColor READ defaultDarkColor NOTIFY defaultDarkColorChanged)
    Q_PROPERTY(QColor defaultDarkInactiveColor READ defaultDarkInactiveColor NOTIFY defaultDarkInactiveColorChanged)
    Q_PROPERTY(QWindow* window READ window WRITE setWindow NOTIFY windowChanged)

public:
    SystemColors(QObject *parent = nullptr);
    virtual ~SystemColors();

    static bool defaultLightHeader();
    QColor defaultLightColor();
    QColor defaultLightInactiveColor();
    QColor defaultDarkColor();
    QColor defaultDarkInactiveColor();

    QWindow *window() const;
    void setWindow(QWindow *newWindow);

    QColor defaultColor() const;
    void setDefaultColor(const QColor &newDefaultColor);

    QColor autoColor() const;

Q_SIGNALS:
    void defaultLightHeaderChanged();
    void defaultLightColorChanged();
    void defaultLightInactiveColorChanged();
    void defaultDarkColorChanged();
    void defaultDarkInactiveColorChanged();
    void windowChanged();
    void defaultColorChanged();
    void autoColorChanged();

private:
    QPointer<QWindow> mWindow;
    QAsemanTitleBarColorGrabber *mColorGrabber = Q_NULLPTR;
    QColor mDefaultColor;
};

#endif // SYSTEMCOLORS_H
