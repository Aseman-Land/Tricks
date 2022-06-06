import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/auth/forget-password/recover"

    property string code
    property string email
    property string new_password

    function doRequest(pass) {
        new_password = Tools.hash(App.salt + pass + App.salt, Tools.Sha256);
        _networkManager.post(req)
    }
}
