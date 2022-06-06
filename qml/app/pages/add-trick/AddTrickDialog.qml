import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import components 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: Viewport.viewport.width > Viewport.viewport.height && !Devices.isMobile? 500 * Devices.density : 0
    ViewportType.touchToClose: !addView.warnable
    ViewportType.gestureWidth: addView.warnable? 0 : height

    property variant quote
    property alias parentId: addView.parentId
    property alias trickData: addView.trickData

    onQuoteChanged: addView.quote(quote)

    function back() {
        if (!addView.warnable) {
            dis.ViewportType.open = false;
            return true;
        }

        var args = {
            "title": qsTr("Warning"),
            "body" : qsTr("Do you realy want to delete this trick?") ,
            "buttons": [qsTr("Yes"), qsTr("No")]
        };
        var obj = Viewport.controller.trigger("dialog:/general/warning", args);
        obj.itemClicked.connect(function(idx, title){
            switch (idx) {
            case 0: // Yes
                dis.ViewportType.open = false;
                break;
            case 1: // No
                break;
            }
            obj.ViewportType.open = false;
        });

        return false;
    }

    AddTrickView {
        id: addView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom
        onTrickPosted: dis.ViewportType.open = false

        property bool warnable: bodyText.length || codeText.length

        onWarnableChanged: {
            if (warnable)
                BackHandler.pushHandler(addView, dis.back);
            else
                BackHandler.removeHandler(addView);
        }
    }

    THeader {
        id: headerItem
        anchors.left: parent.left
        anchors.right: parent.right
        color: Colors.header
        light: true

        ColumnLayout {
            anchors.centerIn: parent
            spacing: -2 * Devices.density

            TLabel {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 10 * Devices.fontDensity
                text: parentId? qsTr("Reply to %1").arg(trickData.owner.fullname) : quote? qsTr("Quote") : qsTr("New Trick") + Translations.refresher
                color: Colors.headerText
            }

            CommunityCombo {
                Layout.alignment: Qt.AlignHCenter
                comboWidth: headerItem.width * 0.5
            }
        }
    }

    THeaderBackButton {
        color: Colors.headerText
        onClicked: dis.back()
    }
}
