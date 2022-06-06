import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/tricks/" + _id + "/rates"

    property int _id
    property int rate

    function doRequest() {
        _networkManager.post(req)
    }
}
