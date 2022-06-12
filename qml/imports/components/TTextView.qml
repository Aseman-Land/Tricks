import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Labs 2.0
import QtGraphicalEffects 1.0
import Tricks 1.0
import globals 1.0

Item {
    id: dis
    implicitHeight: edit.height

    property alias text: edit.text
    property alias textFormat: edit.textFormat

    signal linkActivated(string link)

    function getText(from, to) {
        return edit.getText(from, to);
    }

    Item {
        id: scene
        anchors.left: parent.left
        anchors.right: parent.right
        height: edit.height
        visible: false
        anchors.margins: -10 * Devices.density

        TTextEdit {
            id: edit
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10 * Devices.density
            readOnly: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: TricksTools.directionOf(getText(0, length)) == Qt.RightToLeft? Text.AlignRight : Text.AlignLeft

            onTextChanged: {
                directionHandler.textDocument = textDocument;
                directionHandler.currentText = getText(0, length);
                directionHandler.refresh();
            }

            TextDirectionHandler {
                id: directionHandler
            }
        }
    }

    LevelAdjust {
        source: scene
        anchors.fill: scene
        cached: true
    }

    TMouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10 * Devices.density
        height: edit.height
        onPressed: {
            if (getLink().length)
                mouse.accepted = true;
            else
                mouse.accepted = false;
        }
        onReleased: dis.linkActivated( getLink() )

        function getLink() {
            return edit.linkAt(mouseX, mouseY);
        }
    }
}
