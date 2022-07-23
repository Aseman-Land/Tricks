import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Models 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import Tricks 1.0
import components 1.0
import requests 1.0
import globals 1.0

import "../timeline" as Timeline

Item {
    id: dis

    property alias bodyText: body.text
    property alias codeText: code.text

    property alias quoteMode: quoteAction.active
    property alias darkTheme: code.darkTheme
    readonly property bool sendingMode: !GlobalSettings.mobileView && (postReq.refreshing || reTrickReq.refreshing || reloadTimer.running)

    property int parentId
    property variant trickData

    signal trickPosted()

    function calculateTags(text) {
        var tags = new Array;
        var tags_lowercase = new Array;
        var tagsSplitted = Tools.stringRegExp(text, "(?:^|\\s)\\#[\\w\\+\\-\\#]+", false);
        tagsSplitted.forEach(function(t){
            let tag = t[0].trim().slice(1);
            if (tag.length < Bootstrap.tag.tag_min_length || tag.length > Bootstrap.tag.tag_max_length)
                return;
            if (tags_lowercase.indexOf(tag.toLowerCase()) == -1 && tags.length < Bootstrap.trick.tags_max_count) {
                tags_lowercase[tags_lowercase.length] = tag.toLowerCase();
                tags[tags.length] = tag;
            }
        });
        return tags;
    }

    function calculateMentions(text) {
        var tags = new Array;
        var tagsSplitted = Tools.stringRegExp(text, "\\@\\w+", false);
        tagsSplitted.forEach(function(t){
            let tag = t[0].trim().slice(1);
            tags[tags.length] = tag;
        });
        return tags;
    }

    function quote(trick) {
        quoteItem.pushData(trick);
        quoteItem.commentLineTop = false;
        quoteItem.commentLineBottom = false;
        quoteAction.active = true;
    }

    onTrickDataChanged: {
        replyItem.pushData(trickData);
        replyItem.parentId = 0;
        replyItem.quoteId = 0;
        replyItem.commentLineTop = false;
        replyItem.commentLineBottom = false;
    }
    onParentIdChanged: postReq.parent_id = parentId

    Timer {
        id: keyboardFocusCheck
        interval: 300
        running: true
        repeat: false
        onTriggered: {
            if (parentId || quoteAction.active) {
                body.focus = true;
                body.forceActiveFocus();
            }
        }
    }

    BackAction {
        id: quoteAction
    }

    PostTrickRequest {
        id: postReq
        allowGlobalBusy: GlobalSettings.mobileView
        onSuccessfull: reloadTimer.restart()
    }

    ReTrickRequest {
        id: reTrickReq
        allowGlobalBusy: GlobalSettings.mobileView
        onSuccessfull: reloadTimer.restart()
    }

    Component.onCompleted: MyTricksLimits.refresh()

    Timer {
        id: reloadTimer
        interval: Constants.refreshDelay
        repeat: false
        onRunningChanged: {
            if (!GlobalSettings.mobileView)
                return;
            if (running)
                GlobalSettings.waitCount++
            else
                GlobalSettings.waitCount--
        }
        onTriggered: {
            body.clear();
            code.clear();
            quoteAction.active = false;
            MyTricksLimits.refresh();
            GlobalSignals.snackRequest(qsTr("Tricks posted successfully."));
            GlobalSignals.refreshRequest();
            GlobalSignals.tagsRefreshed();
            dis.trickPosted();
        }
    }

    TScrollView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: submitBtn.top

        TFlickable {
            id: flick
            contentWidth: scene.width
            contentHeight: scene.height

            EscapeItem {
                id: scene
                width: flick.width
                height: columnLyt.height + columnLyt.y * 2
                enabled: !sendingMode

                ColumnLayout {
                    id: columnLyt
                    y: 20 * Devices.density
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: y
                    spacing: 10 * Devices.density

                    Item {
                        id: replyScene
                        Layout.fillWidth: true
                        Layout.preferredHeight: replyItem.height
                        visible: dis.parentId

                        Rectangle {
                            anchors.fill: parent
                            radius: Constants.radius
                            border.color: Colors.foreground
                            border.width: 1 * Devices.density
                            opacity: 0.1
                            color: "transparent"
                        }

                        Timeline.TrickMinimalItem {
                            id: replyItem
                            width: parent.width
                            actions: false
                            commentMode: true
                        }
                    }

                    TTextArea {
                        id: body
                        Layout.fillWidth: true
                        Layout.minimumHeight: 80 * Devices.density
                        placeholderText: qsTr("Message") + Translations.refresher
                        minimumCharacters: Bootstrap.trick.body_min_length
                        maximumCharacters: Bootstrap.trick.body_max_length
                        charsLength: postReq.body.length
                        horizontalAlignment: TricksTools.directionOf(text) == Qt.RightToLeft? Text.AlignRight : Text.AlignLeft
                        onTextChanged: {
                            postReq.references = new Array;
                            postReq.tags = new Array;
                            postReq.mentions = new Array;
                            postReq.body = text.trim();

                            var tags = calculateTags(postReq.body);
                            postReq.tags = tags;
                            tagsRepeater.model = tags;

                            var mentions = calculateMentions(postReq.body);
                            postReq.mentions = mentions;

                            var links = TricksTools.stringLinks(text);

                            links.forEach(function(l){
                                postReq.references[postReq.references.length] = {
                                    "name": l.name,
                                    "link": l.fixed
                                };
                            });
                            linksModel.data = links;

                            postReq.body = TricksTools.removeTagsAndLinks(postReq.body, tags, links);
                        }
                    }

                    TCodeEditor {
                        id: code
                        Layout.fillWidth: true
                        minimumEditorHeight: 120 * Devices.density
                        placeholderText: qsTr("Code") + Translations.refresher
                        visible: {
                            if (quoteAction.active)
                                return false;
                            if (tagsRepeater.model.indexOf("bug_report") >= 0)
                                return false;
                            if (tagsRepeater.model.indexOf("feedback") >= 0)
                                return false;
                            return true;
                        }
                        minimumCharacters: Bootstrap.trick.code_min_length
                        maximumCharacters: Bootstrap.trick.code_max_length
                    }

                    TLabel {
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        font.pixelSize: 7 * Devices.fontDensity
                        opacity: 0.6
                        visible: parentId == 0
                        onLinkActivated: {
                            if (link == "send:/bug")
                                body.append(" #bug_report");
                            else if (link == "send:/feedback")
                                body.append(" #feedback");
                        }

                        text: qsTr("To send bug report or feedback, use <a href='send:/bug'>#bug_report</a> or <a href='send:/feedback'>#feedback</a> tags") + Translations.refresher
                    }

                    Item {
                        id: quoteScene
                        Layout.fillWidth: true
                        Layout.preferredHeight: quoteItem.height
                        visible: quoteAction.active

                        Rectangle {
                            anchors.fill: parent
                            radius: Constants.radius
                            border.color: Colors.foreground
                            border.width: 1 * Devices.density
                            opacity: 0.1
                            color: "transparent"
                        }

                        Timeline.TrickMinimalItem {
                            id: quoteItem
                            width: parent.width
                            actions: false
                            commentMode: true
                        }

                        TIconButton {
                            anchors.right: parent.right
                            anchors.top: parent.bottom
                            materialText: qsTr("Cancel Quote") + Translations.refresher
                            materialIcon: MaterialIcons.mdi_close
                            onClicked: quoteAction.active = false
                        }
                    }

                    TLabel {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("Detected Tags:") + Translations.refresher
                        visible: !quoteAction.active
                    }

                    Flow {
                        spacing: 4 * Devices.density
                        Layout.fillWidth: true
                        visible: tagsRepeater.count && !quoteAction.active

                        Repeater {
                            id: tagsRepeater
                            model: new Array
                            Rectangle {
                                width: tagLbl.width + 14 * Devices.density
                                height: 30 * Devices.density
                                radius: 4 * Devices.density
                                color: {
                                    if (modelData == "bug_report")
                                        return Colors.darkMode? "#ff4245" : "#a00";
                                    else
                                    if (modelData == "feedback")
                                        return Colors.darkMode? "#0d80ec" : "#0d80ec";
                                    else
                                        return Qt.darker(Colors.accent, (marea.containsMouse? 1.1 : 0))
                                }

                                TMouseArea {
                                    id: marea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Viewport.controller.trigger("float:/tag", {"tag": modelData})
                                }

                                TLabel {
                                    id: tagLbl
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 8 * Devices.fontDensity
                                    color: "#fff"
                                }
                            }
                        }
                    }

                    TLabel {
                        visible: tagsRepeater.count == 0 && !quoteAction.active
                        Layout.fillWidth: true
                        font.pixelSize: 8 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("There is no tag assigned. Just type tags using # in the message to add tags.") + Translations.refresher
                        opacity: 0.5
                    }

                    TLabel {
                        Layout.fillWidth: true
                        font.bold: true
                        text: qsTr("References:") + Translations.refresher
                        visible: !quoteAction.active && parentId == 0
                    }

                    Flow {
                        spacing: 4 * Devices.density
                        Layout.fillWidth: true
                        visible: refsRepeater.count && !quoteAction.active && parentId == 0

                        Repeater {
                            id: refsRepeater
                            model: AsemanListModel {
                                id: linksModel
                            }

                            Rectangle {
                                width: refLbl.width + 14 * Devices.density
                                height: 30 * Devices.density
                                radius: 4 * Devices.density
                                color: Qt.darker(Colors.accent, (marea_r.containsMouse? 1.1 : 0))

                                TMouseArea {
                                    id: marea_r
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: Qt.openUrlExternally(model.fixed)
                                }

                                TLabel {
                                    id: refLbl
                                    anchors.centerIn: parent
                                    text: model.name
                                    font.pixelSize: 8 * Devices.fontDensity
                                    color: "#fff"
                                }
                            }
                        }
                    }

                    TLabel {
                        visible: refsRepeater.count == 0 && !quoteAction.active && parentId == 0
                        Layout.fillWidth: true
                        font.pixelSize: 8 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        text: qsTr("There is no references found on the body text.") + Translations.refresher
                        opacity: 0.5
                    }
                }
            }
        }
    }

    TIconButton {
        id: submitBtn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Constants.keyboardHeight? Constants.keyboardHeight - submitBtn.height : Devices.navigationBarHeight + Constants.margins
        anchors.margins: Constants.margins
        highlighted: true
        materialText: sendingMode? "" : quoteAction.active? (body.text.length? qsTr("Post Quote") : qsTr("Retrick")) : qsTr("Post Trick") + Translations.refresher
        flat: false
        enabled: (code.text.length || body.text.length || quoteAction.active) && (!code.visible || code.acceptable || quoteAction.active) && body.acceptable
        onEnabledChanged: if (enabled && MyTricksLimits.dailyPostLimit == 0) GlobalSignals.snackRequest(qsTr("Your daily tricks limits reached!"))
        onClicked: {
            if (sendingMode)
                return;

            if (quoteAction.active && body.text.length == 0) {
                reTrickReq.quoted_text = body.text.trim();
                reTrickReq.trick_id = quoteItem.mainId;
                reTrickReq.doRequest();
                return;
            } else {
                postReq.quoted_trick_id = quoteItem.mainId;
            }

            if (code.visible) {
                postReq.code = code.text;
                postReq.highlighter_id = code.themeCombo.model.get(code.themeCombo.currentIndex).id;
                postReq.programing_language_id = code.definitionCombo.model.get(code.definitionCombo.currentIndex).id;
                postReq.code_frame_id = code.darkTheme? 1 : 2;
            } else {
                postReq.code = " ";
            }

            postReq.type_id = 1;

            if (postReq.tags.length < Bootstrap.trick.tags_min_count) {
                Viewport.controller.trigger("dialog:/general/error", {"title": qsTr("Tags"), "body": qsTr("Please add at least %1 tags to the Message.\nExample: #C++ #STL #ObjectOriented").arg(Bootstrap.trick.tags_min_count)})
                return;
            }

            postReq.doRequest();
        }

        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 8 * Devices.density
            height: 20 * Devices.density
            width: height
            radius: width / 2
            visible: Bootstrap.trick.max_post_tricks < 10000 && parentId == 0
            color: MyTricksLimits.dailyPostLimit == 0? "#a00" : submitBtn.enabled? "#fff" : "#66ffffff"

            TLabel {
                anchors.centerIn: parent
                text: MyTricksLimits.dailyPostLimit
                font.pixelSize: 8 * Devices.fontDensity
                color: MyTricksLimits.dailyPostLimit == 0? "#fff" : Colors.darkMode && !submitBtn.enabled? "#fff" : Colors.accent
            }
        }

        TBusyIndicator {
            anchors.centerIn: parent
            width: 18 * Devices.density
            height: width
            running: sendingMode
            IOSStyle.foreground: "#fff"
            Material.accent: "#fff"
        }
    }
}
