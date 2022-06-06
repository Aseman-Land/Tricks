import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import globals 1.0
import models 1.0

TItemDelegate {
    id: element
    width: 100
    height: 100
    enabled: title.text.length

    property bool visibleTexts: true
    property real iconSizeRatio: 1
    property alias iconText: iconText
    property alias title: title
    property int badgeCount
    property bool selected

    onSelectedChanged: {
        if (!selected)
            return;

        customRatio = 0.85;
        Tools.jsDelayCall(100, function(){ customRatio = 1; })
    }
    property real customRatio: 1

    Behavior on customRatio {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 150 }
    }

    ColumnLayout {
        id: elementColumn
        spacing: 4 * Devices.density
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        TLabel {
            id: iconText
            Layout.preferredHeight: 30 * Devices.density
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: MaterialIcons.family
            font.pixelSize: 17 * Devices.fontDensity * element.iconSizeRatio * element.customRatio
        }
        TLabel {
            id: title
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            font.capitalization: Font.AllUppercase
            font.pixelSize: 7 * Devices.fontDensity
            visible: visibleTexts
        }
    }

    Rectangle {
        anchors.verticalCenter: elementColumn.top
        anchors.horizontalCenter: elementColumn.right
        width: 8 * Devices.density
        height: width
        radius: height / 2
        color: Colors.primary
        visible: element.badgeCount
    }
}
