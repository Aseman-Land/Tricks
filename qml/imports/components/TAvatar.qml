import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.MaterialIcons 2.0
import globals 1.0

CachedImage {
    id: img
    implicitHeight: 42 * Devices.density
    implicitWidth: 42 * Devices.density
    width: height
    radius: width/2
    ignoreSslErrors: GlobalSettings.ignoreSslErrors || GlobalSettings.ignoreSslErrorsPerment

    source: remoteUrl.length? Constants.baseUrl + "/" + remoteUrl : ""
    fillMode: Image.PreserveAspectCrop
    asynchronous: true

    property string remoteUrl
    property color avatarColor: Colors.accent

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: img.avatarColor
        z: -1

        TMaterialIcon {
            anchors.centerIn: parent
            font.pixelSize: 14 * Devices.fontDensity * (img.width / (42 * Devices.density))
            text: MaterialIcons.mdi_account
            color: "#fff"
        }
    }
}
