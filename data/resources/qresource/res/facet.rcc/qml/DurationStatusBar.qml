import QtQuick 1.1
import se.flir 1.0

// This object/item represents the voice playback/recording (annotation) status
// bar. The status bar consists of two things: An optional recording text label
// and a mandatory time label is the format of MM:SS.
//
// The text labels are managed within a row and should in theory work with
// languages which goes from right to left. Further testing needed.
//
// The visibilty and status of the DurationStatusBar is handled by the
// ArchiveHandler class.
Rectangle {
    id: durationStatusBar

    property string durationTime
    property string totalTime

    // See the import for information about ArchiveHandler. Also, see the class
    // ArchiveHandler for the enumerations.
    visible: archiveHandler.audioStatus !== ArchiveHandler.Idle
    onVisibleChanged: {
        durationTime = "00:00"
        totalTime = "00:00"
    }

    // The size of the durationStatusBar (and its border) should be bigger than
    // the two text fields within the row.
    width: statusBarRow.width + grid.horizontalSpacing * 4
    height: statusBarRow.height

    y: grid.topMargin + grid.verticalSpacing
    anchors.horizontalCenter: parent.horizontalCenter

    // Make the rectangle transparant so our border doesn't have a white back-
    // ground.
    color: "transparent"

    Timer {
        id: tickTimer
        interval: 1000
        running: archiveHandler.audioStatus === ArchiveHandler.Recording
              || archiveHandler.audioStatus === ArchiveHandler.Playback
        repeat: true

        onTriggered: {
            durationStatusBar.durationTime = archiveHandler.audioCurrentTime
            durationStatusBar.totalTime = archiveHandler.audioTotalTime
        }
    }

    RoundedRect {
        visible: archiveHandler.audioStatus === ArchiveHandler.PreparingRecord
              || archiveHandler.audioStatus === ArchiveHandler.PreparingPlayback

        anchors.right: durationStatusBar.left
        anchors.rightMargin: grid.verticalSpacing
        anchors.top: durationStatusBar.top
        height: durationStatusBar.height
        width: height

        Spinner {
            anchors.centerIn: parent
            width: parent.width - grid.horizontalSpacing*2
            height: width
        }
    }

    // The background image, which is used for filling up all the space required
    // by durationStatusBar.
    RoundedRect {
        anchors.fill: durationStatusBar
    }

    // The text labels reside within the row. The text labels are separated with
    // a spacing, and centered in durationStatusBar.
    Row {
        id: statusBarRow
        spacing: grid.horizontalSpacing

        height: grid.resultTableRowHeight
        anchors.centerIn: durationStatusBar

        Text {
            id: recordingLabel

            visible: archiveHandler.audioStatus === ArchiveHandler.Recording
                  || archiveHandler.audioStatus === ArchiveHandler.PreparingRecord

            anchors.verticalCenter: statusBarRow.verticalCenter

            font.family: fonts.family
            font.pixelSize: fonts.smallSize
            color: colors.textFocused
            text: visible ? qsTrId("ID_RECORDING") + translation.update : ""
        }

        Item {
            height: 1
            width: grid.horizontalSpacing * 2
            visible: recordingLabel.visible
        }

        Text {
            id: durationLabel

            visible: durationStatusBar.visible

            anchors.verticalCenter: statusBarRow.verticalCenter

            font.family: fonts.latinFamily
            font.pixelSize: fonts.smallSize
            color: colors.textFocused
            text: durationStatusBar.durationTime
        }

        Text {
            font.family: fonts.latinFamily
            font.pixelSize: fonts.smallSize
            color: colors.textFocused

            anchors.verticalCenter: parent.verticalCenter
            text: "/"
            visible: archiveHandler.audioStatus === ArchiveHandler.Playback
        }

        Text {
            font.family: fonts.latinFamily
            font.pixelSize: fonts.smallSize
            color: colors.textFocused

            anchors.verticalCenter: parent.verticalCenter
            text: durationStatusBar.totalTime
            visible: archiveHandler.audioStatus === ArchiveHandler.Playback
        }
    }
}
