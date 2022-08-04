import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import QtQuick.Controls.IOSStyle 2.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: GlobalSettings.viewMode != 2? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    TBusyIndicator {
        anchors.centerIn: parent
        running: tmodel.refreshing
    }

    DeleteTokensRequest {
        id: deleteReq
        allowGlobalBusy: true
        onSuccessfull: {
            if (GlobalSettings.accessToken.indexOf(token) > 0) {
                GlobalSignals.closeAllPages();
                GlobalSettings.accessToken = "";
            } else {
                tmodel.refresh();
            }
        }
    }

    TScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        TListView {
            id: lview
            model: TokensModel {
                id: tmodel
            }
            delegate: TItemDelegate {
                width: lview.width
                implicitHeight: 60 * Devices.density
                focusPolicy: Qt.ClickFocus

                RowLayout {
                    id: likerRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Constants.margins
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Constants.spacing

                    TMaterialIcon {
                        text: MaterialIcons.mdi_key
                    }

                    ColumnLayout {
                        spacing: 0

                        TLabel {
                            Layout.fillWidth: true
                            font.bold: true
                            text: model.title
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        TLabel {
                            Layout.fillWidth: true
                            text: model.token
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            opacity: 0.7
                        }

                        TLabel {
                            Layout.fillWidth: true
                            opacity: currentSession? 1 : 0.7
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            font.pixelSize: 8 * Devices.fontDensity
                            color: currentSession? Colors.accent : Colors.foreground
                            text: {
                                if (currentSession)
                                    return qsTr("Current Session")
                                var dt = GlobalMethods.unNormalizeDate(model.datetime);
                                return CalendarConv.convertDateTimeToString(dt, "yyyy/MM/dd hh:mm:ss");
                            }

                            property bool currentSession: GlobalSettings.accessToken.indexOf(model.token) > 0
                        }
                    }

                    TIconButton {
                        Layout.preferredWidth: 45 * Devices.density
                        materialIcon: MaterialIcons.mdi_trash_can
                        highlighted: true
                        flat: true
                        materialColor: Colors.darkMode? "#ff4245" : "#a00"
                        IOSStyle.accent: Colors.darkMode? "#ff4245" : "#a00"
                        Material.accent: Colors.darkMode? "#ff4245" : "#a00"
                        onClicked: {
                            var args = {
                                "title": qsTr("Revoke Token"),
                                "body" : qsTr("Do you realy want to revoke this token?") ,
                                "buttons": [qsTr("Yes"), qsTr("No")]
                            };
                            var obj = Viewport.controller.trigger("dialog:/general/warning", args);
                            obj.itemClicked.connect(function(idx, title){
                                switch (idx) {
                                case 0: // Yes
                                    deleteReq.token = model.token;
                                    deleteReq.doRequest();
                                    break;
                                case 1: // No
                                    break;
                                }
                                obj.ViewportType.open = false;
                            });
                        }
                    }
                }
            }
        }
    }

    THeader {
        id: header
        anchors.left: parent.left
        anchors.right: parent.right

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0

            TLabel {
                Layout.alignment: Qt.AlignHCenter
                font.pixelSize: 10 * Devices.fontDensity
                text: qsTr("Tokens") + Translations.refresher
            }
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
