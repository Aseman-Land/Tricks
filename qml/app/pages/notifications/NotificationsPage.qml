import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import AsemanQml.Models 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.3
import QtQuick.Controls.Material 2.3
import QtGraphicalEffects 1.0
import components 1.0
import Tricks 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: GlobalSettings.viewMode != 2? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    property bool mainPageMode: false

    function positionViewAtBeginning() {
        listv.positionViewAtBeginning()
    }

    Component.onCompleted: {
        MyNotificationsModel.refresh();
        MyNotificationsModel.markAllAsRead();
        dismisReq.doRequest();
    }

    DismissNotificationsRequest {
        id: dismisReq
    }

    TLabel {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Constants.margins
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("There is no notification here") + Translations.refresher
        font.pixelSize: 8 * Devices.fontDensity
        opacity: 0.6
        visible: listv.count == 0 && !MyNotificationsModel.refreshing
    }

    TScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        TListView {
            id: listv
            model: MyNotificationsModel

            header: TListRefresher {
                id: refresher
                view: listv
                onRefreshRequest: {
                    refreshing = true;
                    listv.model.refresh();
                }

                Connections {
                    target: listv.model
                    onRefreshingChanged: if (!listv.model.refreshing) refresher.refreshing = false;
                }
            }

            delegate: TItemDelegate {
                id: notItem
                width: listv.width
                height: rowItem.height + 16 * Devices.density
                Component.onCompleted: if (model.index == listv.count-1 && listv.model.more) listv.model.more()
                onClicked: {
                    switch (model.notify_type) {
                    case 2:
                    case 7:
                        Viewport.controller.trigger("float:/users", {"userId": model.users[0].id, "title": model.users[0].fullname});
                        break;
                    case 3:
                        Viewport.controller.trigger("float:/tricks", {"trickId": model.comment.id})
                        Viewport.controller.trigger("float:/tricks", {"trickId": model.comment.id})
                        break;
                    case 1:
                    case 5:
                    case 6:
                        Viewport.controller.trigger("float:/tricks", {"trickId": model.trick.id})
                        break;

                    default:
                        if (model.trick)
                            Viewport.controller.trigger("float:/tricks", {"trickId": model.trick.id})
                        else
                            Viewport.controller.trigger("float:/users", {"userId": model.users[0].id, "title": model.users[0].fullname});
                    }
                }

                property bool trickItemMode: model.notify_type == 3 || model.notify_type == 5
                property variant masterObject: model.comment? model.comment : model.trick

                RowLayout {
                    id: rowItem
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Constants.margins
                    y: 8 * Devices.density
                    spacing: Constants.spacing

                    Item {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: 42 * Devices.density
                        Layout.preferredHeight: 42 * Devices.density

                        TAvatar {
                            width: 36 * Devices.density
                            height: 36 * Devices.density
                            remoteUrl: visible? model.users[0].avatar : ""
                            visible: notItem.trickItemMode
                        }

                        TMaterialIcon {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 4 * Devices.density
                            text: {
                                switch (model.notify_type) {
                                case 1:
                                    return MaterialIcons.mdi_thumb_up;
                                case 2:
                                    return MaterialIcons.mdi_account;
                                case 3:
                                    return MaterialIcons.mdi_comment;
                                case 4:
                                    return MaterialIcons.mdi_at;
                                case 5:
                                    return MaterialIcons.mdi_tag;
                                case 6:
                                case 7:
                                    return MaterialIcons.mdi_bitcoin;
                                }
                                return "";
                            }
                            color: {
                                switch (model.notify_type) {
                                case 1:
                                    return Colors.likeColors;
                                case 3:
                                case 4:
                                    return Colors.commentsColor;
                                default:
                                    return Colors.accent;
                                }
                            }
                            font.pixelSize: {
                                switch (model.notify_type) {
                                case 2:
                                case 5:
                                case 6:
                                case 7:
                                    return 14 * Devices.fontDensity
                                default:
                                    return 12 * Devices.fontDensity;
                                }
                            }
                            visible: !notItem.trickItemMode
                        }

                        TMouseArea {
                            anchors.fill: parent
                            onClicked: Viewport.controller.trigger("float:/users", {"userId": model.users[0].id, "title": model.users[0].fullname})
                        }
                    }

                    ColumnLayout {
                        spacing: 4 * Devices.density

                        RowLayout {
                            spacing: 4 * Devices.density
                            visible: !notItem.trickItemMode

                            Repeater {
                                model: AsemanListModel {
                                    data: users
                                }
                                TAvatar {
                                    Layout.preferredWidth: 32 * Devices.density
                                    Layout.preferredHeight: 32 * Devices.density
                                    remoteUrl: model.avatar

                                    TMouseArea {
                                        anchors.fill: parent
                                        onClicked: Viewport.controller.trigger("float:/users", {"userId": model.id, "title": model.fullname})
                                    }
                                }
                            }
                        }

                        RowLayout {
                            spacing: 4 * Devices.density
                            visible: notItem.trickItemMode

                            TLabel {
                                font.bold: true
                                text: notItem.trickItemMode? model.users[0].fullname : ""
                            }

                            TLabel {
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                opacity: 0.7
                                text: notItem.trickItemMode? "@" + model.users[0].username : ""
                            }
                        }

                        RowLayout {
                            spacing: 4 * Devices.density

                            TLabel {
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                text: {
                                    var res = "";
                                    if (!notItem.trickItemMode) {
                                        res += qsTr("<b>%1</b> ").arg(model.users[0].fullname);
                                        if (model.users.length > 1 && (model.count - 1) > 0)
                                            res += qsTr("and %1 others ").arg(model.count - 1);
                                    }

                                    switch (model.notify_type) {
                                    case 1:
                                        res += qsTr("liked your trick.");
                                        break;
                                    case 2:
                                        res += qsTr("followed you.");
                                        break;
                                    case 3:
                                        res += qsTr("posted a comment on your trick.");
                                        break;
                                    case 4:
                                        res += qsTr("mentioned you.");
                                        break;
                                    case 5:
                                        res += qsTr("posted a trick on the %1.").arg(model.tag);
                                        break;
                                    case 6:
                                        res += qsTr("tipped <b>%1SAT</b> your trick.").arg(Math.floor(model.tip_amount/1000));
                                        break;
                                    case 7:
                                        res += qsTr("donated <b>%1SAT</b> you.").arg(Math.floor(model.tip_amount/1000));
                                        break;
                                    }
                                    return res;
                                }
                            }

                            TLabel {
                                opacity: 0.7
                                font.pixelSize: 8 * Devices.fontDensity
                                text: GlobalMethods.dateToString(GlobalMethods.unNormalizeDate(model.datetime))
                            }
                        }

                        TLabel {
                            Layout.topMargin: notItem.trickItemMode? 4 * Devices.density : 0
                            Layout.fillWidth: true
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            horizontalAlignment: TricksTools.directionOf(text) == Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                            text: {
                                if (model.comment)
                                    return model.comment.message;
                                if (model.trick)
                                    return (model.trick.quoted_text? model.trick.quoted_text : model.trick.body);
                                return "";
                            }
                            opacity: notItem.trickItemMode? 1 : 0.7
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            visible: text.length
                        }

                        Loader {
                            Layout.fillWidth: true
                            active: model.notify_type == 3 && model.comment && model.comment.image_size.height > 1
                            visible: active
                            Layout.preferredHeight: model.comment? model.comment.image_size.height * width / model.comment.image_size.width : 1
                            asynchronous: true
                            sourceComponent: Item {
                                anchors.fill: parent

                                TRemoteImage {
                                    id: image
                                    radius: Constants.radius
                                    anchors.fill: parent
                                    remoteUrl: notItem.masterObject.filename
                                }
                            }
                        }

                        Loader {
                            Layout.fillWidth: true
                            Layout.topMargin: notItem.trickItemMode? -8 * Devices.density : 0
                            Layout.preferredHeight: 38 * Devices.density
                            asynchronous: true
                            active: notItem.trickItemMode
                            visible: active
                            sourceComponent: RowLayout {
                                spacing: 0
                                anchors.fill: parent

                                TIconButton {
                                    materialIcon: rateState? MaterialIcons.mdi_thumb_up : MaterialIcons.mdi_thumb_up_outline
                                    materialOpacity: rateReq.refreshing? 0 : 1
                                    materialColor: rateState? Colors.likeColors : Colors.buttonsColor
                                    materialText: notItem.masterObject.rates? notItem.masterObject.rates : ""
                                    onClicked: {
                                        var rate = (rateState? 0 : 1);
                                        GlobalSettings.likedsHash.remove(notItem.masterObject.id);
                                        GlobalSettings.likedsHash.insert(notItem.masterObject.id, rate);

                                        rateState = rate;
                                        rateReq.rate = rate;
                                        rateReq.doRequest();
                                    }

                                    property int rateState: notItem.masterObject? GlobalSettings.likedsHash.count && GlobalSettings.likedsHash.contains(notItem.masterObject.id)? GlobalSettings.likedsHash.value(notItem.masterObject.id) : notItem.masterObject.rate_state : 0

                                    AddRateRequest {
                                        id: rateReq
                                        _id: notItem.masterObject.id
                                        onSuccessfull: {
                                            response.result.forEach(GlobalSignals.trickUpdated)
                                        }
                                    }

                                    TBusyIndicator {
                                        anchors.centerIn: parent
                                        width: 18 * Devices.density
                                        IOSStyle.foreground: IOSStyle.accent
                                        running: rateReq.refreshing
                                    }
                                }
                                TIconButton {
                                    materialIcon: MaterialIcons.mdi_comment_outline
                                    materialColor: Colors.buttonsColor
                                    materialText: notItem.masterObject.comments? notItem.masterObject.comments : ""
                                    onClicked: {
                                        var itemData = Tools.toVariantMap(notItem.masterObject);
                                        itemData["owner"] = Tools.toVariantMap(model.users[0]);
                                        itemData["image_size"] = {
                                            "width": 10,
                                            "height": 0,
                                        };

                                        if (model.tip_amount) {
                                            itemData["owner"] = {
                                                "id": GlobalSettings.userId,
                                                "username": GlobalSettings.username,
                                                "fullname": GlobalSettings.fullname,
                                                "avatar": GlobalSettings.avatar
                                            };
                                        }
                                        if (model.comment) {
                                            itemData["views"] = 0;
                                            itemData["body"] = itemData.message;
                                            itemData["filename"] = "";
                                        }

                                        Viewport.controller.trigger("float:/tricks/add", {"parentId": itemData.id, "itemData": itemData})
                                    }
                                }

                                Item {
                                    Layout.preferredHeight: 1
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                THListSeprator {
                    width: parent.width
                    anchors.bottom: parent.bottom
                }
            }
        }
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        color: mainPageMode? Colors.header : Colors.headerSecondary
        light: true

        TBusyIndicator {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: y
            width: 18 * Devices.density
            height: 18 * Devices.density
            running: MyNotificationsModel.refreshing
            IOSStyle.foreground: mainPageMode? Colors.headerText : Colors.foreground
            Material.accent: mainPageMode? Colors.headerText : Colors.foreground
        }

        TLabel {
            anchors.centerIn: parent
            font.pixelSize: 10 * Devices.fontDensity
            text: qsTr("Notifications") + Translations.refresher
            color: mainPageMode? Colors.headerText : Colors.foreground
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
        visible: !mainPageMode
    }
}
