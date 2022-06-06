pragma Singleton

import QtQuick 2.10
import QtQuick.Controls.Material 2.0
import AsemanQml.Base 2.0

AsemanObject
{
    property alias ubuntuFont: ubuntu_font.name
    property alias monoFont: mono_font.name
    property alias vazirFont: vazir.name
    property alias ubuntuBoldFont: ubuntu_bold_font.name
    readonly property url resourcePath: "fonts"

    property string globalFont: ubuntuFont + ", " + vazirFont + ", Noto Color Emoji"

    FontLoader { id: ubuntu_bold_font; source: "fonts/Ubuntu-B.ttf"}
    FontLoader { id: vazir; source: "fonts/Vazir-Regular-FD.ttf"}
    FontLoader { id: ubuntu_font; source: "fonts/Ubuntu-R.ttf" }
    FontLoader { id: mono_font; source: "fonts/UbuntuMono-R.ttf" }

    function init() {
        AsemanApp.globalFont.family = globalFont
    }
}
