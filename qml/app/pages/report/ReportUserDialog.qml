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
    ViewportType.touchToClose: true

    property alias userId: req._user_id

    ReportUserRequest {
        id: req
        allowGlobalBusy: true
        onSuccessfull: {
            dis.ViewportType.open = false;
            GlobalSignals.snackRequest(qsTr("Report sent successfully"));
        }
    }

    ReportView {
        id: addView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom
        onReportRequest: {
            req.message = message;
            req.report_type = type;
            req.doRequest();
        }
    }

    THeader {
        id: headerItem
        anchors.left: parent.left
        anchors.right: parent.right
        color: Colors.header
        light: true

        TLabel {
            anchors.centerIn: parent
            font.pixelSize: 10 * Devices.fontDensity
            text: qsTr("Report %1").arg(dis.title) + Translations.refresher
            color: Colors.headerText
        }
    }

    THeaderBackButton {
        color: Colors.headerText
        onClicked: dis.ViewportType.open = false
    }
}
