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
    ViewportType.maximumWidth: Viewport.viewport.width > Viewport.viewport.height && !Devices.isMobile? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    property alias trickId: fmodel.trickId

    TBusyIndicator {
        anchors.centerIn: parent
        running: fmodel.refreshing
    }

    TScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        TListView {
            id: lview
            model: TricksTipsModel {
                id: fmodel
            }
            delegate: TUserDelegate {
                width: lview.width
                userId: model.user.id
                ownerRole: model.user.details.role
                fullname: model.user.fullname
                avatar: model.user.avatar
                username: model.user.username
                extraText: qsTr("%1 SAT").arg(formater.output)
                Component.onCompleted: if (model.index == lview.count-1 && lview.model.more) lview.model.more()

                TextFormater {
                    id: formater
                    delimiter: ","
                    count: 3
                    input: Math.floor(model.amount_msat / 1000)
                }
            }
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
                text: qsTr("Tips") + Translations.refresher
            }
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
