import QtQuick 2.0
import AsemanQml.Base 2.0
import AsemanQml.MaterialIcons 2.0
import QtQuick.Layouts 1.3
import globals 1.0
import models 1.0

Item {
    id: footerItem
    height: (visibleTexts? 60 * Devices.density : 50 * Devices.density ) + Devices.navigationBarHeight

    property alias currentIndex: footerListView.currentIndex
    property alias model: footerListView.model
    property bool visibleTexts: true

    signal footerItemDoubleClicked()
    signal itemRequest(int index)

    Rectangle {
        anchors.fill: parent
        color: Colors.backgroundLight
    }

    Rectangle {
        id: footerBorder
        height: 1 * Devices.density
        color: "#33000000"
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
    }

    TListView {
        id: footerListView
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Devices.navigationBarHeight
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width, 400 * Devices.density)
        orientation: ListView.Horizontal
        maximumFlickVelocity: View.flickVelocity
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: 0
        delegate: FooterItem {
            height: footerListView.height
            width: footerListView.width / footerListView.count
            iconText.text: selected ? model.icon : model.icon_o
            iconText.color: selected ? (Colors.darkMode? Colors.accent : Colors.primary) : Colors.foreground
            iconSizeRatio: model.iconSizeRatio
            visibleTexts: footerItem.visibleTexts
            badgeCount: {
                switch (model.badgeCount) {
                case 1:
                    return GlobalMyTagsModel.totalUnreads;
                case 2:
                    return MyNotificationsModel.unreadsCount;
                default:
                case 0:
                    return 0;
                }
            }
            selected: ListView.isCurrentItem

            title.text: model.name
            title.color: selected ? (Colors.darkMode? Colors.accent : Colors.primary) : Colors.foreground

            onClicked: {
                if(currentIndex === model.index) footerItemDoubleClicked();
                itemRequest(model.index)
            }
            onDoubleClicked: footerItemDoubleClicked()
        }
    }
}
