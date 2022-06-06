import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeNone
    url: baseUrl + "/" + Bootstrap.agreement.markdown

    function doRequest() {
        _networkManager.get(req)
    }
}
