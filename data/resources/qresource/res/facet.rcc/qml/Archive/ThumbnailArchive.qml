import QtQuick 1.1

// ThumbnailArchive
// ----------------
// The thumbnail archive.

GridView {

    // Signals
    signal hideArchive
    signal showPreviewArchive

    // Debug output
    //    onHideArchive: console.log("ThumbnailArchive::hideArchive()")
    //    onShowPreviewArchive: console.log("ThumbnailArchive::showPreviewArchive()")

    // Properties
    id: thumbnailArchive
    model: archiveHandler.model
    anchors.fill: parent
    anchors.leftMargin: grid.archiveLeftMargin
    anchors.rightMargin: -grid.archiveLeftMargin
    cellWidth: grid.archiveHorizontalSpace*2 + grid.archiveCellWidth
    cellHeight: grid.archiveVerticalSpace*2 + grid.archiveCellHeight
    snapMode: GridView.SnapToRow
    flickDeceleration: 700 // TODO: configurable value?

    // Delegate
    delegate: ThumbnailDelegate {}

    // Highlight
    highlight: Rectangle {
        visible: !archiveHandler.model.multiSelectMode && (!touchBased || highLightTimer.running)
        x: grid.archiveHorizontalSpace
        y: grid.archiveVerticalSpace
        width: grid.archiveCellWidth
        height: grid.archiveCellHeight
        color: colors.darkGrey
    }
    highlightFollowsCurrentItem: true
    highlightMoveDuration: 1

    property bool showScrollbar: thumbnailArchive.contentHeight > thumbnailArchive.height ? true : false
    property int scrollHeight: thumbnailArchive.height * thumbnailArchive.visibleArea.heightRatio
    property int scrollPos: thumbnailArchive.visibleArea.yPosition * thumbnailArchive.height
    property alias contentY: thumbnailArchive.contentY
    property alias contentHeight: thumbnailArchive.contentHeight

    // Scroll bar
    Item {
        id: scrollBar
        visible: thumbnailArchive.movingVertically && thumbnailArchive.showScrollbar
        anchors.right: parent.right
        anchors.rightMargin: width + 3
        anchors.top: parent.top
        anchors.topMargin: grid.verticalSpacing
        anchors.bottom: parent.bottom
        anchors.bottomMargin: grid.verticalSpacing
        width: 3

        // Background
        Rectangle {
            color: "#323232"
            anchors.fill: parent
        }

        // Slider
        Rectangle {
            color: "#0066cc"
            anchors.right: parent.right
            width: parent.width
            height: thumbnailArchive.scrollHeight
            y: thumbnailArchive.scrollPos
        }
    }

    Timer {
        id: highLightTimer  // for cameras without key focus indication
        interval: 200
        onTriggered: showPreviewArchive()
    }

    // Index handling
    onCurrentIndexChanged: archiveHandler.model.currentIndex = currentIndex

    // Keyboard handling
    property int indexMemory: -1        // Used for setting to last item when pressing down at the end. Kind of a HACK!
    property bool isScrolling: false
    property int repeateCounter: 0
    Keys.onPressed: {
        if ((event.key === keys.up || event.key === keys.down) && event.isAutoRepeat)
        {
            if(repeateCounter%10 !== 0)
            {
                event.accepted = true
                return;
            }
        }
        // Special case when we've reached the bottom.
        var lastIndex = thumbnailArchive.count -1
        if (event.key === keys.down && currentIndex < lastIndex) {
            indexMemory = currentIndex
        }
    }

    Keys.onReleased: {
        if ((event.key === keys.up || event.key === keys.down) && event.isAutoRepeat)
        {
            repeateCounter++
            if(repeateCounter%10 !== 0)
            {
                event.accepted = true
                return
            }
        }
        if (event.key === keys.back) {
            hideArchive()
            event.accepted = true
        }
        else if (event.key === keys.select) {
            showPreviewArchive()
            event.accepted = true
        }
        else if ((event.key === keys.up || event.key === keys.down) && event.isAutoRepeat && !isScrolling)
        {
            isScrolling = true
        }
        else if ((event.key === keys.up || event.key === keys.down) && !event.isAutoRepeat && isScrolling)
        {
            positionViewAtIndex(currentIndex, ListView.Contain)
            isScrolling = false
            repeateCounter = 0
        }

        var lastIndex = thumbnailArchive.count -1
        if (indexMemory === currentIndex && event.key === keys.down && currentIndex < lastIndex) {
            currentIndex = lastIndex
            positionViewAtIndex(currentIndex, ListView.Contain)
        }
        indexMemory = -1
    }

    // Touch handling
    MouseArea {
        id: delegateMouseAreaId
        anchors.fill: parent
        property bool longPressDispatched
        property int longPressX: 0
        property int longPressY: 0

        onPressed: {
            if(archiveHandler.model.multiSelectEnabled)
            {
                longPressDispatched = false
                longPressSelectTimer.restart()
                longPressX = mouseX
                longPressY = mouseY + contentY
            }
        }

        onCanceled: longPressSelectTimer.stop()

        onReleased: {
            longPressSelectTimer.stop()
            var indx = indexAt(mouseX, mouseY + contentY)
            if(archiveHandler.model.multiSelectMode)
            {
                if(!longPressDispatched && indx !== -1)
                    archiveHandler.model.multiSelect(indx)
            }
            else if(longPressDispatched)
            {
                // Eat release, already handled
            }
            else if (thumbnailArchive.currentIndex === indx)
            {
                showPreviewArchive()
            }
            else if (indx !== -1)
            {
                thumbnailArchive.currentIndex = indx
                if (touchBased)
                    highLightTimer.start()
            }
        }

        Timer {
            id: longPressSelectTimer
            interval: 500
            onTriggered: {
                delegateMouseAreaId.longPressDispatched = true
                archiveHandler.model.multiSelect(indexAt(delegateMouseAreaId.longPressX, delegateMouseAreaId.longPressY))
            }
        }
    }
}
