import QtQuick 2.12
import QtQuick.Controls 2.3
import AsemanQml.Base 2.0
import AsemanQml.Labs 2.0
import globals 1.0

TextField {
    id: dis
    implicitHeight: 34 * Devices.density
    horizontalAlignment: Text.AlignLeft
    font.pixelSize: 9 * Devices.fontDensity
    topInset: 0
    topPadding: 4 * Devices.density
    selectByMouse: Devices.isDesktop

    onPressed: {
        if (Devices.isDesktop && event.button == Qt.RightButton) {
            menu.x = event.x;
            menu.y = event.y;
            menu.open()
        }
    }

    property int minimumCharacters: -1
    property int maximumCharacters: -1

    readonly property bool acceptable: visible && (minimumCharacters == maximumCharacters || (text.trim().length >= minimumCharacters && text.trim().length <= maximumCharacters))

    SamsungInputBugFixer {}

    Rectangle {
        width: visible? maxWidth * ratio : 0
        x: 10 * Devices.density
        height: 2 * Devices.density
        radius: height/2
        visible: minimumCharacters != maximumCharacters
        color: ratio>0.9 || dis.length<minimumCharacters? "#f00" : ratio>0.8? "#fa0" : Colors.accent
        anchors.bottom: parent.bottom

        readonly property real ratio: Math.min(1, dis.length / maximumCharacters)
        readonly property real maxWidth: dis.width - 2*x
    }

    QmlWidgetMenu {
        id: menu

        QmlWidgetMenuItem {
            text: qsTr("Select All") + Translations.refresher
            shortcut: "Ctrl+A"
            onClicked: dis.selectAll()
        }
        QmlWidgetMenuItem {
            text: qsTr("Deselect") + Translations.refresher
            onClicked: dis.deselect()
        }
        QmlWidgetMenuItem{}
        QmlWidgetMenuItem {
            text: qsTr("Copy") + Translations.refresher
            shortcut: "Ctrl+C"
            onClicked: dis.copy()
        }
        QmlWidgetMenuItem {
            text: qsTr("Cut") + Translations.refresher
            shortcut: "Ctrl+X"
            onClicked: dis.cut()
        }
        QmlWidgetMenuItem {
            text: qsTr("Paste") + Translations.refresher
            shortcut: "Ctrl+V"
            onClicked: dis.paste()
            enabled: dis.canPaste
        }
        QmlWidgetMenuItem{}
        QmlWidgetMenuItem {
            text: qsTr("Undo") + Translations.refresher
            shortcut: "Ctrl+Z"
            onClicked: dis.cut()
            enabled: dis.canUndo
        }
        QmlWidgetMenuItem {
            text: qsTr("Redo") + Translations.refresher
            shortcut: "Ctrl+Shift+Z"
            onClicked: dis.paste()
            enabled: dis.canRedo
        }
        QmlWidgetMenuItem{}
        QmlWidgetMenuItem {
            text: qsTr("Delete") + Translations.refresher
            shortcut: "Delete"
        }
    }
}
