pragma Singleton

import QtQuick 2.10
import AsemanQml.Base 2.0

AsemanObject {
    readonly property int width: 480
    readonly property int height: 800
    readonly property int radius: 12 * Devices.density
    readonly property int margins: 16 * Devices.density
    readonly property int spacing: 10 * Devices.density

    readonly property int refreshDelay: 1
    readonly property real headerHeight: GlobalSettings.viewMode == 2 || !Devices.isDesktop? Devices.standardTitleBarHeight + Devices.statusBarHeight : 42 * Devices.density + Devices.statusBarHeight

    readonly property string cachePath: AsemanApp.homePath + "/cache"
    readonly property string baseUrl: App.domain + "/api/v1"

    readonly property int version: 0

    readonly property string cacheCommunities: cachePath + "/communities.cache"
    readonly property string cacheCodeFrames: cachePath + "/code-frames.cache"
    readonly property string cacheHighlighters: cachePath + "/highlighters.cache"
    readonly property string cacheNotifications: cachePath + "/notifications.cache"
    readonly property string cacheBookmarks: cachePath + "/bookmarks.cache"
    readonly property string cacheMyTags: cachePath + "/mytags.cache"
    readonly property string cacheMyTricks: cachePath + "/mytricks.cache"
    readonly property string cacheProgrammingLanguages: cachePath + "/programming-languages.cache"
    readonly property string cacheTags: cachePath + "/tags.cache"
    readonly property string cacheTimeline: cachePath + "/timeline.cache"
    readonly property string cacheGlobal: cachePath + "/global.cache"
    readonly property string cacheLimits: cachePath + "/limits.cache"
    readonly property string cacheFeatures: cachePath + "/features.cache"
    readonly property string cacheLicenses: cachePath + "/licenses.cache"

    readonly property real keyboardHeight: {
        if (!Devices.isAndroid)
            return 0;
        if (!GlobalSettings.dynamicKeyboardHeight)
            return 0;
        if (!GlobalSettings.smartKeyboardHeight)
            return Devices.keyboardHeight;

        if (Devices.keyboardHeight) {
            var rect = Qt.inputMethod.cursorRectangle;
            if (rect.y + rect.height + 20 * Devices.density > GlobalMethods.window.height - Devices.keyboardHeight || privates.cachedState) {
                privates.cachedState = true;
                return Devices.keyboardHeight;
            } else {
                return 0;
            }
        } else {
            privates.cachedState = false;
            return 0;
        }
    }

    QtObject {
        id: privates
        property bool cachedState
    }

    Component.onCompleted: {
        Tools.mkDir(cachePath)
    }
}
