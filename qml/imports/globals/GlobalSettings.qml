pragma Singleton

import QtQuick 2.7
import AsemanQml.Base 2.0

AsemanObject {
    id: dis

    property bool smartKeyboardHeight: true
    property bool dynamicKeyboardHeight: true
    property int waitCount
    property bool languageInited: false
    property int viewMode: {
        if (Devices.isMobile)
            return 2;
        if (Devices.isTablet)
            return 1;
        return 0;
    }

    property bool ignoreSslErrorsViewed
    property bool ignoreSslErrors
    property alias ignoreSslErrorsPerment: _settings.ignoreSslErrorsPerment

    property alias loggedInWithoutPassword: _auth.loggedInWithoutPassword
    property alias accessToken: _auth.accessToken
    property alias userId: _auth.userId
    property alias username: _auth.username
    property alias fullname: _auth.fullname
    property alias avatar: _auth.avatar
    property alias about: _auth.about
    property alias google: _auth.google
    property alias github: _auth.github
    property string userInviteCode: _auth.userInviteCode

    property alias googleRegisterSessionId: _auth.googleRegisterSessionId
    property alias googleConnectSessionId: _auth.googleConnectSessionId

    property alias githubRegisterSessionId: _auth.githubRegisterSessionId
    property alias githubConnectSessionId: _auth.githubConnectSessionId

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

        loggedInWithoutPassword = false;
        userId = 0;
        fullname = "";
        username = "";
        avatar = "";
        about = "";
        notificationAsked = false;
        allowNotifications = false;
        followedTags.clear();

        google = false;
        googleRegisterSessionId = "";
        googleConnectSessionId = "";

        github = false;
        githubRegisterSessionId = "";
        githubConnectSessionId = "";
    }

    Component.onCompleted: {
        if (!initialized) {
            ignoreSslErrorsPerment = App.ignoreSslErrors;
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
        property bool loggedInWithoutPassword: false
        property int userId
        property string username
        property string fullname
        property string avatar
        property string about
        property string userInviteCode

        property bool google
        property string googleRegisterSessionId
        property string googleConnectSessionId

        property bool github
        property string githubRegisterSessionId
        property string githubConnectSessionId

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
        property bool ignoreSslErrorsPerment: false

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

