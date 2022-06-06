pragma Singleton

import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

AsemanListModel {
    id: model
    cachePath: Constants.cacheNotifications

    property alias refreshing: req.refreshing
    property int unreadsCount
    property bool inited: false

    function init() {}

    Connections {
        target: GlobalSignals
        function onTagsRefreshed() {
            model.refresh()
        }
    }

    MapObject {
        id: sortingMap
    }

    GetSmartNotificationsRequest {
        id: req
        onSuccessfull: {
            var unreads = 0;
            response.result.forEach(function(t){
                let dateTime = GlobalMethods.unNormalizeDate(t.datetime);
                let dateTime_secs = Tools.dateToSec(dateTime);
                if (GlobalSettings.lastNotificationChecked < dateTime_secs)
                    unreads++;

                let sortId = (dateTime_secs + "").padStart(20, '0');
                sortingMap.remove(sortId);
                sortingMap.insert(sortId, t);
            });

            let list = sortingMap.values.reverse();

            if (!inited && offset == 0) {
                clear();
                inited = true;
            }

            model.change(list);
            unreadsCount = unreads;
        }
    }

    function markAllAsRead() {
        unreadsCount = 0;
        GlobalSettings.lastNotificationChecked = Tools.dateToSec(new Date);
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
