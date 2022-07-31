import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

Item {
    id: dis

    property alias listView: lview
    property alias model: lview.model
    property bool followable: true

    TLabel {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: Constants.margins
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("There is no tag here") + Translations.refresher
        font.pixelSize: 8 * Devices.fontDensity
        opacity: 0.6
        visible: lview.count == 0 && !dis.model.refreshing
    }

    TScrollView {
        anchors.fill: parent

        TListView {
            id: lview

            section.property: "section_title"
            section.criteria: ViewSection.FullString
            section.delegate: Item {
                width: lview.width
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
            }

            header: TListRefresher {
                id: refresher
                view: lview
                onRefreshRequest: {
                    refreshing = true;
                    lview.model.refresh();
                }

                Connections {
                    target: lview.model
                    onRefreshingChanged: if (!lview.model.refreshing) refresher.refreshing = false;
                }
            }

            delegate: TItemDelegate {
                id: titem
                width: lview.width
                onClicked: {
                    var unreadsCount = 0;
                    if (!followable)
                        unreadsCount = model.unreads_count;

                    Viewport.controller.trigger("float:/tag", {"tag": model.tag, "unreadsCount": unreadsCount});
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 20 * Devices.density
                    anchors.rightMargin: 14 * Devices.density
                    spacing: 15 * Devices.density

                    TMaterialIcon {
                        text: MaterialIcons.mdi_tag
                        color: countRect.visible? Colors.accent : Colors.foreground
                        opacity: countRect.visible? 1 : 0.5
                    }

                    TLabel {
                        Layout.fillWidth: true
                        text: model.tag
                    }

                    TIconButton {
                        visible: !followable || followBtn.followed
                        materialIcon: model.notification != undefined && model.notification.enable?  MaterialIcons.mdi_bell : MaterialIcons.mdi_bell_outline
                        flat: true
                        highlighted: true
                        onClicked: Viewport.controller.trigger("bottomdrawer:/tag/notification", {"tag": model.tag, "settingss": model.notification})
                    }

                    RowLayout {
                        spacing: 2 * Devices.density

                        Rectangle {
                            id: followesRect
                            Layout.preferredWidth: Math.max(22 * Devices.density, followesRow.width + 10 * Devices.density)
                            Layout.preferredHeight: 22 * Devices.density
                            radius: 6 * Devices.density
                            color: Colors.accent
                            visible: followable

                            RowLayout {
                                id: followesRow
                                anchors.centerIn: parent
                                spacing: 2 * Devices.density

                                TMaterialIcon {
                                    font.pixelSize: 6 * Devices.fontDensity
                                    text: MaterialIcons.mdi_account
                                    color: "#fff"
                                }

                                TLabel {
                                    font.pixelSize: 8 * Devices.fontDensity
                                    text: model.followers
                                    color: "#fff"
                                }
                            }
                        }

                        Rectangle {
                            id: countRect
                            Layout.preferredWidth: Math.max(22 * Devices.density, countRow.width + 10 * Devices.density)
                            Layout.preferredHeight: 22 * Devices.density
                            radius: 6 * Devices.density
                            color: Colors.accent
                            visible: followable || (model.unreads_count > 0)

                            RowLayout {
                                id: countRow
                                anchors.centerIn: parent
                                spacing: 2 * Devices.density

                                TMaterialIcon {
                                    font.pixelSize: 6 * Devices.fontDensity
                                    text: MaterialIcons.mdi_tag
                                    color: "#fff"
                                }

                                TLabel {
                                    font.pixelSize: 8 * Devices.fontDensity
                                    text: followable? model.count : model.unreads_count
                                    color: "#fff"
                                }
                            }
                        }
                    }

                    TFollowButton {
                        id: followBtn
                        visible: followable
                        Layout.preferredWidth: refreshing? 40 :90 * Devices.density

                        followed: GlobalSettings.followedTags.count && GlobalSettings.followedTags.contains(model.tag)

                        followReq: FollowTagRequest {
                            tag: model.tag
                            onSuccessfull: {
                                GlobalSettings.followedTags.insert(tag, true);
                                GlobalSignals.tagsRefreshed();
                            }
                        }
                        unfollowReq: UnfollowTagRequest {
                            _tag: model.tag
                            onSuccessfull: {
                                GlobalSettings.followedTags.remove(_tag);
                                GlobalSignals.tagsRefreshed();
                            }
                        }
                    }
                }
            }
        }
    }
}
