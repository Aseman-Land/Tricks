import QtQuick 2.0
import AsemanQml.Base 2.0
import QtQuick.Controls.Material 2.0

TNullableArea {

    Rectangle {
        anchors.fill: parent
        opacity: Devices.isAndroid? 1 : 0.7
        color: Material.background
    }
}
