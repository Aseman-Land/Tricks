import QtQuick 2.0
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.MaterialIcons 2.0
import globals 1.0

TButton {
    id: btn
    flat: true
    highlighted: true
    implicitWidth: rowLyt.width + 14 * Devices.density

    property string materialText
    property string materialIcon
    property real materialOpacity: 1
    property color materialColor: flat && highlighted? Colors.accent : "#fff"
    property real materialIconSize: 12 * Devices.fontDensity

    RowLayout {
        id: rowLyt
        opacity: materialOpacity
        spacing: 4 * Devices.density
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: materialText.length && materialIcon.length? -4 * Devices.density : 0

        TMaterialIcon {
            text: materialIcon
            color: materialColor
            font.pixelSize: materialIconSize
            visible: text.length
        }

        TLabel {
            text: materialText
            color: materialColor
            visible: text.length
            font: btn.font
        }
    }
}
