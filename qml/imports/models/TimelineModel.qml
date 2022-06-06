import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model
    cachePath: Constants.cacheTimeline

    property alias refreshing: req.refreshing
    property int unreadCount
    property bool inited: false

    Connections {
        target: GlobalSignals
        function onRefreshRequest() {
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

    TimelineRequest {
        id: req
        onCommunity_idChanged: {
            inited = false;
            refreshTimer.restart();
        }
        onSuccessfull: {
            var counter = 0;

            response.result.forEach(function(t){
                if (t.id == GlobalSettings.lastTimelineId)
                    unreadCount = counter;

                let sortId = ("" + Date.parse(t.datetime)).padStart(20, '0') + (t.id + "").padStart(20, '0');
                sortingMap.remove(sortId);
                sortingMap.insert(sortId, t);
                counter++;
            });

            if (!inited && offset == 0) {
                clear();
                inited = true;
            }

            let list = sortingMap.values.reverse();
            model.change(list);
            if (list.length)
                GlobalSettings.lastTimelineId = list[0].id;
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
