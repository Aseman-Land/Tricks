import QtQuick 2.0
import AsemanQml.Base 2.0

AsemanObject {
    id: t

    property int id

    property string body
    property string code
    property string filename

    property alias owner: owner
    UserJsonItem {
        id: owner
    }

    property variant datetime: new Date

    property alias highlighter: highlighter
    AsemanObject {
        id: highlighter
        property int id
        property string name
    }

    property alias programing_language: programing_language
    AsemanObject {
        id: programing_language
        property int id
        property string name
    }

    property alias code_frame: code_frame
    AsemanObject {
        id: code_frame
        property int id
        property string name
    }

    property alias community: community
    AsemanObject {
        id: community
        property int id
        property string title
    }

    property alias type: type
    AsemanObject {
        id: type
        property int id
        property string name
        property string description
    }

    property int views
    property int comments
    property bool view_state
    property int rates
    property bool rate_state
    property int tips
    property bool tip_state
    property int retricks

    property variant tags: new Array
    property variant references: new Array

    property alias quote: quote
    AsemanObject {
        id: quote
        property int id
        property variant datetime: new Date

        property int type_id
        property int views
        property int comments
        property int rates
        property int tips
        property int retricks
        property int quoted_trick_id
        property int community_id

        property int parent_id
        property int root_id

        property string username
        property string fullname
        property string avatar
        property int owner

        property string body
        property string code
        property string filename
    }

    property int retrick_trick_id
    property alias retricker: retricker
    UserJsonItem {
        id: retricker
    }

    property alias image_size: image_size
    AsemanObject {
        id: image_size
        property real width
        property real height
    }

    property string share_link
    property bool bookmarked

    property int root_id
    property int parent_id
    property int refred_trick_id
    property int link_id

    property alias parent_owner: parent_owner
    UserJsonItem {
        id: parent_owner
    }

    property alias app: app
    AsemanObject {
        id: app
        property int id
        property string title
    }

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
