import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import models 1.0
import requests 1.0
import globals 1.0

Item {
    id: dis
    implicitWidth: menuComboRow.width + 8 * Devices.density
    implicitHeight: menuComboRow.height

    property real comboWidth: width

    function show() {
        var pos = Qt.point(menuCombo.width/2, menuCombo.height/2);
        var parent = menuCombo;
        while (parent && parent != Viewport.viewport) {
            pos.x += parent.x;
            pos.y += parent.y;
            parent = parent.parent;
        }

        Viewport.viewport.append(menuComponent, {"pointPad": pos}, "menu");
    }

    CommunitiesModel {
        id: cmodel
    }

    TMouseArea {
        id: menuCombo
        opacity: 0
        width: comboWidth
        height: 50 * Devices.density
        anchors.centerIn: parent
        onClicked: dis.show()
    }

    RowLayout {
        id: menuComboRow
        x: 6 * Devices.density
        spacing: 0

        TLabel {
            color: Colors.headerText
            font.pixelSize: 7 * Devices.fontDensity
            text: {
                let community = GlobalSettings.communityId? GlobalSettings.communityId : Bootstrap.defaultCommunity;
                for (var i=0; i<cmodel.count; i++) {
                    var c = cmodel.get(i);
                    if (c.id == community)
                        return c.title;
                }
                return ""
            }
        }

        TMaterialIcon {
            color: Colors.headerText
            font.pixelSize: 12 * Devices.fontDensity
            text: MaterialIcons.mdi_menu_down
        }
    }

    Component {
        id: menuComponent
        MenuView {
            id: menuItem
            x: pointPad.x - width/2
            y: pointPad.y
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = 0;
                var x = width/2;
                return Qt.point(x, y);
            }

            property point pointPad

            onItemClicked: {
                GlobalSettings.communityId = cmodel.get(index).id
                ViewportType.open = false;
            }

            model: AsemanListModel {
                data: {
                    var list = new Array;
                    for (var i=0; i<cmodel.count; i++) {
                        var c = cmodel.get(i);
                        list[list.length] = {
                            title: c.title,
                            icon: "mdi_account_group",
                            enabled: true
                        };
                    }

                    return list;
                }
            }

            TLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.bottom
                anchors.topMargin: 10 * Devices.density
                color: Colors.accent
                font.pixelSize: 9 * Devices.fontDensity
                text: qsTr("Choose Community") + Translations.refresher

                Rectangle {
                    anchors.fill: parent
                    color: Colors.background
                    anchors.margins: -6 * Devices.density
                    radius: 8 * Devices.density
                    z: -1
                }
            }
        }
    }
}
