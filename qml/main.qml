import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import globals 1.0
import requests 1.0
import models 1.0

AsemanApplication {
    id: app
    applicationName: "Tricks"
    applicationDisplayName: qsTr("Tricks")
    applicationId: App.uniqueId
    organizationDomain: App.organizationDomain
    applicationVersion: App.version
    statusBarStyle: {
        if (GlobalSettings.accessToken.length == 0)
            return AsemanApplication.StatusBarStyleLight;
        else
        if ((mWin.viewport.currentType == "float" || mWin.viewport.currentType == "popup") && !Devices.isAndroid)
            return AsemanApplication.StatusBarStyleLight;
        else
        if (Colors.darkMode || (!Colors.lightHeader && mWin.viewport.count == 0))
            return AsemanApplication.StatusBarStyleLight;
        else
            return AsemanApplication.StatusBarStyleDark;
    }

    Component.onCompleted: {
        if (Devices.isDesktop) Devices.fontScale = 1.1;
        if (Devices.isAndroid) Devices.fontScale = 1;
        if (Devices.isIOS) Devices.fontScale = 1.15;

        Fonts.init();
        GTranslations.init();
        Bootstrap.init();
    }

    onApplicationStateChanged: {
        if (!GlobalSettings.userId)
            return;

        switch (applicationState) {
        case 4:
            GlobalSignals.reloadMeRequest();
            GlobalSignals.refreshRequest();
            MyNotificationsModel.refresh();
            GlobalMyTagsModel.refresh();
            break;
        }
    }

    MainWindow {
        id: mWin
        visible: true
        font.family: Fonts.globalFont
        font.letterSpacing: -0.5
    }
}
