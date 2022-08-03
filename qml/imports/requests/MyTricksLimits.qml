pragma Singleton

import QtQuick 2.0
import AsemanQml.Base 2.0

AsemanObject {
    property int dailyPostLimit: 0

    function init() {
        Tools.jsDelayCall(100, refresh);
    }

    function refresh() {
        if (req.refreshing)
            return;

        req.doRequest();
    }

    GetMyTricksLimitsRequest {
        id: req
        onSuccessfull: {
            dailyPostLimit = response.result.daily_post_limit;
        }
    }
}
