import QtQuick 2.0
import AsemanQml.Base 2.0
import globals 1.0

Item {
    property variant mWin

    function moveRight(mouseX) {
        mWin.width = mWin.width + mouseX;
    }
    function moveLeft(mouseX) {
        mWin.x = mWin.x + mouseX;
        mWin.width = mWin.width - mouseX;
    }
    function moveTop(mouseY) {
        mWin.y = mWin.y + mouseY;
        mWin.height = mWin.height - mouseY;
    }
    function moveBottom(mouseY) {
        mWin.height = mWin.height + mouseY;
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 6 * Devices.density
        cursorShape: Qt.SizeVerCursor
        onMouseYChanged: moveBottom(mouseY)
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 6 * Devices.density
        cursorShape: Qt.SizeVerCursor
        onMouseYChanged: moveTop(mouseY)
    }

    MouseArea {
        x: 0
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 6 * Devices.density
        cursorShape: Qt.SizeHorCursor
        onPositionChanged: moveLeft(mouseX)
    }

    MouseArea {
        x: parent.width - width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 6 * Devices.density
        cursorShape: Qt.SizeHorCursor
        onPositionChanged: moveRight(mouseX)
    }

    MouseArea {
        x: 0
        anchors.top: parent.top
        width: 6 * Devices.density
        height: 6 * Devices.density
        cursorShape: Qt.SizeFDiagCursor
        onPositionChanged: {
            moveLeft(mouseX);
            moveTop(mouseY);
        }
    }

    MouseArea {
        x: parent.width - width
        anchors.top: parent.top
        width: 6 * Devices.density
        height: 6 * Devices.density
        cursorShape: Qt.SizeBDiagCursor
        onPositionChanged: {
            moveRight(mouseX);
            moveTop(mouseY);
        }
    }

    MouseArea {
        x: parent.width - width
        anchors.bottom: parent.bottom
        width: 6 * Devices.density
        height: 6 * Devices.density
        cursorShape: Qt.SizeFDiagCursor
        onPositionChanged: {
            moveRight(mouseX);
            moveBottom(mouseY);
        }
    }

    MouseArea {
        x: 0
        anchors.bottom: parent.bottom
        width: 6 * Devices.density
        height: 6 * Devices.density
        cursorShape: Qt.SizeBDiagCursor
        onPositionChanged: {
            moveLeft(mouseX);
            moveBottom(mouseY);
        }
    }
}
