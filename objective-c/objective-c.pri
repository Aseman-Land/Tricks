
macx {
    HEADERS += \
        $$PWD/macmanager.h
    SOURCES += \
        $$PWD/macmanager.mm
}

ios {
    HEADERS += \
        $$PWD/iosmanager.h

    SOURCES += \
        $$PWD/iosmanager.mm

    LIBS +=  -framework SafariServices -lobjc
}
