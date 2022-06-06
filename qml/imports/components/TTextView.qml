import QtQuick 2.12
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

    TTextEdit {
        id: edit
        anchors.left: parent.left
        anchors.right: parent.right
        readOnly: true
        visible: false
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

    LevelAdjust {
        source: edit
        anchors.fill: edit
        cached: true
    }

    TMouseArea {
        anchors.fill: edit
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
