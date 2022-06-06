import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users/me/mutes/" + _userId

    property int _userId

    function doRequest() {
        _networkManager.deleteMethod(req)
    }
}
