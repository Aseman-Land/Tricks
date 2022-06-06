import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.IOSStyle 2.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: Viewport.viewport.width > Viewport.viewport.height && !Devices.isMobile? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    TagsView {
        id: tv
        anchors.top: searchFieldRect.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        model: TagsModel { id: tmodel }
    }

    Item {
        id: searchFieldRect
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Devices.standardTitleBarHeight

        TSearchField {
            id: searchField
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 6 * Devices.density
            height: 42 * Devices.density
            onSearchRequest: tmodel.keyword = GlobalMethods.fixUrlProperties(keyword)
        }
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right

        TLabel {
            anchors.centerIn: parent
            font.pixelSize: 10 * Devices.fontDensity
            text: qsTr("Discover Tags") + Translations.refresher
        }

        TBusyIndicator {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: y
            width: 18 * Devices.density
            height: 18 * Devices.density
            running: tmodel.refreshing
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
