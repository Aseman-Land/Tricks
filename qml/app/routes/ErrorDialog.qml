import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Controls 2.3
import QtQuick.Controls.Material 2.0
import QtQuick.Layouts 1.3
import globals 1.0
import components 1.0

Item {
    id: element
    width: Math.min(300, Viewport.viewport.width*0.8)
    height: columnLayout.height

    property variant buttons
    property string title
    property string body
    property bool superPermission

    signal itemClicked(int index, string title, string username)

    Rectangle {
        anchors.fill: parent
        opacity: Devices.isAndroid? 1 : 0.7
        color: Material.background
    }

    ColumnLayout {
        id: columnLayout
        anchors.right: parent.right
        anchors.left: parent.left
        spacing: 0

        ColumnLayout {
            Layout.topMargin: 12
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 10
            spacing: 6

            Label {
                id: titleLabel
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 10 * Devices.fontDensity
                horizontalAlignment: Devices.isAndroid ? Text.AlignLeft : Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: element.title
            }

            Label {
                id: bodyLabel
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: 9 * Devices.fontDensity
                horizontalAlignment: Devices.isAndroid ? Text.AlignLeft : Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: element.body
            }

            TTextField {
                id: usernameFields
                Layout.fillWidth: true
                placeholderText: qsTr("Type your username here") + Translations.refresher
                visible: superPermission
            }
        }

        Rectangle {
            Layout.topMargin: 6
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#88888888"
            visible: !Devices.isAndroid
            opacity: 0.4
        }

        RowLayout {
            spacing: 0
            Layout.fillWidth: true

            Repeater {
                id: repeater
                model: element.buttons? element.buttons : [ qsTr("Ok") + Translations.refresher ]
                TButton {
                    id: btn
                    Layout.fillWidth: true
                    topInset: 0
                    bottomInset: 0
                    leftInset: 0
                    rightInset: 0
                    highlighted: true
                    flat: true
                    hoverEnabled: false
                    text: modelData

                    Component.onCompleted: {
                        focus = true;
                        forceActiveFocus();
                    }

                    Connections {
                        target: btn
                        onClicked: {
                            if (!buttons && model.index == 0)
                                Viewport.viewport.closeLast()
                            else
                                element.itemClicked(model.index, modelData, usernameFields.text)
                        }
                    }
                }
            }
        }
    }
}
