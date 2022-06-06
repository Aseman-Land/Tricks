import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    contentType: NetworkRequest.TypeForm
    url: baseUrl + "/users/me"

    property url avatar

    function doRequest() {
        _networkManager.deleteMethod(this);
    }
}
