import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import QtQuick.Controls 1.3
import globals 1.0

Item {
    id: dis
    clip: true

    onChildrenChanged: {
        for (var i=0; i<children.length; i++) {
            var d = children[i];
            if (d.flicking != undefined) {
                d.anchors.fill = dis
                scroll.scrollArea = d;
                if (d.model == undefined) {
                    d.flickableDirection = Flickable.VerticalFlick;
                }
            }
        }
    }

    HScrollBar {
        id: scroll
        color: Colors.accent
        anchors.topMargin: scrollArea && scrollArea.headerItem? scrollArea.headerItem.height : 0
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
}
