import QtQuick 1.1
import se.flir 1.0
import System 1.0

/**
 *  The QML layer of the panorama recording UI
 */
Item {
    id:           root
    anchors.fill: parent
    visible:      panoramaHandler.visible
    
    onVisibleChanged: {
        // console.debug("PanoramaRecording.root.onVisibleChanged(" + visible + ")")
        if (visible)
            forceActiveFocus()
        else
            clear()
    }

    function clear() {
        message     .visible = false
        thumbnailBar.visible = false
    }

    // frame rectangle
    Rectangle {
        id:     frameRect
        x: (root.width  - panoramaHandler.frameWidth)/2
        y: (root.height - panoramaHandler.frameHeight)/2
        width:            panoramaHandler.frameWidth
        height:           panoramaHandler.frameHeight
        border.color: "white"
        border.width: 1
        color: "transparent"
        opacity: 0.5
        visible: true
    }
    
    // target rectangle
    Rectangle {
        id:           targetRect
        x:            frameRect.x + panoramaHandler.targetX
        y:            frameRect.y + panoramaHandler.targetY
        width:        frameRect.width
        height:       frameRect.height
        border.color: "white"
        border.width: 2
        color:        "transparent"
        visible:      panoramaHandler.showTarget

        // onVisibleChanged: console.debug("PanoramaRecording.targetRect.onVisibleChanged(" + visible + ")")
    }

    // right direction arrow
    Image {
        id: rightArrow
        visible: (panoramaHandler.directionFlags & PanoramaHandler.DirectionFlag_Right) != 0
        source: "../images/Ic_List_ArrowRight_Sel.png"
        x: grid.width - width
        y: (grid.height - height)/2

        // onVisibleChanged: console.debug("PanoramaRecording.rightArrow.onVisibleChanged(" + visible + ")")
    }

    // left direction arrow
    Image {
        id: leftArrow
        visible: (panoramaHandler.directionFlags & PanoramaHandler.DirectionFlag_Left) != 0
        source: "../images/Ic_List_ArrowLeft_Sel.png"
        x: 0
        y: (grid.height - height)/2

        // onVisibleChanged: console.debug("PanoramaRecording.leftArrow.onVisibleChanged(" + visible + ")")
    }

    // down direction arrow
    Image {
        id: downArrow
        visible: (panoramaHandler.directionFlags & PanoramaHandler.DirectionFlag_Down) != 0
        source: "../images/Ic_List_ArrowDown_Sel.png"
        x: (grid.width - width)/2
        y: grid.height - height

        // onVisibleChanged: console.debug("PanoramaRecording.downArrow.onVisibleChanged(" + visible + ")")
    }

    // up direction arrow
    Image {
        id: upArrow
        visible: (panoramaHandler.directionFlags & PanoramaHandler.DirectionFlag_Up) != 0
        source: "../images/Ic_List_ArrowUp_Sel.png"
        x: (grid.width - width)/2
        y: 0

        // onVisibleChanged: console.debug("PanoramaRecording.upArrow.onVisibleChanged(" + visible + ")")
    }

    // panorama status (icon + picture count)
    Item {
        id:      status
        width:   row.width
        height:  grid.resultTableRowHeight
        x:       grid.leftMargin + grid.horizontalSpacing
        y:       grid.topMargin  + grid.verticalSpacing

        // background
        RoundedRect {
            anchors.fill: parent
        }
        Row {
            id: row
            height: parent.height

            // panorama recording mode indicator
            Image {
                id: statusMode
                source: "../images/Ic_Options_RecordingModePanorama_Sel.png"
                opacity: 1.0
                anchors.verticalCenter: parent.verticalCenter
            }
            // recording phase in the form "n/N"
            Text {
                id:             statusText
                text:           panoramaHandler.statusText
                font.family:    fonts.family
                font.pixelSize: fonts.smallSize
                color:          colors.textFocused
                anchors.verticalCenter: parent.verticalCenter

                // onTextChanged: console.debug("PanoramaRecording.statusText.onTextChanged(" + text + ")")
            }
        }
        // onVisibleChanged: console.debug("PanoramaRecording.status.onVisibleChanged(" + visible + ")")
    }
    
    // panorama thumbnail slide bar
    Rectangle {
        id: thumbnailBar
        property int innerMargin: 3
        border.width:   0
        color:          "black"
        radius:         innerMargin
        width:          thumbnailClip.width  + 2*innerMargin
        height:         thumbnailClip.height + 2*innerMargin
        visible:        false

        // clipper
        Rectangle {
            id:             thumbnailClip
            x:              thumbnailBar.innerMargin
            y:              thumbnailBar.innerMargin
            border.width:   0
            color:          "transparent"
            clip:           true
            width:          thumbnail.width
            height:         thumbnail.height

            // actual thumbnail of the captured panorama 
            Image {
                id:     thumbnail
                x:      0
                y:      0
                source: thumbnailBar.visible ? panoramaHandler.thumbnailSource : ""
                cache:  false
            }

            // current frame position overlaid on the thumbnail
            Rectangle {
                id:           thumbnailFrame
                border.color: "white"
                border.width: 2
                color:        "transparent"
                x:            panoramaHandler.thumbnailFrameX
                y:            panoramaHandler.thumbnailFrameY
                width:        panoramaHandler.thumbnailFrameWidth
                height:       panoramaHandler.thumbnailFrameHeight
                visible:      panoramaHandler.showTarget
            }
        }
        
        Connections {
            target: panoramaHandler

            onThumbnailSourceChanged: {
                // force update before retrieving extents
                thumbnail.source = panoramaHandler.thumbnailSource
                var dx = thumbnail.sourceSize.width
                var dy = thumbnail.sourceSize.height
                // console.debug("> PanoramaRecording.onThumbnailSourceChanged(): thumbnail.sourceSize={" + dx + ", " + dy + "}")
                if (dx > 0 && dy > 0) {
                    // determine position given direction and extents
                    switch (panoramaHandler.directionFlags) {
                        case PanoramaHandler.DirectionFlag_Left:
                        case PanoramaHandler.DirectionFlag_Right: {
                            thumbnailBar.x = (grid.width - (dx  + 2*thumbnailBar.innerMargin)) >> 1
                            thumbnailBar.y = grid.height - (grid.bottomMargin + grid.verticalSpacing + (dy + 2*thumbnailBar.innerMargin))
                            thumbnailBar.visible = true
                            // console.debug("thumbnailBar: {x=" + thumbnailBar.x + ", y=" + thumbnailBar.y + "}")
                            break
                        }
                        case PanoramaHandler.DirectionFlag_Up:
                        case PanoramaHandler.DirectionFlag_Down: {
                            thumbnailBar.x = grid.leftMargin + grid.horizontalSpacing
                            thumbnailBar.y = (grid.height + status.y + status.height - (dy + 2*thumbnailBar.innerMargin)) >> 1
                            thumbnailBar.visible = true
                            // console.debug("thumbnailBar: {x=" + thumbnailBar.x + ", y=" + thumbnailBar.y + "}")
                            break
                        }
                    }
                }
                else
                    thumbnailBar.visible = false
                // console.debug("< PanoramaRecording.onThumbnailSourceChanged()")
            }
            onDirectionFlagsChanged: {
                // console.debug("PanoramaRecording.thumbnailBar.onDirectionFlagsChanged(directionFlags->" + panoramaHandler.directionFlags + ")")
                if (panoramaHandler.directionFlags == PanoramaHandler.DirectionFlag_Decide)
                    thumbnailBar.visible = false
            }
        }
        // onVisibleChanged: console.debug("PanoramaRecording.thumbnailBar.onVisibleChanged(" + visible + ")")
        // onWidthChanged:   console.debug("PanoramaRecording.thumbnailBar.onWidthChanged("   + width   + ")")
        // onHeightChanged:  console.debug("PanoramaRecording.thumbnailBar.onHeightChanged("  + height  + ")")
    }

    // message notification
    BorderImage {
        id:      message
        width:   messageIcon.width + messageText.width + grid.unit*2
        height:  grid.resultTableRowHeight
        y:       grid.topMargin  + grid.verticalSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        border   { left: grid.unit; top: grid.unit; right: grid.unit; bottom: grid.unit }
        source:  "../images/Bg_Notification_Bar_Def.png"
        visible: false

        Connections {
            target: panoramaHandler
            onMessageTextChanged: {
                if (panoramaHandler.messageText != "")
                {
                    messageText.text = panoramaHandler.messageText
                    message.visible = true
                }
            }
        }
        
        // icon
        Image {
            id:                     messageIcon
            source:                 "../images/Ic_GlobalDialogue_Warning_Sel.png"
            anchors.left:           parent.left
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // text
        Text {
            id:                     messageText
            font.family:            fonts.family
            font.pixelSize:         fonts.smallSize
            color:                  colors.textFocused
            anchors.right:          parent.right
            anchors.rightMargin:    2*grid.unit
            anchors.verticalCenter: parent.verticalCenter
            
            // onTextChanged: console.debug("PanoramaRecording.messageText.onTextChanged(" + text + ")")
        }
        // onVisibleChanged: console.debug("PanoramaRecording.message.onVisibleChanged(" + visible + ")")
    }
    
    Keys.onPressed: {
        // console.debug("PanoramaHandler.Keys.onPressed(" + event.key + ")")
        if (visible) {
            if (message.visible) {
                event.accepted = true
                clear()
            }
            if (event.key === keys.back) {
                event.accepted = true
                panoramaHandler.close();
            }
        }
    }
    Keys.onReleased: {
        // console.debug("PanoramaHandler.Keys.onReleased(" + event.key + ")")
        if (visible) {
            if (event.key === keys.back) {
                event.accepted = true
            }
        }
    }
}
