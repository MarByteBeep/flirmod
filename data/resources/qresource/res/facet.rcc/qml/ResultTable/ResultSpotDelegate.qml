import QtQuick 1.1
import se.flir 1.0

// ResultSpotDelegate
// -------------------
// Delegate for the ResultTable element.
// the result table has measurement items (functions), this delegate will display the details for the spot type.

Item {

    // Property values
    id: resultSpotDelegate
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
    ResultTableDelegateAlarmRow {
        id: row1
        x: grid.horizontalSpacing
        _label: typeCount > 1 ?
                //: Label for spot meter result in measure result table. Keep as short as possible. '%1' is a placeholder for an ID (number).
                //% "sp%1"
                qsTrId("ID_RESULT_SPOT_INDEX").arg(typeIndex + 1) + translation.update :
            resultTable.totalCount > 1 ?
                //: Label for spot meter result in measure result table. Keep as short as possible.
                //% "spot"
                qsTrId("ID_RESULT_SPOT") + translation.update : ""
        _value: value
        _alarmStatusEnum: valueTypeAlarmStatus
        onWidthsChanged: resultTable.recalcDelegateWidth(index, 1, column1Width, column2Width, column3Width, resultSpotDelegate.height);
    }
}
