import QtQuick 1.1
import se.flir 1.0
import System 1.0

Item{
    id: recallOverlayId
    x: 0
    y: 0
    width: grid.width
    height: grid.height

    // Result table
    ResultTable {
        id: results

        x: grid.leftMargin + grid.irLeftMargin + grid.horizontalSpacing
        y: grid.topMargin + grid.verticalSpacing
    }

    // Temperature unit label
    Item {
        id: unitLabel
        anchors.top: results.top
        x: results.x + results.width + (results.tightTempUnit ? -2 : grid.horizontalSpacing)
        visible: results.visible && resultTable.totalCount > 0 && resultTable.totalCount > resultTable.meterlinkCount
        width: visible ? unitText.width + grid.horizontalSpacing * 2 : 0
        height: grid.resultTableRowHeight

        RoundedRect {
            anchors.fill: parent
        }

        Text {
            id: unitText
            anchors.right: parent.right
            anchors.rightMargin: grid.horizontalSpacing
            font.family: fonts.family
            font.pixelSize: fonts.smallSize
            color: colors.textFocused
            text: qsTrId(resultTable.tempUnit) + translation.update
        }
    }

    MeasureTools {
        width: grid.width - grid.irLeftMargin - grid.irRightMargin
        height: grid.height
        x: grid.irLeftMargin
    }

    PlaybackTempScale{
        id: tempScale
    }
}
