import QtQuick 1.1
import se.flir 1.0
import "ResultTable"

Item {
    id: statusRow
    height: results.height
    width: grid.width
    property int rightEdge: statusBar.width > 0 ? statusBar.x + statusBar.width + grid.horizontalSpacing * 2 + 1 : statusBar.x + grid.horizontalSpacing + 1
    transformOrigin: Item.TopLeft
    state: "0"

    // Tilt states
    states: [
        State {
            name: "0"
            when: greenbox.system.tilt === 0
            PropertyChanges { target: statusRow; rotation: 0 }
            PropertyChanges { target: statusRow; x: grid.leftMargin + grid.irLeftMargin + grid.horizontalSpacing }
            PropertyChanges { target: statusRow; y: grid.topMargin + grid.verticalSpacing }
        },
        State {
            name: "90"
            when: greenbox.system.tilt === 90
            PropertyChanges { target: statusRow; rotation: 90 }
            PropertyChanges { target: statusRow; x: grid.width - grid.horizontalSpacing - grid.rightMargin - grid.irRightMargin}
            PropertyChanges { target: statusRow; y: grid.topMargin + grid.verticalSpacing }
        },
        State {
            name: "180"
            when: greenbox.system.tilt === 180
            PropertyChanges { target: statusRow; rotation: 180 }
            PropertyChanges { target: statusRow; x: grid.width - grid.rightMargin - grid.irRightMargin - grid.horizontalSpacing}
            PropertyChanges { target: statusRow; y: grid.height - grid.topMargin - grid.verticalSpacing }
        },
        State {
            name: "270"
            when: greenbox.system.tilt === 270
            PropertyChanges { target: statusRow; rotation: 270 }
            PropertyChanges { target: statusRow; x: grid.leftMargin + grid.irLeftMargin + grid.horizontalSpacing }
            PropertyChanges { target: statusRow; y: grid.height - grid.bottomMargin - grid.verticalSpacing }
        }
    ]


    // Result table
    ResultTable {
        id: results
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

    // Status bar
    StatusBar {
        id: statusBar
        anchors.top: results.top
        anchors.left: unitLabel.visible ? unitLabel.right : statusRow.left
        anchors.leftMargin: grid.horizontalSpacing
    }

    // Screening touch area (for products without P-button)
    ScreeningTouchArea {
        y: results.tableHeight
        anchors.left: results.left
        visible: greenbox.system.showScreeningTouchArea
    }

}
