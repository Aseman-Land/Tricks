import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users/" + _user_id + "/reports"

    property int _user_id
    property string message
    property int report_type

    function doRequest() {
        _networkManager.post(req)
    }
}
