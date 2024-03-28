import QtQuick 1.1
import se.flir 1.0
import System 1.0

Item{
    x: 0
    y: 0
    width: grid.width
    height: grid.height

VideoElement{

    objectName: "videoPlaybackElement"
    id:videoPlaybackElement
    x: 0
    y: 0
    width: grid.width
    height: grid.height
    focus: true

    signal hideArchive

    Text{
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "white"
        font.pixelSize: 30
        visible: videoPlaybackElement.framerate !== undefined
        text: "FPS: " + videoPlaybackElement.framerate
     }

    function showActionIndicator(action) {
        if(action === "play")
            actionIndicatorImage.source = "../images/Sc_Status_VideoPlay_Def.png";
        else if(action === "pause")
            actionIndicatorImage.source = "../images/Sc_Status_VideoPause_Def.png";
    }

    Image{
        id: leftBorderOfSorrow
        anchors.top: parent.top
        anchors.left: parent.left
        source: grid.irLeftMargin > 0 ? "../images/Bg_Live_NonWidescreen.png" : ""
    }
    Image{
        id: rightBorderOfSorrow
        anchors.top: parent.top
        anchors.right: parent.right
        source: grid.irRightMargin > 0 ? "../images/Bg_Live_NonWidescreen.png" : ""
    }

//    VideoPlaybackRecallOverlay{
//        visible: videoPlaybackElement.isFullSysimgVideo
//    }

    BorderImage {
        id: backgroundImage

        width: elapsedTimeText.width + actionIndicatorImage.width + 6
        height: grid.resultTableRowHeight + 1 // Needs +1 to entirely hide the recording status bar, not sure why, perhaps an encoding artefact(?)
        y: grid.topMargin + grid.verticalSpacing
        x: (videoPlaybackElement.width - width) / 2
        border { left: grid.unit; top: grid.unit; right: grid.unit; bottom: grid.unit }
        source: "../images/Bg_Notification_Bar_Def.png"

        Image{
            id: actionIndicatorImage
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
            source: "" // Set by showActionIndicator()
        }

        Text{
            id: elapsedTimeText
            anchors.right: parent.right
            anchors.rightMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            font.family: fonts.family
            font.pixelSize: fonts.smallSize
            color: colors.textNormal

            text: videoCurrentTime + " / " + videoTotalTime
        }
    }

    Image{
        id: laserOnInVideoIndicator

        x: videoPlaybackElement.width - width - grid.horizontalSpacing
        y: grid.topMargin + grid.verticalSpacing
        width:  sourceSize.width
        height: sourceSize.height

        objectName: "laserOnInVideoIndicator"
        source: laserActive ? "../images/Sc_Status_Laser.png" : ""
        visible: laserActive//laserActive
        onVisibleChanged: videoPlaybackElement.forceRepaint();
    }

    MouseArea{
        anchors.fill: parent
        onReleased: toggleVideoPlayback()
    }

    Keys.onPressed: {
        if(event.key === keys.select)
        {
            toggleVideoPlayback()
        }
        else if (event.key === keys.camera)
        {
            if (flirSystem.lampActive)
                flirSystem.lampActive = false
            else
                flirSystem.lampActive = true
        }
        event.accepted = true
    }

    Keys.onReleased: {
        if (event.key === keys.back || event.key === keys.onOff) {
            view = ArchiveHandler.ImageSelector
            exitVideoPlayback()
        }
        else if(event.key === keys.archive)
        {
            view = ArchiveHandler.ImageSelector
            exitVideoPlayback()
            hideArchive()
        }
        event.accepted = true
    }
}
}
