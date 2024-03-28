import QtQuick 1.1
import se.flir 1.0

// ResultTableDelegateRow
// -------------------
// Helper item for a single row in ResultTableDelagate


Item {
    id: resultTableDelegateRow

    property alias _label: labelId.text
    property alias _value: valueId.text
    property alias column1Width: labelId.width
    property alias column2Width: valueId.width

    signal widthsChanged

    width: parent.width - grid.horizontalSpacing
    height: (labelId.text !== "" || valueId.text !== "") ? grid.resultTableRowHeight : 0

    Text {
        id: labelId
        anchors.left: parent.left
        y: (valueId.text === "" ? (parent.height - height) / 2 : valueId.y + valueId.height - height - (valueId.font.bold ? grid.resultTableAlignBold : 0)) - grid.resultTableAlign
        font.family: fonts.family
        font.pixelSize: fonts.miniSize
        color: colors.textNormal
        onImplicitWidthChanged: parent.widthsChanged()
    }

    Text {
        id: valueId
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 2 + resultTable.alarmColumnWidth
        font.family: fonts.latinFamily
        font.pixelSize: resultTable.totalCount > 1 ? fonts.mediumSize : fonts.largeSize
        font.bold: (resultTable.totalCount === 1)
        color: colors.textFocused
        onImplicitWidthChanged: parent.widthsChanged()
    }
}
