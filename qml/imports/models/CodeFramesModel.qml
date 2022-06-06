import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model
    cachePath: Constants.cacheCodeFrames

    property alias refreshing: req.refreshing

    GetCodeFramesRequest {
        id: req
        onSuccessfull: {
            model.clear();
            response.result.forEach(model.append);
        }
    }

    function refresh() {
        req.doRequest();
    }

    Component.onCompleted: Tools.jsDelayCall(10, refresh)
}
