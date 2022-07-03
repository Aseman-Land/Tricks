import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users"

    property string username
    property string fullname
    property string github_register_token
    property int agreement_version

    function doRequest() {
        _networkManager.post(req)
    }
}
