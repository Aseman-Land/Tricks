import QtQuick 2.0
import AsemanQml.Modern 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Controls.Material 2.3
import QtQuick.Controls 2.12
import globals 1.0

Item {
    id: headerItem
    width: view.width
    height: refreshing? refreshigHeight : 0

    signal refreshRequest()

    Behavior on height {
        NumberAnimation {easing.type: Easing.OutCubic; duration: 300}
    }

    property Item view
    readonly property real refreshigHeight: 60 * Devices.density
    property bool refreshing

    onRefreshingChanged: {
        if (refreshing)
            listener.refreshLock = true;
        else if (!view.dragging)
            listener.refreshLock = false;
    }

    Item {
        id: area
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: headerItem.refreshing? headerItem.refreshigHeight : listener.result.y>0? listener.result.y : 0

        TLabel {
            anchors.centerIn: parent
            font.pixelSize: 8 * Devices.fontDensity
            text: qsTr("Refresh") + Translations.refresher
            opacity: listener.result.y>0? Math.min(listener.result.y / headerItem.refreshigHeight, 1) * 0.6 : 0
            visible: !busyInd.running
        }

        TBusyIndicator {
            id: busyInd
            anchors.centerIn: parent
            width: 22 * Devices.density
            height: width
            running: headerItem.refreshing || listener.refreshLock
            Material.accent: Colors.foreground
        }
    }

    PointMapListener {
        id: listener
        source: view.headerItem
        dest: view
        y: -view.topMargin
        onResultChanged: {
            if (view.flicking)
                return;
            if (view.dragging && refreshLock)
                return;

            refreshLock = false;
            if (result.y > headerItem.refreshigHeight * 1.3)
                headerItem.refreshRequest()
        }

        property bool refreshLock
    }
}
