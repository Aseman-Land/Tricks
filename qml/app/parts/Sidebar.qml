import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Modern 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import components 1.0
import globals 1.0
import models 1.0
import requests 1.0

EscapeItem {
    id: dis

    property alias headerHeight: header.height

    signal searchRequest(string keyword)
    signal itemClicked()

    Item {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        height: Constants.headerHeight

        IOSStyle.theme: Colors.headerIsDark? IOSStyle.Dark : IOSStyle.Light
        Material.theme: Colors.headerIsDark? Material.Dark : Material.Light

        TSearchField {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 6 * Devices.density
            height: 32 * Devices.density
            onSearchRequest: dis.searchRequest(keyword)
        }
    }

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        spacing: 0

        SideBarItemDelegate {
            Layout.topMargin: 10 * Devices.density
            materialText: qsTr("Home") + Translations.refresher
            materialIcon: MaterialIcons.mdi_home
            visible: GlobalSettings.viewMode != 2
            selected: GlobalSettings.homeTabIndex == 0 && GlobalSettings.homeCurrentTag.length == 0
            onClicked: {
                GlobalSettings.homeCurrentTag = "";
                GlobalSettings.homeTabIndex = 0;
                dis.itemClicked();
            }
        }

        SideBarItemDelegate {
            materialText: qsTr("Global") + Translations.refresher
            materialIcon: MaterialIcons.mdi_earth
            visible: GlobalSettings.viewMode != 2
            selected: GlobalSettings.homeTabIndex == 1 && GlobalSettings.homeCurrentTag.length == 0
            onClicked: {
                GlobalSettings.homeCurrentTag = "";
                GlobalSettings.homeTabIndex = 1;
                dis.itemClicked();
            }
        }

        THListSeprator {
            visible: GlobalSettings.viewMode != 2
        }

        SideBarItemDelegate {
            materialText: GlobalSettings.fullname
            materialIcon: MaterialIcons.mdi_account
            onClicked: {
                Viewport.controller.trigger("float:/users", {"userId": GlobalSettings.userId});
                dis.itemClicked();
            }
        }

        THListSeprator {}

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            TScrollView {
                anchors.fill: parent

                TListView {
                    id: tagsList
                    model: GlobalMyTagsModel

                    UpdateTagViews {
                        id: updateReq
                        onSuccessfull: {
                            var list = Tools.toVariantList(tags);
                            list.forEach(GlobalSignals.tagReaded)
                        }
                    }

                    section.property: "section_title"
                    section.criteria: ViewSection.FullString
                    section.delegate: Item {
                        width: tagsList.width
                        height: 30 * Devices.density

                        TLabel {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: Constants.spacing
                            anchors.bottomMargin: 4 * Devices.density
                            font.pixelSize: 10 * Devices.fontDensity
                            text: section
                            color: Colors.accent
                        }

                        TBusyIndicator {
                            anchors.right: readBtn.right
                            anchors.rightMargin: 4 * Devices.density
                            anchors.verticalCenter: parent.verticalCenter
                            width: 12 * Devices.density
                            height: 12 * Devices.density
                            running: updateReq.refreshing
                        }

                        TButton {
                            id: readBtn
                            anchors.rightMargin: 4 * Devices.density
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 60 * Devices.density
                            height: 32 * Devices.density
                            font.pixelSize: 7 * Devices.fontDensity
                            text: qsTr("Read All") + Translations.refresher
                            visible: section != "Read" && !updateReq.refreshing
                            flat: false
                            highlighted: true
                            onClicked: {
                                updateReq.tags = Tools.toVariantList(GlobalMyTagsModel.unreadedTags);
                                updateReq.doRequest();
                            }
                        }
                    }

                    delegate: SideBarItemDelegate {
                        width: tagsList.width
                        materialText: model.tag
                        materialIcon: MaterialIcons.mdi_tag
                        materialCount: model.unreads_count? model.unreads_count : -1
                        selected: GlobalSettings.homeCurrentTag == model.tag
                        onClicked: {
                            if (GlobalSettings.viewMode == 2)
                                Viewport.controller.trigger("float:/tag", {"tag": model.tag});
                            else
                                GlobalSettings.homeCurrentTag = model.tag;
                            dis.itemClicked();
                        }
                    }
                }
            }

            TBusyIndicator {
                anchors.centerIn: parent
                running: GlobalMyTagsModel.refreshing && GlobalMyTagsModel.count == 0
            }
        }

        SideBarItemDelegate {
            Layout.topMargin: 10 * Devices.density
            materialText: qsTr("More Tags") + Translations.refresher
            materialIcon: MaterialIcons.mdi_more
            onClicked: {
                Viewport.controller.trigger("float:/tags");
                dis.itemClicked();
            }
        }

        THListSeprator {}

        SideBarItemDelegate {
            materialText: qsTr("Notifications") + Translations.refresher
            materialIcon: MaterialIcons.mdi_bell
            onClicked: {
                Viewport.controller.trigger("float:/notifications");
                dis.itemClicked();
            }
        }

        SideBarItemDelegate {
            materialText: qsTr("Settings") + Translations.refresher
            materialIcon: MaterialIcons.mdi_settings
            onClicked: {
                Viewport.controller.trigger("float:/settings");
                dis.itemClicked();
            }
        }

//        SideBarItemDelegate {
//            materialText: qsTr("About") + Translations.refresher
//            materialIcon: MaterialIcons.mdi_information
//            onClicked: {
//                Viewport.controller.trigger("float:/about");
//                dis.itemClicked();
//            }
//        }
    }
}
