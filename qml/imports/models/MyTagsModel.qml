import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model

    property alias refreshing: req.refreshing
    property int totalUnreads

    property variant unreadedTags: new Array

    signal finished

    Connections {
        target: GlobalSignals
        function onTagsRefreshed() {
            model.refresh()
        }
        function onTagReaded(tag) {
            for (var i=0; i<model.count; i++) {
                var m = model.get(i);
                if (m.tag != tag)
                    continue;

                totalUnreads -= m.unreads_count;
                m.unreads_count = 0;
                model.remove(i);
                model.insert(i, m);
            }
        }
    }

    GetMyTagsRequest {
        id: req
        onSuccessfull: {
            model.clear();
            GlobalSettings.followedTags.clear();
            unreadedTags = new Array;

            var unreads = 0;
            response.result.forEach(function(t){
                if (!t.unreads_count)
                    return;

                unreads += t.unreads_count;
                t["section_title"] = qsTr("Has new tricks");

                unreadedTags[unreadedTags.length] = t.tag;
                GlobalSettings.followedTags.insert(t.tag, true);
                model.append(t);
            });

            response.result.forEach(function(t){
                if (t.unreads_count)
                    return;

                t["section_title"] = qsTr("Read");

                GlobalSettings.followedTags.insert(t.tag, true);
                model.append(t);
            });

            totalUnreads = unreads;
            model.finished()
        }
    }

    function refresh() {
        req.doRequest();
    }

    Component.onCompleted: Tools.jsDelayCall(10, refresh)
}
