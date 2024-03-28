import QtQuick 1.1
import se.flir 1.0

// PreviewArchive
// --------------
// It handles navigation and decorations in a single image or single group view.
// It has two sub controls for the image(s): GroupView and FullView.

Item {
    id: previewArchive
    anchors.fill: parent

    // Signals and properties
    signal showThumbnailArchive
    signal showArchiveToolBar
    property QtObject model: archiveHandler.model

    property bool goingLeft: false
    property bool goingRight: false
    property bool goingUp: false
    property bool goingDown: false
    property int moveDuration: 1
    property int indicatorTime: 200

    property alias zoomModeFull: previewArchiveFullView.zoomModeFull
    property alias fullscreenImageSource: previewArchiveFullView.fullscreenImage
    property alias currentIndex: previewArchiveGroupView.currentIndex
    property alias currentItem: previewArchiveGroupView.currentItem

    Timer {
        id: indicatorTimer
        interval: indicatorTime
        onTriggered: {
            if (goingLeft)
                goingLeft = false
            if (goingRight)
                goingRight = false
            if (goingUp)
                goingUp = false
            if (goingDown)
                goingDown = false
        }
    }

    function positionViewAtIndex()
    {
        previewArchiveGroupView.positionViewAtIndex(archiveHandler.model.currentIndex, ListView.Contain)
    }

    function goLeft() {
        if (previewArchiveGroupView.currentIndex > 0)
        {
            goingLeft = true
            previewArchiveGroupView.decrementCurrentIndex()
            if (indicatorTimer.running)
                indicatorTimer.restart()
            else
                indicatorTimer.start()
        }
    }

    function goRight() {
        if (previewArchiveGroupView.currentIndex < (previewArchiveGroupView.count - 1))
        {
            goingRight = true
            previewArchiveGroupView.incrementCurrentIndex()
            if (indicatorTimer.running)
                indicatorTimer.restart()
            else
                indicatorTimer.start()
        }
    }

    function goUp() {
        goingUp = true
        previewArchiveGroupView.currentItem.decrementCurrentIndex()
        if (indicatorTimer.running)
            indicatorTimer.restart()
        else
            indicatorTimer.start()
    }

    function goDown() {
        goingDown = true
        previewArchiveGroupView.currentItem.incrementCurrentIndex()
        if (indicatorTimer.running)
            indicatorTimer.restart()
        else
            indicatorTimer.start()
    }

    function tapAction(coord)
    {
        if (previewArchiveGroupView.currentItem !== undefined && previewArchiveGroupView.currentItem.videoPlayIcon !== null &&
            previewArchiveGroupView.currentItem.videoPlayIcon !== undefined)
        {
            var iconRelativeCoord = previewArchiveGroupView.mapToItem(previewArchiveGroupView.currentItem.videoPlayIcon, coord.x, coord.y)
            if(iconRelativeCoord.x > 0 &&
               iconRelativeCoord.x < previewArchiveGroupView.currentItem.videoPlayIcon.width &&
               iconRelativeCoord.y > 0 &&
               iconRelativeCoord.y < previewArchiveGroupView.currentItem.videoPlayIcon.height)
            {
                console.log("enterVideoPlayback")
                archiveHandler.enterVideoPlayback()
                return
            }
        }
        //console.log("toggle ArchiveToolBar")
        menus.toggleMenu()
    }

    // Image group view
    PreviewArchiveGroupView {
        id: previewArchiveGroupView
        visible: root.state !== "fullscreen"
    }

    // Image full view
    PreviewArchiveFullView {
        id: previewArchiveFullView
        visible: root.state == "fullscreen"
        onVisibleChanged: {
            if (visible)
            {
                previewArchiveFullView.contentX = 0
                previewArchiveFullView.contentY = 0
            }
        }
    }

    // Decorations
    Item {
        anchors.fill: parent
        visible: root.state !== "fullscreen" && !menus.menuOpen && !touchBased ? true : touchBased

        // The left arrow
        Image {
            id: leftArrow
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: -grid.horizontalSpacing
            source: "../../images/Ic_List_ArrowLeft_Sel.png"
            visible: previewArchiveGroupView.currentIndex > 0 && !previewArchiveGroupView.moving

            Rectangle {
                visible: touchBased
                color: root.state === "fullscreen" ? "#77000000" : "#FF202020"
                anchors.fill: parent
                anchors.margins: 5
                radius: 1
                z: -1
            }

            MouseArea {
                id: leftArrowMouseArea
                height: grid.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left
                enabled: leftArrow.visible
                onPressed: goLeft()
            }
        }

        // The right arrow
        Image {
            id: rightArrow
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: -grid.horizontalSpacing
            source: "../../images/Ic_List_ArrowRight_Sel.png"
            visible: previewArchiveGroupView.currentIndex < (previewArchiveGroupView.count - 1) && !previewArchiveGroupView.moving

            Rectangle {
                visible: touchBased
                color: root.state === "fullscreen" ? "#77000000" : "#FF202020"
                anchors.fill: parent
                anchors.margins: 5
                radius: 1
                z: -1
            }

            MouseArea {
                id: rightArrowMouseArea
                height: grid.height
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.left: parent.left
                enabled: rightArrow.visible
                onPressed: goRight()
            }
        }

        // The bottom row
        Item {
            id: bottomBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: grid.archivePreviewRowOffsetY
            height: fonts.archiveSize
            visible: !touchBased

            // Group name, file name and arrows
            Item {
                anchors.fill: parent
                visible: (previewArchiveGroupView.currentIndex < 0) ? false : previewArchiveGroupView.currentItem.data.groupSize > 1

                Text {
                    id: groupNameText
                    anchors.centerIn: parent
                    font.family: fonts.family
                    font.pixelSize: fonts.archiveSize
                    color: colors.textFocused
                    text: (previewArchiveGroupView.currentIndex < 0) ? "" : previewArchiveGroupView.currentItem.data.groupName
                }

                Image
                {
                    id: upDownArrow
                    anchors.verticalCenter: groupNameText.verticalCenter
                    anchors.verticalCenterOffset: goingUp ? -4 : goingDown ? 4 : 0
                    anchors.left: groupNameText.right
                    source: goingUp ? "../../images/Ic_List_ArrowUp_Sel.png" : goingDown ?
                                      "../../images/Ic_List_ArrowDown_Sel.png" : "../../images/Ic_List_ArrowUpDown_Def.png"
                }
                MouseArea {
                    id: upDownArrowMouseArea
                    anchors.fill: upDownArrow
                    anchors.topMargin: -5
                    anchors.bottomMargin: -5
                    enabled: upDownArrow.visible
                    onPressed: goUp()
                }
            }

            // Just file name if only one image in group
            Item {
                visible: (previewArchiveGroupView.currentIndex < 0) ? false : previewArchiveGroupView.currentItem.data.groupSize === 1
                anchors.centerIn: parent
                Text {
                    id: singleItemText
                    anchors.centerIn: parent
                    font.family: fonts.family
                    font.pixelSize: fonts.archiveSize
                    color: colors.textFocused
                    text: (previewArchiveGroupView.currentIndex < 0) ? "" : previewArchiveGroupView.currentItem.data.currentShortName
                }
                Text {
                    id: itemReportCount
                    anchors.left: singleItemText.right
                    anchors.leftMargin: grid.horizontalSpacing
                    anchors.verticalCenter: singleItemText.verticalCenter
                    font.family: fonts.family
                    font.pixelSize: fonts.archiveSize
                    color: colors.textNormal
                    text: (previewArchiveGroupView.currentIndex < 0 || archiveHandler.model.lastReportPage < 1) ?
                              "" :
                              "(" + (archiveHandler.model.reportPage+1) + "/" + (archiveHandler.model.lastReportPage+1) + ")"
                }
            }
        }
    }

    // Top file name (touch-only ui)
    Rectangle {
        id: fileNameLabel
        visible: touchBased
        color: "#77000000"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: grid.verticalSpacing * 3
        height: fileNameLabelText.height + grid.verticalSpacing * 2
        width: fileNameLabelText.width + grid.verticalSpacing * 4
        radius: 1

        Text {
            id: fileNameLabelText
            anchors.centerIn: parent
            font.family: fonts.family
            font.pixelSize: fonts.archiveSize
            color: colors.textFocused
            text: (previewArchiveGroupView.currentIndex < 0) ? "" : previewArchiveGroupView.currentItem.data.currentShortName
        }
    }

    // Annotation icons
    Row {
        // Put the annotation icons outside of the bottomBar item so
        // they aren't hidden when bottomBar is.
        anchors.bottom: parent.bottom
        anchors.bottomMargin: grid.archivePreviewRowOffsetY + (bottomBar.height - height) / 2
        anchors.right: parent.right
        anchors.rightMargin: grid.width - grid.previewWidth - grid.irRightMargin
        spacing: grid.horizontalSpacing
        visible: !touchBased

        Image {
            id: textCommentID
            visible: (previewArchiveGroupView.currentIndex < 0) ? false : previewArchiveGroupView.currentItem.data.hasTextComment
            source: visible ? "../../images/Sc_StackContent_AnnotationTextNote_Def.png" : ""
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -5
                anchors.bottomMargin: -5
                onPressed: archiveHandler.openTextNoteWindow()
            }
        }

        Image {
            id: tableCommentID
            visible: (previewArchiveGroupView.currentIndex < 0) ? false : previewArchiveGroupView.currentItem.data.hasTableComment
            source: visible ? "../../images/Sc_StackContent_AnnotationTextTable_Def.png" : ""
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -5
                anchors.bottomMargin: -5
                onPressed: archiveHandler.openTableWindow()
            }
        }

        Image {
            id: voiceCommentID
            visible: (previewArchiveGroupView.currentIndex < 0) ? false : previewArchiveGroupView.currentItem.data.hasVoiceComment
            source: visible ? "../../images/Sc_StackContent_AnnotationVoice_Def.png" : ""
            anchors.verticalCenter: parent.verticalCenter
            MouseArea {
                anchors.fill: parent
                anchors.topMargin: -5
                anchors.bottomMargin: -5
                onPressed: archiveHandler.openVoiceMenu()
            }
        }
    }

    // Keyboard handling
    Keys.onPressed: {
        //console.log("PreviewArchive.Keys.onPressed")
        if (root.state === "fullscreen")
        {
            if (event.key === keys.back || event.key === keys.archive)
                event.accepted = true
            else if (archiveHandler.model.currentGroupIsReport) {
                if (event.key === keys.down) {
                    previewArchiveFullView.contentY = previewArchiveFullView.contentY +grid.pdfScrollStep
                    var maxPanY = previewArchiveFullView.contentHeight - previewArchiveFullView.height
                    if (previewArchiveFullView.contentY > maxPanY) {
                        previewArchiveFullView.contentY = maxPanY
                    }
                    event.accepted = true
                }
                else if (event.key === keys.up) {
                    previewArchiveFullView.contentY = previewArchiveFullView.contentY -grid.pdfScrollStep
                    if (previewArchiveFullView.contentY < 0) {
                        previewArchiveFullView.contentY = 0
                    }
                    event.accepted = true
                }
                else if (event.key === keys.right) {
                    previewArchiveFullView.contentX = previewArchiveFullView.contentX +grid.pdfScrollStep
                    var maxPanX = previewArchiveFullView.contentWidth - previewArchiveFullView.width
                    if (previewArchiveFullView.contentX > maxPanX) {
                        previewArchiveFullView.contentX = maxPanX
                    }
                    event.accepted = true
                }
                else if (event.key === keys.left) {
                    previewArchiveFullView.contentX = previewArchiveFullView.contentX -grid.pdfScrollStep
                    if (previewArchiveFullView.contentX < 0) {
                        previewArchiveFullView.contentX = 0
                    }
                    event.accepted = true
                }
            }
        }
        else
        {
            if (event.key === keys.left) {
                goLeft()
                event.accepted = true
            }
            else if (event.key === keys.right) {
                goRight()
                event.accepted = true
            }
            else if (event.key === keys.up) {
                goUp()
                event.accepted = true
            }
            else if (event.key === keys.down) {
                goDown()
                event.accepted = true
            }
        }
    }

    Keys.onReleased: {
        //console.log("PreviewArchive.Keys.onReleased")
        if (root.state === "fullscreen")
        {
            if (event.key === keys.back || event.key === keys.archive) {
                archiveHandler.view = ArchiveHandler.ImageSelector
                event.accepted = true
            }
        }
        else
        {
            if (event.key === keys.back) {
                showThumbnailArchive()
                event.accepted = true
            }
            else if (event.key === keys.select) {
                showArchiveToolBar()
                event.accepted = true
            }
        }
    }
}
