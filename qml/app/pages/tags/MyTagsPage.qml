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
    ViewportType.maximumWidth: GlobalSettings.viewMode != 2? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    property bool mainPageMode: false

    function positionViewAtBeginning() {
        view.listView.positionViewAtBeginning()
    }

    UpdateTagViews {
        id: updateReq
        onSuccessfull: {
            var list = Tools.toVariantList(tags);
            list.forEach(GlobalSignals.tagReaded)
        }
    }

    TagsView {
        id: view
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: moreBtn.top
        followable: false
        model: GlobalMyTagsModel
        Component.onCompleted: GlobalMyTagsModel.refresh()
    }

    TButton {
        id: moreBtn
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Constants.margins
        anchors.bottomMargin: Devices.navigationBarHeight + Constants.margins
        text: qsTr("Discover Tags") + Translations.refresher
        highlighted: true
        onClicked: Viewport.controller.trigger("float:/tags")
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        color: mainPageMode? Colors.header : Colors.headerSecondary
        light: true

        TLabel {
            anchors.centerIn: parent
            font.pixelSize: 10 * Devices.fontDensity
            text: qsTr("Tags") + Translations.refresher
            color: Colors.headerText
        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10 * Devices.density

            TBusyIndicator {
                Layout.preferredWidth: 18 * Devices.density
                Layout.preferredHeight: 18 * Devices.density
                running: GlobalMyTagsModel.refreshing || updateReq.refreshing
                IOSStyle.foreground: Colors.headerText
                Material.accent: Colors.headerText
            }

            TButton {
                Layout.preferredWidth: 80 * Devices.density
                text: qsTr("Read All") + Translations.refresher
                onClicked: {
                    updateReq.tags = Tools.toVariantList(GlobalMyTagsModel.unreadedTags);
                    updateReq.doRequest();
                }
            }
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
        visible: !mainPageMode
    }
}
