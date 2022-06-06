import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import globals 1.0

TItemDelegate {
    implicitHeight: 56 * Devices.density
    focusPolicy: Qt.ClickFocus

    property string fullname
    property string username
    property string avatar
    property int userId
    property int ownerRole

    onOwnerRoleChanged: {
        if (ownerRole & 1) {
            roleIcon.text = MaterialIcons.mdi_check_decagram
        }
    }

    onClicked: Viewport.controller.trigger("float:/users", {"userId": userId, "title": fullname})

    RowLayout {
        id: likerRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Constants.margins
        anchors.verticalCenter: parent.verticalCenter
        spacing: Constants.spacing

        TAvatar {
            remoteUrl: avatar
        }

        ColumnLayout {
            spacing: 4 * Devices.density

            RowLayout {
                TLabel {
                    font.bold: true
                    text: fullname
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                TMaterialIcon {
                    id: roleIcon
                    font.pixelSize: 9 * Devices.fontDensity
                    visible: text.length
                    color: Colors.accent
                }
            }
            TLabel {
                Layout.fillWidth: true
                opacity: 0.7
                text: "@" + username
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
