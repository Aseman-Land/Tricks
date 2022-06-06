import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Modern 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import components 1.0
import globals 1.0
import requests 1.0
import models 1.0

import "pages/timeline"
import "pages/add-trick"
import "pages/tags" as Tags
import "pages/notifications" as Notification
import "parts"

TPage {
    id: home

    property bool agreementAccepted: false
    property bool agreementRejected: false
    property Item agreementItem
    property Item logoutWarnItem
    property Item introTagDialog
    property Item introAskNotifications

    onIntroTagDialogChanged: {
        if (introTagDialog)
            return;

        GlobalSignals.refreshRequest();
        introCycle();
    }
    onIntroAskNotificationsChanged: if (!introAskNotifications) introCycle()
    onAgreementItemChanged: {
        if (agreementItem || agreementAccepted)
            return;

        var args = {
            "title": qsTr("Warning"),
            "body" : qsTr("Do you realy want to logout?") ,
            "buttons": [qsTr("Logout"), qsTr("Cancel")]
        };
        logoutWarnItem = Viewport.controller.trigger("dialog:/general/warning", args);
        logoutWarnItem.itemClicked.connect(function(idx, title){
            switch (idx) {
            case 0: // Yes
                agreementRejected = true;
                timeLine.doLogout();
                break;
            case 1: // No
                showAgreement();
                break;
            }
            logoutWarnItem.ViewportType.open = false;
        });
    }
    onLogoutWarnItemChanged: if (!logoutWarnItem && !agreementItem && !agreementRejected) showAgreement()

    Component.onCompleted: {
        MyNotificationsModel.init();
        GlobalMyTagsModel.init();
        MyTricksLimits.init();
        introCycle();
    }

    function showAgreement() {
        agreementItem = Viewport.controller.trigger("popup:/licenses/agreement")
        agreementItem.accepted.connect(function(){
            agreementAccepted = true;
            acceptAgreementReq.doRequest();
        });
    }

    function introCycle() {
        if (!GlobalSettings.introDone) {
            Tools.jsDelayCall(1000, function(){
                introTagDialog = Viewport.controller.trigger("float:/tags");
            });
            GlobalSettings.introDone = true;
            return;
        }

        if (qtFirebase && !GlobalSettings.notificationAsked) {
            Tools.jsDelayCall(1000, function(){
                introAskNotifications = Viewport.controller.trigger("bottomdrawer:/notifications/allow");
            });
            return;
        }

        if (!GlobalSettings.communityId) {
            Tools.jsDelayCall(1000, function(){
                GlobalSignals.communityChooseRequest();
            });
            return;
        }
    }

    AcceptAgreementRequest {
        id: acceptAgreementReq
        accept: Bootstrap.agreement.version
        allowGlobalBusy: true
        onSuccessfull: meReq.doRequest()
    }

    Connections {
        target: Notifications
        function onRegisterFcmRequest(token) {
            registerReq.token = token;
            registerReq.doRequest();
        }

        function onUnregisterFcmRequest(token) {
            unregisterReq.token = token;
            unregisterReq.doRequest();
        }
    }

    RegisterFCMToken {
        id: registerReq
        allowGlobalBusy: true
    }

    UnregisterFCMToken {
        id: unregisterReq
        allowGlobalBusy: true
    }

    GetMeRequest {
        id: meReq
        onSuccessfull: {
            GlobalSettings.userId = response.result.id
            GlobalSettings.username = response.result.username
            GlobalSettings.fullname = response.result.fullname
            GlobalSettings.avatar = response.result.avatar
            GlobalSettings.about = response.result.about;
            try {
                GlobalSettings.userInviteCode = response.result.invitation_code;
            } catch (e) {
                GlobalSettings.userInviteCode = "";
            }
            if (!agreementItem && response.result.agreement_version != Bootstrap.agreement.version) {
                showAgreement();
            }
        }
        Component.onCompleted: doRequest()

        Connections {
            target: GlobalSignals
            function onReloadMeRequest() {
                meReq.doRequest();
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        TLoader {
            id: sidebarLoader
            Layout.fillHeight: true
            Layout.preferredWidth: GlobalSettings.mobileView? home.width : 230 * Devices.density
            active: !GlobalSettings.mobileView
            visible: !GlobalSettings.mobileView
            z: 10
            sourceComponent: Rectangle {
                color: Colors.background
                anchors.fill: parent

                THeader {
                    y: timeLine.headerItem.y
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: -2 * Devices.density
                    light: true
                    color: Colors.header
                    height: Constants.headerHeight
                }

                Sidebar {
                    anchors.fill: parent
                    anchors.topMargin: Devices.statusBarHeight
                    headerHeight: Constants.headerHeight - Devices.statusBarHeight
                    onSearchRequest: timeLine.keyword = GlobalMethods.fixUrlProperties(keyword)
                }
            }
        }

        TVListSeprator {
            visible: !GlobalSettings.mobileView
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            TimeLinePage {
                id: timeLine
                headerItem.height: Constants.headerHeight
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: GlobalSettings.mobileView? footerItem.top : parent.bottom
                visible: GlobalSettings.homeTabIndex < 2
            }

            Loader {
                anchors.fill: timeLine
                active: GlobalSettings.homeTabIndex == 3
                sourceComponent: Tags.MyTagsPage {
                    id: tagsPage
                    anchors.fill: parent
                    mainPageMode: true

                    Connections {
                        target: footerItem
                        function onFooterItemDoubleClicked() {
                            tagsPage.positionViewAtBeginning();
                        }
                    }
                }
            }

            Loader {
                anchors.fill: timeLine
                active: GlobalSettings.homeTabIndex == 4
                sourceComponent: Notification.NotificationsPage {
                    id: notifPages
                    anchors.fill: parent
                    mainPageMode: true

                    Connections {
                        target: footerItem
                        function onFooterItemDoubleClicked() {
                            notifPages.positionViewAtBeginning();
                        }
                    }
                }
            }

            TFooter {
                id: footerItem
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                visible: GlobalSettings.mobileView
                visibleTexts: false
                model: HomeFooterModel { id: footerModel }
                currentIndex: GlobalSettings.homeTabIndex
                onItemRequest: {
                    switch (index) {
                    case 0:
                    case 1:
                    case 3:
                    case 4:
                        GlobalSettings.homeTabIndex = index;
                        break;
                    }
                }
                onFooterItemDoubleClicked: {
                    switch (currentIndex) {
                    case 0:
                    case 1:
                        timeLine.positionViewAtBeginning()
                        break;
                    case 3:
                    case 4:
                        break;
                    }
                }

                Connections {
                    target: GlobalSettings
                    function onHomeTabIndexChanged() {
                        footerItem.currentIndex = GlobalSettings.homeTabIndex;
                    }
                }

                FastDropShadow {
                    source: addBtn
                    anchors.fill: addBtn
                    anchors.margins: 1 * Devices.density
                    radius: 6 * Devices.density
                    horizontalOffset: 1 * Devices.density
                    verticalOffset:  1 * Devices.density
                    visible: addBtn.visible
                }

                Rectangle {
                    id: addBtn
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -Devices.navigationBarHeight/2
                    height: 60 * Devices.density
                    width: height
                    radius: height / 2
                    color: Qt.darker(Colors.accent, (addBtnMarea.pressed? 1.2 : 1))
                    visible: GlobalSettings.mobileView

                    MouseArea {
                        id: addBtnMarea
                        anchors.fill: parent
                        onClicked: Viewport.controller.trigger("float:/tricks/add")
                    }

                    TLabel {
                        anchors.verticalCenterOffset: -2 * Devices.density
                        anchors.centerIn: parent
                        font.pixelSize: 18 * Devices.fontDensity
                        font.family: MaterialIcons.family
                        text: MaterialIcons.mdi_plus
                        color: "#fff"
                    }
                }
            }
        }

        TVListSeprator {
            visible: !GlobalSettings.mobileView
        }

        TLoader {
            Layout.fillHeight: true
            Layout.preferredWidth: GlobalSettings.mobileView? home.width : home.width * 0.4
            active: !GlobalSettings.mobileView
            visible: !GlobalSettings.mobileView
            sourceComponent: TPage {
                anchors.fill: parent

                THeader {
                    y: timeLine.headerItem.y
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: -2 * Devices.density
                    light: true
                    color: Colors.header
                    height: Constants.headerHeight
                }

                FastDropShadow {
                    source: addTrickBack
                    anchors.fill: addTrickBack
                    anchors.margins: 1 * Devices.density
                    radius: 6 * Devices.density
                    horizontalOffset: 1 * Devices.density
                    verticalOffset:  1 * Devices.density
                }

                Rectangle {
                    id: addTrickBack
                    anchors.fill: addTrickRow
                    radius: Constants.radius
                    color: Colors.darkMode? "#333" : "#f1f1f1"
                }

                ColumnLayout {
                    id: addTrickRow
                    anchors.fill: parent
                    anchors.margins: 10 * Devices.density
                    anchors.topMargin: Devices.statusBarHeight + 10 * Devices.density

                    TLabel {
                        Layout.preferredHeight: Devices.standardTitleBarHeight
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: addTrick.quoteMode? qsTr("Quote") : qsTr("Add Trick") + Translations.refresher
                    }

                    AddTrickView {
                        id: addTrick
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Connections {
                            target: GlobalSignals
                            function onRetrickRequest(trick) {
                                if (Viewport.viewport.count == 0)
                                    addTrick.quote(trick);
                            }
                        }
                    }
                }
            }
        }
    }
}
