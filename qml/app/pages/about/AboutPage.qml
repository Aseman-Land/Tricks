import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Controls 2.0
import AsemanQml.Viewport 2.0
import AsemanQml.MaterialIcons 2.0
import AsemanQml.Models 2.0
import QtQuick.Layouts 1.3
import components 1.0
import models 1.0
import requests 1.0
import globals 1.0

TPage {
    id: dis
    ViewportType.maximumWidth: Viewport.viewport.width > Viewport.viewport.height && !Devices.isMobile? 500 * Devices.density : 0
    ViewportType.touchToClose: true

    TScrollView {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerItem.bottom
        anchors.bottom: parent.bottom

        TFlickable {
            id: flick
            flickableDirection: Flickable.VerticalFlick
            contentHeight: flickScene.height
            contentWidth: flickScene.width
            bottomMargin: Devices.navigationBarHeight

            Item {
                id: flickScene
                width: flick.width
                height: Math.max(flickColumn.height + 40 * Devices.density, flick.height)

                ColumnLayout {
                    id: flickColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20 * Devices.density
                    spacing: 20 * Devices.density

                    TImage {
                        Layout.fillWidth: true
                        horizontalAlignment: Image.AlignHCenter
                        Layout.preferredHeight: 92 * Devices.density
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 160 * Devices.density
                        sourceSize.height: 160 * Devices.density
                        source: "qrc:/app/files/logo.png"
                    }

                    TLabel {
                        Layout.fillWidth: true
                        font.pixelSize: 9 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignJustify
                        textFormat: Text.StyledText
                        text: qsTr("<b><u>Tricks is a free and opensource programmers social network</u></b>, designed and created by Aseman. It means user freedom and privacy is important for Tricks. So you can access Tricks source code on Github, Read it and change it under the term of the GPLv3 license.") + Translations.refresher
                    }

                    TLabel {
                        Layout.fillWidth: true
                        font.pixelSize: 9 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignLeft
                        text: qsTr("Version:") + " " + appVersion
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 0
                        visible: Bootstrap.aseman

                        Repeater {
                            model: ListModel {
                                ListElement {
                                    title: qsTr("Website")
                                    link: "https://tricks.aseman.io"
                                    icon: "mdi_web"
                                }
                                ListElement {
                                    title: qsTr("Instagram")
                                    link: "https://instagram.com/tricksnetwork/"
                                    icon: "mdi_instagram"
                                }
                                ListElement {
                                    title: qsTr("Telegram")
                                    link: "https://t.me/tricks_social_network"
                                    icon: "mdi_telegram"
                                }
                                ListElement {
                                    title: qsTr("Github")
                                    link: "https://github.com/Aseman-Land/Tricks"
                                    icon: "mdi_git"
                                }
                            }

                            TButton {
                                Layout.preferredWidth: 42 * Devices.density
                                flat: true
                                font.pixelSize: 20 * Devices.fontDensity
                                font.family: MaterialIcons.family
                                text: MaterialIcons[model.icon]
                                onClicked: Qt.openUrlExternally(model.link)
                            }
                        }
                    }

                    TImage {
                        Layout.fillWidth: true
                        Layout.topMargin: 20 * Devices.density
                        horizontalAlignment: Image.AlignHCenter
                        Layout.preferredHeight: 92 * Devices.density
                        fillMode: Image.PreserveAspectFit
                        sourceSize.width: 160 * Devices.density
                        sourceSize.height: 160 * Devices.density
                        source: "qrc:/app/files/aseman.png"
                        visible: Bootstrap.aseman
                    }

                    TLabel {
                        Layout.fillWidth: true
                        font.pixelSize: 9 * Devices.fontDensity
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignJustify
                        textFormat: Text.StyledText
                        text: qsTr("<b><u>Aseman</u></b>, Aseman is a non-profit and community based company that created in 2013 by members of the Idehgostar company. Aseman created to leads open-source and free software.<br />Aseman promotes openness, innovation and participation on the digital and computers world.") + Translations.refresher
                        visible: Bootstrap.aseman
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 0
                        visible: Bootstrap.aseman

                        Repeater {
                            model: ListModel {
                                ListElement {
                                    title: qsTr("Website")
                                    link: "https://aseman.io"
                                    icon: "mdi_web"
                                }
                                ListElement {
                                    title: qsTr("Instagram")
                                    link: "https://instagram.com/asemanland/"
                                    icon: "mdi_instagram"
                                }
                                ListElement {
                                    title: qsTr("Telegram")
                                    link: "https://t.me/asemanland"
                                    icon: "mdi_telegram"
                                }
                                ListElement {
                                    title: qsTr("Twitter")
                                    link: "https://twitter.com/asemanland"
                                    icon: "mdi_twitter"
                                }
                                ListElement {
                                    title: qsTr("Github")
                                    link: "https://github.com/Aseman-Land/"
                                    icon: "mdi_git"
                                }
                            }

                            TButton {
                                Layout.preferredWidth: 42 * Devices.density
                                flat: true
                                font.pixelSize: 20 * Devices.fontDensity
                                font.family: MaterialIcons.family
                                text: MaterialIcons[model.icon]
                                onClicked: Qt.openUrlExternally(model.link)
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        TLabel {
                            Layout.fillWidth: true
                            font.pixelSize: 9 * Devices.fontDensity
                            font.bold: true
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr("Data we collect from your device:") + Translations.refresher
                        }

                        Repeater {
                            model: AsemanListModel {
                                data: {
                                    var map = {
                                        "Device-ID": Devices.deviceId,
                                        "Device-Platform": Devices.platformName,
                                        "Device-Kernel": Devices.platformKernel,
                                        "Device-Name": Devices.deviceName,
                                        "Device-Type": Devices.platformType,
                                        "Device-Version": Devices.platformVersion,
                                        "Device-CPU": Devices.platformCpuArchitecture
                                    }

                                    var res = new Array;
                                    for (var k in map) {
                                        res[res.length] = {
                                            "key": k,
                                            "value": map[k]
                                        };
                                    }

                                    return res;
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: dataCollectColumn.height + 8 * Devices.density

                                RowLayout {
                                    id: dataCollectColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    y: 10 * Devices.density
                                    anchors.margins: 10 * Devices.density
                                    spacing: 4 * Devices.density

                                    TLabel {
                                        font.pixelSize: 9 * Devices.fontDensity
                                        horizontalAlignment: Text.AlignLeft
                                        color: Colors.accent
                                        text: model.key + ":"
                                    }

                                    TLabel {
                                        Layout.fillWidth: true
                                        font.pixelSize: 9 * Devices.fontDensity
                                        horizontalAlignment: Text.AlignRight
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                        text: model.value
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        TLabel {
                            Layout.fillWidth: true
                            font.pixelSize: 9 * Devices.fontDensity
                            font.bold: true
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr("Data we do not collect from your device:") + Translations.refresher
                        }

                        TLabel {
                            Layout.fillWidth: true
                            padding: 10 * Devices.density
                            font.pixelSize: 9 * Devices.fontDensity
                            horizontalAlignment: Text.AlignJustify
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr("We do not collect any other data except of above list from your device.") + Translations.refresher
                        }

                        Repeater {
                            model: AsemanListModel {
                                data: {
                                    var map = {
                                        "Your Medias": qsTr("All safe and don't collect"),
                                        "Your Contacts": qsTr("All safe and don't collect"),
                                        "Your Messages": qsTr("All safe and don't collect"),
                                        "Your Locations": qsTr("All safe and don't collect"),
                                        "Your Camera": qsTr("All safe and don't collect"),
                                        "Your Mic": qsTr("All safe and don't collect"),
                                    }

                                    var res = new Array;
                                    for (var k in map) {
                                        res[res.length] = {
                                            "key": k,
                                            "value": map[k]
                                        };
                                    }

                                    return res;
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: dataNotCollectColumn.height + 8 * Devices.density

                                RowLayout {
                                    id: dataNotCollectColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    y: 10 * Devices.density
                                    anchors.margins: 10 * Devices.density
                                    spacing: 4 * Devices.density

                                    TLabel {
                                        Layout.fillWidth: true
                                        font.pixelSize: 9 * Devices.fontDensity
                                        horizontalAlignment: Text.AlignLeft
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        color: Colors.accent
                                        text: model.key + ":"
                                    }

                                    TLabel {
                                        font.pixelSize: 9 * Devices.fontDensity
                                        horizontalAlignment: Text.AlignJustify
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.value
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        TLabel {
                            Layout.fillWidth: true
                            font.pixelSize: 9 * Devices.fontDensity
                            font.bold: true
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr("Data we store without encryption on the server:") + Translations.refresher
                        }

                        TLabel {
                            Layout.fillWidth: true
                            font.pixelSize: 9 * Devices.fontDensity
                            horizontalAlignment: Text.AlignJustify
                            padding: 10 * Devices.density
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr("There is no private and sensitive feature on the Tricks currently. So all data you posted to the Tricks servers (except your password), store without encryption " +
                                       "and you must aware of posting your sensitive data to the Tricks.\n" +
                                       "But We promise to add sensitive features with encryption-only in the future.") + Translations.refresher
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        TLabel {
                            Layout.fillWidth: true
                            font.pixelSize: 9 * Devices.fontDensity
                            font.bold: true
                            horizontalAlignment: Text.AlignLeft
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: qsTr("Open-source projects used in Tricks:") + Translations.refresher
                        }

                        Repeater {
                            model: AsemanListModel {
                                data: {
                                    var res = [
                                        {"title": "QtAseman " + qtAsemanVersion, "license": "GNU GPL v3", "link": "https://github.com/Aseman-Land/QtAseman/", "description": qsTr("Aseman's Tools, Architectures and Standards all in a module called QtAseman for Qt and Qml.")},
                                        {"title": "KDE Syntax Highlighting", "license": "MIT License", "link": "https://github.com/KDE/syntax-highlighting", "description": qsTr("This is a stand-alone implementation of the Kate syntax highlighting engine. It's meant as a building block for text editors as well as for simple highlighted text rendering.")},
                                        {"title": "Qt Framework " + qtVersion, "license": "GNU Lesser GPL v3", "link": "http://qt.io", "description": qsTr("Qt is a cross-platform application and UI framework for developers using C++ or QML, a CSS & JavaScript like language.")},
                                    ];

                                    if (qtFirebase) {
                                        res[res.length] = {"title": "QtFirebase " + qtFirebaseVersion, "license": "MIT License", "link": "https://github.com/Larpon/QtFirebase", "description": qsTr("QtFirebase aims to bring all the features of the Firebase C++ SDK to Qt 5 - both as C++ wrappers and as QML components.")};
//                                        res[res.length] = {"title": "Firebase", "license": "Apache 2.0", "link": "https://github.com/firebase", "description": qsTr("Firebase is an app development platform with tools to help you build, grow and monetize your app.")};
                                    }

                                    if (qzxing)
                                        res[res.length] = {"title": "QZXing ", "license": "Apache 2.0", "link": "https://github.com/ftylitak/qzxing", "description": qsTr("Qt/QML wrapper library for the ZXing barcode image processing library.")};

                                    res[res.length] = {"title": "OpenSSL", "license": "Apache 2.0", "link": "http://openssl.org", "description": qsTr("OpenSSL is a software library for applications that secure communications over computer networks against eavesdropping or need to identify the party at the other end.")};
                                    res[res.length] = {"title": "Ubuntu Font", "license": "Ubuntu Font License", "link": "https://design.ubuntu.com/font/", "description": qsTr("The Ubuntu font family are a set of matching new libre/open fonts. The development is being funded by Canonical on behalf the wider Free Software community and the Ubuntu project.")};
                                    res[res.length] = {"title": "Vazirmatn Font", "license": "OFL 1.1", "link": "https://github.com/rastikerdar/vazirmatn", "description": qsTr("Vazirmatn is a Persian/Arabic font project that started in 2015 under the name of Vazir with the idea of a new simple and legible typeface suitable for web pages and applications.")};
                                    res[res.length] = {"title": "Material Design Icons", "license": "Apache 2.0", "link": "https://github.com/Templarian/MaterialDesign", "description": qsTr("Material Design Icons' growing icon collection allows designers and developers targeting various platforms to download icons in the format, color and size they need for any project.")};

                                    return res;
                                }
                            }

                            TItemDelegate {
                                Layout.fillWidth: true
                                Layout.preferredHeight: osAppColumn.height + 20 * Devices.density
                                onClicked: Qt.openUrlExternally(model.link)

                                ColumnLayout {
                                    id: osAppColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    y: 10 * Devices.density
                                    anchors.margins: 10 * Devices.density
                                    spacing: 4 * Devices.density

                                    TLabel {
                                        Layout.fillWidth: true
                                        font.pixelSize: 9 * Devices.fontDensity
                                        horizontalAlignment: Text.AlignLeft
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.title
                                    }

                                    TLabel {
                                        Layout.fillWidth: true
                                        font.pixelSize: 8 * Devices.fontDensity
                                        horizontalAlignment: Text.AlignJustify
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.description
                                    }

                                    TLabel {
                                        Layout.fillWidth: true
                                        font.pixelSize: 8 * Devices.fontDensity
                                        horizontalAlignment: Text.AlignLeft
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        text: model.link
                                        color: Colors.accent
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    THeader {
        id: headerItem
        anchors.left: parent.left
        anchors.right: parent.right

        TLabel {
            anchors.centerIn: parent
            font.pixelSize: 10 * Devices.fontDensity
            text: qsTr("About") + Translations.refresher
        }
    }

    THeaderBackButton {
        ratio: 1
        onClicked: dis.ViewportType.open = false
    }
}
