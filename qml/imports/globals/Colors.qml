pragma Singleton

import QtQuick 2.10
import AsemanQml.Base 2.0
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import Tricks 1.0

QtObject {
    IOSStyle.theme: GlobalSettings.iosTheme
    Material.theme: GlobalSettings.androidTheme

    readonly property bool lightHeader: darkMode? true : GlobalSettings.lightHeader

    readonly property color darkAccent: Qt.lighter(App.accentColor, 1.5)
    readonly property color accent: (darkMode? darkAccent : App.accentColor)
    readonly property color primary: App.primaryColor

    readonly property color background: darkMode? "#111" : "#f8f7f8"
    readonly property color backgroundDeep: darkMode? "#333" : "#fff"
    readonly property color backgroundLight: darkMode? "#282828" : "#eee"

    readonly property color header: lightHeader? backgroundLight : primary
    readonly property color headerSecondary: backgroundLight
    readonly property color headerText: lightHeader? foreground : "#ffffff"

    readonly property color likeColors: "#f92669"
    readonly property color bookmarksColors: "#ffaa00"
    readonly property color commentsColor: "#53a9e9"
    readonly property color buttonsColor: darkMode? "#aaa" : "#555"

    readonly property color foreground: darkMode? "#fff" : "#222"

    readonly property bool darkMode: (IOSStyle.background.r + IOSStyle.background.g + IOSStyle.background.b) / 3 < 0.5? true : false

    Component.onCompleted: TricksTools.setupWindowColor(header)
    onHeaderChanged: TricksTools.setupWindowColor(header)
}
