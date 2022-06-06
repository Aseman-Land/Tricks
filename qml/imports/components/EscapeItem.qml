import QtQuick 2.0
import AsemanQml.Base 2.0

Item {

    MouseArea {
        anchors.fill: parent
        onClicked: {
            focus = true;
            Devices.hideKeyboard();
        }
    }
}
