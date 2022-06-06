import QtQuick 2.0
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import components 1.0
import models 1.0
import globals 1.0

Item {
    id: dis

    property alias listView: listv
    property alias model: listv.model
    property alias header: listv.header
    property alias footer: listv.footer
    property real topMargin
    property alias bottomMargin: listv.bottomMargin
    property alias contentY: listv.contentY
    property alias headerVisible: mapListener.headerVisible
    property int unreadsCount
    property bool extraRefresher
    property bool muted
    property bool blocked
    property bool blockedYou
    property bool suspended
    property bool globalViewMode

    PointMapListener {
        id: mapListener
        source: listv.headerItem
        dest: dis

        property bool headerVisible: true
        property real lastY

        onResultChanged: {
            headerBack.height = mapListener.result.y;
            var contentY = mapListener.result.y
            if(contentY > - 100 * Devices.density)
                headerVisible = true;
            else {
                var delta = (contentY-mapListener.lastY)
                if(delta > 100*Devices.density)
                    headerVisible = true;
                else
                if(delta < -50*Devices.density)
                    headerVisible = false;
            }
        }
    }

    Rectangle {
        id: headerBack
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: listv.headerItem && listv.headerItem.color? listv.headerItem.color : "transparent"
    }

    TLabel {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Constants.margins
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("There is no trick here") + Translations.refresher
        font.pixelSize: 8 * Devices.fontDensity
        opacity: 0.6
        visible: listv.count == 0 && !dis.model.refreshing && !extraRefresher && !blocked && !muted
    }

    Timer {
        id: listBlockUpdate
        interval: 300
        repeat: false
    }

    TScrollView {
        anchors.fill: parent

        TListView {
            id: listv

            onDraggingVerticallyChanged: if (draggingVertically) mapListener.lastY = mapListener.result.y

            onCountChanged: {
                if (unreadsCount && count >= unreadsCount)
                    positionViewAtIndex(unreadsCount-1, ListView.Beginning);
            }
            header: Item {
                width: listv.width
                height: refresher.height + dis.topMargin

                TListRefresher {
                    id: refresher
                    y: dis.topMargin
                    view: listv
                    onRefreshRequest: {
                        refreshing = true;
                        listv.model.refresh();
                    }

                    Connections {
                        target: listv.model
                        function onRefreshingChanged() {
                            if (!listv.model.refreshing) refresher.refreshing = false;
                        }
                    }
                }
            }

            delegate: TrickMinimalItem {
                id: loader
                width: listv.width
                visible: !dis.blocked && !dis.blockedYou && !dis.suspended
                globalViewMode: dis.globalViewMode
                onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks", {"trickId": mainId})

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 2 * Devices.density
                    radius: width / 2
                    anchors.margins: Constants.margins / 2 - radius
                    color: Colors.primary
                    opacity: 0.7
                    visible: index < unreadsCount
                }

                Connections {
                    target: GlobalSignals
                    function onTrickUpdated(i) {
                        if (i.id != model.id)
                            return;

                        listBlockUpdate.restart();
                        let idx = model.index;
                        listv.model.remove(idx);
                        listv.model.insert(idx, i);
                    }
                }

                THListSeprator {
                    width: parent.width
                    anchors.bottom: parent.bottom
                }

                Component.onCompleted: {
                    if (model.index == listv.count-1 && listv.model.more && !listBlockUpdate.running) listv.model.more();
                    pushData(listv.model.get(model.index));
                }
            }
        }
    }
}
