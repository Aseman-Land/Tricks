import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Modern 2.0
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.IOSStyle 2.0
import globals 1.0
import components 1.0
import "app"

AsemanWindow {
    id: mwin
    width: GlobalSettings.width;    onWidthChanged: GlobalSettings.width = width;
    height: GlobalSettings.height;  onHeightChanged: GlobalSettings.height = height;
    flags: GlobalSettings.frameless? Qt.FramelessWindowHint | Qt.Window : Qt.Window
    color: GlobalSettings.frameless? "#00000000" : Colors.background

    IOSStyle.theme: GlobalSettings.iosTheme
    IOSStyle.accent: Colors.accent
    IOSStyle.background: Colors.background

    Material.theme: GlobalSettings.androidTheme
    Material.accent: Colors.accent
    Material.background: Colors.background

    property alias viewport: app.viewport

    LayoutMirroring.enabled: GTranslations.reverseLayout
    LayoutMirroring.childrenInherit: true

    Component.onCompleted: {
        GlobalMethods.window = mwin;
        Colors.window = mwin;
    }

    FastRectengleShadow {
        anchors.fill: mainScene
        anchors.margins: 2
        radius: 10
        horizontalOffset: 1
        verticalOffset: 1
        visible: GlobalSettings.frameless && mwin.visibility != Window.Maximized
    }

    Item {
        id: mainScene
        anchors.fill: parent
        anchors.margins: GlobalSettings.frameless && mwin.visibility != Window.Maximized? 5 * Devices.density : 0

        Rectangle {
            id: statusBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Devices.statusBarHeight
            color: Colors.backgroundDeep
        }

        MainPage {
            id: app
            anchors.top: framelessPad.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        Rectangle {
            id: framelessPad
            anchors.left: parent.left
            anchors.right: parent.right
            height: GlobalSettings.frameless? (GlobalSettings.viewMode == 2? 35 : 30) * Devices.density : 0
            color: Colors.header
            visible: GlobalSettings.frameless

            MouseArea {
                id: marea
                anchors.fill: parent
                visible: GlobalSettings.frameless
                onDoubleClicked: mwin.visibility == Window.Maximized? mwin.showNormal() : mwin.showMaximized()
                onPressed: {
                    pin = Qt.point(mouseX, mouseY);
                }
                onPositionChanged: {
                    moveCheckTimer.start()
                }

                property point pin

                Timer {
                    id: moveCheckTimer
                    interval: 10
                    repeat: false
                    onTriggered: {
                        mwin.x = mwin.x + marea.mouseX - marea.pin.x;
                        mwin.y = mwin.y + marea.mouseY - marea.pin.y;
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            border.color: Colors.foreground
            border.width: 1
            opacity: 0.2
            visible: GlobalSettings.frameless
        }

        TitleBarButtons {
        }
    }

    TWindowMovable {
        anchors.fill: parent
        visible: GlobalSettings.frameless
        mWin: mwin
    }
}
