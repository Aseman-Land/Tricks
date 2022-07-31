import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.IOSStyle 2.0
import requests 1.0
import components 1.0
import globals 1.0

Item {
    id: dis
    width: GlobalSettings.viewMode == 2? Viewport.viewport.width : 480 * Devices.density
    height: 340 * Devices.density

    property string tag
    property variant settings

    onSettingsChanged: {
        enableSwitch.checked = settings.enable;
    }

    SubmitTagNotificationRequest {
        id: submitReq
        allowGlobalBusy: true
        _tag: GlobalMethods.fixUrlProperties(dis.tag)
        notification: enableSwitch.checked
        min_view: minView.text * 1
        min_like: minLike.text * 1
        onSuccessfull: {
            GlobalSignals.tagsRefreshed();
            dis.ViewportType.open = false;
        }
    }

    GetTagNotificationRequest {
        id: getReq
        _tag: GlobalMethods.fixUrlProperties(dis.tag)
        onSuccessfull: {
            var obj = Tools.toVariantMap(response.result);
            obj["enable"] = obj.notification;
            dis.settings = obj;
        }
        Component.onCompleted: {
            Tools.jsDelayCall(10, function(){
                if (!dis.settings) doRequest()
            })
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        opacity: 0.5
    }

    TBusyIndicator {
        anchors.centerIn: parent
        running: getReq.refreshing
    }

    AsemanFlickable {
        id: flickable
        visible: !getReq.refreshing
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
                anchors.margins: 35 * Devices.density
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20 * Devices.density

                    Label {
                        id: bodyLabel
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 9 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("To recieve notification on the tag updates, enable it from below form.") + Translations.refresher
                    }
                }

                RowLayout {
                    TLabel {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 9 * Devices.fontDensity
                        text: qsTr("Recieve notification") + Translations.refresher
                    }

                    TSwitch {
                        id: enableSwitch
                    }
                }

                RowLayout {
                    enabled: enableSwitch.checked
                    TLabel {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 9 * Devices.fontDensity
                        text: qsTr("Minimum view") + Translations.refresher
                    }

                    TNumberField {
                        id: minView
                        Layout.preferredWidth: 80 * Devices.density
                        text: dis.settings? dis.settings.min_view : 0
                    }
                }

                RowLayout {
                    enabled: enableSwitch.checked
                    Layout.topMargin: 12 * Devices.density

                    TLabel {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: 9 * Devices.fontDensity
                        text: qsTr("Minimum likes") + Translations.refresher
                    }

                    TNumberField {
                        id: minLike
                        Layout.preferredWidth: 80 * Devices.density
                        text: dis.settings? dis.settings.min_like : 0
                    }
                }

                Button {
                    id: confirmBtn
                    Layout.topMargin: 15 * Devices.density
                    Layout.fillWidth: true
                    font.pixelSize: 9 * Devices.fontDensity
                    text: qsTr("Submit") + Translations.refresher
                    highlighted: true
                    Material.elevation: 0
                    onClicked: submitReq.doRequest()
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
            text: qsTr("%1 Notifications").arg(dis.tag) + Translations.refresher
        }
    }

    THeaderBackButton {
        ratio: 1
        y: headerItem.height/2 - height/2
        onClicked: dis.ViewportType.open = false
        property bool isIOSPopup: true
    }
}
