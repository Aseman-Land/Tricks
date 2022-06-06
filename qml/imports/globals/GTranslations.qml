pragma Singleton

import QtQuick 2.7
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0

AsemanObject {
    id: translationManager

    property alias model: model
    property alias localeName: mgr.localeName
    property alias textDirection: mgr.textDirection
    readonly property bool reverseLayout: textDirection == Qt.RightToLeft

    AsemanListModel {
        id: model
        data: {
            var res = new Array;
            var list = mgr.translations;
            for (var i in list) {
                res[res.length] = {
                    "title": list[i],
                    "key": i
                }
            }
            return res
        }
    }

    TranslationManager {
        id: mgr
        sourceDirectory: "translations/"
        delimiters: "-"
        fileName: "lang"
        localeName: GlobalSettings.language

        Component.onCompleted: refreshLayouts()
        onLocaleNameChanged: refreshLayouts()
    }

    function refreshLayouts() {
        if(mgr.localeName == "fa")
            CalendarConv.calendar = 1;
        else
            CalendarConv.calendar = 0;
    }

    function removePersianNums(str) {
        str = Tools.stringReplace(str, "۰", "0", false);
        str = Tools.stringReplace(str, "۱", "1", false);
        str = Tools.stringReplace(str, "۲", "2", false);
        str = Tools.stringReplace(str, "۳", "3", false);
        str = Tools.stringReplace(str, "۴", "4", false);
        str = Tools.stringReplace(str, "۵", "5", false);
        str = Tools.stringReplace(str, "۶", "6", false);
        str = Tools.stringReplace(str, "۷", "7", false);
        str = Tools.stringReplace(str, "۸", "8", false);
        str = Tools.stringReplace(str, "۹", "9", false);
        return str;
    }

    function init() {}
}
