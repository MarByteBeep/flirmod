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
        id: pipMouseArea

        enabled: boxId.mouseEnabled
        anchors.centerIn: parent
        width: grid.grabSize
        height: grid.grabSize

        drag.target: boxId
        drag.minimumX: 0
        drag.minimumY: 0
        drag.maximumX: grid.width - boxId.width - grid.irLeftMargin - grid.irRightMargin - 1
        drag.maximumY: grid.height - boxId.height - 1

        property bool ignoreMouseX: true
        property bool ignoreMouseY: true
        property int grabOffsetX: 0
        property int grabOffsetY: 0

        onMouseXChanged: {
            if (ignoreMouseX === false)  // avoid jerky jump when first grabbing box
            {
                var myMouseX = mouseX - grabOffsetX

                if (index === 0 || index === 1)
                {
                    if (boxId.width - myMouseX > 10)
                    {
                        boxId.x = boxId.x + myMouseX
                        boxId.width = boxId.width - myMouseX
                        if (boxId.x < 0)
                        {
                            boxId.width = boxId.width + boxId.x
                            boxId.x = 0
                        }
                    }
                }
                else if (index === 2 || index === 3)
                {
                    if (boxId.width + myMouseX > 10)
                    {
                        boxId.width = boxId.width + myMouseX
                        if (boxId.width + boxId.x > grid.width - grid.irLeftMargin - grid.irRightMargin)
                            boxId.width = grid.width - grid.irLeftMargin - grid.irRightMargin - boxId.x
                    }
                }

                if (Math.abs(boxId.dragStartWidth - boxId.width) > 5)
                    boxId.moved = true;
            }
            else
            {
                ignoreMouseX = false
                grabOffsetX = mouseX
            }
        }

        onMouseYChanged: {
            if (ignoreMouseY === false) // avoid jerky jump when first grabbing box
            {
                var myMouseY = mouseY - grabOffsetY

                if (index === 0 || index === 2)
                {
                    if (boxId.height - myMouseY > 10)
                    {
                        boxId.y = boxId.y + myMouseY
                        boxId.height = boxId.height - myMouseY
                        if (boxId.y < 0)
                        {
                            boxId.height = boxId.height + boxId.y
                            boxId.y = 0
                        }

                    }
                }
                else if (index === 1 || index === 3)
                {
                    if (boxId.height + myMouseY > 10)
                    {
                        boxId.height = boxId.height + myMouseY

                        if (boxId.height + boxId.y > grid.height)
                            boxId.height = grid.height - boxId.y
                    }
                }

                if (Math.abs(boxId.dragStartHeight - boxId.height) > 5)
                    boxId.moved = true;
            }
            else
            {
                ignoreMouseY = false
                grabOffsetY = mouseY
            }
        }

        onPressAndHold: {
            if (boxId.moved === false)
            {
                drag.target = undefined
            }
        }

        onPressed: {
            if (activeFocus === false && selected === false)
            {
                selected = true
            }
            if (selectionMoveMode)
            {
                if (index !== 4)
                {
                    selectionMoveMode = false
                }
            }
            else if (index === 4)
            {
                selectionMoveMode = true
            }

            boxId.dragStartWidth = boxId.width
            boxId.dragStartHeight = boxId.height

            if (index !== 4)
                drag.target = undefined

            ignoreMouseX = true
            ignoreMouseY = true
        }

        onReleased: {
            boxId.moved = false
            drag.target = boxId

            greenbox.system.setPIPRect(boxId.x, boxId.y, boxId.x + boxId.width, boxId.y + boxId.height)
        }
    }

    Image {
        id: grabImageId
        source: {
            if (selected)
            {
                if (selectionMoveMode)
                {
                    if (index === 4)
                        return "../images/Sc_MeasureToolPlaced_MarkerBox_Def.png"
                    else
                        return "../images/Sc_MeasureToolPlaced_MarkerBoxSemi_Def.png"
                }
                else
                {
                    if (index === 4)
                        return "../images/Sc_MeasureToolPlaced_MarkerBoxSemi_Def.png"
                    else
                        return "../images/Sc_MeasureToolPlaced_MarkerBox_Def.png"
                }
            }
            else
                return ""
        }
    }
}
