import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users/me"

    property string fullname
    property string username
    property string about
    property string password
    property string current_password

    function doRequest(pass, current_pass) {
        if (pass.length) {
            password = Tools.hash(App.salt + pass + App.salt, Tools.Sha256);
            current_password = Tools.hash(App.salt + current_pass + App.salt, Tools.Sha256);
        }
        _networkManager.patch(req)
    }

}
