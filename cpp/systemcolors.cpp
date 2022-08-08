#include "systemcolors.h"

#include <QColor>
#include <QApplication>
#include <QPalette>

SystemColors::SystemColors(QObject *parent)
    : QObject(parent)
{

}

SystemColors::~SystemColors()
{

}

bool SystemColors::defaultLightHeader()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    auto desktop = qEnvironmentVariable("DESKTOP_SESSION");
    if (desktop == "ubuntu")
        return true;
    if (desktop == "plasma")
        return true;
    if (desktop == "gnome")
        return true;
    return false;
#elif defined(Q_OS_WIN32) || defined(Q_OS_MACOS)
    return true;
#else
    return false;
#endif
}

QColor SystemColors::defaultLightColor()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    auto desktop = qEnvironmentVariable("DESKTOP_SESSION");
    if (desktop == "ubuntu")
        return QStringLiteral("#ebebeb");
    if (desktop == "gnome")
        return QStringLiteral("#d3d1cf");
    if (desktop == "plasma")
    {
        auto res = qApp->palette().color(QPalette::Window);
        if ((res.redF() + res.greenF() + res.blueF())/3 < 0.5) // is dark
            return QStringLiteral("#eeeeee");
        else
            return res;
    }
    return QStringLiteral("#eeeeee");
#else
    return QStringLiteral("#eeeeee");
#endif
}

QColor SystemColors::defaultLightInactiveColor()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    auto desktop = qEnvironmentVariable("DESKTOP_SESSION");
    if (desktop == "ubuntu")
        return QStringLiteral("#fafafa");
    else
        return defaultLightColor();
#else
    return defaultLightColor();
#endif
}

QColor SystemColors::defaultDarkColor()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    auto desktop = qEnvironmentVariable("DESKTOP_SESSION");
    if (desktop == "ubuntu")
        return QStringLiteral("#222222");
    if (desktop == "gnome")
        return QStringLiteral("#272727");
    if (desktop == "plasma")
    {
        auto res = qApp->palette().color(QPalette::Window);
        if ((res.redF() + res.greenF() + res.blueF())/3 < 0.5) // is dark
            return res;
        else
            return QStringLiteral("#282828");
    }
    return QStringLiteral("#282828");
#else
    return QStringLiteral("#282828");
#endif
}

QColor SystemColors::defaultDarkInactiveColor()
{
#if defined(Q_OS_LINUX) && !defined(Q_OS_ANDROID)
    auto desktop = qEnvironmentVariable("DESKTOP_SESSION");
    if (desktop == "ubuntu")
        return QStringLiteral("#2c2c2c");
    else
        return defaultDarkColor();
#else
    return defaultDarkColor();
#endif
}

QWindow *SystemColors::window() const
{
    return mWindow;
}

void SystemColors::setWindow(QWindow *newWindow)
{
    if (mWindow == newWindow)
        return;

    if (mColorGrabber)
    {
        delete mColorGrabber;
        mColorGrabber = Q_NULLPTR;
    }

    mWindow = newWindow;

    if (mWindow) {
#ifdef Q_OS_LINUX
        mColorGrabber = new QAsemanTitleBarColorGrabber(this);
        mColorGrabber->setWindow(mWindow);
        mColorGrabber->setAutoRefresh(true);
        if (mColorGrabber)
            mColorGrabber->setDefaultColor(mDefaultColor);

        connect(mColorGrabber, &QAsemanTitleBarColorGrabber::colorChanged, this, [this](){
            const auto c = mColorGrabber->color();
            if (!c.isValid())
                return;

            Q_EMIT defaultLightColorChanged();
            Q_EMIT defaultLightInactiveColorChanged();
            Q_EMIT defaultDarkColorChanged();
            Q_EMIT defaultDarkInactiveColorChanged();
            Q_EMIT autoColorChanged();
        });
#endif
    }

    Q_EMIT windowChanged();
}

QColor SystemColors::defaultColor() const
{
    return mDefaultColor;
}

void SystemColors::setDefaultColor(const QColor &newDefaultColor)
{
    if (mDefaultColor == newDefaultColor)
        return;
    mDefaultColor = newDefaultColor;
    if (mColorGrabber)
        mColorGrabber->setDefaultColor(mDefaultColor);
    Q_EMIT defaultColorChanged();
}

QColor SystemColors::autoColor() const
{
    if (mColorGrabber)
        return mColorGrabber->color();
    else
        return defaultColor();
}
