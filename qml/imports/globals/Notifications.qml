pragma Singleton

import QtQuick 2.10
import AsemanQml.Base 2.0

AsemanObject {
    id: dis

    readonly property bool allowNotifications: GlobalSettings.allowNotifications
    property variant fcmMessaging

    Component.onCompleted: initFirebase();

    signal registerFcmRequest(string token)
    signal unregisterFcmRequest(string token)
    signal notificationRecieved(variant data)

    function initFirebase() {
        if (!qtFirebase)
            return;

        if (allowNotifications) {
            if (!fcmMessaging) {
                fcmMessaging = Qt.createQmlObject("import QtFirebase 1.0\n" +
                                                  "import globals 1.0\n" +
                                                  "Messaging {\n" +
                                                  "    id: msg\n" +
                                                  "    onDataChanged: Notifications.notificationRecieved(data)\n" +
                                                  "}", dis);
            }
        } else {
            if (fcmMessaging) fcmMessaging.destroy();
        }
    }

    function allow() {
        GlobalSettings.allowNotifications = true;
        initFirebase();
        if (fcmMessaging.token.length) {
            dis.registerFcmRequest(fcmMessaging.token);
        } else {
            fcmMessaging.tokenChanged.connect(function(){
                dis.registerFcmRequest(fcmMessaging.token);
            });
        }
    }

    function disAllow() {
        if (fcmMessaging) {
            dis.unregisterFcmRequest(fcmMessaging.token);
        }
        GlobalSettings.allowNotifications = false;
        initFirebase();
    }
}
