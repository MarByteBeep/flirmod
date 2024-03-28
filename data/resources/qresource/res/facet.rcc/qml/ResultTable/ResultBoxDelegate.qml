import QtQuick 1.1
import se.flir 1.0

// ResultBoxDelegate
// -------------------
// Delegate for the ResultTable element.
// the result table has measurement items (functions), this delegate will display the details for the box kind.

Item {

    // Property values
    id: resultBoxDelegate
    height: column.height + grid.unit
    onHeightChanged: resultTable.setDelegateHeight(index, height);
    width: root.width

    property int delegatesVisible: resultTable.delegatesVisible
    onDelegatesVisibleChanged: visible = resultTable.itemVisible(index)

    // The background
    BorderImage {
        border { left: 3; top: 3; right: 3; bottom: 3 }
        anchors.fill: parent
        anchors.bottomMargin: grid.unit
        source: (preset === "screening_alarm" && maxTypeAlarmStatus === ResultTableModel.AlarmTriggeredAbove) ? "../../images/Bg_Status_Bar_Alarm.png" : "../../images/Bg_Status_Bar_Def.png"
    }

    Column {
        id: column
        x: grid.horizontalSpacing
        width: parent.width

        ResultTableDelegateIconRow {
            id: row1
            _label: resultTable.totalCount === 1 || preset === "screening_alarm" ? "" : typeCount === 1 ?
                    //: Label for box meter result in measure result table. Keep as short as possible.
                    //% "box"
                    qsTrId("ID_RESULT_BOX") :
                    //: Label for box meter result in measure result table. Keep as short as possible. '%1' is a placeholder for an ID (number).
                    //% "bx%1"
                    qsTrId("ID_RESULT_BOX_INDEX").arg(typeIndex + 1) + translation.update
            _value: (preset === "screening_alarm") ? maxValue : value
            _icon: preset === "screening_alarm" ? ((maxTypeAlarmStatus === ResultTableModel.AlarmTriggeredAbove ||
                                                    maxTypeAlarmStatus === ResultTableModel.AlarmTriggeredAbove) ?
                                                    "../../images/Sc_Screening_PeopleSingle_Sel.png" :
                                                    "../../images/Sc_Screening_PeopleSingle_Def.png") : ""
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 1, column1Width, column2Width, 0, resultBoxDelegate.height);
        }

        ResultTableDelegateAlarmRow {
            id: row2
            //: Abbreviation of 'maximum'
            //% "max"
            _label: preset === "screening_alarm" ? "" : maxValue === "" ? "" : (row1._label === "" ? "" : " ") + qsTrId("ID_RESULT_MAX") + translation.update
            _value: preset === "screening_alarm" ? "" : maxValue
            _alarmStatusEnum: (maxValue === "" || preset === "screening_alarm") ? ResultTableModel.AlarmOff : maxTypeAlarmStatus
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 2, column1Width, column2Width, column3Width, resultBoxDelegate.height);
        }

        ResultTableDelegateAlarmRow {
            id: row3
            //: Abbreviation of 'minimum'
            //% "min"
            _label: minValue === "" ? "" : (row1._label === "" ? "" : " ") + qsTrId("ID_RESULT_MIN") + translation.update
            _value: minValue
            _alarmStatusEnum: minValue === "" ? ResultTableModel.AlarmOff : minTypeAlarmStatus
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 3, column1Width, column2Width, column3Width, resultBoxDelegate.height);
        }

        ResultTableDelegateAlarmRow {
            id: row4
            //: Abbreviation of 'average'
            //% "avg"
            _label: avgValue === "" ? "" : (row1._label === "" ? "" : " ") + qsTrId("ID_RESULT_AVG") + translation.update
            _value: avgValue
            _alarmStatusEnum: avgValue === "" ? ResultTableModel.AlarmOff : avgTypeAlarmStatus
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 4, column1Width, column2Width, column3Width, resultBoxDelegate.height);
        }
    }
}
