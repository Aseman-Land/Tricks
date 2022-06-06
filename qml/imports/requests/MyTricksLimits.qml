pragma Singleton

import QtQuick 2.0
import AsemanQml.Base 2.0

GetMyTricksLimitsRequest {
    function init() {
        Tools.jsDelayCall(100, doRequest);
    }

    function refresh() {
        doRequest();
    }

    onSuccessfull: {
        dailyPostLimit = response.result.daily_post_limit;
    }

    property int dailyPostLimit: 0
}
