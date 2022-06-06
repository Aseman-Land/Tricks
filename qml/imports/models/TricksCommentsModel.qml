import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import requests 1.0
import globals 1.0

GlobalTimelineModel {
    id: model

    Connections {
        target: GlobalSignals
        function onRefreshRequest() {
            model.refresh();
        }
    }
}
