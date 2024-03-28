import QtQuick 1.1
import se.flir 1.0

// ResultMeterlinkDelegate
// -------------------
// Delegate for the ResultTable element.
// the result table has measurement items (functions), this delegate will display the details for the meterlink type.

Item {

    // Property values
    id: resultMeterlinkDelegate
    height: row1.height + grid.unit
    onHeightChanged: resultTable.setDelegateHeight(index, height);
    width: root.width

    property int delegatesVisible: resultTable.delegatesVisible
    onDelegatesVisibleChanged: visible = resultTable.itemVisible(index)

    // The background
    BorderImage {
        border { left: 3; top: 3; right: 3; bottom: 3 }
        source: "../../images/Bg_Status_Bar_Def.png"
        anchors.fill: parent
        anchors.bottomMargin: grid.unit
    }

    // Content
    ResultTableDelegateRow {
        id: row1
        x: grid.horizontalSpacing
        _label: meterlinkUnit
        _value: value
        onWidthsChanged: awaitNewIndexTimer.start()

        Timer {
            id: awaitNewIndexTimer
            interval: 500
            onTriggered: resultTable.recalcDelegateWidth(index, 1, row1.column1Width, row1.column2Width, 0, resultMeterlinkDelegate.height);
        }
    }
}
