import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import globals 1.0

CachedImage {
    id: img
    asynchronous: true
    source: remoteUrl.length? Constants.baseUrl + "/" + remoteUrl : ""
    fillMode: Image.PreserveAspectFit
    ignoreSslErrors: GlobalSettings.ignoreSslErrors || GlobalSettings.ignoreSslErrorsPerment

    property string remoteUrl

    TLabel {
        anchors.centerIn: parent
        font.pixelSize: 8 * Devices.fontDensity
        opacity: 0.6
        text: qsTr("Loading...") + Translations.refresher
        visible: img.progress != 1
    }
}
