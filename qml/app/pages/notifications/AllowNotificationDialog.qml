import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.IOSStyle 2.0
import components 1.0
import globals 1.0

Item {
    id: dis
    width: Viewport.viewport.width
    height: 240 * Devices.density

    property alias headerLabel: headerLabel
    property alias scene: scene
    property alias flickable: flickable
    property alias headerItem: headerItem

    Component.onCompleted: GlobalSettings.notificationAsked = true

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        opacity: 0.5
    }

    AsemanFlickable {
        id: flickable
        anchors.top: headerItem.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Devices.navigationBarHeight
        anchors.left: parent.left
        flickableDirection: Flickable.VerticalFlick
        contentWidth: scene.width
        contentHeight: scene.height
        clip: true

        EscapeItem {
            id: scene
            width: flickable.width
            height: flickable.height

            ColumnLayout {
                id: sceneColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 15 * Devices.density
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 20 * Devices.density
                    Layout.rightMargin: 20 * Devices.density
                    spacing: 20 * Devices.density

                    Label {
                        id: bodyLabel
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 9 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("Do you want to recieve device notification when your tricks liked, recieve mentions or some one followed you?" +
                                   "You can enable or disable it on the settings later.") + Translations.refresher
                    }
                }

                Button {
                    id: rejectBtn
                    Layout.fillWidth: true
                    Layout.topMargin: 10 * Devices.density
                    Layout.leftMargin: 20 * Devices.density
                    Layout.rightMargin: 20 * Devices.density
                    font.pixelSize: 9 * Devices.fontDensity
                    text: qsTr("Not Allow") + Translations.refresher
                    Material.elevation: 0
                    onClicked: {
                        Notifications.disAllow();
                        dis.ViewportType.open = false;
                    }
                }

                Button {
                    id: confirmBtn
                    Layout.fillWidth: true
                    Layout.leftMargin: 20 * Devices.density
                    Layout.rightMargin: 20 * Devices.density
                    font.pixelSize: 9 * Devices.fontDensity
                    text: qsTr("Allow Notifications") + Translations.refresher
                    highlighted: true
                    Material.elevation: 0
                    onClicked: {
                        Notifications.allow();
                        dis.ViewportType.open = false;
                    }
                }
            }
        }
    }

    Item {
        id: headerItem
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        height: Devices.standardTitleBarHeight

        Separator {}

        Label {
            id: headerLabel
            anchors.centerIn: parent
            font.pixelSize: 9 * Devices.fontDensity
            text: qsTr("Notifications") + Translations.refresher
        }
    }
}
