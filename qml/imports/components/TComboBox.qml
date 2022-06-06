import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.Labs 2.0
import AsemanQml.MaterialIcons 2.0
import globals 1.0

ComboBox {
    id: control
    font.pixelSize: 9 * Devices.fontDensity
    font.family: Fonts.globalFont
    popup.modal: true
    popup.dim: true
    delegate: ItemDelegate {
        width: parent? parent.width : control.popup.width

        TLabel {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 10 * Devices.density
            text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
            color: Colors.foreground
        }
    }
}
