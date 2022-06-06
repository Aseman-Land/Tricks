import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.MaterialIcons 2.0

TTextField {
    id: dis
    placeholderText: qsTr("Search") + Translations.refresher
    inputMethodHints: Qt.ImhNoPredictiveText

    property alias busy: busy.running

    signal searchRequest(string keyword)

    onTextChanged: timer.restart()

    Timer {
        id: timer
        interval: 300
        repeat: false
        onTriggered: dis.searchRequest(dis.text)
    }

    TIconButton {
        width: 40 * Devices.density
        materialColor: color
        materialIcon: dis.text.length? MaterialIcons.mdi_close : MaterialIcons.mdi_magnify
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        onClicked: dis.clear()
    }

    TBusyIndicator {
        id: busy
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        anchors.leftMargin: 8 * Devices.density
        height: 16 * Devices.density
        width: height
        visible: timer.running
    }
}
