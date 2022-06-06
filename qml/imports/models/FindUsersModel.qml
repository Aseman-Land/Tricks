import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model

    property alias refreshing: req.refreshing
    property alias keyword: req.keyword

    onKeywordChanged: refreshTimer.restart()

    Timer {
        id: refreshTimer
        interval: 10
        repeat: false
        onTriggered: {
            if (keyword.length == 0)
                return;

            sortingMap.clear();
            req.doRequest();
        }
    }

    MapObject {
        id: sortingMap
    }

    FindUsersRequest {
        id: req
        onSuccessfull: {
            response.result.forEach(function(t){
                let sortId = (t.id + "").padStart(20, '0');
                sortingMap.remove(sortId);
                sortingMap.insert(sortId, t);
            });

            let list = sortingMap.values.reverse();
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
}
