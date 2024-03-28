import QtQuick 1.1
import se.flir 1.0

// SavePreview
// ----------
// The save preview, shown at the bottom of the screen while saving

Item {

    // Property values
    property bool isVisible: false
    property int  thumbnailFrameWidth: 1

    id: savePreviewHolder
    x: ( grid.width - width ) / 2
    y: grid.height -
       (grid.savePreviewHeight + grid.bottomMargin + grid.verticalSpacing)
    width: grid.horizontalSpacing * 2 +
           (irThumb.visible ? irThumb.width + grid.horizontalSpacing * 2 + 1 : 0) +
           (dcThumb.visible ? dcThumb.width + grid.horizontalSpacing * 2 + 1 : 0) +
           (videoThumb.visible ? videoThumb.width + grid.horizontalSpacing * 2 +1 : 0);

    height: 2*grid.savePreviewHeight + grid.bottomMargin + grid.verticalSpacing
    visible: isVisible && !pogo
    
    rotation: 0
    transformOrigin: Item.BottomLeft

    onVisibleChanged: {
        greenbox.mediaControl.savePreviewVisibilityChanged(visible)
    }

    // Timer that makes sure save status is shown at least a minimum amount of time
    Timer {
        id: timer
        interval: timing.savePreviewShowTime
        onTriggered: {
            hideAnimation.start()
        }
    }

    NumberAnimation {
        id: showAnimation
        target: savePreview; property: "y"; to: 0;
        duration: 200; easing.type: Easing.InOutQuad
    }

    SequentialAnimation {
        id: hideAnimation
        NumberAnimation {
            id: hideAnimationLower
            target: savePreview; property: "y"; to: grid.savePreviewHeight + grid.bottomMargin + grid.verticalSpacing;
            duration: 200; easing.type: Easing.InOutQuad
        }
        ScriptAction { script: { isVisible = false } }
    }

    function show() {
        isVisible = true
        showAnimation.start()
        timer.start()
    }

    function hide() {
        if (isVisible) {
            isVisible = false
            timer.stop()
            hideAnimation.start()
        }
    }

    // This is the moving part
    Item {
        id: savePreview
        anchors.horizontalCenter: parent.horizontalCenter
        y: grid.savePreviewHeight + grid.bottomMargin + grid.verticalSpacing
        width: parent.width
        height: grid.savePreviewHeight

        // The background
        RoundedRect {
            id: backgroundImage
            width: savePreview.width
            height: grid.savePreviewHeight

            Rectangle {
                id: irThumb
                // these should be even numbers for the centering to work properly
                width:  grid.savePreviewThumbWidth  + 2*thumbnailFrameWidth
                height: grid.savePreviewThumbHeight + 2*thumbnailFrameWidth
                anchors.left: backgroundImage.left
                anchors.leftMargin: grid.horizontalSpacing * 2
                anchors.topMargin:  grid.verticalSpacing
                y: grid.verticalSpacing * 2
                color: colors.background
                visible: greenbox.mediaControl.hasIR

                Rectangle {
                    id: irThumbFrame
                    x: 0
                    y: 0
                    width:  parent.width  - thumbnailFrameWidth
                    height: parent.height - thumbnailFrameWidth
                    color: "transparent"
                    border.color: colors.mediumGrey
                    border.width: thumbnailFrameWidth
                }

                Image {
                    id: irThumbImage
                    width:  grid.savePreviewThumbWidth
                    height: grid.savePreviewThumbHeight
                    anchors.centerIn: parent
                    source:   (isVisible && greenbox.mediaControl.hasIR) ? "image://thumbImageProvider/IR_" + greenbox.mediaControl.thumbCounter : ""
                    fillMode: Image.PreserveAspectFit
                }
            }

            Rectangle {
                id: dcThumb
                width:  grid.savePreviewThumbWidth  + 2*thumbnailFrameWidth
                height: grid.savePreviewThumbHeight + 2*thumbnailFrameWidth
                anchors.right: backgroundImage.right
                anchors.rightMargin: grid.horizontalSpacing * 2 + 1
                y: grid.verticalSpacing * 2
                anchors.topMargin: grid.verticalSpacing
                color: colors.background
                visible: greenbox.mediaControl.hasDC

                Rectangle {
                    id: dcThumbFrame
                    x: 0
                    y: 0
                    width:  parent.width  - thumbnailFrameWidth
                    height: parent.height - thumbnailFrameWidth
                    color: "transparent"
                    border.color: colors.mediumGrey
                    border.width: thumbnailFrameWidth
                }

                Image {
                    id: dcThumbImage
                    width:  grid.savePreviewThumbWidth
                    height: grid.savePreviewThumbHeight
                    anchors.centerIn: parent
                    source: (isVisible && greenbox.mediaControl.hasDC) ? "image://thumbImageProvider/DC_" + greenbox.mediaControl.thumbCounter : ""
                    fillMode: Image.PreserveAspectFit
                }
            }

            Rectangle {
                id: videoThumb
                width:  grid.savePreviewThumbWidth  + 2*thumbnailFrameWidth
                height: grid.savePreviewThumbHeight + 2*thumbnailFrameWidth
                anchors.right: backgroundImage.right
                anchors.rightMargin: grid.horizontalSpacing * 2 + 1
                y: grid.verticalSpacing * 2
                anchors.topMargin: grid.verticalSpacing
                color: colors.background
                visible: greenbox.mediaControl.hasVideo

                Rectangle {
                    id: videoThumbFrame
                    x: 0
                    y: 0
                    width:  parent.width  - thumbnailFrameWidth
                    height: parent.height - thumbnailFrameWidth
                    color: "transparent"
                    border.color: colors.mediumGrey
                    border.width: thumbnailFrameWidth
                }

                Image {
                    id: videoThumbImage
                    width:  grid.savePreviewThumbWidth
                    height: grid.savePreviewThumbHeight
                    anchors.centerIn: parent
                    source: (isVisible && greenbox.mediaControl.hasVideo) ? "image://thumbImageProvider/VI_" + greenbox.mediaControl.thumbCounter : ""
                    fillMode: Image.PreserveAspectFit

                    Image{
                        id: videoIndicationOverlay
                        anchors.centerIn: parent
                        source: (greenbox.mediaControl.hasVideo) ? "../images/Sc_Video_Directplay_Def.png" : ""
                        width: grid.savePreviewThumbWidth / 3
                        height: grid.savePreviewThumbWidth / 3
                        smooth: true
                    }
                }
            }

            // The text labels
            Text {
                id: savingName
                anchors.horizontalCenter: backgroundImage.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: grid.verticalSpacing
                font.family: fonts.family
                font.pixelSize: fonts.smallSize
                color: colors.textFocused
                text: greenbox.mediaControl.saveFileNameShort
            }
        }
    }

    state: {
        if (greenbox.system.tilt === 0)
            return "0"
        else if (greenbox.system.tilt === 90)
            return "90"
        else if (greenbox.system.tilt === 180)
            return "180"
        else
            return "270"
    }

    // tilt states
    states: [
        State {
            name: "0"
            PropertyChanges { target: savePreviewHolder; x: ( grid.width - width ) / 2 }
            PropertyChanges { target: savePreviewHolder; y: grid.height -
                                                            (height - grid.savePreviewHeight) }
            PropertyChanges { target: savePreviewHolder; rotation: 0 }
        },
        State {
            name: "90"
            PropertyChanges { target: savePreviewHolder;
                x: grid.irLeftMargin - grid.savePreviewHeight }
            PropertyChanges { target: savePreviewHolder; y: ( -grid.height ) / 2 }
            PropertyChanges { target: savePreviewHolder; rotation: 90 }
        },
        State {
            name: "180"
            PropertyChanges { target: savePreviewHolder; x: ( grid.width + width ) / 2 }
            PropertyChanges { target: savePreviewHolder; y:  - grid.savePreviewHeight - height}
            PropertyChanges { target: savePreviewHolder; rotation: 180 }
        },
        State {
            name: "270"
            PropertyChanges { target: savePreviewHolder; rotation: 270 }
            PropertyChanges { target: savePreviewHolder; x: grid.width + (grid.irRightMargin + grid.savePreviewHeight)}
            PropertyChanges { target: savePreviewHolder; y: (grid.height - height)/2}
        }
    ]

}
