import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Network 2.0
import AsemanQml.Viewport 2.0
import globals 1.0

NetworkRequest {
    id: req
    contentType: 0//NetworkRequest.TypeJson
    ignoreKeys: ["baseUrl", "refreshingState", "allowGlobalBusy", "allowShowErrors", "forceAllowUnreachable", "accessToken"]
    ignoreRegExp: /^_\w+$/
    ignoreSslErrors: GlobalSettings.ignoreSslErrors
    headers: {
        "Device-ID": Devices.deviceId,
        "Device-Platform": Devices.platformName,
        "Device-Kernel": Devices.platformKernel,
        "Device-Name": Devices.deviceName,
        "Device-Type": Devices.platformType,
        "Device-Version": Devices.platformVersion,
        "Device-CPU": Devices.platformCpuArchitecture,
        "App-Version": App.bundleVersion,
        "App-Secret-ID": appSecretId,
        "Content-Type": "application/json",
        "Authorization": "Bearer " + accessToken,
        "Accept": "application/json"
    }

    property string accessToken: GlobalSettings.accessToken
    readonly property string baseUrl: Constants.baseUrl
    readonly property bool refreshingState: req.refreshing
    property bool allowGlobalBusy: false
    property bool allowShowErrors: true
    property bool forceAllowUnreachable: false

    property alias _networkManager: networkManager
    property bool _debug: false

    signal refreshRequest()

    onErrorChanged: if ((error.indexOf("HostNotFoundError") != -1 || error.indexOf("UnknownNetworkError") != -1) && (forceAllowUnreachable || allowGlobalBusy)) GlobalSignals.errorRequest(qsTr("Network Unreachable"))
    onResponseChanged: if (_debug) console.debug(Tools.variantToJson(response))
    onHeadersChanged: if (!refreshing) refreshRequest()
    onRefreshingStateChanged: {
        if (!allowGlobalBusy)
            return;

        if (refreshingState)
            GlobalSettings.waitCount++
        else
            GlobalSettings.waitCount--
    }

    Component.onDestruction: if (refreshingState && allowGlobalBusy) GlobalSettings.waitCount--

    onSslErrorsChanged: {
        if (GlobalSettings.ignoreSslErrorsViewed)
            return;

        var dlg = GlobalMethods.viewController.trigger("dialog:/general/error", {"title": qsTr("SSL Error"), "body": qsTr("You have connection security issue:%1Do you want to ignore it? If tap on No, all next network requests stop working.").arg("\n" + sslErrors.trim() + "\n"), "buttons": [qsTr("Yes"), qsTr("No")]})
        dlg.itemClicked.connect(function(index){
            if (index == 0) {
                GlobalSettings.ignoreSslErrors = true;
                req.doRequest()
            }

            dlg.Viewport.viewport.closeLast();
        })
        GlobalSettings.ignoreSslErrorsViewed = true;
    }
    onServerError: {
        if (status == 405)
            return;
        try {
            _showError(qsTr("Server Error"), response.message? response.message : error)
        } catch (e) {}
    }
    onClientError: {
        if (status == 405)
            return;
        try {
            _showError(qsTr("Client Error"), response.message? response.message : error);
        } catch (e) {}
    }

    function _showError(title, body) {
//        console.debug(req, url, body)
        if (testMode)
            return;
        if (!allowShowErrors)
            return;
        Tools.jsDelayCall(100, function() {
            GlobalSignals.errorRequest(body);
        })
    }

    NetworkRequestManager {
        id: networkManager
        ignoreSslErrors: GlobalSettings.ignoreSslErrors
    }

    Timer {
        repeat: false
        running: true
        interval: 100
        onTriggered: refreshRequest()
    }
}
