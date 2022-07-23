import QtQuick 2.0
import AsemanQml.Base 2.0

AsemanObject {
    property int id
    property string username
    property string fullname
    property string about
    property variant join_date: new Date
    property string avatar
    property string cover

    property int followers_count
    property int followings_count
    property int tricks_count

    property bool suspended
    property bool is_follower
    property bool is_followed
    property bool blocked
    property bool blocked_you
    property bool muted

    property int invitation_code
    property int agreement_version
    property int github
    property int google

    property variant details: Tools.toVariantMap("{}")

    function push(d, obj) {
        var o = (obj == undefined? t : obj)
        for (var k in d) {
            try {
                if (o[k].objectName != undefined)
                    push(d[k], o[k]);
                else
                    o[k] = d[k];
            } catch (e) {
            }
        }
    }
}
