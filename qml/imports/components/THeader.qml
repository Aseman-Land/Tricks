import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import globals 1.0

Header {
    shadow: false
    color: Colors.headerSecondary
    light: Colors.darkMode

    default property alias sceneData: scene.data

    Item {
        id: scene
        anchors.fill: parent
        anchors.topMargin: Devices.statusBarHeight
    }
}
