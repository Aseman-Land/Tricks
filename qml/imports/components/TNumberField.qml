import QtQuick 2.14
import AsemanQml.Base 2.0
import globals 1.0

TTextField {
    inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
    validator: RegularExpressionValidator { regularExpression: /\d+/ }

    onFocusChanged: if (focus && text == "0") selectAll()

    function getValue() {
        return Tools.stringRemove(text, ",") * 1;
    }
}
