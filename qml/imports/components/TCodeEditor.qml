import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Labs 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import models 1.0
import globals 1.0

Item {
    id: dis
    implicitHeight: mainLyt.height

    property alias acceptable: tArea.acceptable
    property alias placeholderText: tArea.placeholderText
    property alias text: tArea.text
    property alias minimumCharacters: tArea.minimumCharacters
    property alias maximumCharacters: tArea.maximumCharacters
    property alias cursorPosition: tArea.cursorPosition
    property real minimumEditorHeight: 50 * Devices.density

    property alias definitionCombo: definitionCombo
    property alias themeCombo: themeCombo

    property alias darkTheme: highlighter.darkMode

    IOSStyle.theme: darkTheme? IOSStyle.Dark : IOSStyle.Light
    Material.theme: darkTheme? Material.Dark : Material.Light

    function clear() {
        tArea.clear()
    }

    Rectangle {
        anchors.fill: parent
        radius: Constants.radius
        color: darkTheme? "#151718" : "#fff"
        z: -1
    }

    ColumnLayout {
        id: mainLyt
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 0

        Item {
            Layout.topMargin: tArea.leftPadding/2
            Layout.leftMargin: tArea.leftPadding
            Layout.rightMargin: tArea.leftPadding
            Layout.fillWidth: true
            Layout.preferredHeight: toolbarRow.height

            RowLayout {
                id: toolbarRow
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 4 * Devices.density
                clip: true

                TLabel {
                    font.pixelSize: 8 * Devices.fontDensity
                    text: qsTr("Theme:") + Translations.refresher
                }

                TComboBox {
                    id: themeCombo
                    Layout.preferredWidth: 110 * Devices.density
                    font.pixelSize: 8 * Devices.fontDensity
                    model: HighlightersModel { id: hmodel }
                    textRole: "name"
                    onCurrentTextChanged: highlighter.theme = currentText
                    onActivated: GlobalSettings.defaultCodeTheme = currentText
                    onCountChanged: {
                        for (var i=0; i<model.count; i++)
                            if (model.get(i).name.toLowerCase() == GlobalSettings.defaultCodeTheme.toLowerCase()) {
                                currentIndex = i;
                                break;
                            }
                    }
                }

                Item {
                    Layout.preferredHeight: 1
                    Layout.preferredWidth: 10 * Devices.density
                }

                TLabel {
                    font.pixelSize: 8 * Devices.fontDensity
                    text: qsTr("Definitions:") + Translations.refresher
                }

                TComboBox {
                    id: definitionCombo
                    Layout.preferredWidth: 90 * Devices.density
                    font.pixelSize: 8 * Devices.fontDensity
                    model: ProgrammingLanguagesModel { id: pmodel }
                    textRole: "name"
                    onCurrentTextChanged: highlighter.definition = currentText
                    onActivated: GlobalSettings.defaultCodeDefinition = currentText
                    onCountChanged: {
                        for (var i=0; i<model.count; i++)
                            if (model.get(i).name.toLowerCase() == GlobalSettings.defaultCodeDefinition.toLowerCase()) {
                                currentIndex = i;
                                break;
                            }
                    }
                }

                Item {
                    Layout.preferredHeight: 1
                    Layout.fillWidth: true
                }

                TBusyIndicator {
                    Layout.preferredWidth: 16 * Devices.density
                    Layout.preferredHeight: 16 * Devices.density
                    running: pmodel.refreshing || hmodel.refreshing
                }
            }
        }

        TTextArea {
            id: tArea
            Layout.fillWidth: true
            Layout.minimumHeight: minimumEditorHeight
            font.family: Fonts.monoFont
            font.pixelSize: 10 * Devices.fontDensity
            leftPadding: Constants.margins
            rightPadding: leftPadding
            topPadding: leftPadding/2
            bottomPadding: leftPadding
            horizontalAlignment: Text.AlignLeft
            selectByMouse: Devices.isDesktop
            inputMethodHints: Qt.ImhPreferLowercase | Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText

            property string indentText: "    "

            background: Item {}

            onTextChanged: {
                if (indentTimer.lastLength >= length) {
                    indentTimer.lastLength = length;
                    return;
                }

                if (!indentTimer.running) {
                    indentTimer.restart();
                    switch (text[cursorPosition-1]) {
                    case '{':
                        insert(cursorPosition, '}');
                        cursorPosition = cursorPosition - 1;
                        break;
                    case '(':
                        insert(cursorPosition, ')');
                        cursorPosition = cursorPosition - 1;
                        break;
                    case '[':
                        insert(cursorPosition, ']');
                        cursorPosition = cursorPosition - 1;
                        break;
                    }

                    if (text[cursorPosition-1] == text[cursorPosition]) {
                        switch (text[cursorPosition]) {
                        case '}':
                            remove(cursorPosition, cursorPosition+1);
                            break;
                        case ')':
                            remove(cursorPosition, cursorPosition+1);
                            break;
                        case ']':
                            remove(cursorPosition, cursorPosition+1);
                            break;
                        }
                    }

                    if (length - indentTimer.lastLength > 10) {
                        var pos_from_end = length - cursorPosition;
                        text = fixIndent(text);
                        cursorPosition = (length - pos_from_end)
                    }
                    indentTimer.lastLength = length;
                }
            }

            function fixIndent(code) {
                code = Tools.stringReplace(code, "\t", indentText);
                code = Tools.stringReplace(code, "\n\r", "\n");
                code = Tools.stringReplace(code, "\r", "\n");
                var lines = code.split("\n");
                var min = 100000;
                lines.forEach(function(l){
                    if (l.trim() == 0)
                        return;

                    var indent = 0;
                    for (var i=0; i<l.length; i++) {
                        if (l[i] == " ")
                            indent++;
                        else
                            break;
                    }

                    min = Math.min(min, indent);
                });

                code = "";
                lines.forEach(function(l){
                    if (code.length)
                        code += "\n";
                    code += l.slice(min);
                });

                return code;
            }

            function enterPressed() {
                let pos = cursorPosition;
                let t = text;
                var intent = 0;
                var intent_begin = pos;
                var intent_found = false;
                for (var i=pos; i>=0; i--) {
                    intent = 0;
                    if (t[i-1] == ' ' || t[i-1] == '\n' || t[i-1] == '\r')
                        continue;

                    for (var j=2; j<i; j++) {
                        let ch = t[i - j]
                        if (ch == ' ') {
                            intent++;
                            continue;
                        }
                        if (ch == '\n' || ch == '\r') {
                            intent_begin = i - j;
                            intent_found = true;
                            break;
                        }

                        intent = 0;
                        break;
                    }

                    if (intent_found) {
                        break;
                    }
                }

                var str = "\n";
                for (var i=0; i<intent; i++)
                    str += " ";

                var new_pos = cursorPosition;
                if (t[pos - 1] == '{') {
                    str += indentText;
                    if (t[pos] == '}') {
                        str += '\n';
                        for (var i=0; i<intent; i++) {
                            str += " ";
                            new_pos--;
                        }
                        new_pos--;
                    }
                }

                insert(pos, str);
                cursorPosition = new_pos + str.length;
            }

            function tabPressed() {
                let pos = cursorPosition;
                insert(pos, indentText);
            }

            Keys.onEnterPressed: enterPressed()
            Keys.onReturnPressed: enterPressed()
            Keys.onTabPressed: tabPressed()

            Timer {
                id: indentTimer
                interval: 20
                repeat: false

                property int lastLength
            }

            CodeHighlighter {
                id: highlighter
                textDocument: tArea.textDocument
                onRefreshRequest: {
                    let pos = cursorPosition;
                    let temp = tArea.text;
                    tArea.text = "";
                    tArea.text = temp;
                    cursorPosition = pos;
                }
            }
        }
    }
}
