import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/tags"

    property int offset: 0
    property int limit: 200
    property string keyword
    property string user

    function doRequest() {
        _networkManager.get(req)
    }
}
