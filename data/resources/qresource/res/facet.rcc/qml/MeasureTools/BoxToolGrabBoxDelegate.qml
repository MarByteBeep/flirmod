import QtQuick 1.1
import se.flir 1.0

Item {
    width: grabImageId.width
    height: grabImageId.height

    // box index positions:
    //
    //  (0)----------(2)
    //   |            |
    //   |     (4)    |
    //   |            |
    //  (1)----------(3)
    //
    x: index === 0 || index === 1 ? 1 : index === 4 ? (parent.width - width) / 2 : parent.width - width
    y: index === 0 || index === 2 ? 1 : index === 4 ? (parent.height - height) / 2 : parent.height - height

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
        source: {
            if (measureFunctionModel.selected)
            {
                if (measureFunctionModel.moveMode)
                {
                    if (index === 4)
                        return "../../images/Sc_MeasureToolPlaced_MarkerBox_Def.png"
                    else
                        return "../../images/Sc_MeasureToolPlaced_MarkerBoxSemi_Def.png"
                }
                else
                {
                    if (index === 4)
                        return "../../images/Sc_MeasureToolPlaced_MarkerBoxSemi_Def.png"
                    else
                        return "../../images/Sc_MeasureToolPlaced_MarkerBox_Def.png"
                }
            }
            else
            {
                if (index === 0)
                    return "../../images/Sc_MeasureToolPlaced_BoxTopLeft_Def.png"
                else if (index === 1)
                    return "../../images/Sc_MeasureToolPlaced_BoxBottomLeft_Def.png"
                else if (index === 2)
                    return "../../images/Sc_MeasureToolPlaced_BoxTopRight_Def.png"
                else if (index === 3)
                    return "../../images/Sc_MeasureToolPlaced_BoxBottomRight_Def.png"
                else if (index === 4)
                    return ""
            }
        }
    }
}
