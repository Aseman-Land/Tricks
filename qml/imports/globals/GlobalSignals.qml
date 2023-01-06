pragma Singleton

import QtQuick 2.7
import AsemanQml.Base 2.0

AsemanObject {
    signal reloadMeRequest()
    signal tagsRefreshed()
    signal snackRequest(string text)
    signal errorRequest(string text)
    signal fatalRequest(string text)
    signal trickUpdated(variant data)
    signal refreshRequest();
    signal trickDeleted(int id);
    signal retrickRequest(variant trick)
    signal tagReaded(string tag)
    signal communityChooseRequest()
    signal unsuspend()
    signal waitLoginDialog()
    signal closeAllPages()
}

