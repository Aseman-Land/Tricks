import QtQuick 2.12
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

TPage {
    id: dis
    width: Constants.width
    height: Constants.height

    LoginRequest {
        id: loginReq
        allowGlobalBusy: true
        username: userLbl.text.toLowerCase()
        onSuccessfull: {
            GlobalSettings.loggedInWithoutPassword = false;
            GlobalSettings.accessToken = response.result.token
            dis.ViewportType.open = false;
        }
    }

    GoogleGetLinkRequest {
        id: googleReq
        allowGlobalBusy: true
        onSuccessfull: {
            googleCheckReq.session_id = response.result.session_id;
            Qt.openUrlExternally(response.result.authorize_url);
        }
    }

    GoogleCheckStateRequest {
        id: googleCheckReq
        onSuccessfull: {
            if (response.result.register_token) {
                Viewport.viewport.append(signup_component, {"googleRegisterToken": response.result.register_token}, "float");
            } else {
                GlobalSettings.loggedInWithoutPassword = true;
                GlobalSettings.accessToken = response.result.access_token;
                dis.ViewportType.open = false;
            }
            session_id = "";
        }
    }

    GithubGetLinkRequest {
        id: githubReq
        allowGlobalBusy: true
        onSuccessfull: {
            githubCheckReq.session_id = response.result.session_id;
            Qt.openUrlExternally(response.result.authorize_url);
        }
    }

    GithubCheckStateRequest {
        id: githubCheckReq
        onSuccessfull: {
            if (response.result.register_token) {
                Viewport.viewport.append(signup_component, {"githubRegisterToken": response.result.register_token}, "float");
            } else {
                GlobalSettings.loggedInWithoutPassword = true;
                GlobalSettings.accessToken = response.result.access_token;
                dis.ViewportType.open = false;
            }
            session_id = "";
        }
    }

    Connections {
        target: GlobalSignals
        function onUnsuspend() {
            if (googleCheckReq.session_id.length != 0) {
                googleCheckReq.allowGlobalBusy = true;
                googleCheckReq.doRequest();
            }
            if (githubCheckReq.session_id.length != 0) {
                githubCheckReq.allowGlobalBusy = true;
                githubCheckReq.doRequest();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Colors.backgroundDeep }
            GradientStop { position: 1.0; color: Colors.background }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.accent
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
                height: Math.max(flick.height, mainColumn.height + 200 * Devices.density)

                Rectangle {
                    anchors.fill: mainColumn
                    anchors.margins: -30 * Devices.density
                    radius: Constants.radius
                    color: Colors.background
                }

                ColumnLayout {
                    id: mainColumn
                    width: parent.width * 0.7
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -50 * Devices.density
                    spacing: 4 * Devices.density

                    TImage {
                        Layout.preferredWidth: 92 * Devices.density
                        Layout.preferredHeight: 92 * Devices.density
                        Layout.alignment: Qt.AlignHCenter
                        fillMode: Image.PreserveAspectFit
                        source: "../files/logo.png"
                        mipmap: true
                    }

                    TLabel {
                        font.pixelSize: 16 * Devices.fontDensity
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        text: Bootstrap.title
                    }

                    TTextField {
                        id: userLbl
                        Layout.topMargin: 14 * Devices.density
                        Layout.fillWidth: true
                        placeholderText: qsTr("Username") + Translations.refresher
                        font.pixelSize: 9 * Devices.fontDensity
                        horizontalAlignment: Text.AlignLeft
                        selectByMouse: Devices.isDesktop
                        leftPadding: GTranslations.reverseLayout? 0 : 40 * Devices.density
                        rightPadding: GTranslations.reverseLayout? 40 * Devices.density : 0
                        Layout.preferredHeight: 50 * Devices.density
                        validator: RegExpValidator { regExp: /[a-z0-9_]+/ }
                        minimumCharacters: Bootstrap.user.username_min_length
                        maximumCharacters: Bootstrap.user.username_max_length
                        inputMethodHints: Qt.ImhLowercaseOnly | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
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
                        minimumCharacters: Bootstrap.user.password_min_length
                        maximumCharacters: Bootstrap.user.password_max_length
                        inputMethodHints: Qt.ImhNoPredictiveText
                        Layout.preferredHeight: 50 * Devices.density
                        onAccepted: if(loginBtn.enabled) loginReq.doRequest(passLbl.text)

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

                    RowLayout {
                        spacing: 4 * Devices.density
                        Layout.alignment: Qt.AlignHCenter

                        TButton {
                            id: loginBtn
                            Layout.preferredWidth: flick.width * 0.3 - 2 * Devices.density
                            text: qsTr("Login") + Translations.refresher
                            enabled: passLbl.acceptable && userLbl.acceptable
                            highlighted: true
                            font.pixelSize: 9 * Devices.fontDensity
                            onClicked: loginReq.doRequest(passLbl.text)
                        }

                        TButton {
                            id: signupBtn
                            Layout.preferredWidth: flick.width * 0.3 - 2 * Devices.density
                            text: qsTr("Signup") + Translations.refresher
                            highlighted: true
                            font.pixelSize: 9 * Devices.fontDensity
                            onClicked: Viewport.viewport.append(signup_component, {}, "float")
                            IOSStyle.accent: "#333"
                            Material.accent: "#333"
                        }
                    }

                    TButton {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Forgot password?") + Translations.refresher
                        highlighted: true
                        flat: true
                        font.pixelSize: 9 * Devices.fontDensity
                        onClicked: Viewport.viewport.append(forget_pass_init_component, {}, "float")
                    }

                    ColumnLayout {
                        spacing: -8 * Devices.density
                        Layout.alignment: Qt.AlignHCenter

                        TIconButton {
                            id: googleBtn
                            Layout.alignment: Qt.AlignHCenter
                            materialText: qsTr("Sign-In using Google") + Translations.refresher
                            materialIcon: MaterialIcons.mdi_google
                            materialBold: true
                            highlighted: true
                            flat: true
                            font.pixelSize: 9 * Devices.fontDensity
                            onClicked: googleReq.doRequest()
                        }

                        TIconButton {
                            id: githubBtn
                            Layout.alignment: Qt.AlignHCenter
                            materialText: qsTr("Sign-In using Github") + Translations.refresher
                            materialIcon: MaterialIcons.mdi_github_circle
                            materialBold: true
                            highlighted: true
                            flat: true
                            font.pixelSize: 9 * Devices.fontDensity
                            onClicked: githubReq.doRequest()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: signup_component
        SignupPage {
            anchors.fill: parent
            onSignupSuccessfull: {
                GlobalSettings.introDone = false;
                GlobalSettings.loggedInWithoutPassword = (googleRegisterToken.length || githubRegisterToken.length);
                GlobalSettings.accessToken = accessToken;
                dis.ViewportType.open = false;
            }
        }
    }

    Component {
        id: forget_pass_init_component
        ForgotPasswordInit {
            anchors.fill: parent
        }
    }
}
