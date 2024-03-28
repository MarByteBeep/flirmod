import QtQuick 1.1
import se.flir 1.0
import System 1.0

// Pip
// ---
/// The box for interacting with PIP. It is invisible when not selected.

Item {
    id: pipArea

    // These need to be on root level to be reachable by delegate!
    property bool selected: false
    property bool selectionMoveMode: true
    property bool mfuncSelected: measureFuncs.hasSelection
    onMfuncSelectedChanged: {
        if (mfuncSelected)
            selected = false
    }

    onSelectedChanged: {
        if (selected)
        {
            menus.closeMenu()
            measureFuncs.unselectAll()
        }
    }

    Rectangle {

        // Properties
        id: boxId
        x: greenbox.system.pipX1
        y: greenbox.system.pipY1
        width: greenbox.system.pipX2 - greenbox.system.pipX1 + 3
        height: greenbox.system.pipY2 - greenbox.system.pipY1 + 3
        color: Qt.rgba(0, 0, 0, 0)
        visible: greenbox.system.viewMode === System.VIEW_MODE_PIP &&
                 greenbox.system.pipLocked === false ? true : false

        property bool moved: false
        property int dragStartWidth: 0
        property int dragStartHeight: 0
        property bool mouseEnabled: greenbox.system.viewMode === System.VIEW_MODE_PIP //&&
        //                            greenbox.system.pipLocked === false ? true : false

        // Needed as binding will break when dragging/resizing
        property int myX: greenbox.system.pipX1
        property int myY: greenbox.system.pipY1
        property int myWidth: greenbox.system.pipX2 - greenbox.system.pipX1 + 3
        property int myHeight: greenbox.system.pipY2 - greenbox.system.pipY1 + 3
        onMyXChanged: x = myX
        onMyYChanged: y = myY
        onMyWidthChanged: width = myWidth
        onMyHeightChanged: height = myHeight

        // PIP box
        Rectangle {
            id: selectedBoxId
            visible: selected
            anchors.fill: boxId
            border.color: "white"
            border.width: 1
            color: Qt.rgba(0, 0, 0, 0)
        }

        // Grab boxes
        Repeater {
            model: 5
            delegate: PipToolGrabBoxDelegate {
            }
        }
    }
}
