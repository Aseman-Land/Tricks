pragma Singleton

import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

AsemanObject {

    Connections {
        target: GlobalSettings
        function onAccessTokenChanged() {
            pushTimer.stop();
            hash.clear();
        }
    }

    HashObject {
        id: hash
    }

    Timer {
        id: pushTimer
        interval: 5000
        repeat: false
        onTriggered: {
            req.tricks = new Array;
            hash.keys.forEach(function(k){
                req.tricks[req.tricks.length] = k*1;
            });
            req.doRequest();
            hash.clear();
        }
    }

    function push(id) {
        if (GlobalSettings.accessToken.length == 0)
            return;
        if (hash.contains(id))
            return;

        hash.insert(id, null);
        pushTimer.restart();
    }

    AddViewsRequest {
        id: req
    }
}
