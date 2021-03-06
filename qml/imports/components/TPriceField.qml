import QtQuick 2.14
import AsemanQml.Base 2.0
import globals 1.0

TNumberField {
    id: dis
    rightPadding: LayoutMirroring.enabled? 16 * Devices.density : unit.width + 16 * Devices.density
    leftPadding: LayoutMirroring.enabled? unit.width + 16 * Devices.density : 16 * Devices.density
    inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
    validator: RegularExpressionValidator { regularExpression: /[\,\d]+/ }
    text: "0"

    property alias unit: unit
    property string customValue

    onCustomValueChanged: setValue(customValue)

    onTextEdited: {
        if (formater.signalBlocker)
            return;

        formater.input = "" + (getValue() * 1);

        formater.signalBlocker = true;
        text = formater.output;
        formater.signalBlocker = false;
    }

    function setValue(value) {
        formater.input = Qt.binding( function(){ return "" + value; });
        text = Qt.binding( function(){ return formater.output; });
    }

    TextFormater {
        id: formater
        delimiter: ","
        count: 3

        property bool signalBlocker: false
    }

    TLabel {
        id: unit
        anchors.rightMargin: 8 * Devices.density
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 8 * Devices.fontDensity
        color: Colors.accent
    }
}
