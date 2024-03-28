import QtQuick 1.1
import se.flir 1.0

Item {
    width: grabImageId.width
    height: grabImageId.height

    // circle index positions:
    //
    //   (1)
    //     \
    //      \
    //      (0)
    //        \
    //         \
    //         (2)
    //

    x: index === 1 ? parent.width * 0.1464  - width/2: index === 0 ? (parent.width - width) / 2 : parent.width*0.8536 - width/2
    y: index === 1 ? parent.height * 0.1464 - height/2 : index === 0 ? (parent.height - height) / 2 : parent.height*0.8536 - height/2

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
            if (!measureFunctionModel.selected)
                return ""

            if (measureFunctionModel.moveMode)
            {
                if (index === 0)
                    return "../../images/Sc_MeasureToolPlaced_MarkerBox_Def.png"
                else
                    return "../../images/Sc_MeasureToolPlaced_MarkerCircleSemi_Def.png"
            }
            else
            {
                if (index === 0)
                    return "../../images/Sc_MeasureToolPlaced_MarkerBoxSemi_Def.png"
                else
                    return "../../images/Sc_MeasureToolPlaced_MarkerCircle_Def.png"
            }

        }
    }
}
