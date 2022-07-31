import QtQuick 2.0
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Modern 2.0
import AsemanQml.MaterialIcons 2.0
import AsemanQml.Models 2.0
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis

    property alias headerItem: headerItem

    Component.onCompleted: refresh()

    function refresh() {
        Tools.jsDelayCall(10, gmodel.refresh);
    }

    TimeLine {
        id: timeLine
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        model: GlobalNonAuthTimelineModel {
            id: gmodel
        }
        listView.footer: Item { width: 1; height: 150 * Devices.density }
        topMargin: headerItem.height
        globalViewMode: true
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.top: signupArea.top
        anchors.topMargin: -Constants.margins
        anchors.right: parent.right
        height: 150 * Devices.density + Devices.navigationBarHeight
        color: Colors.background

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            color: Colors.foreground
            height: 1 * Devices.density
            opacity: 0.1
        }
    }

    ColumnLayout {
        id: signupArea
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: Constants.margins
        anchors.bottomMargin: Devices.navigationBarHeight + Constants.margins
        spacing: Constants.spacing

        TLabel {
            Layout.fillWidth: true
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignHCenter
            color: Colors.accent
            text: qsTr("Signup and Login to post, share, like, comment, search and follow Tricks.") + Translations.refresher
        }

        TButton {
            Layout.fillWidth: true
            text: qsTr("Login/Signup") + Translations.refresher
            highlighted: true
            onClicked: Viewport.controller.trigger("float:/auth")
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: headerItem.bottom
        anchors.top: headerItem.top
        color: Colors.background
    }

    THeader {
        id: headerItem
        y: timeLine.headerVisible? 0 : -Devices.standardTitleBarHeight
        anchors.left: parent.left
        anchors.right: parent.right
        height: defaultHeight
        light: true
        color: Colors.header

        Behavior on y {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }

        ColumnLayout {
            id: headerTitle
            anchors.centerIn: parent
            spacing: -2 * Devices.density

            TLabel {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 10 * Devices.fontDensity
                text: Bootstrap.title
                color: Colors.headerText
            }

            CommunityCombo {
                Layout.alignment: Qt.AlignHCenter
                comboWidth: headerItem.width * 0.5
            }
        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10 * Devices.density
            spacing: 10 * Devices.density

            TBusyIndicator {
                Layout.preferredWidth: 18 * Devices.density
                Layout.preferredHeight: 18 * Devices.density
                running: timeLine.model.refreshing
                IOSStyle.foreground: Colors.headerText
                Material.accent: Colors.headerText
            }

            TIconButton {
                id: editBtn
                Layout.preferredHeight: 40 * Devices.density
                visible: GlobalSettings.homeTabIndex == 0 && GlobalSettings.viewMode == 2
                materialIcon: MaterialIcons.mdi_dots_vertical
                flat: true
                materialColor: Colors.headerText
                onClicked: {
                    var pos = Qt.point(dis.LayoutMirroring.enabled? Constants.radius : editBtn.width - Constants.radius, editBtn.height);
                    var parent = editBtn;
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

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        color: headerItem.color
        height: Devices.statusBarHeight
    }

    Component {
        id: menuComponent
        MenuView {
            id: menuItem
            x: pointPad.x - width
            y: pointPad.y
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = 0;
                var x = dis.LayoutMirroring.enabled? 0 : width;
                return Qt.point(x, y);
            }

            property point pointPad
            property int index

            onItemClicked: {
                switch (index) {
                case 0:
                    Viewport.controller.trigger("float:/settings");
                    ViewportType.open = false;
                    break;

                case 1:
                    Viewport.controller.trigger("float:/about");
                    ViewportType.open = false;
                    break;
                }
            }

            model: AsemanListModel {
                data: [
                    {
                        title: qsTr("Settings"),
                        icon: "mdi_settings",
                        enabled: true
                    },
                    {
                        title: qsTr("About Tricks"),
                        icon: "mdi_information",
                        enabled: true
                    }
                ]
            }
        }
    }
}
