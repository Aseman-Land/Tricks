import QtQuick 2.12
import AsemanQml.Base 2.0
import globals 1.0

TextEdit {
    font.pixelSize: 9 * Devices.fontDensity
    font.family: Fonts.globalFont
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
    selectionColor: Colors.accent
    selectedTextColor: "#fff"
    color: Colors.foreground
}
