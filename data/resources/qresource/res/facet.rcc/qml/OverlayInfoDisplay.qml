import QtQuick 1.1
import se.flir 1.0
import System 1.0
/**
 * Displays the overlay information
 */

Item
{
    id: overlayRow
    width: grid.width
    height: combinedWidth < allowedWidth ? grid.listItemHeight : 2 * grid.listItemHeight

    property int combinedWidth: datetimeitem.width + otheritems.width
    property int allowedWidth: grid.width
    clip: true

    // Date and Time display on the far right
    RoundedRect {
        id: datetimeitem
        visible: greenbox.system.isOverlayDateTimeEnabled
        height: grid.listItemHeight
        width: visible ? timedatetext.width + 2 * grid.horizontalSpacing : 0
        anchors.right: overlayRow.right
        anchors.top: overlayRow.top
        Text{
            id: timedatetext
            text: greenbox.system.formattedDateTime + qsTrId(greenbox.system.formattedTimePostFix())
            color: colors.textFocused
            font.family: fonts.family
            font.pixelSize: 17
            anchors.verticalCenter: parent.verticalCenter
            x: grid.horizontalSpacing
        }
    }

    // other items shall be displayed in the same rectangle
    RoundedRect {
        id: otheritems
        visible: greenbox.system.overlayDataText !== ""
        height: grid.listItemHeight
        width: childrenRect.width < overlayRow.allowedWidth ? childrenRect.width : overlayRow.allowedWidth
        anchors.right: overlayRow.combinedWidth < overlayRow.allowedWidth ? datetimeitem.left : overlayRow.right
        anchors.rightMargin: overlayRow.combinedWidth < overlayRow.allowedWidth ? grid.horizontalSpacing : 0
        anchors.top: overlayRow.combinedWidth < overlayRow.allowedWidth ? overlayRow.top : datetimeitem.bottom
        Text{
            id: atm
            text: greenbox.system.overlayDataText
            color: colors.textFocused
            font.family: fonts.family
            font.pixelSize: 17
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Tilt properties
    rotation: 0
    transformOrigin: Item.BottomRight
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

    // Tilt states
    states: [
        State {
            name: "0"
            PropertyChanges { target: overlayRow; rotation: 0 }
            PropertyChanges { target: overlayRow; anchors.right: tempScale.left}
            PropertyChanges { target: overlayRow; anchors.rightMargin: 5 * grid.horizontalSpacing}
            PropertyChanges { target: overlayRow; y: grid.height - grid.bottomMargin - grid.verticalSpacing - overlayRow.height }
            PropertyChanges { target: overlayRow; allowedWidth: grid.width - tempScale.width - logo.width - grid.irLeftMargin - 4 * grid.horizontalSpacing }
        },
        State {
            name: "90"
            PropertyChanges { target: overlayRow; rotation: 90 }
            PropertyChanges { target: overlayRow; anchors.right: tempScale.right}
            PropertyChanges { target: overlayRow; anchors.rightMargin: tempScale.height }
            PropertyChanges { target: overlayRow; y: grid.height - grid.bottomMargin - 2 * grid.horizontalSpacing - height - tempScale.width}
            PropertyChanges { target: overlayRow; allowedWidth: grid.height - tempScale.width - logo.width - 4 * grid.horizontalSpacing }
        },
        State {
            name: "180"
            PropertyChanges { target: overlayRow; rotation: 180 }
            PropertyChanges { target: overlayRow; anchors.right: tempScale.right}
            PropertyChanges { target: overlayRow; anchors.rightMargin: -tempScale.width - 5 * grid.horizontalSpacing}
            PropertyChanges { target: overlayRow; y: -height + grid.topMargin + grid.verticalSpacing }
            PropertyChanges { target: overlayRow; allowedWidth: grid.width - tempScale.width - logo.width - grid.irLeftMargin - 4 * grid.horizontalSpacing }
        },
        State {
            name: "270"
            PropertyChanges { target: overlayRow; rotation: 270 }
            PropertyChanges { target: overlayRow; anchors.right: tempScale.right}
            PropertyChanges { target: overlayRow; anchors.rightMargin: -tempScale.height}
            PropertyChanges { target: overlayRow; y: tempScale.width - height + grid.bottomMargin + 2 * grid.horizontalSpacing }
            PropertyChanges { target: overlayRow; allowedWidth: grid.height - tempScale.width - logo.width - 4 * grid.horizontalSpacing }
        }
    ]
}
