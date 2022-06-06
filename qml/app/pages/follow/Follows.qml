import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Layouts 1.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

Item {
    id: dis

    property alias listView: lview
    property alias model: lview.model

    TScrollView {
        anchors.fill: parent

        TListView {
            id: lview
            delegate: TUserDelegate {
                width: lview.width
                fullname: model.fullname
                username: model.username
                avatar: model.avatar
                userId: model.id
                ownerRole: model.details.role
                Component.onCompleted: if (model.index == lview.count-1 && lview.model.more) lview.model.more()
            }
        }
    }
}
