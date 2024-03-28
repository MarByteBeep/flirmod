import QtQuick 1.1
import se.flir 1.0

Item {
    width: index !== 0 || lineId.vertical ? grabImageId.width : lineId.width
    height: index !== 0 || !lineId.vertical ? grabImageId.height : lineId.height

    // box index positions: (the center box is first to make its (large) mouse area underneath the boundary boxes)
    //
    //  (1)----(0)-----(2)
    //
    x: lineId.vertical ? - width/2 : index === 1 ? 0 : index === 0 ? (parent.width - width) / 2 : parent.width - width
    y: !lineId.vertical ? - height/2 : index === 1 ? 0 : index === 0 ? (parent.height - height) / 2 : parent.height - height

    MouseArea {
        anchors.fill: parent
        anchors.margins: -(grid.spotSize/2)
        visible: measureFunctionModel.selectable

        onPositionChanged: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mousePositionChanged(index, cursor.x, cursor.y, mouse.wasHeld)
        }

        onPressAndHold: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mousePressed(index, cursor.x, cursor.y, mouse.wasHeld)
        }

        onPressed: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mousePressed(index, cursor.x, cursor.y, mouse.wasHeld)
        }

        onReleased: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mouseReleased(index, cursor.x, cursor.y, mouse.wasHeld)
        }

        onCanceled: {
            measureFunctionModel.mouseCanceled(index)
        }
    }

    Image {
        id: grabImageId
        anchors.centerIn: parent
        source: {
            if (!measureFunctionModel.selected)
                return ""

            if (measureFunctionModel.moveMode)
            {
                if (index === 0)
                    return "../../images/Sc_MeasureToolPlaced_MarkerBox_Def.png"
                else
                    return "../../images/Sc_MeasureToolPlaced_MarkerBoxSemi_Def.png"
            }
            else
            {
                if (index === 0)
                    return "../../images/Sc_MeasureToolPlaced_MarkerBoxSemi_Def.png"
                else
                    return "../../images/Sc_MeasureToolPlaced_MarkerBox_Def.png"
            }

        }
    }
}
