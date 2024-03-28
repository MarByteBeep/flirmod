import QtQuick 1.1
import se.flir 1.0

// ResultRefTempDelegate
// -------------------
// Delegate for the ResultTable element.
// the result table has measurement items (functions), this delegate will display the details for the ref temp type.

Item {

    // Property values
    id: resultRefTempDelegate
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

        ResultTableDelegateIconRow {
            id: row1
            //: Label for a reference temperature in measure result table. Keep as short as possible.
            //% "temp"
            _label: preset === "screening_alarm" ? "" : qsTrId("ID_RESULT_REF_TEMP") + translation.update
            _value: value
            _icon: preset === "screening_alarm" ? "../../images/Sc_Screening_SampleMean_Def.png" : ""
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 1, column1Width, column2Width, 0, resultRefTempDelegate.height);
        }

        ResultTableDelegateIconRow {
            id: row2
            _value: preset === "screening_alarm" ? refTempOffset : ""
            _icon: preset === "screening_alarm" ? "../../images/Sc_Screening_AlarmLimit_Def.png" : ""
            onWidthsChanged: resultTable.recalcDelegateWidth(index, 2, column1Width, column2Width, 0, resultRefTempDelegate.height);
        }
    }
}
