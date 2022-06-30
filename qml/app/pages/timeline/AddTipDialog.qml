import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.0
import QtQuick.Controls.IOSStyle 2.0
import components 1.0
import requests 1.0
import globals 1.0

TNullableArea {
    id: dis
    width: Viewport.viewport.width
    height: Math.min(360 * Devices.density + tipItem.height, Viewport.viewport.height - Devices.standardTitleBarHeight)
    ViewportType.gestureWidth: Devices.standardTitleBarHeight + bodyLabel.height + bodyLabel.y

    property alias headerLabel: headerLabel
    property alias scene: scene
    property alias flickable: flickable
    property alias headerItem: headerItem

    property alias trickId: tipReq._trick_id
    property variant trickData

    onTrickDataChanged: {
        tipItem.pushData(trickData)
        tipItem.parentId = 0;
        tipItem.quoteId = 0;
        tipItem.commentLineTop = false;
        tipItem.commentLineBottom = true;
    }

    property int balance: {
        try {
            return valcanoReq.response.result.balance;
        } catch (e) {
            return 0;
        }
    }

    GetVolcanoWalletRequest {
        id: valcanoReq
        allowShowErrors: true
        Component.onCompleted: doRequest()
    }

    SubmitTipRequest {
        id: tipReq
        allowGlobalBusy: true
        amount_msat: Math.floor(formater.msats / 1000) * 1000
        onSuccessfull: {
            GlobalSignals.snackRequest(qsTr("You tipped %1 satoshi to \"%2\"").arg(Math.floor(formater.msats / 1000)).arg(tipItem.fullname));
            GlobalSignals.refreshRequest();
            dis.ViewportType.open = false;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        opacity: 0.5
    }

    ColumnLayout {
        anchors.centerIn: parent
        visible: valcanoReq.refreshing

        TBusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: valcanoReq.refreshing
        }

        TLabel {
            text: qsTr("Loading your volcano...") + Translations.refresher
        }
    }

    ColumnLayout {
        anchors.top: headerItem.bottom
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Devices.navigationBarHeight
        anchors.left: parent.left
        spacing: 4 * Devices.density
        visible: !valcanoReq.refreshing

        TScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TFlickable {
                id: flickable
                flickableDirection: Flickable.VerticalFlick
                contentWidth: scene.width
                contentHeight: scene.height
                clip: true

                EscapeItem {
                    id: scene
                    width: flickable.width
                    height: Math.max(flickable.height, sceneColumn.height + 20 * Devices.density)

                    ColumnLayout {
                        id: sceneColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        y: 10 * Devices.density
                        anchors.margins: 15 * Devices.density
                        spacing: 0

                        TrickMinimalItem {
                            id: tipItem
                            Layout.fillWidth: true
                            actions: false
                            commentMode: true
                            globalViewMode: true
                        }
                    }
                }
            }
        }

        TLabel {
            id: bodyLabel
            Layout.fillWidth: true
            Layout.topMargin: 10 * Devices.density
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Colors.accent
            text: qsTr("How many Satoshies you want to tip to this trick?") + Translations.refresher
        }

        TModernSlider {
            id: slider
            Layout.topMargin: 50 * Devices.density
            Layout.rightMargin: 50 * Devices.density
            Layout.leftMargin: 50 * Devices.density
            Layout.fillWidth: true
            labelText: qsTr("%1 Satoshi").arg(formater.output)
            to: 10 * Math.log( Math.min(Bootstrap.tips.max_tip, dis.balance)) / Math.log(10)
            from: 10 * Math.log(Bootstrap.tips.min_tip) / Math.log(10)
            stepSize: 1

            TextFormater {
                id: formater
                delimiter: ","
                count: 3
                input: "" + Math.floor(msats / 1000)

                property int msats: Math.min(Math.min(dis.balance, Bootstrap.tips.max_tip), ((slider.value % 10) + 1) * Math.pow(10, Math.floor(slider.value / 10)))
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            spacing: 4 * Devices.density

            TLabel {
                horizontalAlignment: Text.AlignLeft
                font.bold: true
                color: Colors.accent
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr("Your Balance:") + Translations.refresher
            }

            TLabel {
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: qsTr("%1 Satoshi").arg(Math.floor(dis.balance / 1000) + "") + Translations.refresher
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 1 * Devices.density
            }
        }

        TButton {
            id: rejectBtn
            Layout.fillWidth: true
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            text: qsTr("Cancel") + Translations.refresher
            onClicked: {
                dis.ViewportType.open = false;
            }
        }

        TButton {
            id: confirmBtn
            Layout.fillWidth: true
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            Layout.bottomMargin: 20 * Devices.density
            text: qsTr("Submit Tip") + Translations.refresher
            highlighted: true
            enabled: formater.msats >= Bootstrap.tips.min_tip
            onClicked: {
                var args = {
                    "title": qsTr("Warning"),
                    "body" : qsTr("Do you realy want to tip <b>%1 satoshi</b> to this trick?").arg(formater.output) ,
                    "buttons": [qsTr("Yes"), qsTr("No")]
                };
                var obj = Viewport.controller.trigger("dialog:/general/warning", args);
                obj.itemClicked.connect(function(idx, title){
                    switch (idx) {
                    case 0: // Yes
                        tipReq.doRequest();
                        break;
                    case 1: // No
                        break;
                    }
                    obj.ViewportType.open = false;
                });
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

        TLabel {
            id: headerLabel
            anchors.centerIn: parent
            text: qsTr("Tip") + Translations.refresher
        }
    }

    THeaderBackButton {
        ratio: 1
        y: headerItem.height/2 - height/2
        onClicked: dis.ViewportType.open = false
        property bool isIOSPopup: true
    }
}
