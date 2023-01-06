import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model

    property alias refreshing: req.refreshing
    property alias userId: req._userId

    MapObject {
        id: sortingMap
    }

    GetUserFollowingsRequest {
        id: req
        onSuccessfull: {
            response.result.forEach(function(t){
                let sortId = (t.id + "").padStart(20, '0');
                sortingMap.remove(sortId);
                sortingMap.insert(sortId, t);
            });

            var list = new Array; sortingMap.values.forEach(function(l){ list.unshift(l); });
            model.change(list);
        }
    }

    function refresh() {
        if (refreshing)
            return;

        req.offset = 0;
        req.doRequest();
    }

    function more() {
        if (refreshing)
            return;

        req.offset = count;
        req.doRequest();
    }

    Component.onCompleted: Tools.jsDelayCall(10, refresh)
}
