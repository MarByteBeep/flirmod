import QtQuick 1.1
import se.flir 1.0
import System 1.0

Item {
    id: statusBar
    width: visualElement.width
    height: grid.resultTableRowHeight
    visible: (greenbox.system.tilt === 0 || greenbox.system.tilt === 180)

    property int lastIndex: statusBarController.statusList.length > 0
                            ? statusBarController.statusList.length - 1
                            : 0

    RoundedRect {
        id: visualElement
        visible: statusBarController.statusList.length > 0
        width: listView.contentWidth
        height: parent.height

        ListView {
            id: listView
            anchors.fill: parent
            anchors.margins: 1
            model: statusBarController.statusList
            orientation: ListView.Horizontal

            delegate: Item {
                width: divider.width + status.width
                height: status.height

                Item {
                    id: status
                    width: (icon.width > overlayText.width) ? icon.width : overlayText.width + 6
                    height: (icon.height > overlayText.height) ? icon.height : overlayText.height

                    Image {
                        id: icon
                        source: modelData.icon
                                ? "../images/" + modelData.icon
                                : ""
                        opacity: modelData.opacity
                    }

                    Text {
                        id: overlayText
                        anchors.centerIn: parent
                        text: modelData.overlayText
                        font.family: fonts.family
                        font.pixelSize: fonts.smallSize
                        color: colors.textFocused
                    }
                }

                Image {
                    id: divider
                    anchors.left: status.right
                    visible: statusBarController.statusList[statusBar.lastIndex] !== modelData
                    source: "../images/Bg_Status_Divider_Def.png"
                }
            }
        }
    }
}


