import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import AsemanQml.Models 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import globals 1.0
import components 1.0
import requests 1.0

TItemDelegate {
    id: dis
    implicitHeight: likerRow.height + 16 * Devices.density

    property string fullname
    property string username
    property string avatar
    property string message
    property int userId
    property int trickOwner
    property int trickId
    property int commentId
    property string dateTime

    onContextMenuRequest: menuBtn.clicked()

    signal deleted();

    function deleteRequest() {
        var args = {
            "title": qsTr("Warning"),
            "body" : qsTr("Do you realy want to delete this comment?") ,
            "buttons": [qsTr("Yes"), qsTr("No")]
        };
        var obj = Viewport.controller.trigger("dialog:/general/warning", args);
        obj.itemClicked.connect(function(idx, title){
            switch (idx) {
            case 0: // Yes
                deleteReq.doRequest();
                break;
            case 1: // No
                break;
            }
            obj.ViewportType.open = false;
        });
    }

    DeleteCommentRequest {
        id: deleteReq
        allowGlobalBusy: true
        _trick_id: trickId
        _comment_id: commentId
        onSuccessfull: dis.deleted()
    }

    RowLayout {
        id: likerRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Constants.margins
        y: 8 * Devices.density
        spacing: Constants.spacing

        TAvatar {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 22 * Devices.density
            Layout.preferredHeight: 22 * Devices.density
            remoteUrl: avatar

            TMouseArea {
                anchors.fill: parent
                onClicked: Viewport.controller.trigger("float:/users", {"userId": userId, "title": fullname})
            }
        }

        ColumnLayout {
            spacing: 4 * Devices.density

            RowLayout {
                spacing: 10 * Devices.density

                TLabel {
                    font.bold: true
                    text: fullname
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1

                    TMouseArea {
                        anchors.fill: parent
                        anchors.margins: -4 * Devices.density
                        onClicked: Viewport.controller.trigger("float:/users", {"userId": userId, "title": fullname})
                    }
                }
                TLabel {
                    Layout.fillWidth: true
                    opacity: 0.7
                    text: "@" + username
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            Label {
                Layout.fillWidth: true
                font.pixelSize: 9 * Devices.fontDensity
                font.family: Fonts.globalFont
                text: message
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }

            TLabel {
                text: GlobalMethods.dateToString(GlobalMethods.unNormalizeDate(dateTime))
                font.pixelSize: 8 * Devices.fontDensity
                opacity: 0.7
            }
        }
    }

    TIconButton {
        id: menuBtn
        anchors.right: parent.right
        anchors.top: parent.top
        materialIcon: MaterialIcons.mdi_dots_vertical
        width: 30 * Devices.density
        height: 30 * Devices.density
        flat: true
        onClicked: {
            var pos = Qt.point(dis.LayoutMirroring.enabled? Constants.radius : menuBtn.width - Constants.radius, menuBtn.height);
            var parent = menuBtn;
            while (parent && parent != Viewport.viewport) {
                pos.x += parent.x;
                pos.y += parent.y;
                parent = parent.parent;
            }

            Viewport.viewport.append(menuComponent, {"pointPad": pos}, "menu");
        }
    }

    THListSeprator {
        width: parent.width
        anchors.bottom: parent.bottom
    }

    Component {
        id: menuComponent
        MenuView {
            id: menuItem
            x: pointPad.x - width
            y: pointPad.y - height - 40 * Devices.density
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = height;
                var x = dis.LayoutMirroring.enabled? 0 : width;
                return Qt.point(x, y);
            }

            property point pointPad
            property int index

            onItemClicked: {
                switch (index) {
                case 0:
                    deleteRequest()
                    break;
                }

                ViewportType.open = false;
            }

            model: AsemanListModel {
                data: [
                    {
                        title: qsTr("Delete Comment"),
                        icon: "mdi_trash_can",
                        enabled: (GlobalSettings.userId == userId || GlobalSettings.userId == trickOwner)
                    },
                ]
            }
        }
    }
}
