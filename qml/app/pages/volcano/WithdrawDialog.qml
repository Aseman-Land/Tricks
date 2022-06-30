import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
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
    height: (resultColumn.visible? resultColumn.height : generateColumn.height) + headerItem.height + Devices.navigationBarHeight

    Behavior on height {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
    }

    property alias headerLabel: headerLabel
    property alias headerItem: headerItem

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        opacity: 0.5
    }

    SubmitVolcanoWhitdrawRequest {
        id: withdrawReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSignals.snackRequest(qsTr("Withdraw process completed successfully."));
            dis.ViewportType.open = false;
        }
    }

    SubmitVolcanoDecodeRequest {
        id: decodeReq
        onSuccessfull: {
            try {
                formater.number = response.result.amount_msat / 1000;
                paymentHash.text = response.result.payment_hash;
                resultColumn.visible = true;
            } catch (e) {
                formater.number = 0;
                paymentHash.text = "";
                resultColumn.visible = false;
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        visible: decodeReq.refreshing

        TBusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: decodeReq.refreshing
        }

        TLabel {
            text: qsTr("Checking payment...") + Translations.refresher
        }
    }

    ColumnLayout {
        id: resultColumn
        anchors.top: headerItem.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        spacing: 4 * Devices.density
        visible: false;

        TLabel {
            Layout.fillWidth: true
            Layout.topMargin: 10 * Devices.density
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: qsTr("Please check below informations and click on Pay to complete withraw process.") + Translations.refresher
        }

        RowLayout {
            spacing: 4 * Devices.density
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20 * Devices.density
            Layout.bottomMargin: 20 * Devices.density

            TLabel {
                color: Colors.accent
                font.pixelSize: 18 * Devices.fontDensity
                text: qsTr("%1.%2").arg(formater.output).arg( formater.number - Math.floor(formater.number) )

                TextFormater {
                    id: formater
                    count: 3
                    delimiter: ","
                    input: Math.floor(number)

                    property real number
                }
            }

            TLabel {
                color: Colors.accent
                text: qsTr("Satoshi") + Translations.refresher
            }
        }

        RowLayout {
            spacing: 10 * Devices.density
            Layout.fillWidth: true
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density

            TLabel {
                text: qsTr("Payment Hash:")
                font.bold: true
                color: Colors.accent
            }

            TLabel {
                id: paymentHash
                Layout.fillWidth: true
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 1
                elide: Text.ElideRight
            }
        }

        TButton {
            Layout.fillWidth: true
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            text: qsTr("Cancel") + Translations.refresher
            onClicked: {
                dis.ViewportType.open = false;
            }
        }

        TButton {
            id: payBtn
            Layout.fillWidth: true
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            Layout.bottomMargin: 20 * Devices.density + Devices.navigationBarHeight
            text: qsTr("Pay Withdraw") + Translations.refresher
            highlighted: true
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
                        withdrawReq.bolt = paymentLink.text;
                        withdrawReq.doRequest();
                        break;
                    case 1: // No
                        break;
                    }
                    obj.ViewportType.open = false;
                });
            }
        }
    }

    ColumnLayout {
        id: generateColumn
        anchors.top: headerItem.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        spacing: 4 * Devices.density
        visible: !decodeReq.refreshing && !resultColumn.visible

        TLabel {
            Layout.fillWidth: true
            Layout.topMargin: 10 * Devices.density
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Colors.accent
            text: qsTr("Please enter payment key to withdraw from your account:") + Translations.refresher
        }

        TItemDelegate {
            Layout.fillWidth: true
            Layout.preferredHeight: paymentColumn.height + 20 * Devices.density
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            onClicked: paymentLink.paste()

            ColumnLayout {
                id: paymentColumn
                spacing: 4 * Devices.density
                anchors.left: parent.left
                anchors.right: parent.right
                y: 10 * Devices.density

                TLabel {
                    text: qsTr("Click to paste:")
                    font.bold: true
                    color: Colors.accent
                }

                TTextArea {
                    id: paymentLink
                    Layout.fillWidth: true
                    Layout.minimumHeight: 100 * Devices.density
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    TIconButton {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 4 * Devices.density
                        width: 30 * Devices.density
                        height: 30 * Devices.density
                        materialIcon: MaterialIcons.mdi_qrcode_scan
                        onClicked: {
                            var comp = Qt.createComponent("QRScannerDialog.qml");
                            var dlg = Viewport.viewport.append(comp, {}, "float");
                            dlg.tagFound.connect(function(tag) {
                                paymentLink.text = tag;
                                confirmBtn.clicked();
                            });
                        }
                    }
                }
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
            text: qsTr("Check payment key") + Translations.refresher
            highlighted: true
            onClicked: {
                decodeReq.bolt = paymentLink.text;
                decodeReq.doRequest();
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
            text: qsTr("Withdraw") + Translations.refresher
        }
    }

    THeaderBackButton {
        y: headerItem.height/2 - height/2
        ratio: 1
        onClicked: dis.ViewportType.open = false
        property bool isIOSPopup: true
    }
}
