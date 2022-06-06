import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Layouts 1.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: Viewport.viewport.width > Viewport.viewport.height && !Devices.isMobile? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    signal accepted()

    property bool buttons: true

    GetLicenseAgreementRequest {
        id: getReq
        Component.onCompleted: if (!Bootstrap.refreshing) doRequest()
    }

    Connections {
        target: Bootstrap
        function onRefreshingChanged() {
            if (!Bootstrap.refreshing)
                getReq.doRequest();
        }
    }

    TScrollView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: buttonsRow.visible? buttonsRow.top : parent.bottom

        Flickable {
            id: flick
            contentWidth: scene.width
            contentHeight: scene.height

            Item {
                id: scene
                width: flick.width
                height: Math.max(columnLyt.height + 40 * Devices.density, flick.height)

                ColumnLayout {
                    id: columnLyt
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20 * Devices.density

                    TLabel {
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        textFormat: Text.MarkdownText
                        text: {
                            if (!getReq.response)
                                return "";

                            var res = getReq.response;
                            let privace_key = "<!--- privacy collect table -->";
                            let private_key_text = "| Key | Value |\n| --- | ----- |\n";

                            var map = {
                                "Device-ID": Devices.deviceId,
                                "Device-Platform": Devices.platformName,
                                "Device-Kernel": Devices.platformKernel,
                                "Device-Name": Devices.deviceName,
                                "Device-Type": Devices.platformType,
                                "Device-Version": Devices.platformVersion,
                                "Device-CPU": Devices.platformCpuArchitecture
                            }

                            for (var k in map)
                                private_key_text += "| " + k + " | " + map[k] + " |\n";

                            res = Tools.stringReplace(res, privace_key, private_key_text);
                            return res;
                        }
                        horizontalAlignment: Text.AlignJustify
                    }
                }

                TBusyIndicator {
                    anchors.centerIn: parent
                    width: 26 * Devices.density
                    height: 26 * Devices.density
                    running: Bootstrap.refreshing || getReq.refreshing
                }
            }
        }
    }

    RowLayout {
        id: buttonsRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Constants.margins
        anchors.bottomMargin: Devices.navigationBarHeight + Constants.margins
        spacing: 0
        visible: buttons

        TButton {
            Layout.fillWidth: true
            highlighted: true
            text: qsTr("Accept") + Translations.refresher
            onClicked: {
                dis.accepted();
                dis.ViewportType.open = false;
            }
        }

        TButton {
            Layout.fillWidth: true
            text: qsTr("Reject") + Translations.refresher
            onClicked: dis.ViewportType.open = false
        }
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right

        TLabel {
            anchors.centerIn: parent
            font.pixelSize: 10 * Devices.fontDensity
            text: qsTr("Agreement") + Translations.refresher
        }
    }

    THeaderBackButton {
        ratio: 1
        onClicked: dis.ViewportType.open = false
    }
}
