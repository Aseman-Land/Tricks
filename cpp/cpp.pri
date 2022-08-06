QT += quick widgets svg asemancore asemangui

CONFIG += c++17

QTPLUGIN.sqldrivers += qsqlite
QTPLUGIN.imageformats += qsvg qjpeg
linux: QTPLUGIN.platforms += qxcb qlinuxfb qminimal

DEFINES += \
    APP_VERSION='\\"$${VERSION}\\"' \
    APP_BUNDLE_VERSION='\\"$${BUNDLE_VERSION}\\"' \
    APP_NAME='\\"$${APPNAME}\\"' \
    APP_UNIQUEID='\\"$${UNIQUEID}\\"' \
    APP_DOMAIN='\\"$${QMAKE_TARGET_BUNDLE_PREFIX}\\"' \

INCLUDEPATH += $$PWD

include(quick/quick.pri)
include(thirdparty/thirdparty.pri)

SOURCES += \
    $$PWD/appoptions.cpp \
    $$PWD/checks.cpp \
    $$PWD/main.cpp \
    $$PWD/trickstools.cpp

HEADERS += \
    $$PWD/appoptions.h \
    $$PWD/checks.h \
    $$PWD/trickstools.h
