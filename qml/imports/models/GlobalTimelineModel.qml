import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model

    property alias refreshing: req.refreshing
    property alias keyword: req.keyword
    property alias tag_name: req.tag_name
    property alias parentId: req.parent_id
    property bool reversed: false
    property bool active: true

    onKeywordChanged: refreshTimer.restart()
    onTag_nameChanged: refreshTimer.restart()
    onParentIdChanged: refreshTimer.restart()
    onActiveChanged: refreshTimer.restart()

    Connections {
        target: GlobalSignals
        function onTrickDeleted(id) {
            var keys = sortingMap.keys;
            keys.forEach(function(k){
                var item = sortingMap.value(k);
                if (item.id == id)
                    sortingMap.remove(k);
            })
        }
    }

    Timer {
        id: refreshTimer
        interval: 10
        repeat: false
        onTriggered: {
            if (!active)
                return;
            if (tag_name.length && keyword.length == 0)
                return;

            sortingMap.clear();
            req.offset = 0;
            if (!refreshing)
                req.doRequest();
        }
    }

    MapObject {
        id: sortingMap
    }

    GlobalTimelineRequest {
        id: req
        onCommunity_idChanged: refreshTimer.restart()
        onSuccessfull: {
            response.result.forEach(function(t){
                let sortId = ("" + Date.parse(t.datetime)).padStart(20, '0') + (t.id + "").padStart(20, '0');
                sortingMap.remove(sortId);
                sortingMap.insert(sortId, t);
            });

            let list = (reversed? sortingMap.values : sortingMap.values.reverse());
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
