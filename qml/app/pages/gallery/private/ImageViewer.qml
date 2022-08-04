import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import components 1.0

Flickable{
    id : view
    contentHeight: imageViewer.height
    contentWidth: imageViewer.width
    topMargin: view.height > imageViewer.height ? (view.height - imageViewer.height)/2 : 0
    interactive: false
    contentX : -(view.width - imageViewer.width)/2
    contentY : -(view.height - imageViewer.height)/2
    clip: true
    onFlickEnded: {
        if ( listv.bounded && contentX == 0 ) {
            listv.currentIndex == 0 ? null : imageViewer.zoom = 1
            listv.currentIndex == 0 ? null : listv.currentIndex--
            listv.bounded = false
        }
        else if ( listv.bounded && contentX == view.width ){
            listv.currentIndex == listv.count-1 ? null : imageViewer.zoom = 1
            listv.currentIndex == listv.count-1 ? null : listv.currentIndex++
            listv.bounded = false
        }
        else { if ( (listv.currentIndex == 0 && contentX == 0 )  ||
                    (listv.currentIndex == listv.count-1 && contentX == view.width ))
                   listv.bounded = false
              else listv.bounded = true
        }
    }

    property alias source: imageViewer.remoteUrl

    NumberAnimation{
        id : doubleClickedZoomEffectGrow
        target: imageViewer
        property: "zoom"
        to : 2
        duration: 300
        running : false
    }

    NumberAnimation{
        id : doubleClickedZoomEffectUnGrow
        target: imageViewer
        property: "zoom"
        to : 1
        duration: 300
        running : false
    }

    NumberAnimation{
        id : minimumZoomIsOne
        target: imageViewer
        property: "zoom"
        to : 0.9
        duration: 300
        running : false
    }

    TRemoteImage {
        id : imageViewer
        opacity: 1.0
        width: (ratio<1? view.width : view.height / ratio) * zoom
        height: (ratio<1? view.width * ratio : view.height) * zoom
        asynchronous: true
        fillMode: Image.PreserveAspectFit

        property real _width_: ratio<1? view.width :imageViewer.height / ratio
        property real _height_: ratio<1? imageViewer.width * ratio :view.height
        property real ratio: (imageViewer.sourceSize.height / imageViewer.sourceSize.width)
        property real zoom: 0.9
        property bool wheeled : false


        onZoomChanged:  {
            imageViewer.width  = (ratio<1? imageViewer._width_ : imageViewer._height_ / imageViewer.ratio ) * imageViewer.zoom
            imageViewer.height = (ratio<1? imageViewer._width_ * imageViewer.ratio : imageViewer._height_ ) * imageViewer.zoom
            imageViewer.zoom === 1 ? imageViewer.wheeled = false : imageViewer.wheeled = true
            imageViewer.zoom <= 1 ? listv.interactive = true : listv.interactive = false
            imageViewer.zoom <= 1 ? view.interactive = false : view.interactive = true
        }

        onRotationChanged: {
            imageViewer.rotation === 0 ? imageViewer.wheeled = false : imageViewer.wheeled = true
            imageViewer.rotation <= 1 ? listv.interactive = true : listv.interactive = false
            imageViewer.rotation <= 1 ? view.interactive = false : view.interactive = true
        }

        PinchArea {
            id : pinchArea
            anchors.fill: parent
            pinch.target: imageViewer
            pinch.minimumRotation: 0
            pinch.maximumRotation: 0
            pinch.minimumScale: 1
            pinch.maximumScale: 10
            pinch.dragAxis: Pinch.XAndYAxis

            MouseArea {
                id: dragArea
                hoverEnabled: true
                anchors.fill: parent
                drag.target: null
                scrollGestureEnabled: true

                onWheel: {
                    if (wheel.modifiers & Qt.ControlModifier) {
                        imageViewer.rotation += wheel.angleDelta.y / 120 * 5;
                        if (Math.abs(imageViewer.rotation) < 4)
                            imageViewer.rotation = 0;
                    } else {
                        imageViewer.rotation += wheel.angleDelta.x / 120;
                        if (Math.abs(imageViewer.rotation) < 0.6)
                            imageViewer.rotation = 0;
                        imageViewer.zoom += imageViewer.zoom * wheel.angleDelta.y / 120 / 10;
                    }
                    if ( imageViewer.zoom < 0.9 )
                        minimumZoomIsOne.running = true
                }

                onDoubleClicked: {
                    imageViewer.wheeled ? doubleClickedZoomEffectUnGrow.running = true : doubleClickedZoomEffectGrow.running = true
                    imageViewer.rotation = 0
                }

                onReleased: {
                    if ( imageViewer.zoom < 0.9 )
                        minimumZoomIsOne.running = true
                }
            }
        }
    }
}
