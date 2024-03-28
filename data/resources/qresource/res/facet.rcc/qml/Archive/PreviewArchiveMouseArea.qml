import QtQuick 1.1

MouseArea {
    id: swipeArea
    width: grid.width
    height: grid.height

    property real startX: 0
    property real startY: 0
    property bool pressed: false
    property bool manualFlick: false

    onPressed: {
        if (pressed && !touchBased) // If touchbased there is no repeats, but instead the sliding will have effect
            return
        startX = mouseX
        startY = mouseY
        pressed = true
    }

    function upDownTrig(deltaX, deltaY, released) {
        if (deltaY > grid.swipeLimit)
            goDown()
        else if (deltaY < -grid.swipeLimit)
            goUp()
        else if (mouseY < height / 10)  // Treat touch in the top area as swiping in a group
            goUp()
        else if (released)
        {
            var coord2 = mapToItem(previewArchiveGroupView,mouseX,mouseY)
            tapAction(coord2)
        }
        else
            return false
        return true
    }

    function reactOnMove(released) {
        var deltaX = mouseX-startX
        var deltaY = mouseY-startY
        var absX = deltaX > 0 ? deltaX : -deltaX
        var absY = deltaY > 0 ? deltaY : -deltaY

        if (touchBased && !manualFlick) {
            // prevent the ListView from stealing some data
            if (absY > absX && absX > 8) // After 9 pixels the ListView steals are events --- HACK!
                setInteractive(false)

            if (!released)
                return
            upDownTrig(deltaX, deltaY, released)
            pressed = false
            return
        }
        if (absX > absY)
        {
            if (deltaX > grid.swipeLimit)
                goLeft()
            else if (deltaX < -grid.swipeLimit)
                goRight()
            else if (released)
            {
                var coord = mapToItem(previewArchiveGroupView,mouseX,mouseY)
                tapAction(coord)
            }
            else
                return
        }
        else
        {
            if (!upDownTrig(deltaX, deltaY, released))
                return
        }
        pressed = false

    }

//    onMouseXChanged: {
    onMousePositionChanged: {
        if (!pressed)
            return
        reactOnMove(false)
    }

    onReleased: {
        if (!pressed)
            return
        reactOnMove(true)

        // enable interaction again! --- HACK!
        if (touchBased && !manualFlick) {
            setInteractive(true)
        }
    }
}
