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

                let rid = t.refred_trick_id? t.refred_trick_id : t.id;
                let rid2 = t.refred_trick_id? t.refred_trick_id+1 : t.id;
                let sortId = (rid + "").padStart(20, '0') + (rid2 + "").padStart(20, '0');
                sortingMap.remove(sortId);
                sortingMap.insert(sortId, t);
                counter++;
            });

            if (!inited && offset == 0) {
                clear();
                inited = true;
            }

            let list = sortingMap.values.reverse();
            let linkes = new Array;
            let last_link_id = 0;
            list.forEach(function(l){
                var m = l;
                if (m.refred_trick_id) {
                    last_link_id = m.id;
                    m["link_id"] = m.refred_trick_id;
                } else if (last_link_id) {
                    m["link_id"] = last_link_id;
                    last_link_id = 0;
                } else {
                    m["link_id"] = null;
                    last_link_id = 0;
                }

                linkes[linkes.length] = m;
            })
            model.change(linkes);
            if (list.length) {
                var t = list[0];
                GlobalSettings.lastTimelineId = (t.refred_trick_id? t.refred_trick_id : t.id);
            }
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
