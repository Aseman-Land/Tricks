import QtQuick 2.0
import AsemanQml.Base 2.0

MouseArea {
    anchors.fill: flick

    property Flickable flick
    property bool animated: true
    property bool reverse: false
    property bool naturalScroll: View.reverseScroll

    property real endContentY

    NumberAnimation {
        id: animY
        target: flick
        easing.type: Easing.OutSine
        property: "contentY"
        duration: 400
        onRunningChanged: if(!running) flick.returnToBounds()
    }

    onPressed: mouse.accepted = false
    onWheel: {
        wheel.accepted = true
        var contentX = 0
        var contentY = 0

        var angleX = wheel.angleDelta.x * (naturalScroll? -1 : 1)
        var angleY = wheel.angleDelta.y * (naturalScroll? -1 : 1)

        if(!animY.running)
            endContentY = flick.contentY

        var ratio = animated? 0.7 : 0.5
        if( flick.orientation ) {
            if( flick.orientation == Qt.Horizontal )
                contentX = -angleY*ratio
            else
                contentY = -angleY*ratio
        } else {
            if( flick.flickableDirection == Flickable.VerticalFlick )
                contentY = -angleY*ratio
            else
            if( flick.flickableDirection == Flickable.HorizontalFlick )
                contentX = -angleY*ratio
            else {
                contentY = -angleY*ratio
                contentX = -angleX*ratio
            }
        }

        if(animated) {
            endContentY += contentY
            var padY
            if(reverse) {
                padY = flick.originY+flick.contentHeight
                if( endContentY > -flick.height+padY )
                    endContentY = -flick.height+padY
                else
                if( endContentY < -flick.contentHeight+padY )
                    endContentY = -flick.contentHeight+padY
            } else {
                padY = flick.originY
                if( endContentY < padY )
                    endContentY = padY
                else
                if( endContentY > flick.contentHeight - flick.height + padY )
                    endContentY = flick.contentHeight - flick.height + padY
            }

            if(animY.to != endContentY) {
                animY.from = flick.contentY;
                animY.to = endContentY;
                animY.restart();
            }

            flick.contentX += contentX
        } else {
            flick.contentY += contentY
            flick.contentX += contentX
            flick.returnToBounds()
        }
    }
}
