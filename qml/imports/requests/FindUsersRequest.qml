import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users"

    property int offset
    property int limit: 100
    property string keyword

    function doRequest() {
        _networkManager.get(req)
    }
}
