import QtQuick 2.4
import QtQuick.Layouts 1.1
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.1
import globals 1.0

Rectangle {
    id: snackbar

    property string buttonText
    property string text
    property bool opened
    property int duration: 2000
    property bool fullWidth: GlobalSettings.viewMode == 2

    signal clicked

    function open(text) {
        snackbar.text = text
        opened = true;
        timer.restart();
    }

    anchors {
        bottom: parent.bottom
        bottomMargin: opened ? (fullWidth? navigArea.height : Constants.margins) :  -snackbar.height

        Behavior on bottomMargin {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
    }
    radius: fullWidth ? 0 : Constants.radius
    color: Colors.accent
    height: snackLayout.height
    width: fullWidth ? parent.width : snackLayout.width
    x: parent.width/2 - width/2
    opacity: opened ? 1 : 0

    Timer {
        id: timer

        interval: snackbar.duration

        onTriggered: {
            if (!running) {
                snackbar.opened = false;
            }
        }
    }

    Rectangle {
        id: navigArea
        anchors.top: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: snackbar.color
        height: Devices.navigationBarHeight
    }

    RowLayout {
        id: snackLayout

        anchors {
            verticalCenter: parent.verticalCenter
            left: snackbar.fullWidth ? parent.left : undefined
            right: snackbar.fullWidth ? parent.right : undefined
        }

        spacing: 0

        Item {
            width: 24 * Devices.density
        }

        Label {
            id: snackText
            font.pixelSize: 9*Devices.fontDensity
            Layout.fillWidth: true
            Layout.minimumWidth: snackbar.fullWidth ? -1 : 216 * Devices.fontDensity - snackButton.width
            Layout.maximumWidth: snackbar.fullWidth ? -1 :
                Math.min(496 * Devices.fontDensity - snackButton.width - middleSpacer.width - 48 * Devices.fontDensity,
                         snackbar.parent.width - snackButton.width - middleSpacer.width - 48 * Devices.fontDensity)

            Layout.preferredHeight: lineCount == 2 ? 80 * Devices.density : 48 * Devices.density
            verticalAlignment: Text.AlignVCenter
            maximumLineCount: 2
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            text: snackbar.text
            color: "#fff"
        }

        Item {
            id: middleSpacer
            width: snackbar.buttonText == "" ? 0 : snackbar.fullWidth ? 24 * Devices.density : 48 * Devices.density
        }

        Button {
            id: snackButton
            flat: true
            visible: snackbar.buttonText != ""
            text: snackbar.buttonText
            onClicked: snackbar.clicked()
        }

        Item {
            width: 24 * Devices.density
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }
}
