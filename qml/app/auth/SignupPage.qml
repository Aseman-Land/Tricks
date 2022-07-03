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

    signal signupSuccessfull(string accessToken)

    property alias googleRegisterToken: googleRegReq.google_register_token

    RegisterRequest {
        id: regReq
        allowGlobalBusy: true
        username: userLbl.text.toLowerCase()
        fullname: nameLbl.text
        email: emailLbl.text.toLowerCase()
        invitation_code: invitationLbl.text.toLowerCase()
        agreement_version: Bootstrap.agreement.version
        onSuccessfull: {
            dis.ViewportType.open = false;
            signupSuccessfull(response.result.access_token);
        }
    }

    GoogleRegisterRequest {
        id: googleRegReq
        allowGlobalBusy: true
        username: userLbl.text.toLowerCase()
        fullname: nameLbl.text
        agreement_version: Bootstrap.agreement.version
        onSuccessfull: {
            dis.ViewportType.open = false;
            signupSuccessfull(response.result.access_token);
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Colors.backgroundDeep }
            GradientStop { position: 1.0; color: Colors.background }
        }
    }

    Item {
        anchors.left: parent.left
        anchors.leftMargin: 80 * Devices.density
        anchors.right: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        visible: !GlobalSettings.mobileView

        TImage {
            width: parent.width * 0.6
            height: parent.height * 0.6
            sourceSize: Qt.size(width*1.2, height*1.2)
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
            source: Colors.darkMode? "../files/login_dark.png" : "../files/login_light.png"
        }
    }

    TScrollView {
        anchors.right: parent.right
        anchors.rightMargin: GlobalSettings.mobileView? 0 : 80 * Devices.density
        anchors.left: GlobalSettings.mobileView? parent.left : parent.horizontalCenter
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
                        text: {
                            if (googleRegisterToken.length)
                                return qsTr("Complete Registration") + Translations.refresher;
                            return qsTr("Register") + Translations.refresher;
                        }
                    }

                    TTextField {
                        id: userLbl
                        Layout.fillWidth: true
                        placeholderText: qsTr("Username") + Translations.refresher
                        font.pixelSize: 9 * Devices.fontDensity
                        horizontalAlignment: Text.AlignLeft
                        selectByMouse: Devices.isDesktop
                        leftPadding: GTranslations.reverseLayout? 0 : 40 * Devices.density
                        rightPadding: GTranslations.reverseLayout? 40 * Devices.density : 0
                        Layout.preferredHeight: 50 * Devices.density
                        validator: RegExpValidator { regExp: /[a-z0-9_]+/ }
                        inputMethodHints: Qt.ImhLowercaseOnly | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                        minimumCharacters: Bootstrap.user.username_min_length
                        maximumCharacters: Bootstrap.user.username_max_length
                        onAccepted: passLbl.focus = true

                        Label {
                            anchors.left: parent.left
                            anchors.leftMargin: 12 * Devices.density
                            anchors.verticalCenterOffset: 3 * Devices.density
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: MaterialIcons.family
                            font.pixelSize: 12 * Devices.fontDensity
                            opacity: 0.6
                            text: MaterialIcons.mdi_account
                        }
                    }

                    TTextField {
                        id: passLbl
                        Layout.fillWidth: true
                        placeholderText: qsTr("Password") + Translations.refresher
                        font.pixelSize: 9 * Devices.fontDensity
                        horizontalAlignment: Text.AlignLeft
                        echoMode: TextField.Password
                        passwordCharacter: '*'
                        passwordMaskDelay: 500
                        selectByMouse: Devices.isDesktop
                        leftPadding: GTranslations.reverseLayout? 0 : 40 * Devices.density
                        rightPadding: GTranslations.reverseLayout? 40 * Devices.density : 0
                        Layout.preferredHeight: 50 * Devices.density
                        visible: googleRegisterToken.length == 0
                        minimumCharacters: Bootstrap.user.password_min_length
                        maximumCharacters: Bootstrap.user.password_max_length
                        inputMethodHints: Qt.ImhNoPredictiveText

                        TLabel {
                            anchors.left: parent.left
                            anchors.leftMargin: 12 * Devices.density
                            anchors.verticalCenterOffset: 3 * Devices.density
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: MaterialIcons.family
                            font.pixelSize: 12 * Devices.fontDensity
                            opacity: 0.6
                            text: MaterialIcons.mdi_textbox_password
                        }
                    }

                    TTextField {
                        id: nameLbl
                        Layout.fillWidth: true
                        placeholderText: qsTr("Fullname") + Translations.refresher
                        font.pixelSize: 9 * Devices.fontDensity
                        horizontalAlignment: Text.AlignLeft
                        selectByMouse: Devices.isDesktop
                        leftPadding: GTranslations.reverseLayout? 0 : 40 * Devices.density
                        rightPadding: GTranslations.reverseLayout? 40 * Devices.density : 0
                        Layout.preferredHeight: 50 * Devices.density
                        minimumCharacters: Bootstrap.user.fullname_min_length
                        maximumCharacters: Bootstrap.user.fullname_max_length
                        onAccepted: passLbl.focus = true

                        TLabel {
                            anchors.left: parent.left
                            anchors.leftMargin: 12 * Devices.density
                            anchors.verticalCenterOffset: 3 * Devices.density
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: MaterialIcons.family
                            font.pixelSize: 12 * Devices.fontDensity
                            opacity: 0.6
                            text: MaterialIcons.mdi_account
                        }
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
                        visible: googleRegisterToken.length == 0
                        validator: RegExpValidator { regExp: /[a-z0-9\._]+\@[a-z0-9\._]+/ }
                        inputMethodHints: Qt.ImhLowercaseOnly | Qt.ImhNoAutoUppercase
                        onAccepted: (invitationLbl.visible? invitationLbl : passLbl).focus = true

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

                    TTextField {
                        id: invitationLbl
                        Layout.fillWidth: true
                        placeholderText: qsTr("Invitation Code") + Translations.refresher
                        font.pixelSize: 9 * Devices.fontDensity
                        horizontalAlignment: Text.AlignLeft
                        selectByMouse: Devices.isDesktop
                        leftPadding: GTranslations.reverseLayout? 0 : 40 * Devices.density
                        rightPadding: GTranslations.reverseLayout? 40 * Devices.density : 0
                        Layout.preferredHeight: 50 * Devices.density
                        inputMethodHints: Qt.ImhLowercaseOnly | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                        visible: Bootstrap.signup.invitation_code && googleRegisterToken.length == 0
                        onAccepted: passLbl.focus = true

                        TLabel {
                            anchors.left: parent.left
                            anchors.leftMargin: 12 * Devices.density
                            anchors.verticalCenterOffset: 3 * Devices.density
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: MaterialIcons.family
                            font.pixelSize: 12 * Devices.fontDensity
                            opacity: 0.6
                            text: MaterialIcons.mdi_gift
                        }
                    }

                    RowLayout {
                        spacing: 4 * Devices.density

                        TButton {
                            id: signupBtn
                            Layout.preferredWidth: flick.width * 0.3 - 2 * Devices.density
                            text: qsTr("Signup") + Translations.refresher
                            enabled: (!passLbl.visible || (passLbl.acceptableInput && passLbl.acceptable)) &&
                                     userLbl.acceptableInput && userLbl.acceptable &&
                                     nameLbl.acceptableInput && nameLbl.acceptable &&
                                     (!emailLbl.visible || emailLbl.acceptableInput) &&
                                     (!invitationLbl.visible || invitationLbl.length)
                            highlighted: true
                            font.pixelSize: 9 * Devices.fontDensity
                            onClicked: {
                                var obj = Viewport.controller.trigger("popup:/licenses/agreement")
                                obj.accepted.connect(function(){
                                    if (googleRegisterToken.length)
                                        googleRegReq.doRequest();
                                    else
                                        regReq.doRequest(passLbl.text);
                                });
                            }
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
}
