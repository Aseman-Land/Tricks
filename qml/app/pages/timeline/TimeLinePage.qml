import QtQuick 2.0
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Modern 2.0
import AsemanQml.Models 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import QtGraphicalEffects 1.0
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis

    property alias headerItem: headerItem
    property string keyword
    readonly property bool blurHeader: !Devices.isAndroid

    onKeywordChanged: {
        if (GlobalSettings.homeCurrentTag.length == 0)
            GlobalSettings.homeTabIndex = 1

        if (timeLine.model == tagModel)
            tagModel.keyword = keyword;
        else if (timeLine.model == gmodel)
            gmodel.keyword = keyword;
    }
    Component.onCompleted: refresh()

    function refresh() {
        if (GlobalSettings.homeCurrentTag.length)
            return;

        switch (GlobalSettings.homeTabIndex) {
        case 0:
            tmodel.refresh();
            break;
        case 1:
            gmodel.refresh();
            break;
        }
    }

    function doLogout() {
        logoutReq.doRequest();
    }

    function positionViewAtBeginning() {
        timeLine.listView.positionViewAtBeginning();
        if (searchField.visible) {
            searchField.focus = true;
            searchField.forceActiveFocus();
        }
    }

    Connections {
        target: GlobalSignals
        function onRetrickRequest(trick) {
            if (GlobalSettings.viewMode == 2 || Viewport.viewport.count > 0)
                Viewport.controller.trigger("float:/tricks/add", {"quote": trick});
        }
    }

    Rectangle {
        id: timeLineScene
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: Colors.background

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            y: headerItem.y + Devices.statusBarHeight
            height: headerItem.height
            color: Colors.header
            visible: blurHeader
        }

        TimeLine {
            id: timeLine
            anchors.fill: parent
            visible: tabBar.currentIndex == 0 || !tabBar.visible
            model: {
                if (GlobalSettings.homeCurrentTag.length)
                    return tagModel;

                switch (GlobalSettings.homeTabIndex) {
                case 0:
                    return tmodel;
                case 1:
                    return gmodel;
                }
                return tmodel;
            }
            unreadsCount: {
                if (model == tmodel)
                    return tmodel.unreadCount;
                return 0;
            }
            onModelChanged: {
                if (timeLine.model == tagModel)
                    tagModel.keyword = keyword;
                else if (timeLine.model == gmodel)
                    gmodel.keyword = keyword;

                Tools.jsDelayCall(10, dis.refresh)
            }
            topMargin: headerItem.height + (tabBar.visible? tabBar.height : 0)
        }
    }

    FindUserView {
        id: findUser
        anchors.fill: timeLineScene
        visible: tabBar.currentIndex == 1 && tabBar.visible
        listView.header: Item {
            height: headerItem.height + (tabBar.visible? tabBar.height : 0)
            width: timeLine.listView.width
        }
        model: FindUsersModel {
            id: findUsersModel
            keyword: dis.keyword
        }
    }

    GlobalTimelineModel {
        id: gmodel
        active: timeLine.model == gmodel
    }

    TimelineModel {
        id: tmodel
        active: timeLine.model == tmodel
    }

    TagTricksModel {
        id: tagModel
        tag: GlobalMethods.fixAddressProperties( GlobalSettings.homeCurrentTag )
        onTagChanged: {
            if (tag.length == 0)
                return;

            updateReq.tags = [tag];
            updateReq.doRequest();
            timeLine.listView.positionViewAtBeginning();
        }

        UpdateTagViews {
            id: updateReq
            onSuccessfull: GlobalSignals.tagReaded(tags[0]);
        }
    }

    LogoutRequest {
        id: logoutReq
        allowGlobalBusy: true
        onServerError: doLogout()
        onClientError: doLogout()
        onSuccessfull: doLogout()

        function doLogout() {
            GlobalSettings.userId = 0;
            GlobalSettings.username = "";
            GlobalSettings.fullname = "";
            GlobalSettings.avatar = "";
            GlobalSettings.about = "";
            GlobalSettings.accessToken = "";
            GlobalSettings.userInviteCode = "";
            GlobalSettings.notificationAsked = false;
            GlobalSettings.allowNotifications = false;

            Tools.deleteFile(Constants.cacheCodeFrames);
            Tools.deleteFile(Constants.cacheHighlighters);
            Tools.deleteFile(Constants.cacheNotifications);
            Tools.deleteFile(Constants.cacheBookmarks);
            Tools.deleteFile(Constants.cacheMyTags);
            Tools.deleteFile(Constants.cacheMyTricks);
            Tools.deleteFile(Constants.cacheProgrammingLanguages);
            Tools.deleteFile(Constants.cacheTags);
            Tools.deleteFile(Constants.cacheTimeline);
            Tools.deleteFile(Constants.cacheGlobal);
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: tabBar.visible? tabBar.bottom : headerScene.bottom
        anchors.bottomMargin: -headerItem.y - Devices.statusBarHeight
        color: blurHeader? "transparent" : Colors.background
        clip: true

        FastBlur {
            source: timeLineScene
            radius: blurHeader? 64 : 0
            cached: true
            transparentBorder: false
            width: timeLineScene.width
            height: timeLineScene.height
            visible: blurHeader
        }
    }

    TTabBar {
        id: tabBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerScene.bottom
        visible: GlobalSettings.homeTabIndex == 1

        TTabButton {
            text: qsTr("Tricks") + Translations.refresher
        }
        TTabButton {
            text: qsTr("Users") + Translations.refresher
        }
    }

    Item {
        id: headerScene
        y: Devices.statusBarHeight
        height: headerItem.height - Devices.statusBarHeight
        anchors.left: parent.left
        anchors.right: parent.right
        clip: true

        THeader {
            id: headerItem
            y: (timeLine.headerVisible || GlobalSettings.viewMode != 2 || findUser.visible? 0 : -Devices.standardTitleBarHeight + 1) - Devices.statusBarHeight
            anchors.left: parent.left
            anchors.right: parent.right
            height: GlobalSettings.viewMode == 2? defaultHeight : 42 * Devices.density
            light: true
            color: Qt.rgba(Colors.header.r, Colors.header.g, Colors.header.b, (blurHeader? 0.7 : 1))

            Behavior on y {
                NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
            }

            ColumnLayout {
                id: headerTitle
                anchors.centerIn: parent
                visible: !searchField.visible
                spacing: -2 * Devices.density

                TLabel {
                    Layout.alignment: Qt.AlignHCenter
                    font.pixelSize: 10 * Devices.fontDensity
                    visible: text.length
                    text: {
                        if (GlobalSettings.homeCurrentTag.length)
                            return GlobalSettings.homeCurrentTag;

                        switch (GlobalSettings.homeTabIndex) {
                        case 0:
                            return qsTr("Home") + Translations.refresher;
                        case 1:
                            return qsTr("Global") + Translations.refresher;
                        case 2:
                            return GlobalSettings.fullname;
                        }
                        return Bootstrap.title;
                    }
                    color: Colors.headerText
                }

                CommunityCombo {
                    id: comCombo
                    Layout.alignment: Qt.AlignHCenter
                    comboWidth: headerItem.width * 0.5

                    Connections {
                        target: GlobalSignals
                        function onCommunityChooseRequest() {
                            comCombo.show();
                        }
                    }
                }
            }

            TSearchField {
                id: searchField
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 6 * Devices.density
                height: 38 * Devices.density
                visible: GlobalSettings.homeTabIndex == 1 && GlobalSettings.viewMode == 2
                onSearchRequest: dis.keyword = GlobalMethods.fixUrlProperties(keyword)
                IOSStyle.theme: Colors.headerIsDark? IOSStyle.Dark : IOSStyle.Light
                Material.theme: Colors.headerIsDark? Material.Dark : Material.Light
            }

            TAvatar {
                height: 24 * Devices.density
                width: height
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 14 * Devices.density
                visible: GlobalSettings.homeTabIndex == 0 && GlobalSettings.viewMode == 2
                remoteUrl: GlobalSettings.avatar

                TMouseArea {
                    anchors.fill: parent
                    onClicked: Viewport.controller.trigger("float:/users/me")
                }
            }

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: GlobalSettings.homeCurrentTag.length && GlobalSettings.viewMode != 2? 0 : (searchField.visible? 50 * Devices.density : 10 * Devices.density)
                spacing: 10 * Devices.density

                TBusyIndicator {
                    Layout.preferredWidth: 18 * Devices.density
                    Layout.preferredHeight: 18 * Devices.density
                    running: timeLine.model.refreshing || findUsersModel.refreshing
                    IOSStyle.foreground: Colors.headerText
                    Material.accent: Colors.headerText
                }

                RowLayout {
                    spacing: 0

                    TIconButton {
                        id: bookmarksBtn
                        Layout.preferredHeight: 40 * Devices.density
                        Layout.preferredWidth: 30 * Devices.density
                        visible: GlobalSettings.homeTabIndex == 0
                        materialIcon: MaterialIcons.mdi_star_outline
                        flat: true
                        materialColor: Colors.headerText
                        onClicked: Viewport.controller.trigger("float:/bookmarks");
                    }

                    TIconButton {
                        id: editBtn
                        Layout.preferredHeight: 40 * Devices.density
                        Layout.preferredWidth: 30 * Devices.density
                        visible: GlobalSettings.homeTabIndex == 0
                        materialIcon: MaterialIcons.mdi_dots_vertical
                        flat: true
                        materialColor: Colors.headerText
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

                TFollowButton {
                    Layout.rightMargin: 2 * Devices.density
                    Layout.preferredWidth: refreshing? 40 :90 * Devices.density
                    visible: GlobalSettings.homeCurrentTag.length
                    highlighted: !Colors.lightHeader
                    IOSStyle.background: Colors.lightHeader? Colors.background : IOSStyle.accent

                    followed: GlobalSettings.followedTags.count && GlobalSettings.followedTags.contains(GlobalSettings.homeCurrentTag)

                    followReq: FollowTagRequest {
                        tag: GlobalSettings.homeCurrentTag
                        onSuccessfull: {
                            GlobalSettings.followedTags.insert(tag, true);
                            GlobalSignals.tagsRefreshed();
                        }
                    }
                    unfollowReq: UnfollowTagRequest {
                        _tag: GlobalSettings.homeCurrentTag
                        onSuccessfull: {
                            GlobalSettings.followedTags.remove(_tag);
                            GlobalSignals.tagsRefreshed();
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        color: headerItem.color
        height: Devices.statusBarHeight
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
                switch (index) {
                case 0:
                    Viewport.controller.trigger("float:/settings");
                    ViewportType.open = false;
                    break;

                case 1:
                    Viewport.controller.trigger("float:/about");
                    ViewportType.open = false;
                    break;

                case 2:
                    var args = {
                        "title": qsTr("Warning"),
                        "body" : qsTr("Do you realy want to logout?") ,
                        "buttons": [qsTr("Yes"), qsTr("No")]
                    };
                    var obj = Viewport.controller.trigger("dialog:/general/warning", args);
                    obj.itemClicked.connect(function(idx, title){
                        switch (idx) {
                        case 0: // Yes
                            doLogout();
                            break;
                        case 1: // No
                            break;
                        }
                        obj.ViewportType.open = false;
                        ViewportType.open = false;
                    });
                    break;
                }
            }

            model: AsemanListModel {
                data: [
                    {
                        title: qsTr("Settings"),
                        icon: "mdi_settings",
                        enabled: true
                    },
                    {
                        title: qsTr("About Tricks"),
                        icon: "mdi_information",
                        enabled: true
                    },
                    {
                        title: qsTr("Logout"),
                        icon: "mdi_logout",
                        enabled: true
                    },
                ]
            }
        }
    }
}
