import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import globals 1.0

ViewportController {
    id: viewController

    readonly property int waitCount: GlobalSettings.waitCount
    property variant waitObj

    onWaitCountChanged: {
        if (waitCount) {
            if (!waitObj) waitObj = trigger("dialog:/wait");
        } else {
            if (waitObj) waitObj.close()
        }
    }

    ViewportControllerRoute {
        route: /dialog\:\/general\/error.*/
        source: "ErrorDialog.qml"
    }

    ViewportControllerRoute {
        route: /dialog\:\/general\/warning.*/
        source: "ErrorDialog.qml"
    }

    ViewportControllerRoute {
        route: /dialog\:\/wait/
        source: "WaitDialog.qml"
    }

    ViewportControllerRoute {
        route: /\w+:\/web\/browse/
        source: "WebBrowserPage.qml"
    }

    ViewportControllerRoute {
        route: /\w+:\/auth/
        source: "qrc:/app/auth/AuthPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/auth\/signup/
        source: "qrc:/app/auth/SignupPage.qml"
        viewportType: "float"
    }

    ViewportControllerRoute {
        route: /\w+:\/tricks/
        source: "qrc:/app/pages/timeline/TrickPage.qml"
        viewportType: GlobalSettings.mobileView? "page" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/tricks\/tip/
        source: "qrc:/app/pages/timeline/AddTipDialog.qml"
        viewportType: "bottomdrawer"
    }

    ViewportControllerRoute {
        route: /\w+:\/users/
//        source: "qrc:/app/pages/timeline/ProfilePage.qml"
        source: "qrc:/app/pages/timeline/MyProfilePage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/users\/me/
        source: "qrc:/app/pages/timeline/MyProfilePage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/tags\/me/
        source: "qrc:/app/pages/tags/MyTagsPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/notifications/
        source: "qrc:/app/pages/notifications/NotificationsPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/profile\/edit/
        source: "qrc:/app/pages/profile/EditProfile.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/about/
        source: "qrc:/app/pages/about/AboutPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/users\/followings/
        source: "qrc:/app/pages/follow/FollowingsPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/users\/followers/
        source: "qrc:/app/pages/follow/FollowersPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/tricks\/rates/
        source: "qrc:/app/pages/timeline/LikesPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/tricks\/tips/
        source: "qrc:/app/pages/timeline/TricksTipsDialog.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/users\/report/
        source: "qrc:/app/pages/report/ReportUserDialog.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/bookmarks/
        source: "qrc:/app/pages/timeline/BookmarksPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/tag/
        source: "qrc:/app/pages/timeline/TagPage.qml"
        viewportType: GlobalSettings.mobileView? "page" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/tag\/notification/
        source: "qrc:/app/pages/notifications/TagNotificationDialog.qml"
        viewportType: "bottomdrawer"
    }

    ViewportControllerRoute {
        route: /\w+:\/tags/
        source: "qrc:/app/pages/tags/TagsPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/settings/
        source: "qrc:/app/pages/settings/SettingsPage.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/settings\/qr-login/
        source: "qrc:/app/pages/settings/QRLogin.qml"
        viewportType: "bottomdrawer"
    }

    ViewportControllerRoute {
        route: /\w+:\/tricks\/add/
        source: "qrc:/app/pages/add-trick/AddTrickDialog.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/tricks\/report/
        source: "qrc:/app/pages/report/ReportTrickDialog.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/licenses\/agreement/
        source: "qrc:/app/auth/LicenseAgreement.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }

    ViewportControllerRoute {
        route: /\w+:\/notifications\/allow/
        source: "qrc:/app/pages/notifications/AllowNotificationDialog.qml"
        viewportType: "bottomdrawer"
    }

    ViewportControllerRoute {
        route: /\w+:\/volcano\/deposit/
        source: "qrc:/app/pages/volcano/DepositDialog.qml"
        viewportType: "bottomdrawer"
    }

    ViewportControllerRoute {
        route: /\w+:\/volcano\/withdraw/
        source: "qrc:/app/pages/volcano/WithdrawDialog.qml"
        viewportType: "bottomdrawer"
    }

    ViewportControllerRoute {
        route: /\w+:\/volcano\/payments/
        source: "qrc:/app/pages/volcano/PaymentsDialog.qml"
        viewportType: GlobalSettings.mobileView? "float" : "popup"
    }
}

