import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import AsemanQml.Base 2.0
import globals 1.0

TButton {
    id: dis
    text: followBusy.running? "" : followed? qsTr("Unfollow") : qsTr("Follow") + Translations.refresher
    IOSStyle.background: Qt.darker(Colors.headerSecondary, (Colors.darkMode? 0.5 : 1.1))
    IOSStyle.accent: accentColor
    Material.accent: accentColor
    font.pixelSize: 8 * Devices.fontDensity
    onClicked: {
        if (followed)
            unfollowReq.doRequest();
        else
            followReq.doRequest();
    }

    property variant unfollowReq
    property variant followReq
    property bool followed
    readonly property alias refreshing: followBusy.running
    readonly property color accentColor: {
        var res;
        if (Colors.darkMode)
            res = followed? "#ff4245" : Qt.lighter(Colors.accent, 1.2);
        else
            res = followed? "#a00" : Qt.darker(Colors.accent, 1.2);
        return res;
    }

    TBusyIndicator {
        id: followBusy
        anchors.centerIn: parent
        width: 18 * Devices.density
        height: width
        running: followReq.refreshing || unfollowReq.refreshing
        IOSStyle.foreground: dis.highlighted? "#fff" : Colors.accent
        Material.accent: dis.highlighted? "#fff" : Colors.accent
    }
}
