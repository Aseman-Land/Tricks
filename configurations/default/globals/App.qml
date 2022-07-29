pragma Singleton

import QtQuick 2.0
import AsemanQml.Base 2.0
import Tricks 1.0

AppOptions {
    // App Information
    readonly property string uniqueId: appUniqueId
    readonly property string version: appVersion
    readonly property string organizationDomain: appDomain
    readonly property string bundleId: appDomain + ".tricks"
    readonly property int bundleVersion: appBundleVersion

    // Connection
    readonly property string domain: "https://tricks.aseman.io"
    readonly property string sslCertificate: "" // If Any and If Qt Framework built with SSL_SUPPORT
    readonly property bool ignoreSslErrors: false
    readonly property string salt: "92bcd38b-9aae-4528-a5b0-4c38489db279"

    // Look and Feel
    readonly property url logo: "logo.png"
    readonly property color primaryColor: "#5856D6"
    readonly property color accentColor: "#5856D6"
}

