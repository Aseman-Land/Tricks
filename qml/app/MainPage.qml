import QtQuick 2.12
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Controls 2.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import AsemanQml.MaterialIcons 2.0
import globals 1.0
import requests 1.0
import components 1.0
import "auth" as Auth
import "pages/timeline" as TimeLine
import "routes"

TPage {
    id: dis
    font.family: Fonts.globalFont

    IOSStyle.accent: Colors.accent
    IOSStyle.primary: Colors.primary

    Material.accent: Colors.accent
    Material.primary: Colors.primary

    property alias viewport: mainViewport

    property Item loginMessageDialog

    onLoginMessageDialogChanged: if (!loginMessageDialog) GlobalSignals.unsuspend()

    Connections {
        target: GlobalSignals
        function onSnackRequest(text) {
            snackBar.open(text);
        }
        function onErrorRequest(text) {
            errorsSnackBar.open(text);
        }
        function onFatalRequest(text) {
            var args = {
                "title": qsTr("Fatal"),
                "body" : text
            };
            GlobalMethods.viewController.trigger("dialog:/general/warning", args);
        }
        function onCloseAllPages() {
            mainViewport.list.forEach(function(i){
                i.open = false;
            });
        }
        function onWaitLoginDialog() {
            if (Devices.isWebAssembly)
                loginMessageDialog = mainController.trigger("dialog:/general/warning", {"title": qsTr("Authenticate"), "body": qsTr("Tap OK if done.")});
        }
    }

    Component.onCompleted: {
        if (Devices.isWebAssembly)
            mainController.trigger("dialog:/general/warning", {"title": qsTr("It's Beta"), "body": qsTr("It's a <b>beta</b> test of the Tricks app that built on a <b>beta</b> technology that\n" +
                                                                                                                      "also built on a <b>beta</b> technology. It's slow, It's buggy.\n" +
                                                                                                                      "It's not a typical web app. It's web assembly. So be careful. it's super <b>beta</b> :)")});
    }

    Viewport {
        id: mainViewport
        anchors.fill: parent
        mainItem: TPage {
            anchors.fill: parent

            TLoader {
                anchors.fill: parent
                active: GlobalSettings.accessToken.length !== 0
                sourceComponent: Home {
                    anchors.fill: parent
                }
            }

            TLoader {
                anchors.fill: parent
                active: GlobalSettings.accessToken.length === 0 && (Bootstrap.timeline.unauth_timeline && GlobalSettings.viewMode == 2)
                sourceComponent: TimeLine.NonAuthTimeLinePage {
                    anchors.fill: parent
                }
            }

            TLoader {
                anchors.fill: parent
                active: GlobalSettings.accessToken.length === 0 && (!Bootstrap.timeline.unauth_timeline || GlobalSettings.viewMode != 2)
                sourceComponent: Auth.AuthPage {
                    anchors.fill: parent
                }
            }

            Auth.SignInCheckArea {
                anchors.fill: parent
            }
        }
    }

    Snackbar {
        id: snackBar
        z: 1000
    }

    Snackbar {
        id: errorsSnackBar
        z: 1000
        color: "#a00"
    }

    ViewController {
        id: mainController
        viewport: mainViewport
        Component.onCompleted: GlobalMethods.viewController = mainController
    }
}
