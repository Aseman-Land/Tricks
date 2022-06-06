pragma Singleton

import QtQuick 2.10
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0

QtObject {

    property ViewportController viewController
    property variant window

    function normalizeDate(date) {
        return date.toISOString();
    }

    function unNormalizeDate(dateStr) {
        return Tools.dateFromSec( Math.floor(Date.parse(dateStr) / 1000) - (new Date).getTimezoneOffset()*60 );
    }

    function dateToString(date) {
        let secs = Tools.dateToSec(new Date) - Tools.dateToSec(date);
        let min_length = 60;
        let hour_length = 60 * min_length;
        let day_length = 24 * hour_length;
        let week_length = 7 * day_length;
        let month_length = 30 * day_length;
        let year_length = 365 * day_length;
        let array = [
            // Length, Unit Str, Many String, Max
            [1, qsTr("1 sec ago"), qsTr("%1 secs ago"), min_length],
            [min_length, qsTr("1 min ago"), qsTr("%1 mins ago"), hour_length],
            [hour_length, qsTr("1 hour ago"), qsTr("%1 hours ago"), day_length],
            [day_length, qsTr("1 day ago"), qsTr("%1 days ago"), week_length],
            [week_length, qsTr("1 week ago"), qsTr("%1 weeks ago"), month_length],
            [month_length, qsTr("1 month ago"), qsTr("%1 months ago"), year_length],
            [year_length, qsTr("1 year ago"), qsTr("%1 years ago"), 100 * year_length],
        ];

        for (var i=0; i<array.length; i++) {
            var it = array[i];
            if (secs <= it[0])
                return it[1];
            if (secs < it[3])
                return it[2].arg( Math.floor(secs/it[0]) )
        }

        return CalendarConv.convertDateTimeToLittleString(date);
    }

    function formName(n) {
        if (n.length == 0)
            return "";

        return n[0].toUpperCase() + n.slice(1).toLowerCase();
    }

    function fixUrlProperties(s) {
        s = Tools.stringReplace(s, "%", "%25");
        s = Tools.stringReplace(s, "+", "%2B");
        s = Tools.stringReplace(s, "/", "%2F");
        s = Tools.stringReplace(s, "#", "%23");
        return s;
    }

    function fixAddressProperties(s) {
        s = Tools.stringReplace(s, "/", "%2F");
        s = Tools.stringReplace(s, "#", "%23");
        return s;
    }
}
