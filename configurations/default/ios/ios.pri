
ios {
    OTHER_FILES += \
        $$PWD/Launch.xib \
        $$PWD/Info.plist \
        $$files($$PWD/*.png, true)

    QMAKE_INFO_PLIST = $$PWD/Info.plist

    Q_ENABLE_BITCODE.name = ENABLE_BITCODE
    Q_ENABLE_BITCODE.value = NO
    QMAKE_MAC_XCODE_SETTINGS += Q_ENABLE_BITCODE
    QMAKE_IOS_DEPLOYMENT_TARGET = 14.0

    app_launch_images.files = $$PWD/Launch.xib $$files($$PWD/splash/LaunchImage*.png)
    QMAKE_BUNDLE_DATA += app_launch_images

    ios_icon.files = $$files($$PWD/icons/*.png)
    QMAKE_BUNDLE_DATA += ios_icon

    QTFIREBASE_SDK_PATH = $$getenv(FIREBASE_CPP_SDK_DIR)
    !isEmpty(QTFIREBASE_SDK_PATH) {
        fcm_files.files = $$PWD/GoogleService-Info.plist
        QMAKE_BUNDLE_DATA += fcm_files
    }

    QMAKE_ASSET_CATALOGS += $$PWD/icons.xcassets
}
