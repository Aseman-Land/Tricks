import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/tricks"

    property string body
    property string code
    property variant highlighter_id
    property variant programing_language_id
    property variant code_frame_id
    property variant quoted_trick_id
    property variant uploaded_file_id
    property int type_id
    property variant tags: new Array
    property variant references: new Array
    property variant mentions: new Array
    property variant parent_id
    property variant community_id: GlobalSettings.communityId? GlobalSettings.communityId : Bootstrap.defaultCommunity

    function doRequest() {
        _networkManager.post(req)
    }
}
