import QtQuick 2.9
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.MaterialIcons 2.0
import globals 1.0

HeaderMenuButton {
    id: btn
    ratio: 1
    buttonColor: iosPopup? "transparent" : color
    color: Colors.foreground

    TMaterialIcon {
        anchors.centerIn: parent
        text: MaterialIcons.mdi_close
        font.pixelSize: 14 * Devices.fontDensity
        color: btn.color
        visible: btn.iosPopup
    }

    property bool iosPopup

    Component.onCompleted: {
        var obj = this;
        while (obj) {
            if (obj.isIOSPopup) {
                iosPopup = true;
                break;
            }
            obj = obj.parent;
        }
    }
}
