import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.Models 2.0
import AsemanQml.MaterialIcons 2.0

AsemanListModel {
    data: [
        {
            name: qsTr("Home") + Translations.refresher,
            icon: MaterialIcons.mdi_home,
            icon_o: MaterialIcons.mdi_home_outline,
            iconSizeRatio: 1,
            badgeCount: 0
        },
        {
            name: qsTr("Search") + Translations.refresher,
            icon: MaterialIcons.mdi_magnify,
            icon_o: MaterialIcons.mdi_magnify,
            iconSizeRatio: 1,
            badgeCount: 0
        },
        {
            name: qsTr("") + Translations.refresher,
            icon: "",
            icon_o: "",
            iconSizeRatio: 1,
            badgeCount: 0
        },
        {
            name: qsTr("Tags") + Translations.refresher,
            icon: MaterialIcons.mdi_tag,
            icon_o: MaterialIcons.mdi_tag_outline,
            iconSizeRatio: 1,
            badgeCount: 1
        },
        {
            name: qsTr("Notifications") + Translations.refresher,
            icon: MaterialIcons.mdi_bell,
            icon_o: MaterialIcons.mdi_bell_outline,
            iconSizeRatio: 1,
            badgeCount: 2
        }
    ]
}
