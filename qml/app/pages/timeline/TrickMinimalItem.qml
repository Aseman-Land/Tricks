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

TrickItem {
    id: dis
    implicitHeight: defaultHeight
    clip: true
    sceneWidth: Math.min(450*Devices.density, width - 2*Constants.margins)
    serverAddress: Constants.baseUrl
    cachePath: Constants.cachePath
    font.pixelSize: 9 * Devices.fontDensity
    font.family: Fonts.globalFont
    fontIcon.family: MaterialIcons.family
    fontIcon.pixelSize: 9 * Devices.fontDensity
    highlightColor: Colors.primary
    foregroundColor: Colors.foreground
    rateColor: Colors.likeColors
    favoriteColor: Colors.bookmarksColors
    imageRoundness: Constants.radius
    myUserId: GlobalSettings.userId
    stateHeader: !commentMode
    z: 1000
    onButtonClicked: {
        switch (action) {
        case TrickItem.RateButton:
            rate();
            break;
        case TrickItem.CommentButton:
            comment();
            break;
        case TrickItem.RetrickButton:
            retrick(rect);
            break;
        case TrickItem.TipButton:
            tip();
            break;
        case TrickItem.FavoriteButton:
            favorite();
            break;
        case TrickItem.MoreButton:
            showMenu(undefined, rect);
            break;
        }
    }

    onUserClicked: if (!globalViewMode) Viewport.controller.trigger("float:/users", {"userId": ownerId, "title": fullname})
    onImageClicked: if (!globalViewMode) Viewport.controller.trigger("activity:/gallery", {"model": [image]})
    onContextMenuRequest: if (!globalViewMode) showMenu(point)
    onPressAndHold: if (!globalViewMode) showMenu(point)
    onQuoteClicked: if (!globalViewMode) Viewport.controller.trigger("float:/tricks", {"trickId": quoteId})
    onQuoteUserClicked: if (!globalViewMode) Viewport.controller.trigger("float:/users", {"userId": quoteUserId, "title": quoteFullname})

    readonly property bool myRetrick: GlobalSettings.userId == originalOwnerId && isRetrick
    readonly property real defaultHeight: contentRect.height

    readonly property string tipsText: {
        if (tipsSat == 0)
            return ""
        else if (tipsSat < 1000)
            return tipsSat;
        else if (tipsSat < 1000000)
            return Math.floor(tipsSat/100) / 10 + "K";
        else
            return Math.floor(tipsSat/100000) / 10 + "M";
    }

    property int mainId: isRetrick? retrickTrickId : trickId
    property bool stateHeaderVisible: !commentMode

    property bool actions

    signal trickDeleted()

    function pushData(data) {
        itemData = data;
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

    function rate() {
        if (globalViewMode)
            return;

        var rate = (rateState? 0 : 1);
        GlobalSettings.likedsHash.remove(trickId);
        GlobalSettings.likedsHash.insert(trickId, rate);

        dis.rateState = rate;
        rateReq.rate = rate;
        rateReq.doRequest();
    }

    function comment() {
        if (!globalViewMode)
            Viewport.controller.trigger("float:/tricks/add", {"parentId": dis.trickId, "itemData": dis.itemData})
    }

    function retrick(rect) {
        var pos = Qt.point(rect.x + (dis.LayoutMirroring.enabled? Constants.radius : rect.width - Constants.radius), rect.y + rect.height/2);
        var parent = dis;
        while (parent && parent != Viewport.viewport) {
            pos.x += parent.x;
            pos.y += parent.y;
            parent = parent.parent;
        }

        Viewport.viewport.append(quoteComponent, {"pointPad": pos}, "menu");
    }

    function tip() {
        if (globalViewMode)
            return;
        if (GlobalSettings.userId != ownerId)
            Viewport.controller.trigger("bottomdrawer:/tricks/tip", {"trickId": dis.trickId, "itemData": dis.itemData})
        else
            Viewport.controller.trigger("page:/tricks/tips", {"trickId": dis.trickId})
    }

    function favorite() {
        if (globalViewMode)
            return;

        if (dis.bookmarked)
            deleteBookmarkReq.doRequest();
        else
            addBookmarkReq.doRequest();
        bookmarked = !bookmarked;
    }

    function showMenu(point, rect) {
        var pos = Qt.point(0,0);
        var freePoint = false;
        if (point != undefined) {
            pos = point;
            freePoint = true;
        } else {
            pos = Qt.point(rect.x + (dis.LayoutMirroring.enabled? Constants.radius : rect.width - Constants.radius), rect.y + rect.height/2);
        }

        var parent = dis;
        while (parent && parent != Viewport.viewport) {
            pos.x += parent.x;
            pos.y += parent.y;
            parent = parent.parent;
        }

        Viewport.viewport.append(menuComponent, {"pointPad": pos, "freePoint": freePoint}, "menu");
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
        _debug: true
        onSuccessfull: {
            bookmarked = true;
            GlobalSignals.trickUpdated(itemData);
        }
    }

    DeleteBookmarkRequest {
        id: deleteBookmarkReq
        _trick_id: dis.trickId
        onSuccessfull: {
            bookmarked = false;
            GlobalSignals.trickUpdated(itemData);
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

    Component {
        id: menuComponent
        MenuView {
            id: menuItem
            x: {
                if (freePoint) {
                    if (pointPad.x - width/2 < 0)
                        return 0;
                    if (pointPad.x + width/2 > Viewport.viewport.width)
                        return Viewport.viewport.width - width;
                    return pointPad.x - width/2;
                }

                return dis.LayoutMirroring.enabled? pointPad.x : pointPad.x - width;
            }
            y: {
                if (freePoint) {
                    if (pointPad.y - height/2 < 0)
                        return 0;
                    if (pointPad.y + height/2 > Viewport.viewport.height)
                        return Viewport.viewport.height - height;
                    return pointPad.y - height/2;
                }

                return pointPad.y + (openFromTop? 10 * Devices.density : - height - 10 * Devices.density);
            }
            width: 220 * Devices.density
            ViewportType.transformOrigin: {
                if (freePoint)
                    return Qt.point(width/2, height/2);

                var y = openFromTop? 0 : height;
                var x = dis.LayoutMirroring.enabled? 0 : width;
                return Qt.point(x, y);
            }

            property bool freePoint
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
                    GlobalSignals.retrickRequest(itemData);
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
