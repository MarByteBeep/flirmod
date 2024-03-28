import QtQuick 1.1
import se.flir 1.0

// ResultTableDelegateAlarmRow
// -------------------
// Helper item for a single row in ResultTableDelagate with alarm support


Item {
    id: resultTableDelegateAlarmRow

    property alias _label: labelId.text
    property alias _value: valueId.text
    property alias column1Width: labelId.width
    property alias column2Width: valueId.width
    property alias column3Width: alarmId.width

    property variant _alarmStatusEnum : ResultTableModel.AlarmOff
    property bool alarmTimerToggle : true

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
        color: _alarmStatusEnum === ResultTableModel.AlarmTriggeredAbove ? colors.alarmRed :
               _alarmStatusEnum === ResultTableModel.AlarmTriggeredBelow ? colors.alarmBlue :
               colors.textFocused
        onImplicitWidthChanged: parent.widthsChanged()
    }

    Image{
        id: alarmId
        anchors.right: parent.right
        anchors.rightMargin: 2
        source: _alarmStatusEnum === ResultTableModel.AlarmTriggeredAbove ? "../../images/Sc_Status_AlarmAbove_Def.png" :
                _alarmStatusEnum === ResultTableModel.AlarmTriggeredBelow ? "../../images/Sc_Status_AlarmBelow_Def.png" :
                                                                            "../../images/Sc_Status_Alarm_Def.png"
        visible: _alarmStatusEnum !== ResultTableModel.AlarmOff && (alarmTimerToggle || pogo)
        width: _alarmStatusEnum !== ResultTableModel.AlarmOff ? sourceSize.width : 0
        onWidthChanged: parent.widthsChanged()

        Timer {
            interval: 500
            repeat: true
            running: (_alarmStatusEnum === ResultTableModel.AlarmTriggeredBelow || _alarmStatusEnum === ResultTableModel.AlarmTriggeredAbove)
            onRunningChanged: alarmTimerToggle = true
            onTriggered: alarmTimerToggle = (alarmTimerToggle) ? false : true
        }
    }
}
