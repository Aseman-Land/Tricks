import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model

    property alias refreshing: req.refreshing
    property alias tag: req._tag

    Connections {
        target: GlobalSignals
        function onRefreshRequest() {
            if (tag.length)
                model.refresh();
        }
        function onTrickDeleted(id) {
            var keys = sortingMap.keys;
            keys.forEach(function(k){
                var item = sortingMap.value(k);
                if (item.id == id)
                    sortingMap.remove(k);
            })
        }
    }

    onTagChanged: {
        sortingMap.clear();
        if (tag.length)
            Tools.jsDelayCall(10, refresh);
        else
            clear();
    }

    MapObject {
        id: sortingMap
    }

    Timer {
        id: refreshTimer
        interval: 10
        repeat: false
        onTriggered: {
            sortingMap.clear();
            req.offset = 0;
            req.doRequest();
        }
    }

    GetTagTricksRequest {
        id: req
        onCommunity_idChanged: {
            if (_tag.length)
                refreshTimer.restart()
        }
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
