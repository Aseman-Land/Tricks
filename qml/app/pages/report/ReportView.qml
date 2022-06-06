import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import components 1.0
import requests 1.0
import globals 1.0

Item {
    id: dis

    signal reportRequest(string message, int type)

    TScrollView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: submitBtn.top

        TFlickable {
            id: flick
            contentWidth: scene.width
            contentHeight: scene.height

            EscapeItem {
                id: scene
                width: flick.width
                height: columnLyt.height + columnLyt.y * 2

                ColumnLayout {
                    id: columnLyt
                    y: 20 * Devices.density
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: y
                    spacing: 10 * Devices.density

                    TComboBox {
                        id: type
                        Layout.fillWidth: true
                        model: [qsTr("Abuse"), qsTr("Spam"), qsTr("Pornography"), qsTr("Other")]
                    }

                    TTextArea {
                        id: body
                        Layout.fillWidth: true
                        Layout.minimumHeight: 200 * Devices.density
                        placeholderText: qsTr("Message") + Translations.refresher
                    }
                }
            }
        }
    }

    TIconButton {
        id: submitBtn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Devices.navigationBarHeight + Constants.margins
        anchors.margins: Constants.margins
        highlighted: true
        materialText: qsTr("Report") + Translations.refresher
        flat: false
        enabled: body.length
        onClicked: dis.reportRequest(body.text, type.currentIndex)
    }
}
