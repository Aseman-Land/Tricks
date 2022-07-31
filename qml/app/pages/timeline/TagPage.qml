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

    property string tag
    property alias userId: umodel.userId
    property alias unreadsCount: tl.unreadsCount

    onUserIdChanged: Tools.jsDelayCall(10, umodel.refresh)

    UpdateTagViews {
        id: updateReq
        tags: [tag]
        onSuccessfull: GlobalSignals.tagReaded(tag);
        Component.onCompleted: Tools.jsDelayCall(100, update)

        function update() {
            if (dis.userId)
                return;

            doRequest();
        }
    }

    GlobalTimelineModel {
        id: tagSearchModel
        tag_name: GlobalMethods.fixUrlProperties(dis.tag)
    }

    TagTricksModel {
        id: tmodel
        tag: GlobalMethods.fixAddressProperties(dis.tag)
    }

    UserTricksModel {
        id:umodel
        tagName: GlobalMethods.fixUrlProperties(dis.tag)
        blockAutoRefresh: true
    }

    TimeLine {
        id: tl
        anchors.top: searchFieldRect.visible? searchFieldRect.bottom : header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: tagSearchModel.keyword.length? tagSearchModel : (dis.userId? umodel : tmodel)
    }

    Item {
        id: searchFieldRect
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Devices.standardTitleBarHeight
        visible: dis.userId == 0

        TSearchField {
            id: searchField
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 6 * Devices.density
            height: 42 * Devices.density
            visible: !dis.userId
            onSearchRequest: tagSearchModel.keyword = GlobalMethods.fixUrlProperties(keyword)
        }
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        text: dis.tag

        TBusyIndicator {
            anchors.right: followBtn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: y
            width: 18 * Devices.density
            height: 18 * Devices.density
            running: tmodel.refreshing || tagSearchModel.refreshing
        }

        TFollowButton {
            id: followBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10 * Devices.density
            width: refreshing? 40 :90 * Devices.density

            followed: GlobalSettings.followedTags.count && GlobalSettings.followedTags.contains(dis.tag)

            followReq: FollowTagRequest {
                tag: dis.tag
                onSuccessfull: {
                    GlobalSettings.followedTags.insert(tag, true);
                    GlobalSignals.tagsRefreshed();
                }
            }
            unfollowReq: UnfollowTagRequest {
                _tag: dis.tag
                onSuccessfull: {
                    GlobalSettings.followedTags.remove(_tag);
                    GlobalSignals.tagsRefreshed();
                }
            }
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
