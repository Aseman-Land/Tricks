import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Network 2.0
import globals 1.0

BaseRequest {
    id: req
    contentType: NetworkRequest.TypeJson
    url: baseUrl + "/users"

    property string fullname
    property string username
    property string password
    property string email
    property string invitation_code
    property int agreement_version

    function doRequest(pass) {
        password = Tools.hash(App.salt + pass + App.salt, Tools.Sha256);
        _networkManager.post(req)
    }

}
