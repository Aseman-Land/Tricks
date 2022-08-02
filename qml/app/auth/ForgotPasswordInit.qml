import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.MaterialIcons 2.0
import AsemanQml.Viewport 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import globals 1.0
import components 1.0
import requests 1.0

Page {
    id: dis
    width: Constants.width
    height: Constants.height
    ViewportType.maximumWidth: GlobalSettings.viewMode != 2? 500 * Devices.density : 0

    Component.onCompleted: {
        if (GlobalSettings.forgetPasswordEmail.length) {
            Tools.jsDelayCall(300, function(){
                Viewport.viewport.append(forget_pass_component, {}, "popup");
            });
        }
    }

    InitForgetPasswordRequest {
        id: regReq
        allowGlobalBusy: true
        email: emailLbl.text
        onSuccessfull: {
            GlobalSettings.forgetPasswordEmail = email;
            Viewport.viewport.append(forget_pass_component, {}, "popup");
            GlobalSignals.snackRequest(qsTr("Code sent successfully."));
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Colors.backgroundDeep }
            GradientStop { position: 1.0; color: Colors.background }
        }
    }

    TScrollView {
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Constants.keyboardHeight

        TFlickable {
            id: flick
            contentWidth: scene.width
            contentHeight: scene.height

            EscapeItem {
                id: scene
                width: flick.width
                height: Math.max(flick.height, columnLyt.height + 200 * Devices.density)

                ColumnLayout {
                    id: columnLyt
                    width: parent.width * 0.6
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -50 * Devices.density
                    spacing: 4 * Devices.density

                    TLabel {
                        font.pixelSize: 16 * Devices.fontDensity
                        font.bold: true
                        text: qsTr("Forgot Password") + Translations.refresher
                    }

                    TLabel {
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("Please enter your username below and tap on the 'Send Email' button to send recovery code to your Email.") + Translations.refresher
                    }

                    TTextField {
                        id: emailLbl
                        Layout.fillWidth: true
                        placeholderText: qsTr("Email") + Translations.refresher
                        font.pixelSize: 9 * Devices.fontDensity
                        horizontalAlignment: Text.AlignLeft
                        selectByMouse: Devices.isDesktop
                        leftPadding: GTranslations.reverseLayout? 0 : 40 * Devices.density
                        rightPadding: GTranslations.reverseLayout? 40 * Devices.density : 0
                        Layout.preferredHeight: 50 * Devices.density
                        validator: RegExpValidator { regExp: /[a-z0-9\._]+\@[a-z0-9\._]+/ }
                        inputMethodHints: Qt.ImhLowercaseOnly | Qt.ImhNoAutoUppercase
                        onAccepted: regReq.doRequest()

                        TLabel {
                            anchors.left: parent.left
                            anchors.leftMargin: 12 * Devices.density
                            anchors.verticalCenterOffset: 3 * Devices.density
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: MaterialIcons.family
                            font.pixelSize: 12 * Devices.fontDensity
                            opacity: 0.6
                            text: MaterialIcons.mdi_email
                        }
                    }

                    RowLayout {
                        spacing: 4 * Devices.density

                        TButton {
                            id: sendBtn
                            Layout.preferredWidth: flick.width * 0.3 - 2 * Devices.density
                            text: qsTr("Send Email") + Translations.refresher
                            enabled: emailLbl.acceptableInput && emailLbl.acceptable
                            highlighted: true
                            font.pixelSize: 9 * Devices.fontDensity
                            onClicked: regReq.doRequest()
                        }

                        TButton {
                            id: cancelBtn
                            Layout.preferredWidth: flick.width * 0.3 - 2 * Devices.density
                            text: qsTr("Cancel") + Translations.refresher
                            highlighted: true
                            font.pixelSize: 9 * Devices.fontDensity
                            onClicked: dis.ViewportType.open = false
                            IOSStyle.accent: "#333"
                            Material.accent: "#333"
                        }
                    }
                }
            }
        }
    }

    Component {
        id: forget_pass_component
        ForgotPassword {
            anchors.fill: parent
            onDone: dis.ViewportType.open = false;
        }
    }
}
