import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Modern 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import components 1.0
import globals 1.0

TItemDelegate {
    id: sideBarItem
    Layout.fillWidth: true

    property bool selected: false
    property string materialIcon
    property string materialText
    property int materialCount: -1

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 20 * Devices.density
        anchors.rightMargin: 14 * Devices.density
        spacing: 15 * Devices.density

        TMaterialIcon {
            font.bold: sideBarItem.selected
            color: sideBarItem.selected? Colors.accent : Colors.foreground
            text: sideBarItem.materialIcon
        }

        TLabel {
            Layout.fillWidth: true
            font.bold: sideBarItem.selected
            color: sideBarItem.selected? Colors.accent : Colors.foreground
            text: sideBarItem.materialText
        }

        Rectangle {
            Layout.preferredWidth: Math.max(18 * Devices.density, countLabel.width + 8 * Devices.density)
            Layout.preferredHeight: 18 * Devices.density
            radius: width / 2
            color: Colors.accent
            visible: sideBarItem.materialCount > -1

            TLabel {
                id: countLabel
                anchors.centerIn: parent
                font.pixelSize: 8 * Devices.fontDensity
                text: sideBarItem.materialCount
                color: "#fff"
            }
        }
    }
}
