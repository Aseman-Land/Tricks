#ifndef CHECKS_H
#define CHECKS_H

#include <QColor>

class Checks
{
public:
    static void checkLinuxDesktopIcon();
    static bool defaultLightHeader();
    static QColor defaultLightColor();
    static QColor defaultLightInactiveColor();
    static QColor defaultDarkColor();
    static QColor defaultDarkInactiveColor();
};

#endif // CHECKS_H
