import QtQuick 2.12
import AsemanQml.Base 2.0
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.IOSStyle 2.3
import components 1.0
import "private"

Rectangle {
    id : item
    color: "#000"

    property alias model: listv.model
    property alias currentIndex: listv.currentIndex
    property alias count: listv.count
    property string roleName

    Label {
        anchors.centerIn: parent
        text: qsTr("There is no image")
        font.pixelSize: 8 * Devices.fontDensity
        color: "#fff"
        visible: listv.count == 0
    }

    ListView{
        id: listv
        anchors.fill: parent

        orientation: ListView.Horizontal
        snapMode: ListView.SnapOneItem
        keyNavigationEnabled : true
        preferredHighlightBegin: 0
        preferredHighlightEnd: width
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightMoveDuration: 0

        Component.onCompleted: Tools.jsDelayCall(this, function(){ highlightMoveDuration = 150 })

        property bool bounded: false
        onCurrentIndexChanged: bounded = false

        delegate: Item {
            width: listv.width
            height: listv.height

            TRemoteImage {
                id: img
                anchors.fill: parent
                anchors.margins: 10 * Devices.density
                source: roleName.length? model[roleName] : modelData
                asynchronous: true
                fillMode: Image.PreserveAspectFit

                TBusyIndicator {
                    anchors.centerIn: parent
                    IOSStyle.foreground: "#fff"
                    Material.accent: "#fff"
                    running: img.status != Image.Ready
                }
            }
        }
    }
}
