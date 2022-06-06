import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users/" + _userId + "/tricks"

    property int _userId
    property int offset: 0
    property int limit: 20
    property string tag_name

    function doRequest() {
        _networkManager.get(req)
    }
}
