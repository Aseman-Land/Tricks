import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import AsemanQml.Models 2.0
import QtQuick.Layouts 1.3
import components 1.0
import requests 1.0
import models 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: Viewport.viewport.width > Viewport.viewport.height && !Devices.isMobile? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    property alias trickId: req._id
    property bool deleted

    onTrickIdChanged: {
        Tools.jsDelayCall(10, req.doRequest)
    }

    Connections {
        target: GlobalSignals
        function onTrickUpdated(data) {
            if (data.id == trickId) {
                item.pushData(data);
                tags.model = data.tags;
                trickTime.text = CalendarConv.convertDateTimeToString( GlobalMethods.unNormalizeDate(data.datetime) );
                parentsModel.change(data.parent_tricks.reverse());
                if (data.app)
                    trickApp.text = data.app.title;
            }
        }
    }

    GetTrickRequest {
        id: req
        onSuccessfull: {
            if (response.result.length == 0)
                dis.deleted = true;
            else
                response.result.forEach(GlobalSignals.trickUpdated)
        }
    }

    EscapeItem {
        id: scene
        parent: flick.headerItem
        width: flick.width
        height: columnLyt.height + columnLyt.y * 2

        ColumnLayout {
            id: columnLyt
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10 * Devices.density

            Timer {
                id: listBlockUpdate
                interval: 300
                repeat: false
            }

            ColumnLayout {
                id: parentsColumns
                spacing: 0

                Repeater {
                    id: parents_repeater
                    model: AsemanListModel {
                        id: parentsModel
                    }
                    TrickMinimalItem {
                        Layout.fillWidth: true
                        onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks", {"trickId": mainId})
                        commentMode: true
                        commentLineTop: model.index != 0 || parentId != 0
                        commentLineBottom: true
                        stateHeaderVisible: model.index == 0

                        Connections {
                            target: GlobalSignals
                            function onTrickUpdated(i) {
                                if (i.id != model.id)
                                    return;

                                listBlockUpdate.restart();
                                let idx = model.index;
                                parentsModel.insert(idx+1, i);
                                parentsModel.remove(idx);
                            }
                        }

                        Component.onCompleted: {
                            if (model.index == parentsModel.count-1 && parentsModel.more && !listBlockUpdate.running) parentsModel.more();
                            pushData(parentsModel.get(model.index));
                        }
                    }
                }
            }

            TrickMinimalItem {
                id: item
                Layout.fillWidth: true
                visible: !dis.deleted
                onTrickDeleted: dis.ViewportType.open = false
            }

            TLabel {
                Layout.fillWidth: true
                Layout.topMargin: Constants.margins
                horizontalAlignment: Text.AlignHCenter
                font.bold: true
                opacity: 0.4
                visible: dis.deleted
                text: qsTr("Deleted Trick") + Translations.refresher
                font.pixelSize: 12 * Devices.fontDensity
            }

            RowLayout {
                Layout.leftMargin: Constants.margins
                Layout.rightMargin: Constants.margins
                spacing: 4 * Devices.density
                visible: !dis.deleted

                TLabel {
                    id: trickTime
                    font.pixelSize: 8 * Devices.fontDensity
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    opacity: 0.6
                }

                TLabel {
                    font.pixelSize: 8 * Devices.fontDensity
                    text: "-"
                    opacity: 0.6
                }

                TLabel {
                    id: trickApp
                    Layout.fillWidth: true
                    font.pixelSize: 8 * Devices.fontDensity
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: Colors.accent
                }

                Item {
                    Layout.preferredWidth: likesBtn.width
                    Layout.preferredHeight: 2

                    TIconButton {
                        id: likesBtn
                        anchors.verticalCenter: parent.verticalCenter
                        materialText: qsTr("%1 Likes").arg(item.rates) + Translations.refresher
                        onClicked: Viewport.controller.trigger("page:/tricks/rates", {"trickId": dis.trickId})
                    }
                }
            }

            ColumnLayout {
                spacing: 6 * Devices.density

                THListSeprator {
                    visible: !dis.deleted
                }

                RowLayout {
                    Layout.leftMargin: Constants.margins
                    Layout.rightMargin: Constants.margins
                    spacing: 4 * Devices.density
                    visible: !dis.deleted

                    TLabel {
                        Layout.alignment: Qt.AlignVCenter
                        font.bold: true
                        text: qsTr("Tags:") + Translations.refresher
                    }

                    TLabel {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        font.pixelSize: 8 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        opacity: 0.7
                        text: qsTr("There is no assigned tag.") + Translations.refresher
                        visible: tags.count == 0
                    }

                    TListView {
                        id: tags
                        spacing: 4 * Devices.density
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30 * Devices.density
                        orientation: ListView.Horizontal
                        clip: true
                        delegate: Rectangle {
                            width: tagLbl.width + 14 * Devices.density
                            height: tags.height
                            radius: 4 * Devices.density
                            color: {
                                if (modelData == "bug_report")
                                    return Colors.darkMode? "#ff4245" : "#a00";
                                else
                                if (modelData == "feedback")
                                    return Colors.darkMode? "#0d80ec" : "#0d80ec";
                                else
                                    return Qt.darker(Colors.accent, (marea.containsMouse? 1.1 : 0))
                            }

                            TMouseArea {
                                id: marea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: Viewport.controller.trigger("float:/tag", {"tag": modelData})
                            }

                            TLabel {
                                id: tagLbl
                                anchors.centerIn: parent
                                font.pixelSize: 8 * Devices.fontDensity
                                text: modelData
                                color: "#fff"
                            }
                        }
                    }
                }

                THListSeprator {}

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: commentSendRow.height + 8 * Devices.density

                    RowLayout {
                        id: commentSendRow
                        y: 4 * Devices.density
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: Constants.margins
                        opacity: enabled? 1 : 0.5

                        TTextArea {
                            Layout.fillWidth: true
                            placeholderText: qsTr("Write a comment") + Translations.refresher
                            enabled: false
                        }

                        TIconButton {
                            Layout.fillHeight: true
                            materialIcon: MaterialIcons.mdi_send
                            highlighted: true
                            enabled: false
                        }
                    }

                    TMouseArea {
                        anchors.fill: parent
                        onClicked: Viewport.controller.trigger("float:/tricks/add", {"parentId": dis.trickId, "trickData": item.trickData})
                    }
                }

                THListSeprator {
                    visible: !dis.deleted
                }
            }
        }
    }

    TScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: !req.refreshing

        TListView {
            id: flick
            contentWidth: scene.width
            contentHeight: scene.height
            header: Item {
                width: flick.width
                height: scene.height
            }

            Timer {
                id: commentsBlockUpdate
                interval: 300
                repeat: false
            }

            model: TricksCommentsModel { id: commentsModel; parentId: dis.trickId; reversed: true }
            delegate: TrickMinimalItem {
                width: flick.width
                commentMode: true
//                commentLineTop: true
//                commentLineBottom: model.index < commentsModel.count-1
                onClicked: Viewport.controller.trigger("float:/tricks", {"trickId": trickId})

                Connections {
                    target: GlobalSignals
                    function onTrickUpdated(i) {
                        if (i.id != model.id)
                            return;

                        commentsBlockUpdate.restart();
                        let idx = model.index;
                        commentsModel.insert(idx + 1, i);
                        commentsModel.remove(idx);
                    }
                }

                THListSeprator {
                    width: parent.width
                    anchors.bottom: parent.bottom
                }

                Component.onCompleted: {
                    if (model.index == commentsModel.count-1 && commentsModel.more && !commentsBlockUpdate.running) commentsModel.more();
                    pushData(commentsModel.get(model.index));
                    parentId = 0;
                }
            }
        }
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right
        text: qsTr("Trick") + Translations.refresher

        TBusyIndicator {
            id: busyIndic
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: y
            width: 18 * Devices.density
            height: 18 * Devices.density
            running: req.refreshing || commentsModel.refreshing
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
