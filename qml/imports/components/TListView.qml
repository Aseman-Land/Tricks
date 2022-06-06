import QtQuick 2.12
import AsemanQml.Base 2.0

ListView {
    id: dis
    maximumFlickVelocity: View.flickVelocity

    TDesktopWheelArea {
        anchors.fill: parent
        visible: Devices.isDesktop
        flick: dis
    }
}
