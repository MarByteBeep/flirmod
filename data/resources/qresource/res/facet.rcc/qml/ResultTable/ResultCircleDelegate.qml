import QtQuick 1.1
import se.flir 1.0

// ResultCircleDelegate
// -------------------
// Delegate for the ResultTable element.
// the result table has measurement items (functions), this delegate will display the details for the circle kind.

Item {

    // Property values
    id: resultCircleDelegate
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
            _label: resultTable.totalCount === 1 ? "" : typeCount === 1 ?
                    //: Label for circle meter result in measure result table. Keep as short as possible.
                    //% "circle"
                    qsTrId("ID_RESULT_CIRCLE") :
                    //: Label for circle meter result in measure result table. Keep as short as possible. '%1' is a placeholder for an ID (number).
                    //% "cr%1"
                    qsTrId("ID_RESULT_CIRCLE_INDEX").arg(typeIndex + 1) + translation.update
            _value: value
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 1, column1Width, column2Width, 0, resultCircleDelegate.height);
        }

        ResultTableDelegateAlarmRow {
            id: row2
            //: Abbreviation of 'maximum'
            //% "max"
            _label: maxValue === "" ? "" : (row1._label === "" ? "" : " ") + qsTrId("ID_RESULT_MAX") + translation.update
            _value: maxValue
            _alarmStatusEnum: maxValue === "" ? ResultTableModel.AlarmOff : maxTypeAlarmStatus
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 2, column1Width, column2Width, column3Width, resultCircleDelegate.height);
        }

        ResultTableDelegateAlarmRow {
            id: row3
            //: Abbreviation of 'minimum'
            //% "min"
            _label: minValue === "" ? "" : (row1._label === "" ? "" : " ") + qsTrId("ID_RESULT_MIN") + translation.update
            _value: minValue
            _alarmStatusEnum: minValue === "" ? ResultTableModel.AlarmOff : minTypeAlarmStatus
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 3, column1Width, column2Width, column3Width, resultCircleDelegate.height);
        }

        ResultTableDelegateAlarmRow {
            id: row4
            //: Abbreviation of 'average'
            //% "avg"
            _label: avgValue === "" ? "" : (row1._label === "" ? "" : " ") + qsTrId("ID_RESULT_AVG") + translation.update
            _value: avgValue
            _alarmStatusEnum: avgValue === "" ? ResultTableModel.AlarmOff : avgTypeAlarmStatus
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 4, column1Width, column2Width, column3Width, resultCircleDelegate.height);
        }
    }
}
