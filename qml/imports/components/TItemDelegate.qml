import QtQuick 2.10
import AsemanQml.Base 2.0
import QtQuick.Controls 2.3
import globals 1.0

MouseArea {
    id: dis
    implicitHeight: 50 * Devices.density
    pressAndHoldInterval: 400

    property int focusPolicy: Qt.NoFocus

    onPressed: {
        forceActiveFocus();
        focus = true;
    }

    Rectangle {
        anchors.fill: parent
        z: -1
        color: Colors.foreground
        opacity: dis.pressed? 0.1 : 0
    }

    signal contextMenuRequest(int mouseX, int mouseY)

    TMouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onPressed: contextMenuRequest(mouseX, mouseY)
    }
}
