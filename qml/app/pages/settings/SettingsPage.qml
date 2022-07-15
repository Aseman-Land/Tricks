import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Models 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: Viewport.viewport.width > Viewport.viewport.height && !Devices.isMobile? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    property int balance: {
        try {
            return valcanoReq.response.result.balance;
        } catch (e) {
            return 0;
        }
    }

    property Item withdrawDlg
    property Item depositDlg
    property Item paymentsDlg

    onWithdrawDlgChanged: if (!withdrawDlg) valcanoReq.doRequest()
    onDepositDlgChanged: if (!depositDlg) valcanoReq.doRequest()

    GetVolcanoWalletRequest {
        id: valcanoReq
        allowShowErrors: true
        Component.onCompleted: if (GlobalSettings.accessToken.length) doRequest()
    }

    TScrollView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Constants.keyboardHeight? Constants.keyboardHeight : Devices.navigationBarHeight

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
                        text: qsTr("Interface Settings") + Translations.refresher
                        color: Colors.darkAccent
                    }

                    RowLayout {
                        spacing: 8 * Devices.density

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            color: Colors.darkAccent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: -10 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Theme") + Translations.refresher
                                }

                                TComboBox {
                                    id: themeCombo
                                    model: isAndroidStyle? [qsTr("Light") + Translations.refresher, qsTr("Dark")] :
                                                           [qsTr("Auto") + Translations.refresher, qsTr("Light"), qsTr("Dark")]
                                    onActivated: {
                                        if (isAndroidStyle) {
                                            switch (themeCombo.currentIndex) {
                                            case 0:
                                                GlobalSettings.androidTheme = Material.Light;
                                                break;
                                            case 1:
                                                GlobalSettings.androidTheme = Material.Dark;
                                                break;
                                            }
                                        } else {
                                            switch (themeCombo.currentIndex) {
                                            case 0:
                                                GlobalSettings.iosTheme = IOSStyle.System;
                                                break;
                                            case 1:
                                                GlobalSettings.iosTheme = IOSStyle.Light;
                                                break;
                                            case 2:
                                                GlobalSettings.iosTheme = IOSStyle.Dark;
                                                break;
                                            }
                                        }
                                    }

                                    Component.onCompleted: {
                                        if (isAndroidStyle) {
                                            switch (GlobalSettings.androidTheme) {
                                            case Material.System:
                                                themeCombo.currentIndex = 0;
                                                break;
                                            case Material.Light:
                                                themeCombo.currentIndex = 1;
                                                break;
                                            case Material.Dark:
                                                themeCombo.currentIndex = 2;
                                                break;
                                            }
                                        } else {
                                            switch (GlobalSettings.iosTheme) {
                                            case IOSStyle.System:
                                                themeCombo.currentIndex = 0;
                                                break;
                                            case IOSStyle.Light:
                                                themeCombo.currentIndex = 1;
                                                break;
                                            case IOSStyle.Dark:
                                                themeCombo.currentIndex = 2;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Force codes follows theme") + Translations.refresher
                                }

                                TSwitch {
                                    checked: GlobalSettings.forceCodeTheme
                                    onClicked: GlobalSettings.forceCodeTheme = checked
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Color Header") + Translations.refresher
                                }

                                TSwitch {
                                    enabled: themeCombo.currentIndex != 2
                                    checked: !GlobalSettings.lightHeader
                                    onClicked: GlobalSettings.lightHeader = !checked
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density
                                visible: false

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Language") + Translations.refresher
                                }

                                TComboBox {
                                    model: GTranslations.model
                                    textRole: "title"
                                    onActivated: GlobalSettings.language = GTranslations.model.get(currentIndex).key
                                    Component.onCompleted: {
                                        for (var i=0; i<GTranslations.model.count; i++)
                                            if (GTranslations.model.get(i).key == GlobalSettings.language) {
                                                currentIndex = i;
                                                return;
                                            }
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density
                                enabled: qtFirebase
                                visible: GlobalSettings.accessToken.length

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Notifications") + Translations.refresher
                                }

                                TSwitch {
                                    checked: GlobalSettings.allowNotifications
                                    onClicked: {
                                        if (checked)
                                            Notifications.allow();
                                        else
                                            Notifications.disAllow();
                                    }
                                }
                            }
                        }
                    }

                    TLabel {
                        Layout.fillWidth: true
                        Layout.topMargin: 10 * Devices.density
                        font.pixelSize: 12 * Devices.fontDensity
                        text: qsTr("Your Tips") + Translations.refresher
                        color: Colors.darkAccent
                        visible: GlobalSettings.accessToken.length
                    }

                    RowLayout {
                        spacing: 8 * Devices.density
                        visible: GlobalSettings.accessToken.length

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            color: Colors.darkAccent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: -5 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    text: qsTr("Balance:") + Translations.refresher
                                }

                                TLabel {
                                    text: valcanoReq.refreshing? qsTr("Loading...") : qsTr("%1 SAT").arg(formater.output) + Translations.refresher
                                    color: Colors.accent
                                    Layout.fillWidth: true

                                    TextFormater {
                                        id: formater
                                        delimiter: ","
                                        count: 3
                                        input: "" + Math.floor(dis.balance / 1000)
                                    }
                                }

                                TBusyIndicator {
                                    running: valcanoReq.refreshing
                                    visible: valcanoReq.refreshing
                                    Layout.preferredWidth: 16 * Devices.density
                                    Layout.preferredHeight: 16 * Devices.density
                                }

                                TIconButton {
                                    id: moreBtn
                                    materialIcon: MaterialIcons.mdi_dots_vertical
                                    materialColor: Colors.accent
                                    onClicked: {
                                        var pos = Qt.point(dis.LayoutMirroring.enabled? Constants.radius : moreBtn.width - Constants.radius, moreBtn.height/2);
                                        var parent = moreBtn;
                                        while (parent && parent != Viewport.viewport) {
                                            pos.x += parent.x;
                                            pos.y += parent.y;
                                            parent = parent.parent;
                                        }

                                        Viewport.viewport.append(menuComponent, {"pointPad": pos}, "menu");
                                    }
                                }
                            }
                        }
                    }

                    TLabel {
                        Layout.fillWidth: true
                        Layout.topMargin: 10 * Devices.density
                        font.pixelSize: 12 * Devices.fontDensity
                        text: qsTr("Other") + Translations.refresher
                        color: Colors.darkAccent
                        visible: GlobalSettings.accessToken.length
                    }

                    RowLayout {
                        spacing: 8 * Devices.density
                        visible: GlobalSettings.accessToken.length

                        Rectangle {
                            Layout.leftMargin: 8 * Devices.density
                            Layout.preferredWidth: 2 * Devices.density
                            color: Colors.darkAccent
                        }

                        ColumnLayout {
                            Layout.topMargin: 8 * Devices.density
                            spacing: -5 * Devices.density

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Invitation Code") + Translations.refresher
                                }

                                TLabel {
                                    visible: GlobalSettings.userInviteCode.length == 0
                                    text: qsTr("None") + Translations.refresher
                                }

                                TIconButton {
                                    visible: GlobalSettings.userInviteCode.length
                                    materialIcon: MaterialIcons.mdi_content_copy
                                    materialText: GlobalSettings.userInviteCode
                                    materialColor: Colors.accent
                                    onClicked: {
                                        Devices.setClipboard(GlobalSettings.userInviteCode);
                                        GlobalSignals.snackRequest(qsTr("Invitation code copied"));
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Agreement") + Translations.refresher
                                }

                                TIconButton {
                                    materialText: qsTr("Review")
                                    materialColor: Colors.accent
                                    onClicked: Viewport.controller.trigger("popup:/licenses/agreement", {"buttons": false})
                                }
                            }

                            RowLayout {
                                spacing: 4 * Devices.density
                                enabled: qzxing

                                TLabel {
                                    Layout.fillWidth: true
                                    text: qsTr("Link to other Device") + Translations.refresher
                                }

                                TIconButton {
                                    materialText: qsTr("QR Code")
                                    materialColor: Colors.accent
                                    opacity: qzxing? 1 : 0.5
                                    onClicked: Viewport.controller.trigger("bottomdrawer:/settings/qr-login")
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

    THeader {
        id: headerItem
        anchors.left: parent.left
        anchors.right: parent.right
        text: qsTr("Settings") + Translations.refresher
    }

    THeaderBackButton {
        color: IOSStyle.foreground
        onClicked: dis.ViewportType.open = false
    }

    Component {
        id: menuComponent
        MenuView {
            id: menuItem
            x: dis.LayoutMirroring.enabled? pointPad.x : pointPad.x - width
            y: pointPad.y + (openFromTop? 10 * Devices.density : - height - 10 * Devices.density)
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = openFromTop? 0 : height;
                var x = dis.LayoutMirroring.enabled? 0 : width;
                return Qt.point(x, y);
            }

            property point pointPad
            property int index
            property bool openFromTop: pointPad.y < Viewport.viewport.height/2

            onItemClicked: {
                switch (index) {
                case 0:
                    paymentsDlg = Viewport.controller.trigger("float:/volcano/payments");
                    break;
                case 1:
                    depositDlg = Viewport.controller.trigger("bottomdrawer:/volcano/deposit");
                    break;
                case 2:
                    withdrawDlg = Viewport.controller.trigger("bottomdrawer:/volcano/withdraw");
                    break;
                }

                ViewportType.open = false;
            }

            model: AsemanListModel {
                data: [
                    {
                        title: qsTr("Payments"),
                        icon: "mdi_view_list",
                        enabled: true
                    },
                    {
                        title: qsTr("Deposit"),
                        icon: "mdi_plus",
                        enabled: true
                    },
                    {
                        title: qsTr("Withdraw"),
                        icon: "mdi_minus",
                        enabled: true
                    }
                ]
            }
        }
    }
}
