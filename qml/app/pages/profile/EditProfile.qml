import QtQuick 2.14
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import Tricks 1.0
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: GlobalSettings.viewMode != 2? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    readonly property real labelsWidth: 120 * Devices.density

    Component.onCompleted: {
        GlobalSettings.googleConnectSessionId = "";
        GlobalSettings.githubConnectSessionId = "";
        GlobalSettings.appleConnectSessionId = "";
    }

    EditProfileRequest {
        id: req
        allowGlobalBusy: true
        fullname: fullnameField.text
        username: usernameField.text
        about: bioField.text
        onSuccessfull: {
            GlobalSignals.reloadMeRequest();
            GlobalSignals.refreshRequest();
            GlobalSignals.snackRequest(qsTr("Profile updated"));
            dis.ViewportType.open = false;
        }
    }

    GoogleGetLinkRequest {
        id: googleReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSettings.googleConnectSessionId = response.result.session_id;
            if (Devices.isIOS && Bootstrap.bultInBrowser && TricksTools.iosOpenUrl(response.result.authorize_url))
                GlobalSignals.unsuspend();
            else {
                Qt.openUrlExternally(response.result.authorize_url);
                GlobalSignals.waitLoginDialog();
            }
        }
    }

    GithubGetLinkRequest {
        id: githubReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSettings.githubConnectSessionId = response.result.session_id;
            if (Devices.isIOS && Bootstrap.bultInBrowser && TricksTools.iosOpenUrl(response.result.authorize_url))
                GlobalSignals.unsuspend();
            else {
                Qt.openUrlExternally(response.result.authorize_url);
                GlobalSignals.waitLoginDialog();
            }
        }
    }

    AppleGetLinkRequest {
        id: appleReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSettings.appleConnectSessionId = response.result.session_id;
            if (Devices.isIOS && Bootstrap.bultInBrowser && TricksTools.iosOpenUrl(response.result.authorize_url))
                GlobalSignals.unsuspend();
            else {
                Qt.openUrlExternally(response.result.authorize_url);
                GlobalSignals.waitLoginDialog();
            }
        }
    }

    DeleteMeRequest {
        id: delMeReq
        allowGlobalBusy: true
        onSuccessfull: doLogout()

        function doLogout() {
            Viewport.viewport.list.forEach(function(l){
                l.open = false;
            })

            GlobalSettings.userId = 0;
            GlobalSettings.username = "";
            GlobalSettings.fullname = "";
            GlobalSettings.avatar = "";
            GlobalSettings.about = "";
            GlobalSettings.accessToken = "";
            GlobalSettings.userInviteCode = "";
            GlobalSettings.notificationAsked = false;
            GlobalSettings.allowNotifications = false;

            Tools.deleteFile(Constants.cacheCodeFrames);
            Tools.deleteFile(Constants.cacheHighlighters);
            Tools.deleteFile(Constants.cacheNotifications);
            Tools.deleteFile(Constants.cacheBookmarks);
            Tools.deleteFile(Constants.cacheMyTags);
            Tools.deleteFile(Constants.cacheMyTricks);
            Tools.deleteFile(Constants.cacheProgrammingLanguages);
            Tools.deleteFile(Constants.cacheTags);
            Tools.deleteFile(Constants.cacheTimeline);
            Tools.deleteFile(Constants.cacheGlobal);
        }
    }

    function deteleMe() {
        var args = {
            "title": qsTr("Warning"),
            "body" : qsTr("Do you realy want to delete your account? If yes please enter your username blow and click on Yes.") ,
            "superPermission": true,
            "buttons": [qsTr("Yes"), qsTr("No")]
        };
        var obj = Viewport.controller.trigger("dialog:/general/warning", args);
        obj.itemClicked.connect(function(idx, title, username){
            switch (idx) {
            case 0: // Yes
                if (username == GlobalSettings.username)
                    delMeReq.doRequest();
                else {
                    Viewport.controller.trigger("dialog:/general/error", {"title": qsTr("Error"), "body": qsTr("Wrong username!")});
                    return;
                }
                break;
            case 1: // No
                break;
            }
            obj.ViewportType.open = false;
        });
    }

    TScrollView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerItem.bottom
        anchors.bottom: saveBtn.top

        TFlickable {
            id: flick
            contentWidth: scene.width
            contentHeight: scene.height

            Item {
                id: scene
                width: flick.width
                height: Math.max(flick.height, columnLyt.height + 40 * Devices.density)

                ColumnLayout {
                    id: columnLyt
                    width: scene.width - 40 * Devices.density
                    x: 20 * Devices.density
                    y: x
                    spacing: 0 * Devices.density

                    TLabel {
                        Layout.fillWidth: true
                        font.pixelSize: 12 * Devices.fontDensity
                        text: qsTr("General Details") + Translations.refresher
                        color: Colors.accent
                    }

                    RowLayout {
                        spacing: 8 * Devices.density

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            Layout.preferredHeight: 100 * Devices.density
                            color: Colors.accent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: 4 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.preferredWidth: labelsWidth
                                    text: qsTr("Fullname") + Translations.refresher
                                }

                                TTextField {
                                    id: fullnameField
                                    Layout.fillWidth: true
                                    text: GlobalSettings.fullname
                                    minimumCharacters: Bootstrap.user.fullname_min_length
                                    maximumCharacters: Bootstrap.user.fullname_max_length
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.preferredWidth: labelsWidth
                                    text: qsTr("Username") + Translations.refresher
                                }

                                TTextField {
                                    id: usernameField
                                    Layout.fillWidth: true
                                    validator: RegularExpressionValidator { regularExpression: /[a-z0-9_]+/ }
                                    inputMethodHints: Qt.ImhLowercaseOnly | Qt.ImhNoAutoUppercase
                                    minimumCharacters: Bootstrap.user.username_min_length
                                    maximumCharacters: Bootstrap.user.username_max_length
                                    text: GlobalSettings.username
                                }
                            }
                        }
                    }

                    TLabel {
                        Layout.topMargin: 20 * Devices.density
                        Layout.fillWidth: true
                        font.pixelSize: 12 * Devices.fontDensity
                        text: qsTr("Other") + Translations.refresher
                        color: Colors.accent
                    }

                    RowLayout {
                        spacing: 8 * Devices.density

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            Layout.preferredHeight: 110 * Devices.density
                            color: Colors.accent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: 4 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.preferredWidth: labelsWidth
                                    Layout.alignment: Qt.AlignTop
                                    text: qsTr("Biography") + Translations.refresher
                                }

                                TTextArea {
                                    id: bioField
                                    Layout.fillWidth: true
                                    Layout.minimumHeight: 100 * Devices.density
                                    text: GlobalSettings.about
                                    minimumCharacters: 0
                                    maximumCharacters: Bootstrap.user.about_max_length
                                }
                            }
                        }
                    }

                    TLabel {
                        Layout.topMargin: 20 * Devices.density
                        Layout.fillWidth: true
                        font.pixelSize: 12 * Devices.fontDensity
                        text: qsTr("Security") + Translations.refresher
                        color: Colors.accent
                        visible: !GlobalSettings.loggedInWithoutPassword
                    }

                    RowLayout {
                        spacing: 8 * Devices.density
                        visible: !GlobalSettings.loggedInWithoutPassword

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            Layout.preferredHeight: 120 * Devices.density
                            color: Colors.accent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: 4 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.preferredWidth: labelsWidth
                                    text: qsTr("Current") + Translations.refresher
                                }

                                TTextField {
                                    id: current_pass
                                    Layout.fillWidth: true
                                    echoMode: TextField.Password
                                    passwordCharacter: '*'
                                    passwordMaskDelay: 500
                                    minimumCharacters: Bootstrap.user.password_min_length
                                    maximumCharacters: Bootstrap.user.password_max_length
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.preferredWidth: labelsWidth
                                    text: qsTr("Password") + Translations.refresher
                                }

                                TTextField {
                                    id: new_pass
                                    Layout.fillWidth: true
                                    echoMode: TextField.Password
                                    passwordCharacter: '*'
                                    passwordMaskDelay: 500
                                    minimumCharacters: Bootstrap.user.password_min_length
                                    maximumCharacters: Bootstrap.user.password_max_length
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.preferredWidth: labelsWidth
                                    text: qsTr("Repeat Password") + Translations.refresher
                                }

                                TTextField {
                                    id: rep_pass
                                    Layout.fillWidth: true
                                    echoMode: TextField.Password
                                    passwordCharacter: '*'
                                    passwordMaskDelay: 500
                                    minimumCharacters: Bootstrap.user.password_min_length
                                    maximumCharacters: Bootstrap.user.password_max_length
                                }
                            }
                        }
                    }

                    TLabel {
                        Layout.topMargin: 20 * Devices.density
                        Layout.fillWidth: true
                        font.pixelSize: 12 * Devices.fontDensity
                        text: qsTr("Authentication Methods") + Translations.refresher
                        color: Colors.accent
                        visible: authMethodsRow.visible
                    }

                    RowLayout {
                        id: authMethodsRow
                        spacing: 8 * Devices.density
                        visible: Bootstrap.appleSignIn || Bootstrap.googleSignIn || Bootstrap.githubSignIn

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            Layout.preferredHeight: 120 * Devices.density
                            color: Colors.accent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: 4 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density
                                Layout.topMargin: -10 * Devices.density
                                visible: Bootstrap.googleSignIn

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Google") + Translations.refresher
                                }

                                TIconButton {
                                    enabled: !GlobalSettings.google
                                    materialIcon: MaterialIcons.mdi_google
                                    materialText: GlobalSettings.google? qsTr("Connected") : qsTr("Connect") + Translations.refresher
                                    flat: true
                                    materialColor: GlobalSettings.google? Colors.foreground :"#e34133"
                                    opacity: enabled? 1 : 0.7
                                    onClicked: googleReq.doRequest()
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density
                                Layout.topMargin: -10 * Devices.density
                                visible: Bootstrap.githubSignIn

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Github") + Translations.refresher
                                }

                                TIconButton {
                                    enabled: !GlobalSettings.github
                                    materialIcon: MaterialIcons.mdi_github_circle
                                    materialText: GlobalSettings.github? qsTr("Connected") : qsTr("Connect") + Translations.refresher
                                    flat: true
                                    materialColor: GlobalSettings.github? Colors.foreground : "#2cb44c"
                                    opacity: enabled? 1 : 0.7
                                    onClicked: githubReq.doRequest()
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density
                                Layout.topMargin: -10 * Devices.density
                                visible: Bootstrap.appleSignIn

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Apple") + Translations.refresher
                                }

                                TIconButton {
                                    enabled: !GlobalSettings.apple
                                    materialIcon: MaterialIcons.mdi_apple
                                    materialText: GlobalSettings.apple? qsTr("Connected") : qsTr("Connect") + Translations.refresher
                                    flat: true
                                    materialColor: Colors.foreground
                                    opacity: enabled? 1 : 0.7
                                    onClicked: appleReq.doRequest()
                                }
                            }
                        }
                    }

                    TLabel {
                        Layout.topMargin: 20 * Devices.density
                        Layout.fillWidth: true
                        font.pixelSize: 12 * Devices.fontDensity
                        text: qsTr("Delete Account") + Translations.refresher
                        color: Colors.accent
                    }

                    RowLayout {
                        spacing: 8 * Devices.density

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            Layout.preferredHeight: 40 * Devices.density
                            color: Colors.accent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: 4 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Delete Account") + Translations.refresher
                                }

                                TIconButton {
                                    materialIcon: MaterialIcons.mdi_delete_forever
                                    materialText: qsTr("Delete") + Translations.refresher
                                    flat: true
                                    materialColor: "#a00"
                                    onClicked: deteleMe()
                                }
                            }
                        }
                    }

                    Item {
                        Layout.preferredWidth: 2 * Devices.density
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }

    TButton {
        id: saveBtn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Constants.keyboardHeight? Constants.keyboardHeight - saveBtn.height : Devices.navigationBarHeight + Constants.margins
        anchors.margins: Constants.margins
        text: qsTr("Save changes") + Translations.refresher
        highlighted: true
        enabled: fullnameField.acceptable && usernameField.acceptable && bioField.acceptable &&
                 fullnameField.acceptableInput && usernameField.acceptableInput &&
                 (new_pass.length == 0 || (current_pass.length && new_pass.acceptableInput && new_pass.acceptable && new_pass.text == rep_pass.text))
        onClicked: {
            req.doRequest(new_pass.text, current_pass.text);
        }
    }

    THeader {
        id: headerItem
        anchors.left: parent.left
        anchors.right: parent.right
        text: qsTr("Edit Profile") + Translations.refresher
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
