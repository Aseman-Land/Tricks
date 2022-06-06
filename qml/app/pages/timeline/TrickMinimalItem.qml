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

    readonly property real defaultHeight: columnLyt.height + columnLyt.y + (actionsRow.visible? 0 : columnLyt.y)

    property int mainId: isRetrick? quoteId : trickId
    property int trickId
    property int ownerId
    property int ownerRole: 0
    property alias fullname: fullnameLbl.text
    property alias username: usernameLbl.text
    property string body
    property string language
    property string avatar
    property string dateTime
    property alias viewCount: viewCountLbl.text
    property string trickImage
    property real imageWidth: 100
    property real imageHeight: 100
    property string code
    property int rates
    property int comments
    property bool rateState
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

    property string quote
    property int quoteId
    property int quoteQuoteId
    property string quoteUsername
    property string quoteFullname
    property int quoteUserId
    property string quoteAvatar

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
        dis.avatar = data.owner.avatar;
        try {
            dis.language = data.programing_language.name;
        } catch (e) {}
        dis.dateTime = data.datetime;
        dis.viewCount = data.views;
        dis.body = styleText(data.body);
        dis.trickImage = data.filename;
        dis.imageWidth = data.image_size.width;
        dis.imageHeight = data.image_size.height;

        try {
            dis.code = data.code;
            dis.rates = data.rates;
            dis.comments = data.comments;
            dis.rateState = (GlobalSettings.likedsHash.contains(trickId)? GlobalSettings.likedsHash.value(trickId) : data.rate_state);
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
            quoteId = data.quote.trick_id;

            if (data.quote.quote == null) { // It's retrick
                isRetrick = true;
                let trk = data.quote.trick;
                dis.dateTime = trk.datetime;
                dis.viewCount = trk.views;
                dis.rates = trk.rates;
                dis.comments = trk.comments;

                dis.fullname = trk.fullname;
                dis.username = "@" + trk.username;
                dis.ownerId = trk.owner;
                dis.avatar = trk.avatar;

                quoteUserId = data.owner.id;
                quoteUsername = data.owner.username;
                quoteFullname = data.owner.fullname;
                quoteAvatar = data.owner.avatar;

                quote = trk.quoted_text;
                dis.body = trk.body;
                quoteQuoteId = trk.quoted_trick_id;
            } else { // It's quote
                quote = data.quote.quote;
                quoteUsername = data.quote.user.username;
                quoteFullname = data.quote.user.fullname;
                quoteUserId = data.quote.user.id;
                quoteAvatar = data.quote.user.avatar;

                let trk = data.quote.trick;
                if (trk.quoted_trick_id) {
                    dis.trickImage = "";
                    dis.imageHeight = 0;
                    dis.body = trk.quoted_text;
                }
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

    function deleteRequest() {
        var args = {
            "title": qsTr("Warning"),
            "body" : qsTr("Do you realy want to delete this trick?") ,
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
        _id: dis.trickId
        onSuccessfull: {
            GlobalSignals.trickDeleted(_id)
            GlobalSignals.refreshRequest();
            dis.trickDeleted();
        }
    }

    AddRateRequest {
        id: rateReq
        _id: dis.mainId
        onSuccessfull: {
            response.result.forEach(GlobalSignals.trickUpdated)
        }
    }

    AddBookmarkRequest {
        id: addBookmarkReq
        trick_id: dis.mainId
        onSuccessfull: {
            trickData.bookmarked = true;
            GlobalSignals.trickUpdated(trickData);
        }
    }

    DeleteBookmarkRequest {
        id: deleteBookmarkReq
        _trick_id: dis.mainId
        onSuccessfull: {
            trickData.bookmarked = false;
            GlobalSignals.trickUpdated(trickData);
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
                text: qsTr("%1 (@%2) Retricked...").arg(quoteFullname).arg(quoteUsername) + Translations.refresher
                font.pixelSize: 8 * Devices.fontDensity
            }
        }

        RowLayout {
            spacing: 4 * Devices.density
            visible: dis.parentId && stateHeaderVisible && !commentMode
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
                        onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks", {"trickId": (isRetrick? quoteQuoteId : quoteId)})
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
                            onClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks/add", {"parentId": dis.mainId, "trickData": dis.trickData})
                        }
                        TIconButton {
                            materialIcon: MaterialIcons.mdi_repeat
                            visible: !globalViewMode && quote.length == 0
                            materialColor: Colors.buttonsColor
                            onClicked: GlobalSignals.retrickRequest(trickData)
                        }

                        Item {
                            Layout.preferredHeight: 1
                            Layout.fillWidth: true
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
                switch (index) {
                case 0:
                    Devices.clipboard = dis.share_link;
                    GlobalSignals.snackRequest(qsTr("Link copied to the clipboard"));
                    break;
                case 1:
                    Devices.clipboard = (quote.length? quote : dis.body);
                    GlobalSignals.snackRequest(qsTr("Message copied to the clipboard"));
                    break;
                case 2:
                    Devices.clipboard = dis.code;
                    GlobalSignals.snackRequest(qsTr("Code copied to the clipboard"));
                    break;
                case 3:
                    Devices.share(dis.fullname + " from " + AsemanApp.applicationName, (dis.quoteId? dis.quote : dis.body) + "\n" + dis.share_link)
                    break;
                case 4:
                    if (GlobalSettings.userId != ownerId) {
                        Viewport.controller.trigger("float:/tricks/report", {"trickId": dis.mainId, "title": dis.title});
                        ViewportType.open = false;
                    } else {
                        deleteRequest()
                    }
                    break;
                }

                ViewportType.open = false;
            }

            model: AsemanListModel {
                data: {
                    var res = [
                        {
                            title: qsTr("Copy Link"),
                            icon: "mdi_content_copy",
                            enabled: true
                        },
                        {
                            title: qsTr("Copy Message"),
                            icon: "mdi_content_copy",
                            enabled: true
                        },
                        {
                            title: qsTr("Copy Code"),
                            icon: "mdi_content_copy",
                            enabled: true
                        },
                        {
                            title: qsTr("Share"),
                            icon: "mdi_share",
                            enabled: true
                        }
                    ];

                    if (GlobalSettings.userId != ownerId) {
                        res[res.length] = {
                            title: qsTr("Report"),
                            icon: "mdi_pen",
                            enabled: true
                        };
                    } else {
                        res[res.length] = {
                            title: qsTr("Delete Trick"),
                            icon: "mdi_trash_can",
                            enabled: true
                        };
                    }
                    return res;
                }
            }
        }
    }
}
