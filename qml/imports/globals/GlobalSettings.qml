pragma Singleton

import QtQuick 2.7
import AsemanQml.Base 2.0

AsemanObject {
    id: dis

    property bool smartKeyboardHeight: true
    property bool dynamicKeyboardHeight: true
    property int waitCount
    property bool languageInited: false
    property bool mobileView: true
    property bool ignoreSslErrorsViewed
    property bool ignoreSslErrors: App.ignoreSslErrors

    property alias accessToken: _auth.accessToken
    property alias userId: _auth.userId
    property alias username: _auth.username
    property alias fullname: _auth.fullname
    property alias avatar: _auth.avatar
    property alias about: _auth.about
    property string userInviteCode: _auth.userInviteCode

    property alias width: _settings.width
    property alias height: _settings.height

    property string homeCurrentTag
    property alias followedTags: followedTags
    property alias likedsHash: likedsHash
    property alias lastTimelineId: _settings.lastTimelineId
    property alias lastNotificationChecked: _settings.lastNotificationChecked
    property alias communityId: _settings.communityId
    property int homeTabIndex

    property alias initialized: _settings.initialized
    property alias introDone: _settings.introDone
    property alias lightHeader: _settings.lightHeader
    property alias forceCodeTheme: _settings.forceCodeTheme
    property alias language: _settings.language
    property alias defaultCodeDefinition: _settings.defaultCodeDefinition
    property alias defaultCodeTheme: _settings.defaultCodeTheme
    property alias iosTheme: _settings.iosTheme
    property alias androidTheme: _settings.androidTheme
    property alias allowNotifications: _settings.allowNotifications
    property alias notificationAsked: _settings.notificationAsked

    property alias forgetPasswordEmail: _auth.forgetPasswordEmail

    property bool frameless: Devices.isWindows

    onAccessTokenChanged: {
        if (accessToken.length != 0)
            return;

        userId = 0;
        fullname = "";
        username = "";
        avatar = "";
        about = "";
        notificationAsked = false;
        allowNotifications = false;
        followedTags.clear();
    }

    Component.onCompleted: {
        if (!initialized) {
            initialized = true;
        }
    }

    HashObject {
        id: likedsHash
    }

    HashObject {
        id: followedTags
    }

    Settings {
        id: _auth
        category: "General"
        source: AsemanApp.homePath + "/auth.ini"

        property string accessToken
        property int userId
        property string username
        property string fullname
        property string avatar
        property string about
        property string userInviteCode

        property string forgetPasswordEmail
    }

    Settings {
        id: _settings
        category: "General"
        source: AsemanApp.homePath + "/settings.ini"

        property bool introDone: false
        property bool lightHeader: false
        property bool forceCodeTheme: false
        property int iosTheme: 2
        property int androidTheme: 0
        property bool allowNotifications: false
        property bool notificationAsked: false

        property bool initialized: false

        property real width: 1280
        property real height: 700

        property string language: "en"

        property string defaultCodeDefinition: "C++"
        property string defaultCodeTheme: "Breeze Light"

        property int communityId: 0
        property int lastTimelineId: 0
        property int lastNotificationChecked: 0
    }
}

