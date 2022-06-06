linux: !android {

    SHORTCUT = tricks

    shortcut.input = $$PWD/share/Tricks.desktop.in
    shortcut.output = $$PWD/share/Tricks.desktop
    shortcut.path = $$PREFIX/share/applications/
    shortcut.files = $$shortcut.output
    icons.path = $$PREFIX/share/icons
    icons.files = $$PWD/share/hicolor
    pixmaps.path = $$PREFIX/share/pixmaps
    pixmaps.files = $$PWD/share/tricks.png
    target.path = $$PREFIX/bin

    QMAKE_SUBSTITUTES += shortcut

    INSTALLS += target shortcut icons pixmaps

    DISTFILES += \
        $$PWD/share/Tricks.desktop.in \
        $$PWD/share/hicolor/128x128/apps/tricks.png \
        $$PWD/share/hicolor/16x16/apps/tricks.png \
        $$PWD/share/hicolor/256x256/apps/tricks.png \
        $$PWD/share/hicolor/32x32/apps/tricks.png \
        $$PWD/share/hicolor/48x48/apps/tricks.png \
        $$PWD/share/hicolor/64x64/apps/tricks.png \
        $$PWD/share/hicolor/96x96/apps/tricks.png \
        $$PWD/share/tricks.png \
}
