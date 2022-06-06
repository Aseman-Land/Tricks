import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Models 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Controls 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import globals 1.0
import "../models" as Models

RowLayout {

    property alias currentIndex: iconCombo.currentIndex
    property alias currentText: iconCombo.currentText

    ComboBox {
        id: iconCombo
        Layout.preferredWidth: 300 * Devices.density
        font.pixelSize: 9 * Devices.fontDensity
        model: Models.IconsModel { id: iconsModel }
        textRole: "icon"
        popup: Popup {
            id: iconComboPopup
            implicitHeight: 500 * Devices.density
            implicitWidth: iconCombo.width
            y: iconCombo.height
            padding: 0
            onOpened: if (!Devices.isWindows) iconSearchTimer.restart()

            Timer {
                id: iconSearchTimer
                interval: 400
                repeat: false
                onTriggered: {
                    iconSearchField.focus = true;
                    iconSearchField.forceActiveFocus();
                }
            }

            TextField {
                id: iconSearchField
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10 * Devices.density
                font.pixelSize: 9 * Devices.fontDensity
                placeholderText: qsTr("Search Keyword")
                horizontalAlignment: Text.AlignLeft
                height: 50 * Devices.density
                onTextChanged: refresh()

                function refresh() {
                    iconPopupModel.clear();
                    var kw = iconSearchField.text.toLowerCase();
                    var cnt = -1;
                    iconsModel.data.forEach(function(i){
                        cnt++;
                        if (kw.length && i.icon.indexOf(kw) == -1)
                            return;

                        iconPopupModel.append({"icon": i.icon, "iconIndex": cnt});
                    })
                }

                Component.onCompleted: refresh();
            }

            ListView {
                id: iconComboList
                anchors.right: parent.right
                anchors.top: iconSearchField.bottom
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.topMargin: 10 * Devices.density
                model: AsemanListModel { id: iconPopupModel }
                clip: true
                delegate: ItemDelegate {
                    width: iconCombo.width
                    height: 45 * Devices.density
                    onClicked: {
                        iconCombo.currentIndex = model.iconIndex;
                        iconComboPopup.close();
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10 * Devices.density
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10 * Devices.density

                        Label {
                            font.pixelSize: 12 * Devices.fontDensity
                            font.family: MaterialIcons.family
                            text: MaterialIcons[model.icon]
                        }

                        Label {
                            Layout.fillWidth: true
                            font.pixelSize: 9 * Devices.fontDensity
                            text: model.icon
                        }
                    }
                }

                HScrollBar {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    scrollArea: iconComboList
                    color: Colors.accent
                }
            }
        }
    }

    Label {
        font.pixelSize: 12 * Devices.fontDensity
        font.family: MaterialIcons.family
        text: MaterialIcons[iconCombo.currentText]
    }
}
