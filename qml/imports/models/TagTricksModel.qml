import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model

    property alias refreshing: req.refreshing
    property alias tag: req._tag
    property alias keyword: globReq.keyword

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
            model.refresh();
        }
    }

    GetTagTricksRequest {
        id: req
        onCommunity_idChanged: if (_tag.length) refreshTimer.restart()
        onSuccessfull: if (keyword.length == 0) appendItems(response.result)
    }

    GlobalTimelineRequest {
        id: globReq
        tag_name: req._tag
        onTag_nameChanged: tryRefresh()
        onCommunity_idChanged: tryRefresh()
        onKeywordChanged: tryRefresh()
        onSuccessfull: if (keyword.length != 0) appendItems(response.result)

        function tryRefresh() {
            if (tag_name.length)
                refreshTimer.restart()
        }
    }

    function appendItems(items) {
        items.forEach(function(t){
            let sortId = ("" + Date.parse(t.datetime)).padStart(20, '0') + (t.id + "").padStart(20, '0');
            sortingMap.remove(sortId);
            sortingMap.insert(sortId, t);
        });

        let list = sortingMap.values.reverse();
        model.change(list);
    }

    function refresh() {
        var r = keyword.length? globReq : req;
        if (r.refreshing)
            return;

        r.offset = 0;
        r.doRequest();
    }

    function more() {
        var r = keyword.length? globReq : req;
        if (r.refreshing)
            return;

        r.offset = count;
        r.doRequest();
    }
}
