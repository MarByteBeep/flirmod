import QtQuick 1.1
import se.flir 1.0

// PreviewArchiveGroupView
// --------------
// Handle the flickable list of image groups of the archive.

ListView {

    id: previewArchiveGroupView

    anchors.fill: parent
    orientation: ListView.Horizontal
    snapMode: ListView.SnapOneItem
    highlightRangeMode: ListView.StrictlyEnforceRange
    highlightMoveDuration: moveDuration
    cacheBuffer: 1
    interactive: touchBased ? true : false
    objectName: "previewArchiveGroupView"
    model: archiveHandler.model
    flickableDirection: Flickable.HorizontalFlick

    delegate: PreviewArchiveGroupViewDelegate {
        property variant data: model
    }

    property int moveDuration: 100

    function setInteractive(newInteractive) {
        if (interactive !== newInteractive)
            interactive = newInteractive
    }

    // Swipe mouse area (for flick interaction)
    PreviewArchiveMouseArea {
        id: swipeArea
    }

    onCurrentIndexChanged: {
        archiveHandler.model.currentIndex = currentIndex
        if (currentItem !== null && currentItem.currentIndex !== 0)
            currentItem.resetCurrentIndex()
    }
}
