import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Viewport 2.0
import globals 1.0
import requests 1.0

Item {

    GoogleCheckStateRequest {
        id: googleCheckReq
        session_id: GlobalSettings.googleRegisterSessionId
        onErrorChanged: if (error.length) GlobalSettings.googleRegisterSessionId = "";
        onSuccessfull: {
            if (response.result.register_token) {
                Viewport.controller.trigger("float:/auth/signup", {"googleRegisterToken": response.result.register_token});
            } else {
                GlobalSettings.loggedInWithoutPassword = true;
                GlobalSettings.accessToken = response.result.access_token;
            }
            GlobalSettings.googleRegisterSessionId = "";
        }
    }

    GithubCheckStateRequest {
        id: githubCheckReq
        session_id: GlobalSettings.githubRegisterSessionId
        onErrorChanged: if (error.length) GlobalSettings.githubRegisterSessionId = "";
        onSuccessfull: {
            if (response.result.register_token) {
                Viewport.controller.trigger("float:/auth/signup", {"githubRegisterToken": response.result.register_token});
            } else {
                GlobalSettings.loggedInWithoutPassword = true;
                GlobalSettings.accessToken = response.result.access_token;
            }
            GlobalSettings.githubRegisterSessionId = "";
        }
    }

    GoogleCheckStateRequest {
        id: googleConnectCheckReq
        session_id: GlobalSettings.googleConnectSessionId
        onErrorChanged: if (error.length) GlobalSettings.googleConnectSessionId = "";
        onSuccessfull: {
            if (response.result.register_token) {
                googleConnectReq.register_token = response.result.register_token;
                googleConnectReq.doRequest();
            } else {
                GlobalSignals.fatalRequest(qsTr("This account assigned to another account. You can't assign it to your account."))
            }
            GlobalSettings.googleConnectSessionId = "";
        }
    }

    GithubCheckStateRequest {
        id: githubConnectCheckReq
        session_id: GlobalSettings.githubConnectSessionId
        onErrorChanged: if (error.length) GlobalSettings.githubConnectSessionId = "";
        onSuccessfull: {
            if (response.result.register_token) {
                githubConnectReq.register_token = response.result.register_token;
                githubConnectReq.doRequest();
            } else {
                GlobalSignals.fatalRequest(qsTr("This account assigned to another account. You can't assign it to your account."))
            }
            GlobalSettings.githubConnectSessionId = "";
        }
    }

    GoogleConnectRequest {
        id: googleConnectReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSignals.reloadMeRequest();
            GlobalSignals.snackRequest(qsTr("Google account connected successfully."));
        }
    }

    GithubConnectRequest {
        id: githubConnectReq
        allowGlobalBusy: true
        onSuccessfull: {
            GlobalSignals.reloadMeRequest();
            GlobalSignals.snackRequest(qsTr("Github account connected successfully."));
        }
    }

    Connections {
        target: GlobalSignals
        function onUnsuspend() {
            if (googleCheckReq.session_id.length != 0) {
                googleCheckReq.allowGlobalBusy = true;
                googleCheckReq.doRequest();
            }
            if (githubCheckReq.session_id.length != 0) {
                githubCheckReq.allowGlobalBusy = true;
                githubCheckReq.doRequest();
            }
            if (googleConnectCheckReq.session_id.length != 0) {
                googleConnectCheckReq.allowGlobalBusy = true;
                googleConnectCheckReq.doRequest();
            }
            if (githubConnectCheckReq.session_id.length != 0) {
                githubConnectCheckReq.allowGlobalBusy = true;
                githubConnectCheckReq.doRequest();
            }
        }
    }
}
