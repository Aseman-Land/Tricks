import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Layouts 1.3
import components 1.0
import globals 1.0

Rectangle {
    id: tagItem
    width: tagRow.width + 14 * Devices.density
    radius: 4 * Devices.density
    color: Qt.darker(bgColor, (marea.containsMouse? 1.1 : 0))

    property bool selected
    property color bgColor: Colors.darkMode? Colors.foreground : (selected? Colors.accent : Colors.foreground) // IOSStyle.theme != IOSStyle.Dark? Colors.accent : "#fff"
    property color fgColor: Colors.darkMode? (selected? Colors.accent : Colors.background) : Colors.background // IOSStyle.theme != IOSStyle.Dark? "#fff" : IOSStyle.accent

    property string tag
    property int count

    signal clicked

    TMouseArea {
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: tagItem.clicked()
    }

    RowLayout {
        id: tagRow
        anchors.centerIn: parent

        TLabel {
            text: tagItem.tag
            font.pixelSize: 8 * Devices.fontDensity
            color: tagItem.fgColor
        }

        Rectangle {
            Layout.preferredWidth: Math.max(18 * Devices.density, countLabel.width + 6 * Devices.density)
            Layout.preferredHeight: 18 * Devices.density
            radius: width / 2
            color: tagItem.fgColor

            TLabel {
                id: countLabel
                anchors.centerIn: parent
                font.pixelSize: 6 * Devices.fontDensity
                text: tagItem.count
                color: tagItem.bgColor
            }
        }
    }
}
