import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Models 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.IOSStyle 2.3
import QtQuick.Layouts 1.3
import "../profile" as Profile
import Tricks 1.0
import models 1.0
import components 1.0
import requests 1.0
import globals 1.0

Item {
    id: dis
    height: defaultHeight
    property alias color: background.color
    property alias background: background

    property real topMargin: 0
    readonly property real defaultHeight: headerRow.height + Constants.margins + 8 * Devices.density
    property int userId
    property alias loaded: headerRow.visible
    property alias avatar: avatar.remoteUrl
    property string cover
    property alias fullname: fullname.text
    property alias username: username.text
    property alias isFollower: isFollower.visible
    property string about
    property alias tricksCount: tricksCount.text
    property alias followingsCount: followingsCount.text
    property alias followersCount: followersCount.text
    property alias tagsModel: tagsList.model
    property alias tagsList: tagsList
    property alias followBtn: followBtn
    property variant joinDate: new Date
    property string newAvatarPath
    property string newCoverPath
    property int ownerRole
    property string selectedTag

    property int imageSelectMode: 0

    onOwnerRoleChanged: {
        if (ownerRole & 1) {
            roleIcon.text = MaterialIcons.mdi_check_decagram
        }
    }

    Connections {
        target: Devices
        function onSelectImageResult(path) {
            let p = Devices.localFilesPrePath + path;
            let size = Tools.imageSize(p);
            let ratio = size.width / size.height;

            let img = Constants.cachePath + "/" + Tools.createUuid() + ".jpg";

            switch (imageSelectMode) {
            case 0: // avatar
                Tools.imageResize(p, Qt.size(512, 512/ratio), img, function(){
                    newAvatarPath = Devices.localFilesPrePath + img;
                    Viewport.viewport.append(avatar_dialog_component, {"source": newAvatarPath}, "dialog");
                });
                break;
            case 1: // cover
                Tools.imageResize(p, (ratio>1? Qt.size(1280, 1280/ratio) : Qt.size(1280*ratio, 1280)), img, function(){
                    newCoverPath = Devices.localFilesPrePath + img;
                    Viewport.viewport.append(cover_dialog_component, {"source": newCoverPath}, "dialog");
                });
                break;
            }
        }
    }

    EditAvatarRequest {
        id: editAvatarReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSettings.waitCount++;
            Tools.jsDelayCall(Constants.refreshDelay, function(){
                GlobalSignals.reloadMeRequest();
                GlobalSignals.refreshRequest();
                GlobalSignals.snackRequest(qsTr("Avatar updated"));
                newAvatarPath = "";
                GlobalSettings.waitCount--;
            });
        }
    }

    DeleteAvatarRequest {
        id: deleteAvatarReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSettings.waitCount++;
            Tools.jsDelayCall(Constants.refreshDelay, function(){
                GlobalSignals.reloadMeRequest();
                GlobalSignals.refreshRequest();
                GlobalSignals.snackRequest(qsTr("Avatar removed"));
                newAvatarPath = "";
                GlobalSettings.waitCount--;
            });
        }
    }

    function chooseAvatar() {
        AsemanApp.requestPermissions(["android.permission.READ_EXTERNAL_STORAGE"],
                                     function(res) {
            if(res["android.permission.READ_EXTERNAL_STORAGE"] == true) {
                imageSelectMode = 0;
                GlobalSettings.lastImageRequestId = Tools.createUuid();
                Devices.getOpenPictures();
            }
        });
    }

    function deleteAvatar() {
        var args = {
            "title": qsTr("Warning"),
            "body" : qsTr("Do you realy want to your avatar?") ,
            "buttons": [qsTr("Yes"), qsTr("No")]
        };
        var obj = Viewport.controller.trigger("dialog:/general/warning", args);
        obj.itemClicked.connect(function(idx, title){
            switch (idx) {
            case 0: // Yes
                deleteAvatarReq.doRequest();
                break;
            case 1: // No
                break;
            }
            obj.ViewportType.open = false;
        });
    }

    EditCoverRequest {
        id: editCoverReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSettings.waitCount++;
            Tools.jsDelayCall(Constants.refreshDelay, function(){
                GlobalSignals.reloadMeRequest();
                GlobalSignals.refreshRequest();
                GlobalSignals.snackRequest(qsTr("Cover updated"));
                newCoverPath = "";
                GlobalSettings.waitCount--;
            });
        }
    }

    DeleteCoverRequest {
        id: deleteCoverReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSettings.waitCount++;
            Tools.jsDelayCall(Constants.refreshDelay, function(){
                GlobalSignals.reloadMeRequest();
                GlobalSignals.refreshRequest();
                GlobalSignals.snackRequest(qsTr("Cover removed"));
                newCoverPath = "";
                GlobalSettings.waitCount--;
            });
        }
    }

    function chooseCover() {
        AsemanApp.requestPermissions(["android.permission.READ_EXTERNAL_STORAGE"],
                                     function(res) {
            if(res["android.permission.READ_EXTERNAL_STORAGE"] == true) {
                imageSelectMode = 1;
                GlobalSettings.lastImageRequestId = Tools.createUuid();
                Devices.getOpenPictures();
            }
        });
    }

    function deleteCover() {
        var args = {
            "title": qsTr("Warning"),
            "body" : qsTr("Do you realy want to delete your cover?") ,
            "buttons": [qsTr("Yes"), qsTr("No")]
        };
        var obj = Viewport.controller.trigger("dialog:/general/warning", args);
        obj.itemClicked.connect(function(idx, title){
            switch (idx) {
            case 0: // Yes
                deleteCoverReq.doRequest();
                break;
            case 1: // No
                break;
            }
            obj.ViewportType.open = false;
        });
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.bottomMargin: tagsList.height + 16 * Devices.density
        color: "transparent"
    }

    ColumnLayout {
        id: headerRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Constants.margins
        anchors.topMargin: topMargin + Constants.margins
        spacing: 0

        GridLayout {
            columnSpacing: Constants.spacing
            rowSpacing: 4 * Devices.density
            columns: 2

            TAvatar {
                id: avatar
                Layout.preferredWidth: 64 * Devices.density
                Layout.preferredHeight: 64 * Devices.density
                avatarColor: Colors.lightHeader? Colors.accent : "#222"

                TBusyIndicator {
                    anchors.centerIn: parent
                    running: editAvatarReq.refreshing
                    width: 32 * Devices.density
                }

                TMouseArea {
                    id: avatarBtn
                    anchors.fill: parent
                    visible: dis.userId == GlobalSettings.userId
                    onClicked: {
                        var pos = Qt.point(dis.LayoutMirroring.enabled? avatarBtn.width - Constants.radius : Constants.radius, avatarBtn.height);
                        var parent = avatarBtn;
                        while (parent && parent != Viewport.viewport) {
                            pos.x += parent.x;
                            pos.y += parent.y;
                            parent = parent.parent;
                        }

                        Viewport.viewport.append(menuComponent, {"pointPad": pos}, "menu");
                    }
                }
            }

            RowLayout {
                spacing: 4 * Devices.density

                ColumnLayout {
                    spacing: 4 * Devices.density

                    RowLayout {
                        spacing: 4 * Devices.density

                        TLabel {
                            id: fullname
                            font.pixelSize: 12 * Devices.fontDensity
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }

                        TMaterialIcon {
                            id: roleIcon
                            font.pixelSize: 9 * Devices.fontDensity
                            visible: text.length
                        }
                    }

                    RowLayout {
                        TLabel {
                            id: username
                            opacity: 0.7
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            maximumLineCount: 1
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            id: isFollower
                            Layout.preferredWidth: followsYou.width + 8 * Devices.density
                            Layout.preferredHeight: followsYou.height + 8 * Devices.density
                            radius: 4 * Devices.density
                            color: Colors.backgroundDeep

                            TLabel {
                                id: followsYou
                                anchors.centerIn: parent
                                text: qsTr("Follows you") + Translations.refresher
                                font.pixelSize: 7 * Devices.fontDensity
                                color: Colors.accent
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                        }
                    }

                    TLabel {
                        id: joined
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("Joined %1").arg(CalendarConv.convertDateTimeToString(joinDate, "MMMM yyyy")) + Translations.refresher
                    }
                }

                TFollowButton {
                    id: followBtn
                    Layout.preferredWidth: refreshing? 40 : 90 * Devices.density
                    visible: false
                }
            }

            Item {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 1
            }

            ColumnLayout {
                spacing: 4 * Devices.density

                TLabel {
                    id: aboutLabel
                    Layout.fillWidth: true
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    visible: text.length
                    linkColor: Colors.darkAccent
                    onLinkActivated: Qt.openUrlExternally(link)
                    textFormat: Text.StyledText
                    horizontalAlignment: TricksTools.directionOf(text) == Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                    text: {
                        var res = about;
                        var links = TricksTools.stringLinks(res);
                        links.forEach(function(l){
                            var link = l.link;
                            res = Tools.stringReplace(res, link, "<a href='" + l.fixed + "'>" + link + "</a>");
                        });
                        return res;
                    }
                }

                GridLayout {
                    columnSpacing: 20 * Devices.density
                    Layout.topMargin: 8 * Devices.density
                    columns: {
                        if (width > 300 * Devices.density)
                            return 4;
                        if (width > 200 * Devices.density)
                            return 2;
                        return 1;
                    }

                    Item {
                        Layout.preferredWidth: followingsRow.width
                        Layout.preferredHeight: followingsRow.height

                        TItemDelegate {
                            anchors.fill: parent
                            anchors.margins: -6 * Devices.density
                            onClicked: Viewport.controller.trigger("float:/users/followings", {"userId": dis.userId, "fullname": fullname.text})
                        }

                        RowLayout {
                            id: followingsRow
                            anchors.centerIn: parent
                            spacing: 4 * Devices.density

                            TLabel {
                                id: followingsCount
                                font.pixelSize: 12 * Devices.fontDensity
                            }

                            TLabel {
                                Layout.alignment: Qt.AlignBottom
                                text: qsTr("Followings") + Translations.refresher
                                opacity: 0.7
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: followersRow.width
                        Layout.preferredHeight: followersRow.height

                        TItemDelegate {
                            anchors.fill: parent
                            anchors.margins: -6 * Devices.density
                            onClicked: Viewport.controller.trigger("float:/users/followers", {"userId": dis.userId, "fullname": fullname.text})
                        }

                        RowLayout {
                            id: followersRow
                            anchors.centerIn: parent
                            spacing: 4 * Devices.density

                            TLabel {
                                id: followersCount
                                font.pixelSize: 12 * Devices.fontDensity
                            }

                            TLabel {
                                Layout.alignment: Qt.AlignBottom
                                text: qsTr("Followers") + Translations.refresher
                                opacity: 0.7
                            }
                        }
                    }

                    RowLayout {
                        spacing: 4 * Devices.density

                        TLabel {
                            id: tricksCount
                            font.pixelSize: 12 * Devices.fontDensity
                        }

                        TLabel {
                            Layout.alignment: Qt.AlignBottom
                            text: qsTr("Tricks") + Translations.refresher
                            opacity: 0.7
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }
                }
            }

        }

        RowLayout {
            Layout.topMargin: 8 * Devices.density + Constants.margins

            TLabel {
                text: qsTr("Top Tags:") + Translations.refresher
                font.bold: true
                color: Colors.foreground
            }

            TListView {
                id: tagsList
                spacing: 4 * Devices.density
                Layout.fillWidth: true
                Layout.preferredHeight: 26 * Devices.density
                orientation: ListView.Horizontal
                clip: true

                header: Item {
                    width: tagItem.width + tagsList.spacing
                    height: tagItem.height

                    TagListItem {
                        id: tagItem
                        anchors.left: parent.left
                        height: tagsList.height
                        tag: qsTr("All") + Translations.refresher
                        count: dis.tricksCount
                        selected: selectedTag.length == 0
                        onClicked: selectedTag = ""
                    }
                }

                delegate: TagListItem {
                    height: tagsList.height
                    tag: model.tag
                    count: model.count
                    selected: selectedTag == tag
                    onClicked: selectedTag = tag // Viewport.controller.trigger("float:/tag", {"tag": tagItem.tag, "userId": dis.userId})
                }
            }
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
            x: pointPad.x
            y: pointPad.y
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = 0;
                var x = dis.LayoutMirroring.enabled? width : 0;
                return Qt.point(x, y);
            }

            property point pointPad
            property int index

            onItemClicked: {
                switch (index) {
                case 0:
                    chooseAvatar();
                    break;
                case 1:
                    deleteAvatar();
                    break;
                }

                ViewportType.open = false;
            }

            model: AsemanListModel {
                data: [
                    {
                        title: qsTr("Edit Avatar"),
                        icon: "mdi_pen",
                        enabled: true
                    },
                    {
                        title: qsTr("Delete Avatar"),
                        icon: "mdi_delete",
                        enabled: true
                    }
                ]
            }
        }
    }

    Component {
        id: avatar_dialog_component
        Profile.EditAvatarDialog {
            id: dlg
            ratio: 1
            title: qsTr("Avatar")
            onItemClicked: {
                switch (index) {
                case 0:
                    editAvatarReq.avatar = newAvatarPath;
                    editAvatarReq.doRequest();
                    break;
                case 1:
                    newAvatarPath = "";
                    break;
                }

                dlg.ViewportType.open = false;
            }
        }
    }

    Component {
        id: cover_dialog_component
        Profile.EditAvatarDialog {
            id: dlg
            ratio: 16 / 9
            title: qsTr("Cover")
            onItemClicked: {
                switch (index) {
                case 0:
                    editCoverReq.cover = newCoverPath;
                    editCoverReq.doRequest();
                    break;
                case 1:
                    newCoverPath = "";
                    break;
                }

                dlg.ViewportType.open = false;
            }
        }
    }
}
