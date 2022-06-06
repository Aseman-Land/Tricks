import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/auth/logout"

    property string fcm_token

    function doRequest() {
        if (Notifications.fcmMessaging)
            fcm_token = Notifications.fcmMessaging.token;

        _networkManager.post(req);
    }

}
