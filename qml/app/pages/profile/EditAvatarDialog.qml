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
    width: Math.min(300, Viewport.viewport.width*0.9)
    height: columnLayout.height

    property alias title: titleLabel.text
    property string source
    property real ratio

    signal itemClicked(int index)

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
            spacing: 12 * Devices.density

            Label {
                id: titleLabel
                Layout.fillWidth: true
                font.bold: true
                font.pixelSize: 10 * Devices.fontDensity
                horizontalAlignment: Devices.isAndroid ? Text.AlignLeft : Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            TAvatar {
                id: avatar
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: element.ratio>1? 250 * Devices.density : 128 * Devices.density
                Layout.preferredHeight: element.ratio>1? 250 * Devices.density / element.ratio : 128 * Devices.density
                source: element.source
                radius: ratio != 1? 8 * Devices.density : height/2
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
                model: [ qsTr("Update"), qsTr("Cancel") + Translations.refresher ]
                Button {
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
                        onClicked: element.itemClicked(model.index)
                    }
                }
            }
        }
    }
}
