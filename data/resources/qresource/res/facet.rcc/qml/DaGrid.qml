import QtQuick 1.1

/**
 * This is a debugging class to show the grid as defined by UX and implemented in the design xml
 */

Column {
    spacing: grid.verticalSpacing
    y: grid.topBorder
    Repeater {
        model: grid.verticalCellCount

        Row {
            height: grid.cellHeight
            width: grid.width
            x: grid.rightBorder
            spacing: grid.horizontalSpacing
            Repeater {
                model: grid.horizontalCellCount
                Rectangle {
                    color: "#55FFD769"
                    width: grid.cellWidth
                    height: grid.cellHeight
                }
            }
        }
    }
}
