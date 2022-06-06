import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users/me/timeline"

    property int offset
    property int limit: 20
    property string community_id: GlobalSettings.communityId? GlobalSettings.communityId : Bootstrap.defaultCommunity

    function doRequest() {
        _networkManager.get(req)
    }
}
