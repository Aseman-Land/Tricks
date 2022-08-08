import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import globals 1.0
import QtQuick.Window 2.3

Item {
    id: tbar_btn
    width: 50 * Devices.density
    height: 32 * Devices.density

    property alias text: titleLabel.text
    property alias font: titleLabel.font
    property alias color: back.color
    signal clicked()

    Rectangle {
        id: back
        anchors.fill: parent
        color: "#22000000"
        opacity: marea.containsMouse? 1 : 0
    }

    TLabel {
        id: titleLabel
        anchors.centerIn: parent
        font.family: MaterialIcons.family
        font.pixelSize: 12 * Devices.fontDensity
        color: Colors.darkMode || !GlobalSettings.lightHeader? "#ffffff" : "#333333"
        text: MaterialIcons.mdi_close
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: tbar_btn.clicked()
    }
}
