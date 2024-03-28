import QtQuick 1.1
import se.flir 1.0
// Touch based control for setting zoom and showing zoom/pan

Image {
    id: controlRoot

    // TODO: can we have different images for touch feedback?
    source: visible ? (mouseArea.pressed ? "../images/Bg_Leftbar_ZoomIndicator_Def.png" : "../images/Bg_Leftbar_ZoomIndicator_Def.png") : ""

    Text {
        id: zoomText
        anchors.right: parent.right
        anchors.rightMargin: grid.horizontalSpacing
        anchors.verticalCenter: parent.verticalCenter
        color: colors.textFocused
        text: greenbox.system.zoomString
    }

    Item {
        id: zoomPanHolder
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 24 //todo: Hardcoded!
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1 //todo: Hardcoded!

        Rectangle {
            id: zoomPanBox
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: (greenbox.system.panX * parent.width) / (grid.width - 2*grid.irLeftMargin)
            anchors.verticalCenterOffset: (greenbox.system.panY * parent.height) / grid.height
            width: parent.width / greenbox.system.zoom
            height: parent.height / greenbox.system.zoom

            color: colors.transparent

            border.width: 1
            border.color: colors.white
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onClicked: {
            greenbox.system.nextZoom()
        }
    }

}
