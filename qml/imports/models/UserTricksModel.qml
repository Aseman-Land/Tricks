import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model

    property alias refreshing: req.refreshing
    property alias userId: req._userId
    property alias tagName: req.tag_name
    property bool blockAutoRefresh: false

    onTagNameChanged: refreshTimer.restart()

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

    Connections {
        target: GlobalSignals
        function onRefreshRequest() {
            if (userId)
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

    MapObject {
        id: sortingMap
    }

    GetUserTricksRequest {
        id: req
        onSuccessfull: {
            response.result.forEach(function(t){
                let sortId = ("" + Date.parse(t.datetime)).padStart(20, '0') + (t.id + "").padStart(20, '0');
                sortingMap.remove(sortId);
                sortingMap.insert(sortId, t);
            });

            var list = new Array; sortingMap.values.forEach(function(l){ list.unshift(l); });
            model.change(list);
        }
    }

    function refresh() {
        if (userId == 0)
            return;
        if (refreshing)
            return;

        req.offset = 0;
        req.doRequest();
    }

    function more() {
        if (userId == 0)
            return;
        if (refreshing)
            return;

        req.offset = count;
        req.doRequest();
    }

    Component.onCompleted: Tools.jsDelayCall(10, function() { if (!blockAutoRefresh) refresh(); })
}
