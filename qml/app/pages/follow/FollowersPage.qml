import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Layouts 1.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: GlobalSettings.viewMode != 2? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    property alias userId: fmodel.userId
    property string fullname

    TBusyIndicator {
        anchors.centerIn: parent
        running: fmodel.refreshing
    }

    Follows {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: UserFollowersModel {
            id: fmodel
        }
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            TLabel {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 10 * Devices.fontDensity
                text: qsTr("Followers") + Translations.refresher
            }

            TLabel {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 8 * Devices.fontDensity
                text: dis.fullname
                opacity: 0.7
            }
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
