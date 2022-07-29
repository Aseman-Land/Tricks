import QtQuick 2.12
import QtQuick.Layouts 1.3
import AsemanQml.Base 2.0
import AsemanQml.MaterialIcons 2.0
import AsemanQml.Models 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.Labs 2.0
import QtQuick.Controls.IOSStyle 2.0
import QtQuick.Controls.Material 2.0
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import Tricks 1.0
import components 1.0
import requests 1.0
import globals 1.0

TItemDelegate {
    id: dis
    implicitHeight: defaultHeight
    focusPolicy: Qt.ClickFocus
    clip: true

    readonly property bool myRetrick: GlobalSettings.userId == originalOwnerId && isRetrick
    readonly property real defaultHeight: columnLyt.height + columnLyt.y + (actionsRow.visible? 0 : columnLyt.y)

    readonly property string tipsText: {
        if (tips_sat == 0)
            return ""
        else if (tips_sat < 1000)
            return tips_sat;
        else if (tips_sat < 1000000)
            return Math.floor(tips_sat/100) / 10 + "K";
        else
            return Math.floor(tips_sat/100000) / 10 + "M";
    }

    property int mainId: isRetrick? retrickTrickId : trickId
    property int trickId
    property int link_id
    property int ownerId
    property int originalOwnerId
    property int ownerRole: 0
    property alias fullname: fullnameLbl.text
    property alias username: usernameLbl.text
    property string body
    property string originalBody
    property string language
    property string avatar
    property string dateTime
    property alias viewCount: viewCountLbl.text
    property string trickImage
    property real imageWidth: 100
    property real imageHeight: 100
    property string code
    property int rates
    property int retricks
    property int comments
    property int tips_sat
    property bool rateState
    property int tipState
    property bool bookmarked
    property string share_link
    property variant references: new Array
    property variant tags: new Array
    property bool codeFrameIsDark: false
    property bool isRetrick: false

    property int parentId
    property string parentOwnerFullName
    property string parentOwnerUsername
    property int parentOwnerId

    property int retrickTrickId
    property string retrickUsername
    property string retrickFullname
    property int retrickUserId
    property string retrickAvatar

    property string quote
    property int quoteId
    property int quoteQuoteId
    property string quoteUsername
    property string quoteFullname
    property int quoteUserId
    property string quoteAvatar
    property string quoteImageUrl
    property bool quoteCodeFrameIsDark: false
    property real quoteImageWidth: 100
    property real quoteImageHeight: 1

    property bool globalViewMode
    property bool commentMode
    property bool commentLineTop
    property bool commentLineBottom
    property bool stateHeaderVisible: !commentMode

    property variant trickData
    property alias actions: actionsRow.visible

    property Item moreBtnObj

    onContextMenuRequest: if (!globalViewMode) moreBtnObj.clicked()
    onPressAndHold: if (!globalViewMode) moreBtnObj.clicked()

    signal trickDeleted()

    function pushData(data) {
        trickData = data;

        dis.trickId = data.id;
        dis.fullname = data.owner.fullname;
        dis.username = "@" + data.owner.username;
        dis.ownerId = data.owner.id;
        dis.originalOwnerId = data.owner.id;
        dis.avatar = data.owner.avatar;
        try {
            dis.language = data.programing_language.name;
        } catch (e) {}
        dis.dateTime = data.datetime;
        dis.viewCount = data.views;
        dis.originalBody = data.body;
        dis.body = styleText(dis.originalBody);
        dis.trickImage = data.filename;
        dis.imageWidth = data.image_size.width;
        dis.imageHeight = data.image_size.height;

        if (data.link_id && link_id == 0) {
            link_id = data.link_id;
            if (link_id < trickId)
                commentLineTop = true;
            if (link_id > trickId)
                commentLineBottom = true
        }

        try {
            dis.code = data.code;
            dis.rates = data.rates;
            dis.retricks = data.retricks;
            dis.tips_sat = Math.floor(data.tips / 1000);
            dis.comments = data.comments;
            dis.rateState = (GlobalSettings.likedsHash.contains(trickId)? GlobalSettings.likedsHash.value(trickId) : data.rate_state);
            dis.tipState = data.tip_state;
            dis.share_link = data.share_link;
            dis.references = data.references;
            dis.tags = data.tags;
            dis.bookmarked = data.bookmarked;

            if (data.type.id > 100000) {
                dis.language = data.type.name;
                switch (data.type.id - 100000) {
                case 1:
                    codeIcon.text = MaterialIcons.mdi_bug;
                    break;
                case 2:
                    codeIcon.text = MaterialIcons.mdi_pen;
                    break;
                case 3:
                    codeIcon.text = MaterialIcons.mdi_chess_queen;
                    break;
                }
            }
        } catch (e) {}

        try {
            codeFrameIsDark = data.code_frame.id == 1;
        } catch (e) {}
        try {
            ownerRole = data.owner.details.role;
            if (ownerRole & 1) {
                roleIcon.text = MaterialIcons.mdi_check_decagram
            }
        } catch (e) {}

        isRetrick = false;
        try {
            if (data.retricker) { // It's retrick
                isRetrick = true;
                retrickTrickId = data.retrick_trick_id
                retrickUserId = data.retricker.id;
                retrickUsername = data.retricker.username;
                retrickFullname = data.retricker.fullname;
                retrickAvatar = data.retricker.avatar;
            }

            if (data.quote) { // It's quote
                quote = data.body;
                quoteId = data.quote.id;
                quoteUsername = data.quote.username;
                quoteFullname = data.quote.fullname;
                quoteUserId = data.quote.owner;
                quoteAvatar = data.quote.avatar;

                try {
                    if (data.quote.filename) {
                        quoteImageUrl = dis.trickImage;
                        quoteImageWidth = dis.imageWidth;
                        quoteImageHeight = dis.imageHeight;
                        quoteCodeFrameIsDark = dis.codeFrameIsDark;

                        dis.trickImage = data.quote.filename;
                        dis.imageWidth = data.quote.image_size.width;
                        dis.imageHeight = data.quote.image_size.height;
                        dis.codeFrameIsDark = data.quote.code_frame_id == 1;
                    }
                } catch (e) {}

                let trk = data.quote;
                dis.body = trk.body;
            }
        } catch (e) {
        }

        try {
            parentId = data.parent_id;
            parentOwnerId = data.parent_owner.id;
            parentOwnerFullName = data.parent_owner.fullname;
            parentOwnerUsername = data.parent_owner.username;
        } catch (e) {
        }

        pushView.restart();
    }

    function deleteRequest(retrickMode) {
        var args = {
            "title": qsTr("Warning"),
            "body" : retrickMode? qsTr("Do you realy want undo retrick?") : qsTr("Do you realy want to delete this trick?") ,
            "buttons": [qsTr("Yes"), qsTr("No")]
        };
        var obj = Viewport.controller.trigger("dialog:/general/warning", args);
        obj.itemClicked.connect(function(idx, title){
            switch (idx) {
            case 0: // Yes
                deleteReq.doRequest();
                break;
            case 1: // No
                break;
            }
            obj.ViewportType.open = false;
        });
    }

    function styleText(text) {
        var tags = Tools.stringRegExp(text, "\\#[\\w\\+\\-\\#]+", false);
        tags.forEach(function(t) {
            if (bodyLbl.textFormat == Text.MarkdownText)
                text = Tools.stringReplace(text, t, "[" + t + "](go:/" + t + ")")
            else
                text = Tools.stringReplace(text, t, "<a href=\"go:/%1\">".arg(t) + t + "</a>")
        });

        var mentions = Tools.stringRegExp(text, "\\@\\w+", false);
        mentions.forEach(function(t) {
            if (bodyLbl.textFormat == Text.MarkdownText)
                text = Tools.stringReplace(text, t, "[" + Tools.stringRemove(t, "@") + "](user:/" + t + ")")
            else
                text = Tools.stringReplace(text, t, "<a href=\"user:/%1\">".arg(Tools.stringRemove(t, "@")) + t + "</a>")
        });

        return text;
    }

    Timer {
        id: pushView
        repeat: false
        interval: 5000
        onTriggered: {
            Views.push(trickId);
            if (quoteId)
                Views.push(quoteId);
        }
    }

    DeleteTrickRequest {
        id: deleteReq
        allowGlobalBusy: true
        _id: dis.trickId
        onSuccessfull: {
            GlobalSignals.trickDeleted(_id)
            GlobalSignals.refreshRequest();
            dis.trickDeleted();
        }
    }

    AddRateRequest {
        id: rateReq
        _id: dis.trickId
        onSuccessfull: {
            response.result.forEach(GlobalSignals.trickUpdated)
        }
    }

    AddBookmarkRequest {
        id: addBookmarkReq
        trick_id: dis.trickId
        onSuccessfull: {
            trickData.bookmarked = true;
            GlobalSignals.trickUpdated(trickData);
        }
    }

    DeleteBookmarkRequest {
        id: deleteBookmarkReq
        _trick_id: dis.trickId
        onSuccessfull: {
            trickData.bookmarked = false;
            GlobalSignals.trickUpdated(trickData);
        }
    }

    ReTrickRequest {
        id: reTrickReq
        allowGlobalBusy: true
        onSuccessfull: {
            MyTricksLimits.refresh();
            GlobalSignals.snackRequest(qsTr("Trick retricked successfully"));
            GlobalSignals.refreshRequest();
        }
    }

    GetUserRequest {
        id: userReq
        allowGlobalBusy: true
        onSuccessfull: {
            Viewport.controller.trigger("float:/users", {"userId": response.result.id, "title": response.result.fullname})
        }
    }

    ColumnLayout {
        id: columnLyt
        y: Constants.margins
        width: Math.min(450*Devices.density, parent.width - 2*Constants.margins)
        anchors.horizontalCenter: parent.horizontalCenter

        RowLayout {
            spacing: 4 * Devices.density
            Layout.bottomMargin: Constants.margins / 2
            visible: isRetrick && stateHeaderVisible && !commentMode

            TMaterialIcon {
                text: MaterialIcons.mdi_repeat
                color: Colors.accent
            }

            TLabel {
                Layout.fillWidth: true
                font.bold: true
                opacity: 0.4
                text: qsTr("%1 (@%2) Retricked...").arg(retrickFullname).arg(retrickUsername) + Translations.refresher
                font.pixelSize: 8 * Devices.fontDensity
            }
        }

        RowLayout {
            spacing: 4 * Devices.density
            visible: dis.parentId && stateHeaderVisible && !commentMode && (link_id == 0 || link_id > trickId)
            Layout.bottomMargin: Constants.margins / 2

            TMaterialIcon {
                text: MaterialIcons.mdi_replay
                color: Colors.accent
            }

            TLabel {
                Layout.fillWidth: true
                font.bold: true
                opacity: 0.4
                visible: dis.parentId && dis.parentOwnerId
                text: qsTr("In reply to %1's (@%2) trick...").arg(parentOwnerFullName).arg(parentOwnerUsername) + Translations.refresher
                font.pixelSize: 8 * Devices.fontDensity

                TMouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks", {"trickId": dis.parentId})
                }
            }

            TLabel {
                Layout.fillWidth: true
                font.bold: true
                opacity: 0.4
                visible: dis.parentId && dis.parentOwnerId == 0
                text: qsTr("In reply to a deleted trick...") + Translations.refresher
                font.pixelSize: 8 * Devices.fontDensity

                TMouseArea {
                    anchors.fill: parent
                    z: -1
                    onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks", {"trickId": dis.parentId})
                }
            }
        }

        RowLayout {
            spacing: Constants.spacing

            Item {
                Layout.preferredWidth: 42 * Devices.density
                Layout.preferredHeight: 42 * Devices.density
                Layout.alignment: Qt.AlignTop

                Loader {
                    id: avatarLoader
                    anchors.right: parent.right
                    width: commentMode? 42 * Devices.density : 42 * Devices.density
                    height: commentMode? 42 * Devices.density : 42 * Devices.density
                    asynchronous: true
                    sourceComponent: TAvatar {
                        id: profileImage
                        anchors.fill: parent
                        remoteUrl: dis.avatar

                        TMouseArea {
                            anchors.fill: parent
                            onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/users", {"userId": ownerId, "title": fullname})
                        }
                    }

                    Item {
                        z: -1
                        width: 2 * Devices.density
                        height: dis.height * 2
                        anchors.centerIn: parent

                        Rectangle {
                            width: parent.width
                            anchors.top: parent.top
                            anchors.bottom: parent.verticalCenter
                            color: Colors.primary
                            opacity: commentLineTop? 0.2 : 0
                            radius: width / 2
                        }

                        Rectangle {
                            width: parent.width
                            anchors.top: parent.verticalCenter
                            anchors.bottom: parent.bottom
                            color: Colors.primary
                            opacity: commentLineBottom? 0.2 : 0
                            radius: width / 2
                        }

                        Rectangle {
                            anchors.centerIn: parent
                            width: avatarLoader.width + 6 * Devices.density
                            height: width
                            radius: width / 2
                            color: Colors.background
                        }
                    }
                }
            }

            ColumnLayout {
                spacing: 8 * Devices.density

                RowLayout {

                    TLabel {
                        id: fullnameLbl
                        font.bold: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 1
                        elide: Text.ElideRight
                    }

                    TMaterialIcon {
                        id: roleIcon
                        font.pixelSize: 9 * Devices.fontDensity
                        color: Colors.accent
                        visible: text.length
                    }

                    TLabel {
                        id: usernameLbl
                        Layout.fillWidth: true
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        maximumLineCount: 1
                        elide: Text.ElideRight
                        opacity: 0.7
                    }

                    TLabel {
                        text: GlobalMethods.dateToString(GlobalMethods.unNormalizeDate(dis.dateTime))
                        font.pixelSize: 8 * Devices.fontDensity
                        opacity: 0.7
                    }
                }

                RowLayout {
                    visible: !commentMode && !dis.parentId

                    TMaterialIcon {
                        id: codeIcon
                        font.pixelSize: 8 * Devices.fontDensity
                        text: MaterialIcons.mdi_code_braces
                        color: Colors.accent
                    }

                    TLabel {
                        id: langLbl
                        font.pixelSize: 8 * Devices.fontDensity
                        opacity: 0.7
                        text: GlobalMethods.formName(dis.language)
                        visible: dis.tags.length == 0
                    }

                    Item {
                        Layout.preferredHeight: 14 * Devices.density
                        Layout.fillWidth: true
                        clip: true

                        RowLayout {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            spacing: 0

                            Repeater {
                                model: dis.tags
                                RowLayout {
                                    spacing: 0

                                    TMaterialIcon {
                                        text: MaterialIcons.mdi_chevron_right
                                        visible: model.index > 0
                                        font.pixelSize: 8 * Devices.fontDensity
                                        color: Colors.accent
                                    }

                                    TLabel {
                                        font.pixelSize: 8 * Devices.fontDensity
                                        opacity: 0.7
                                        text: GlobalMethods.formName(modelData)
                                    }
                                }
                            }
                        }
                    }

                    TMaterialIcon {
                        font.pixelSize: 8 * Devices.fontDensity
                        text: MaterialIcons.mdi_eye
                        color: Colors.accent
                    }

                    TLabel {
                        id: viewCountLbl
                        font.pixelSize: 8 * Devices.fontDensity
                        opacity: 0.7
                    }
                }

                TTextView {
                    id: quoteLbl
                    Layout.fillWidth: true
                    visible: quoteBorder.visible && text.length
                    text: quote
                }

                Loader {
                    Layout.fillWidth: true
                    active: quoteImageHeight > 1
                    visible: active
                    Layout.preferredHeight: quoteImageHeight * width / quoteImageWidth
                    asynchronous: true
                    sourceComponent: Item {
                        anchors.fill: parent

                        TRemoteImage {
                            id: quoteImage
                            radius: Constants.radius
                            anchors.fill: parent
                            remoteUrl: dis.quoteImageUrl
                            visible: !invertQuoteImg.visible
                        }

                        LevelAdjust {
                            id: invertQuoteImg
                            anchors.fill: quoteImage
                            source: quoteImage
                            minimumOutput: "#00ffffff"
                            maximumOutput: "#ff000000"
                            visible: GlobalSettings.forceCodeTheme && (dis.quoteCodeFrameIsDark != Colors.darkMode)
                        }
                    }
                }

                Item {
                    id: trickFrame
                    Layout.fillWidth: true
                    Layout.preferredHeight: trickColumn.height + trickColumn.y*2
                    visible: quoteId || bodyLbl.text.length

                    Rectangle {
                        id: quoteBorder
                        anchors.fill: parent
                        radius: Constants.radius
                        border.color: Colors.foreground
                        border.width: 1 * Devices.density
                        opacity: 0.1
                        visible: quoteId && quote.length
                        color: marea.containsMouse? Colors.foreground : "transparent"
                    }

                    TMouseArea {
                        id: marea
                        anchors.fill: quoteBorder
                        hoverEnabled: true
                        visible: quoteId && quote.length
                        onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks", {"trickId": quoteId})
                    }

                    ColumnLayout {
                        id: trickColumn
                        width: parent.width - 2*y
                        x: y
                        y: quoteBorder.visible? Constants.margins : 0
                        spacing: 8 * Devices.density

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Constants.spacing
                            visible: quoteBorder.visible

                            Loader {
                                Layout.preferredHeight: 26 * Devices.density
                                Layout.preferredWidth: 26 * Devices.density
                                asynchronous: true
                                sourceComponent: TAvatar {
                                    remoteUrl: quoteAvatar

                                    TMouseArea {
                                        anchors.fill: parent
                                        onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/users", {"userId": quoteUserId, "title": quoteFullname})
                                    }
                                }
                            }

                            TLabel {
                                font.bold: true
                                text: quoteFullname
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            TLabel {
                                Layout.fillWidth: true
                                opacity: 0.7
                                text: "@" + quoteUsername
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        TTextView {
                            id: bodyLbl
                            Layout.fillWidth: true
                            textFormat: TextEdit.RichText
                            visible: text.length
                            onLinkActivated: {
                                if (link.slice(0, 4) == "go:/") {
                                    Viewport.controller.trigger("float:/tag", {"tag": link.slice(5)})
                                } else if (link.slice(0, 6) == "user:/") {
                                    userReq._userId = link.slice(6);
                                    userReq.doRequest();
                                } else {
                                    Qt.openUrlExternally(link)
                                }
                            }
                            text: {
                                var res = dis.body;
                                var i = 0;
                                dis.references.forEach(function(r){
                                    if (textFormat == Text.MarkdownText)
                                        res = Tools.stringReplace(res, "[r:%1]".arg(i), "[" + r.name + "](" + r.link + ")");
                                    else
                                        res = Tools.stringReplace(res, "[r:%1]".arg(i), "<a href=\"" + r.link + "\">" + r.name + "</a>");
                                    i++;
                                });
                                if (textFormat == TextEdit.RichText)
                                    res = Tools.stringReplace(res, "\n", "<br />");
                                return res;
                            }
                        }

                        Loader {
                            Layout.fillWidth: true
                            active: imageHeight > 1
                            visible: active
                            Layout.preferredHeight: imageHeight * width / imageWidth
                            asynchronous: true
                            sourceComponent: Item {
                                anchors.fill: parent

                                TRemoteImage {
                                    id: image
                                    radius: Constants.radius
                                    anchors.fill: parent
                                    remoteUrl: dis.trickImage
                                    visible: !invertImg.visible
                                }

                                LevelAdjust {
                                    id: invertImg
                                    anchors.fill: image
                                    source: image
                                    minimumOutput: "#00ffffff"
                                    maximumOutput: "#ff000000"
                                    visible: GlobalSettings.forceCodeTheme && (dis.codeFrameIsDark != Colors.darkMode)
                                }
                            }
                        }
                    }
                }

                Loader {
                    id: actionsRow
                    Layout.fillWidth: true
                    Layout.topMargin: -8 * Devices.density
                    Layout.preferredHeight: 46 * Devices.density
                    asynchronous: true
                    sourceComponent: RowLayout {
                        spacing: 0
                        anchors.fill: parent

                        TIconButton {
                            materialIcon: rateState? MaterialIcons.mdi_thumb_up : MaterialIcons.mdi_thumb_up_outline
                            materialText: rates? rates : ""
                            materialOpacity: rateReq.refreshing? 0 : 1
                            materialColor: rateState? Colors.likeColors : Colors.buttonsColor
                            onClicked: {
                                if (globalViewMode)
                                    return;

                                var rate = (rateState? 0 : 1);
                                GlobalSettings.likedsHash.remove(trickId);
                                GlobalSettings.likedsHash.insert(trickId, rate);

                                dis.rateState = rate;
                                rateReq.rate = rate;
                                rateReq.doRequest();
                            }

                            TBusyIndicator {
                                anchors.centerIn: parent
                                width: 18 * Devices.density
                                IOSStyle.foreground: IOSStyle.accent
                                running: rateReq.refreshing
                            }
                        }
                        TIconButton {
                            materialIcon: comments? MaterialIcons.mdi_comment_outline : MaterialIcons.mdi_comment_outline
                            materialText: comments? comments : ""
                            materialColor: Colors.buttonsColor
                            onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks/add", {"parentId": dis.trickId, "trickData": dis.trickData})
                        }
                        TIconButton {
                            id: retrickBtn
                            materialIcon: MaterialIcons.mdi_repeat
                            visible: !globalViewMode
                            materialText: retricks? retricks : ""
                            materialBold: myRetrick
                            materialColor: myRetrick? Colors.accent : Colors.buttonsColor
                            onClicked: {
                                var pos = Qt.point(dis.LayoutMirroring.enabled? Constants.radius : retrickBtn.width - Constants.radius, retrickBtn.height/2);
                                var parent = retrickBtn;
                                while (parent && parent != Viewport.viewport) {
                                    pos.x += parent.x;
                                    pos.y += parent.y;
                                    parent = parent.parent;
                                }

                                Viewport.viewport.append(quoteComponent, {"pointPad": pos}, "menu");
                            }
                        }

                        Item {
                            Layout.preferredHeight: 1
                            Layout.fillWidth: true
                        }
                        TIconButton {
                            id: tipsBtn
                            materialIcon: MaterialIcons.mdi_bitcoin
                            materialIconSize: 13 * Devices.fontDensity
                            materialOpacity: 1
                            materialColor: tipState? Colors.accent : Colors.buttonsColor
                            materialText: dis.tipsText
                            visible: GlobalSettings.userId != ownerId && !globalViewMode
                            onClicked: {
                                if (globalViewMode)
                                    return;

                                Viewport.controller.trigger("bottomdrawer:/tricks/tip", {"trickId": dis.trickId, "trickData": dis.trickData})
                            }
                        }
                        TIconButton {
                            materialIcon: dis.bookmarked? MaterialIcons.mdi_star : MaterialIcons.mdi_star_outline
                            materialIconSize: 13 * Devices.fontDensity
                            materialOpacity: addBookmarkReq.refreshing || deleteBookmarkReq.refreshing? 0 : 1
                            materialColor: dis.bookmarked? Colors.bookmarksColors : Colors.buttonsColor
                            visible: !globalViewMode
                            onClicked: {
                                if (globalViewMode)
                                    return;

                                if (dis.bookmarked)
                                    deleteBookmarkReq.doRequest();
                                else
                                    addBookmarkReq.doRequest();
                            }

                            TBusyIndicator {
                                anchors.centerIn: parent
                                width: 18 * Devices.density
                                IOSStyle.foreground: IOSStyle.accent
                                running: addBookmarkReq.refreshing || deleteBookmarkReq.refreshing
                            }
                        }
                        TIconButton {
                            id: moreBtn
                            visible: !globalViewMode
                            materialIcon: MaterialIcons.mdi_dots_horizontal
                            materialColor: Colors.buttonsColor
                            onClicked: {
                                var pos = Qt.point(dis.LayoutMirroring.enabled? Constants.radius : moreBtn.width - Constants.radius, moreBtn.height/2);
                                var parent = moreBtn;
                                while (parent && parent != Viewport.viewport) {
                                    pos.x += parent.x;
                                    pos.y += parent.y;
                                    parent = parent.parent;
                                }

                                Viewport.viewport.append(menuComponent, {"pointPad": pos}, "menu");
                            }

                            Component.onCompleted: moreBtnObj = moreBtn
                        }
                    }
                }

            }
        }
    }

    Component {
        id: menuComponent
        MenuView {
            id: menuItem
            x: pointPad.x - width
            y: pointPad.y + (openFromTop? 10 * Devices.density : - height - 10 * Devices.density)
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = openFromTop? 0 : height;
                var x = dis.LayoutMirroring.enabled? 0 : width;
                return Qt.point(x, y);
            }

            property point pointPad
            property int index
            property bool openFromTop: pointPad.y < Viewport.viewport.height/2

            onItemClicked: {
                var d = menuModel.get(index);
                switch (d.command) {
                case "copy_link":
                    Devices.clipboard = dis.share_link;
                    GlobalSignals.snackRequest(qsTr("Link copied to the clipboard"));
                    break;
                case "copy_message":
                    Devices.clipboard = (quote.length? quote : dis.originalBody);
                    GlobalSignals.snackRequest(qsTr("Message copied to the clipboard"));
                    break;
                case "copy_code":
                    Devices.clipboard = dis.code;
                    GlobalSignals.snackRequest(qsTr("Code copied to the clipboard"));
                    break;
                case "share":
                    Devices.share(dis.fullname + " from " + AsemanApp.applicationName, (dis.quoteId? dis.quote : dis.originalBody) + "\n" + dis.share_link)
                    break;
                case "report":
                    Viewport.controller.trigger("float:/tricks/report", {"trickId": dis.trickId, "title": dis.title});
                    ViewportType.open = false;
                    break;
                case "delete":
                    deleteRequest(myRetrick);
                    break;
                }

                ViewportType.open = false;
            }

            model: AsemanListModel {
                id: menuModel
                data: {
                    var res = [
                        {
                            title: qsTr("Copy Link"),
                            icon: "mdi_content_copy",
                            enabled: true,
                            command: "copy_link"
                        }
                    ];

                    if ((quote.length? quote : dis.originalBody).trim().length)
                        res[res.length] = {
                            title: qsTr("Copy Message"),
                            icon: "mdi_content_copy",
                            enabled: true,
                            command: "copy_message"
                        }

                    if (dis.code.trim().length)
                        res[res.length] = {
                            title: qsTr("Copy Code"),
                            icon: "mdi_content_copy",
                            enabled: true,
                            command: "copy_code"
                        }

                    if (GlobalSettings.userId != originalOwnerId)
                            res[res.length] = {
                            title: qsTr("Share"),
                            icon: "mdi_share",
                            enabled: true,
                            command: "share"
                        }

                    if (GlobalSettings.userId != originalOwnerId) {
                        res[res.length] = {
                            title: qsTr("Report"),
                            icon: "mdi_pen",
                            enabled: true,
                            command: "report"
                        };
                    } else if (GlobalSettings.userId == dis.ownerId) {
                        res[res.length] = {
                            title: qsTr("Delete Trick"),
                            icon: "mdi_trash_can",
                            enabled: true,
                            command: "delete"
                        };
                    }
                    return res;
                }
            }
        }
    }

    Component {
        id: quoteComponent
        MenuView {
            id: menuItem
            x: pointPad.x - width/2
            y: pointPad.y + (openFromTop? 10 * Devices.density : - height - 10 * Devices.density)
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                var y = openFromTop? 0 : height;
                var x = width/2;
                return Qt.point(x, y);
            }

            property point pointPad
            property int index
            property bool openFromTop: pointPad.y < Viewport.viewport.height/2

            onItemClicked: {
                var d = menuModel.get(index);
                switch (d.command) {
                case "quote":
                    GlobalSignals.retrickRequest(trickData);
                    break;
                case "retrick":
                    reTrickReq.trick_id = dis.trickId;
                    reTrickReq.doRequest();
                    break;
                case "undo_retrick":
                    deleteRequest(myRetrick);
                    break;
                }

                ViewportType.open = false;
            }

            model: AsemanListModel {
                id: menuModel
                data: {
                    var res = [
                        {
                            title: qsTr("Quote"),
                            icon: "mdi_comment",
                            enabled: true,
                            command: "quote"
                        },
                        {
                            title: qsTr("Retrick"),
                            icon: "mdi_repeat",
                            enabled: true,
                            command: "retrick"
                        }
                    ];

                    if (isRetrick)
                        res[res.length] = {
                            title: qsTr("Undo retrick"),
                            icon: "mdi_trash_can",
                            enabled: true,
                            command: "undo_retrick"
                        }

                    return res;
                }
            }
        }
    }
}
