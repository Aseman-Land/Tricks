TARGET = tricks

APPNAME = Tricks
VERSION = 0.9.0
BUNDLE_VERSION = 4
UNIQUEID = f293006e-ffe3-4609-b130-76d9d56b8278

ios {
    QMAKE_TARGET_BUNDLE_PREFIX = io.aseman.app
    QMAKE_BUNDLE = CodeTrick
    CURRENT_PROJECT_VERSION = 1
} else {
    QMAKE_TARGET_BUNDLE_PREFIX = io.aseman
    QMAKE_BUNDLE = $${APPNAME}
}

!isEmpty(APP_SECRET_ID) {
    DEFINES += APP_SECRET_ID='\\"$${APP_SECRET_ID}\\"'
} else {
    !isEmpty(APP_SECRET_ID_INCLUDE) {
        DEFINES += APP_SECRET_ID_INCLUDE='\\"$${APP_SECRET_ID_INCLUDE}\\"'
    } else {
        warning(If you build a public package or installer for tricks, please get a token and set APP_SECRET_ID on qmake input. Example: qmake APP_SECRET_ID="app-secret-id")
    }
}

include(translations/translations.pri)
include(objective-c/objective-c.pri)
include(cpp/cpp.pri)
include(configurations/configurations.pri)

exists ($$PWD/qml/imports): QML_IMPORT_PATH += $$PWD/qml/imports

RESOURCES += qml/qml.qrc

android: include(/opt/develop/android/openssl/openssl.pri)
