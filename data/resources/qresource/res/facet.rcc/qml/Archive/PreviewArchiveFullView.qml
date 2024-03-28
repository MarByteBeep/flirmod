import QtQuick 1.1
import ".."

// PreviewArchiveFullView
// --------------
// Handle the full view of an image. This is used for reports or for cameras (or images) that do not have full recall (edit).

Item {
    id: fullscreen
    anchors.fill: parent

    property bool zoomModeFull: false
    property alias fullscreenImage: fullscreenImageData.source
    property alias contentX: fullscreenImage.contentX
    property alias contentY: fullscreenImage.contentY
    property alias contentWidth: fullscreenImage.contentWidth
    property alias contentHeight: fullscreenImage.contentHeight

    Flickable {
        id: fullscreenImage
        anchors.fill: parent
        contentWidth: fullscreenImageData.width
        contentHeight: fullscreenImageData.height

        Image {
            id: fullscreenImageData
            sourceSize.width: archiveHandler.model.currentGroupIsReport ?
                                  (fullscreen.zoomModeFull ? grid.pdfFlickWidth : grid.pdfFlickWidthSmall) : grid.width
            sourceSize.height: archiveHandler.model.currentGroupIsReport ?
                                   (fullscreen.zoomModeFull ? grid.pdfFlickHeight : grid.pdfFlickHeightSmall) : grid.height
            width: archiveHandler.model.currentGroupIsReport ?
                       (fullscreen.zoomModeFull ? grid.pdfFlickWidth : grid.pdfFlickWidthSmall) : grid.width
            height: archiveHandler.model.currentGroupIsReport ?
                        (fullscreen.zoomModeFull ? grid.pdfFlickHeight : grid.pdfFlickHeightSmall) : grid.height
            cache: false
            smooth: true
            asynchronous: archiveHandler.model.currentGroupIsReport ? true : false
        }

        // Swipe/Pan mouse area
        PreviewArchiveMouseArea {
            id: mousePanArea
            manualFlick: true
        }
    }

    // Zoom indicator for the fullscreen view of the report
    RoundedRect {
        anchors.fill: reportZoomInidicator
        visible: reportZoomInidicator.visible
    }
    Image {
        id: reportZoomInidicator
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: grid.verticalSpacing
        anchors.rightMargin: grid.horizontalSpacing

        visible: archiveHandler.model.currentGroupIsReport// && root.state === "fullscreen"
        source: fullscreen.zoomModeFull ? "../../images/Sc_Status_Zoom2x_Def.png" :
                                          "../../images/Sc_Status_Zoom1x_Def.png"
    }
}
