import QtQuick 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/protected"

    function doRequest() { _networkManager.get(req) }

}
