import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/tricks/" + _trick_id + "/tips"

    property int _trick_id

    property int offset: 0
    property int limit: 20

    function doRequest() {
        _networkManager.get(req)
    }
}
