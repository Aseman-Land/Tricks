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
    height: resultColumn.height + headerItem.height + Devices.navigationBarHeight

    Rectangle {
        anchors.fill: parent
        color: Colors.background
        opacity: 0.5
    }

    ColumnLayout {
        id: resultColumn
        anchors.top: headerItem.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        spacing: 4 * Devices.density

        TLabel {
            id: bodyLabel
            Layout.fillWidth: true
            Layout.topMargin: 10 * Devices.density
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: Colors.accent
            text: qsTr("From Sign-in menu click on QR-Login and scan below QR-Code.") + Translations.refresher
        }

        TImage {
            id: qrImage
            Layout.topMargin: 40 * Devices.density
            Layout.bottomMargin: 40 * Devices.density
            Layout.preferredWidth: dis.width - 80 * Devices.density
            Layout.preferredHeight: dis.width - 80 * Devices.density
            Layout.alignment: Qt.AlignHCenter
            sourceSize: Qt.size(width, height)
            asynchronous: true
            mipmap: true
            source: "image://QZXing/encode/" + GlobalSettings.accessToken
        }

        TButton {
            id: doneBtn
            Layout.fillWidth: true
            Layout.leftMargin: 20 * Devices.density
            Layout.rightMargin: 20 * Devices.density
            Layout.bottomMargin: 20 * Devices.density
            text: qsTr("Done") + Translations.refresher
            highlighted: true
            onClicked: {
                dis.ViewportType.open = false;
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
            text: qsTr("QR-Login") + Translations.refresher
        }
    }

    THeaderBackButton {
        ratio: 1
        y: headerItem.height/2 - height/2
        onClicked: dis.ViewportType.open = false
        property bool isIOSPopup: true
    }
}
