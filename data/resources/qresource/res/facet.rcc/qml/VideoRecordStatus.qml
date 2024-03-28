import QtQuick 1.1
import se.flir 1.0

// SaveStatus
// ----------
// The save status, shown in the bottom left corner while saving.

Item {

    // Property values
    id: videoRecordStatus
    anchors.horizontalCenter: parent.horizontalCenter
    y: grid.topMargin + grid.verticalSpacing


    width: animatedImage.anchors.leftMargin * 3 + animatedImage.width + recStatusText.width
    height: grid.resultTableRowHeight
    visible: pogo ? false :
                 (greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_VIDEO_IDLE         ||
                  greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_VIDEO_PENDINGSTOP  ||
                  greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_VIDEO_RECORDING    ||
                  greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_PROGRAM_IDLE       ||
                  greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_PROGRAM_COUNTDOWN  ||
                  greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_PROGRAM_SAVING)        &&
                 (greenbox.appState === GreenBox.FacetLiveView ||
                  greenbox.appState === GreenBox.FacetMediaControlState)

    // The background
    BorderImage {
        id: backgroundImage
        width: videoRecordStatus.width
        height: grid.resultTableRowHeight
        border { left: grid.unit; top: grid.unit; right: grid.unit; bottom: grid.unit }
        source: "../images/Bg_Notification_Bar_Def.png"
    }


    // The animated image
    Item {
        id: animatedImage
        width: grid.resultTableRowHeight - 4*grid.unit
        height: grid.resultTableRowHeight - 4*grid.unit
        anchors.left: parent.left
        anchors.leftMargin: (parent.height - height ) /2
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.fill: parent
            radius: width
            smooth: true
            visible: (greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_VIDEO_IDLE)
            color: "darkgray"
        }

        Image {
            anchors.centerIn: parent
            width: sourceSize.width
            height: sourceSize.height
            visible: (greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_PROGRAM_IDLE)
            source: "../images/Sc_Status_Timelapse_Def.png"
        }

        Image {
            id: timelapseIndicator
            anchors.centerIn: parent
            width: sourceSize.width
            height: sourceSize.height
            visible: false
            source: "../images/Sc_Status_TimelapseRecording_Def.png"

            Timer {
                interval: 1000
                repeat: true
                running: greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_PROGRAM_COUNTDOWN ||
                         greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_PROGRAM_SAVING
                onRunningChanged: {
                    if(!running)
                        timelapseIndicator.visible = false
                }

                onTriggered: {
                    if(timelapseIndicator.visible)
                        timelapseIndicator.visible = false
                    else
                        timelapseIndicator.visible = true
                }
            }
        }


        Spinner {
            anchors.fill: parent
            width: 10
            height: 10
            visible: (greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_VIDEO_PENDINGSTOP)
        }

        Rectangle {
            id: recIndicator
            visible: false
            anchors.fill: parent
            radius: width / 2
            smooth: true
            color: "#F00000"

            Timer {
                interval: 1000
                repeat: true
                running: greenbox.mediaControl.mediaControlVisual === MediaControl.MEDIA_CONTROL_VISUAL_VIDEO_RECORDING
                onRunningChanged: {
                    if(!running)
                        recIndicator.visible = false
                }

                onTriggered: {
                    if(recIndicator.visible)
                        recIndicator.visible = false
                    else
                        recIndicator.visible = true
                }
            }
        }
    }

    // The text labels
    Text {
        id: recStatusText
        anchors.left: animatedImage.right
        anchors.leftMargin: animatedImage.anchors.leftMargin
        anchors.verticalCenter: parent.verticalCenter
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: colors.textNormal
        text: greenbox.mediaControl.recordingStatusText
    }
}
