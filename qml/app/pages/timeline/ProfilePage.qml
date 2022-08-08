import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Models 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.3
import QtQuick.Controls.Material 2.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: GlobalSettings.viewMode != 2? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    property alias userId: userReq._userId
    property alias headerItem: headerItem
    property alias profileHeader: profileHeader
    property alias headerText: headerText
    property alias timeLine: timeLine
    property alias tagName: umodel.tagName

    Connections {
        target: GlobalSignals
        function onRefreshRequest() {
            userReq.doRequest();
        }
    }

    BlockUserRequest {
        id: blockReq
        allowGlobalBusy: true
        user_id: dis.userId
        onSuccessfull: {
            GlobalSignals.snackRequest(qsTr("User blocked"));
            GlobalSignals.refreshRequest();
        }
    }

    UnblockUserRequest {
        id: unblockReq
        allowGlobalBusy: true
        _userId: dis.userId
        onSuccessfull: {
            GlobalSignals.snackRequest(qsTr("User unblocked"));
            GlobalSignals.refreshRequest();
        }
    }

    MuteUserRequest {
        id: muteReq
        allowGlobalBusy: true
        user_id: dis.userId
        onSuccessfull: {
            GlobalSignals.snackRequest(qsTr("User muted"));
            GlobalSignals.refreshRequest();
        }
    }

    UnmuteUserRequest {
        id: unmuteReq
        allowGlobalBusy: true
        _userId: dis.userId
        onSuccessfull: {
            GlobalSignals.snackRequest(qsTr("User unmuted"));
            GlobalSignals.refreshRequest();
        }
    }

    GetUserRequest {
        id: userReq
        _userId: dis.userId
        on_UserIdChanged: Tools.jsDelayCall(10, doRequest)
        onSuccessfull: {
            umodel.userId = _userId;
            umodel.refresh();
            dis.title = response.result.fullname;
            lastValidResult = response.result;
        }

        property variant lastValidResult
    }

    Rectangle {
        id: backgroundArea
        anchors.left: parent.left
        anchors.right: parent.right
        height: headerItem.height + profileHeader.background.height
        clip: true
        color: Colors.primary

        TRemoteImage {
            remoteUrl: profileHeader.cover
            asynchronous: true
            fillMode: Image.PreserveAspectCrop
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: backgroundArea.height
            scale: Math.max(1, backgroundArea.height/height)

            Rectangle {
                anchors.fill: parent
                color: "#000000"
                opacity: 0.4 - (backgroundArea.height/height) * 0.2
            }
        }
    }

    PointMapListener {
        id: mapListener
        source: profileHeader.background
        dest: dis
        y: profileHeader.background.height

        onResultChanged: {
            backgroundArea.height = Math.max(headerItem.height, mapListener.result.y);
        }
    }

    ProfileHeader {
        id: profileHeader
        parent: timeLine.listView.headerItem
        width: timeLine.listView.width
        loaded: userReq.lastValidResult? true : false
        avatar: userReq.lastValidResult? userReq.lastValidResult.avatar : ""
        cover: userReq.lastValidResult? userReq.lastValidResult.cover : ""
        fullname: userReq.lastValidResult? userReq.lastValidResult.fullname : ""
        username: userReq.lastValidResult? "@" + userReq.lastValidResult.username : ""
        isFollower: userReq.lastValidResult? userReq.lastValidResult.is_follower : false
        ownerRole: userReq.lastValidResult? userReq.lastValidResult.details.role : 0;
        about: userReq.lastValidResult? userReq.lastValidResult.about : ""
        tricksCount: userReq.lastValidResult? userReq.lastValidResult.tricks_count : ""
        joinDate: userReq.lastValidResult? GlobalMethods.unNormalizeDate(userReq.lastValidResult.join_date) : new Date
        followingsCount: userReq.lastValidResult? userReq.lastValidResult.followings_count : ""
        followersCount: userReq.lastValidResult? userReq.lastValidResult.followers_count : ""
        userId: dis.userId
        tagsModel: TagsModel {
            limit: 5
            user: dis.userId
        }
        onSelectedTagChanged: umodel.tagName = GlobalMethods.fixUrlProperties(selectedTag)
        followBtn {
            visible: userReq.lastValidResult && dis.userId != GlobalSettings.userId? true : false
            followed: userReq.lastValidResult? userReq.lastValidResult.is_followed : false
            followReq: FollowUserRequest {
                user_id: dis.userId
                onSuccessfull: {
                    userReq.doRequest();
                }
            }
            unfollowReq: UnfollowUserRequest {
                _userId: dis.userId
                onSuccessfull: {
                    userReq.doRequest();
                }
            }
        }

        IOSStyle.theme: Colors.headerIsDark || cover.length != 0? IOSStyle.Dark : IOSStyle.Light
        Material.theme: Colors.headerIsDark || cover.length != 0? Material.Dark : Material.Light
        color: cover.length? "transparent" : Colors.header
    }

    TimeLine {
        id: timeLine
        anchors.top: headerItem.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        extraRefresher: userReq.refreshing
        muted: userReq.response != null && userReq.response.result.muted
        blocked: userReq.response != null && userReq.response.result.blocked
        blockedYou: userReq.response != null && userReq.response.result.blocked_you
        suspended: userReq.response != null && userReq.response.result.suspended
        model: UserTricksModel {
            id: umodel
        }

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Constants.margins
            visible: timeLine.blocked || timeLine.blockedYou

            TLabel {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: 8 * Devices.fontDensity
                color: Colors.accent
                text: timeLine.blockedYou? qsTr("The user blocked you") : qsTr("The user is blocked") + Translations.refresher
            }

            TButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 90 * Devices.density
                highlighted: true
                text: qsTr("Unblock") + Translations.refresher
                visible: timeLine.blocked
                onClicked: unblockReq.doRequest()
            }
        }

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: Constants.margins
            visible: timeLine.suspended

            TLabel {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.pixelSize: 8 * Devices.fontDensity
                color: Colors.accent
                text: qsTr("This account is suspended. Are you sure you want to see tricks?") + Translations.refresher
            }

            TButton {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 90 * Devices.density
                highlighted: true
                text: qsTr("View Tricks") + Translations.refresher
                onClicked: timeLine.suspended = false
            }
        }

        header: Item {
            width: profileHeader.width
            height: profileHeader.height
            property color color: profileHeader.color
        }
    }

    THeader {
        id: headerItem
        anchors.left: parent.left
        anchors.right: parent.right
        color: profileHeader.cover.length? "transparent" : Colors.header
        shadowOpacity: 0

        TLabel {
            id: headerText
            anchors.centerIn: parent
            font.pixelSize: 10 * Devices.fontDensity
            text: dis.title
            color: profileHeader.cover.length? "#fff" : Colors.headerText
        }

        TBusyIndicator {
            anchors.right: muteIcon.visible? muteIcon.left : editBtn.visible? editBtn.left : parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: editBtn.visible && !muteIcon.visible? 0 : y
            width: 18 * Devices.density
            height: 18 * Devices.density
            running: umodel.refreshing || userReq.refreshing
            IOSStyle.foreground: headerText.color
            Material.accent: headerText.color
        }

        TMaterialIcon {
            id: muteIcon
            anchors.verticalCenter: editBtn.verticalCenter
            anchors.right: editBtn.left
            font.pixelSize: 11 * Devices.fontDensity
            text: MaterialIcons.mdi_volume_mute
            color: headerText.color
            visible: timeLine.muted
        }

        TIconButton {
            id: editBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10 * Devices.density
            width: 40 * Devices.density
            materialIcon: MaterialIcons.mdi_dots_vertical
            IOSStyle.background: Qt.darker(Colors.headerSecondary, (Colors.darkMode? 0.5 : 1.1))
            materialColor: headerText.color
            onClicked: {
                var pos = Qt.point(dis.LayoutMirroring.enabled? Constants.radius : editBtn.width - Constants.radius, editBtn.height);
                var parent = editBtn;
                while (parent && parent != Viewport.viewport) {
                    pos.x += parent.x;
                    pos.y += parent.y;
                    parent = parent.parent;
                }

                Viewport.viewport.append(menuComponent, {"pointPad": pos}, "menu");
            }
        }
    }

    Component {
        id: menuComponent
        MenuView {
            id: menuItem
            x: pointPad.x - width
            y: pointPad.y
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = 0;
                var x = dis.LayoutMirroring.enabled? 0 : width;
                return Qt.point(x, y);
            }

            property point pointPad
            property int index

            onItemClicked: {
                if (dis.userId != GlobalSettings.userId) {
                    switch (index) {
                    case 0:
                        Viewport.controller.trigger("float:/users/report", {"userId": dis.userId, "title": dis.title});
                        ViewportType.open = false;
                        break;
                    case 1:
                        if (timeLine.muted)
                            unmuteReq.doRequest();
                        else
                            muteReq.doRequest();
                        ViewportType.open = false;
                        break;

                    case 2:
                        if (timeLine.blocked)
                            unblockReq.doRequest();
                        else
                            blockReq.doRequest();
                        ViewportType.open = false;
                        break;
                    }
                } else {
                    switch (index) {
                    case 0:
                        Viewport.controller.trigger("float:/profile/edit");
                        break;
                    case 1:
                        profileHeader.chooseAvatar();
                        break;
                    case 2:
                        profileHeader.deleteAvatar();
                        break;
                    case 3:
                        profileHeader.chooseCover();
                        break;
                    case 4:
                        profileHeader.deleteCover();
                        break;
                    }
                    ViewportType.open = false;
                }
            }

            model: AsemanListModel {
                data: {
                    if (dis.userId != GlobalSettings.userId) {
                        return [
                            {
                                title: qsTr("Report"),
                                icon: "mdi_pen",
                                enabled: true
                            },
                            {
                                title: timeLine.muted? qsTr("Unmute") : qsTr("Mute"),
                                icon: "mdi_volume_mute",
                                enabled: true
                            },
                            {
                                title: timeLine.blocked? qsTr("Unblock") : qsTr("Block"),
                                icon: "mdi_do_not_disturb",
                                enabled: true
                            },
                        ];
                    } else {
                        return [
                            {
                                title: qsTr("Edit Profile"),
                                icon: "mdi_account_edit",
                                enabled: true
                            },
                            {
                                title: qsTr("Edit Avatar"),
                                icon: "mdi_pen",
                                enabled: true
                            },
                            {
                                title: qsTr("Delete Avatar"),
                                icon: "mdi_delete",
                                enabled: true
                            },
                            {
                                title: qsTr("Edit Cover"),
                                icon: "mdi_pen",
                                enabled: true
                            },
                            {
                                title: qsTr("Delete Cover"),
                                icon: "mdi_delete",
                                enabled: true
                            }
                        ];
                    }
                }
            }
        }
    }

    THeaderBackButton {
        color: headerText.color
        onClicked: dis.ViewportType.open = false
    }
}
