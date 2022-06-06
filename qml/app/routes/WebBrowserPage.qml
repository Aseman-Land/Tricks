import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Controls.Material 2.0
import AsemanQml.Viewport 2.0
import QtWebView 1.1
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import globals 1.0

Page {
    id: webPage
    width: Constants.width
    height: Constants.height

    property string link

    signal urlReqested(string url)

    onLinkChanged: {
        if (link == "ehraz.aseman.io/api/v1/payment/confirmed") {
            Tools.jsDelayCall(2000, function(){
                webPage.ViewportType.open = false;
                webPage.urlReqested("ehraz-hoviat://successfull")
            })
        }
    }

    Timer {
        id: visibleTimer
        running: true
        interval: 1000
        repeat: false
        onTriggered: checkUrl()
    }

    function checkUrl() {
        if (!visibleTimer.running) webPage.urlReqested(webView.url)
    }

    Rectangle {
        anchors.fill: parent
        color: Material.background
    }

    Item {
        id: scene
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom

        WebView {
            id: webView
            url: {
                if (webPage.link.indexOf("http") == 0)
                    return webPage.link;
                else
                    return "https://" + webPage.link;
            }
            anchors.fill: parent
            visible: !visibleTimer.running && webPage.link.length && !loading
            onUrlChanged: checkUrl()
        }
    }

    BusyIndicator {
        id: busyIndicator
        Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
        anchors.centerIn: parent
        running: Colors.androidStyle? false : webView.loading
    }

    Rectangle {
        id: headerItem
        color: Material.background
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Devices.standardTitleBarHeight + Devices.statusBarHeight

        ProgressBar {
            id: progressBar
            indeterminate: true
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left
            visible: Colors.androidStyle? webView.loading : false
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 14 * Devices.density
            anchors.rightMargin: 2 * Devices.density
            anchors.bottom: parent.bottom
            height: Devices.standardTitleBarHeight

            Label {
                id: webTitle
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 12 * Devices.fontDensity
                horizontalAlignment: Text.AlignLeft
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                maximumLineCount: 1
                elide: Text.ElideRight
                text: webView.title
            }
        }
    }

    THeaderBackButton {
        color: "#333"
        onClicked: webPage.ViewportType.open = false
    }
}

