import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
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
        running: fmodel.refreshing
    }

    TScrollView {
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        TListView {
            id: lview
            model: VolcanoPaymentsModel {
                id: fmodel
            }
            delegate: TItemDelegate {
                width: lview.width
                height: 56 * Devices.density
                focusPolicy: Qt.ClickFocus

                Component.onCompleted: if (model.index == lview.count-1 && lview.model.more) lview.model.more()

                RowLayout {
                    id: pymntRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: Constants.margins
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Constants.spacing

                    TMaterialIcon {
                        text: model.out_payment? MaterialIcons.mdi_arrow_up : MaterialIcons.mdi_arrow_down
                        color: Material.color(model.out_payment? Material.Red : Material.Green)
                    }

                    ColumnLayout {
                        spacing: 4 * Devices.density

                        RowLayout {
                            TLabel {
                                Layout.fillWidth: true
                                font.bold: true
                                text: formater.output
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight
                                maximumLineCount: 1

                                TextFormater {
                                    id: formater
                                    delimiter: ","
                                    count: 3
                                    input: model.amount + ""
                                }
                            }

                            TLabel {
                                font.pixelSize: 8 * Devices.fontDensity
                                color: Colors.accent
                                text: {
                                    var dt = GlobalMethods.unNormalizeDate(model.datetime);
                                    return CalendarConv.convertDateTimeToString(dt, "yyyy/MM/dd hh:mm:ss");
                                }
                            }
                        }
                        TLabel {
                            Layout.fillWidth: true
                            opacity: 0.7
                            font.pixelSize: 7 * Devices.fontDensity
                            text: model.payment_req
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            elide: Text.ElideRight
                            maximumLineCount: 1
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
                text: qsTr("Payments") + Translations.refresher
            }
        }
    }

    THeaderBackButton {
        color: Colors.foreground
        onClicked: dis.ViewportType.open = false
    }
}
