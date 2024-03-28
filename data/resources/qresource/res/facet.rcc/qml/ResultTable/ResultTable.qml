import QtQuick 1.1
import System 1.0
import se.flir 1.0

// ResultTable
// -----------
// The result table.

Item {
    id: root
    property bool tightTempUnit: resultTableMainColumn.height - 3 <= grid.resultTableRowHeight
    width: resultTable.tableWidth
    visible: cameraHasStaticFocus || greenbox.system.viewMode !== System.VIEW_MODE_VISUAL

    property alias tableHeight: resultTableMainColumn.height

    Component.onCompleted: resultTable.sizeRestrictions(grid.resultTableRowHeight + grid.unit, grid.height, grid.width - grid.irLeftMargin - grid.irRightMargin, grid.horizontalSpacing)

    Column {
        id: resultTableMainColumn
        Repeater {
            id: repeater
            model: resultTable
            Loader {
                id: resultLoader
                onSourceChanged: gc()
                source: type === "spot" ? "ResultSpotDelegate.qml" :
                        type === "box" ? "ResultBoxDelegate.qml" :
                        type === "circle" ? "ResultCircleDelegate.qml" :
                        type === "line" ? "ResultLineDelegate.qml" :
                        type === "refTemp" ? "ResultRefTempDelegate.qml" :
                        type === "diff" ? "ResultDiffDelegate.qml" :
                                          "ResultMeterlinkDelegate.qml"
            }
        }
    }

    BorderImage {
        border { left: 3; top: 3; right: 3; bottom: 3 }
        source: "../../images/Bg_Status_Bar_Def.png"
        id: moreIndicator
        width: visible ? resultTableMainColumn.width : 0        // Needed for some strange reason on device, bug?!
        height: grid.resultTableRowHeight
        y: resultTable.hiddenIndicatorY
        visible: resultTable.numberHiddenResults > 0
        clip: true                                              // Needed for some strange reason on device, bug?!

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            font.family: fonts.latinFamily
            font.pixelSize: fonts.miniSize
            color: colors.textNormal
            text: "... (" + resultTable.numberHiddenResults + ")"
        }
    }
}
