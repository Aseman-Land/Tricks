import QtQuick 2.0
import AsemanQml.Base 2.0
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.1

Slider {
    id: slider
    orientation: Qt.Horizontal


    property alias labelText: lbl.text

    Rectangle {
        id: lblScene
        parent: slider.handle
        width: lbl.width + 20*Devices.density
        height: lbl.height + 20*Devices.density
        anchors.bottom: parent.top
        anchors.bottomMargin: 10*Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        color: Material.accent
        radius: 8*Devices.density
        scale: slider.pressed? 1.2 : 1
        transformOrigin: Item.Bottom

        Behavior on scale {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }

        TLabel {
            id: lbl
            anchors.centerIn: parent
            color: "#fff"
        }
    }
}
