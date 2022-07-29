import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    contentType: NetworkRequest.TypeForm
    url: baseUrl + "/tricks/photo"

    property url image

    function doRequest() {
        _networkManager.post(this);
    }
}
