
exists($$[QT_INSTALL_HEADERS]/KF5SyntaxHighlighting/SyntaxHighlighter): {
    message(KF5SyntaxHighlighting founded)
    DEFINES += KSYNTAX_HIGHLIGHTER
    INCLUDEPATH += $$[QT_INSTALL_HEADERS]/KF5SyntaxHighlighting
    android: {
        LIBS += -L$$[QT_INSTALL_LIBS] -lKF5SyntaxHighlighting_$${ANDROID_TARGET_ARCH}
    } else {
        LIBS += -L$$[QT_INSTALL_LIBS] -lKF5SyntaxHighlighting
    }
} else {
exists($$[QT_INSTALL_HEADERS]/KF5/KSyntaxHighlighting/KSyntaxHighlighting/SyntaxHighlighter): {
    message(KF5SyntaxHighlighting founded)
    DEFINES += KSYNTAX_HIGHLIGHTER
    INCLUDEPATH += $$[QT_INSTALL_HEADERS]/KF5/KSyntaxHighlighting/KSyntaxHighlighting
    android: {
        LIBS += -L$$[QT_INSTALL_LIBS] -lKF5SyntaxHighlighting_$${ANDROID_TARGET_ARCH}
    } else {
        LIBS += -L$$[QT_INSTALL_LIBS] -lKF5SyntaxHighlighting
    }
} else {
exists(/usr/include/KF5/KSyntaxHighlighting/KSyntaxHighlighting) {
    message(KF5SyntaxHighlighting founded)
    DEFINES += KSYNTAX_HIGHLIGHTER
    INCLUDEPATH += /usr/include/KF5/KSyntaxHighlighting/KSyntaxHighlighting/

    LIBS += -lKF5SyntaxHighlighting
} else {
    exists(/usr/include/KF5/KSyntaxHighlighting/SyntaxHighlighter) {
            DEFINES += KSYNTAX_HIGHLIGHTER
            INCLUDEPATH += /usr/include/KF5/KSyntaxHighlighting
            LIBS += -lKF5SyntaxHighlighting
    } else {
        message(Warning: KF5SyntaxHighlighting not found)
    }
}
} 
}
