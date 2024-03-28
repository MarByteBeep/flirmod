import QtQuick 1.1
import se.flir 1.0
// Touch based control for setting zoom and showing zoom/pan

Item{
    id: statusBarZoomPanIndicatorId

    Rectangle {
        id: idOuterFrameShadow
        y: 1
        color: colors.transparent
        border.width: 1
        border.color: colors.underbright
        height:  parent.height
        width: parent.width
    }

    Item {
        id: zoomPanHolder
        anchors.fill: parent

        Item {
            id: idZoomPanBoxFrame
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: (greenbox.system.panX * parent.width) / (grid.width - 2*grid.irLeftMargin)
            anchors.verticalCenterOffset: (greenbox.system.panY * parent.height) / grid.height
            width: parent.width / greenbox.system.zoom
            height: parent.height / greenbox.system.zoom

            Rectangle {
                id: idZoomPanBoxShadow
                height:  parent.height
                width: parent.width
                y: 1
                color: "#00000000"
                border.width: 1
                border.color: colors.underbright
            }

            Rectangle {
                id: idZoomPanBoxForeground
                height:  parent.height
                width: parent.width
                color: "#00000000"
                border.width: 1
                border.color: colors.white
            }

        }
    }

    Rectangle {
        id: idOuterFrameForeground
        height:  parent.height
        width: parent.width
        color: "#00000000"
        border.width: 1
        border.color: colors.white
    }


    MouseArea {
        id: mouseArea
        anchors.fill: statusBarZoomPanIndicatorId

        onClicked: {
            greenbox.system.nextZoom()
        }
    }
}
