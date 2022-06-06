import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import globals 1.0
import QtQuick.Window 2.3

Row {
    x: parent.width - width - 2 * Devices.density
    anchors.top: parent.top
    anchors.margins: 2 * Devices.density
    visible: GlobalSettings.frameless

    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    TitleBarButtonItem {
        width: 50 * Devices.density
        height: 32 * Devices.density
        text: MaterialIcons.mdi_window_minimize
        font.pixelSize: 11 * Devices.fontDensity
        onClicked: Window.window.showMinimized()
    }

    TitleBarButtonItem {
        width: 50 * Devices.density
        height: 32 * Devices.density
        text: Window.window.visibility == Window.Maximized? MaterialIcons.mdi_window_restore : MaterialIcons.mdi_window_maximize
        font.pixelSize: 11 * Devices.fontDensity
        onClicked: Window.window.visibility == Window.Maximized? Window.window.showNormal() : Window.window.showMaximized()
    }

    TitleBarButtonItem {
        width: 50 * Devices.density
        height: 32 * Devices.density
        text: MaterialIcons.mdi_window_close
        color: "#bbff0000"
        onClicked: AsemanApp.exit(0)
    }
}
