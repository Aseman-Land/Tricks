import QtQuick 2.15
import QtQuick.Controls 2.3
import AsemanQml.Base 2.0
import Tricks 1.0

Item {
    id: dis

    property Item textField: parent

    onTextFieldChanged: {
        if (!core.apiIsAvailable)
            return;
        core.color = textField.color;
        textField.color = "transparent";
        textField.readOnly = true;
    }

    Connections {
        target: textField
        function onFocusChanged() {
            if (!core.apiIsAvailable)
                return;
            if (textField.focus)
                core.focus()
        }
    }

    PointMapListener {
        id: listener
        source: textField
    }

    TextInputHandlerCore {
        id: core
        x: listener.result.x
        y: listener.result.y
        width: textField.width
        height: textField.height
        leftPadding: textField.leftPadding + textField.leftInset
        topPadding: textField.topPadding + textField.topInset
        rightPadding: textField.rightPadding + textField.rightInset
        bottomPaddding: textField.bottomPadding + textField.bottomInset
        text: textField.text
        font: textField.font
        echoMode: textField.echoMode
        visible: textField.visible
        horizonalAlignment: {
            if (!dis.LayoutMirroring.enabled)
                return textField.horizontalAlignment;

            switch (textField.horizontalAlignment) {
            case TextField.AlignLeft:
                return TextField.AlignRight;
            case TextField.AlignRight:
                return TextField.AlignLeft;
            default:
                return textField.horizontalAlignment;
            }
        }
        onTextChanged: textField.text = text
        onFocusedChanged: {
            textField.focus = core.focused;
            if (core.focused)
                textField.forceActiveFocus();
        }
    }
}
