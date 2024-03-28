import QtQuick 1.1
import se.flir 1.0

// ResultDiffDelegate
// -------------------
// Delegate for the ResultTable element.
// the result table has measurement items (functions), this delegate will display the details for the difference type.

Item {

    // Property values
    id: resultDiffDelegate
    height: column.height + grid.unit
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

    Column {
        id: column
        x: grid.horizontalSpacing
        width: parent.width

        ResultTableDelegateRow {
            id: row1
            _label: preset === "deltaSpot" ?
                        //: Label for a delta function in measure result table. 'D' should be replaced by Greek captital delta. 's' should be the first letter of 'spot'.
                        //% "D s"
                        qsTrId("ID_RESULT_DELTA_SPOT") + translation.update :
                    preset === "deltaTemp" ?
                        //: Label for a delta function in measure result table. 'D' should be replaced by Greek captital delta. 't' should be the first letter of 'temperature'.
                        //% "D t"
                        qsTrId("ID_RESULT_DELTA_TEMP") + translation.update :
                    (diff1 === "" || diff2 === "") ? "" : qsTrId(diff1).arg(diffId1) + "-" + qsTrId(diff2).arg(diffId2)
            _value: preset === "" ? "" : value
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 1, column1Width, column2Width, 0, resultDiffDelegate.height);
        }

        ResultTableDelegateAlarmRow {
            id: row2
            _label: preset === "" ? (typeCount > 1 ? "\u0394 %1".arg(typeIndex + 1) : "\u0394") : ""
            _value: preset === "" ? value : ""
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 2, column1Width, column2Width, column3Width, resultDiffDelegate.height);
            _alarmStatusEnum: valueTypeAlarmStatus
        }
    }
}
