import QtQuick 1.0
import se.flir 1.0

Item {
    width: grid.width - grid.irLeftMargin - grid.irRightMargin
    height: grid.height
    x: grid.irLeftMargin
    visible: sketchHandler.showSketch

    Sketching {
        id: sketch
        anchors.fill: parent

        function updateOnAvailable() {
            if (visible && !passive) {
                forceActiveFocus()
                sketch.tool = Sketching.Draw
                sketch.color = "white"
                sketch.isModified = false
                sketch.penSize = grid.sketchPenSize
            }
        }

        onVisibleChanged: {
            updateOnAvailable()
        }
        onPassiveChanged: {
            updateOnAvailable()
        }

        semiTransparentColor: colors.overbright
        passive: greenbox.appState !== GreenBox.FacetSketchView

        // Some of our user-input comes from the menu. So connect to that.
        Connections { target: menus.menuItem("sketch_stamp_larrow")
            onTriggered: sketch.startStamp(Sketching.StampLeftArrow)
        }
        Connections { target: menus.menuItem("sketch_stamp_rarrow")
            onTriggered: sketch.startStamp(Sketching.StampRightArrow)
        }
        Connections { target: menus.menuItem("sketch_stamp_circle")
            onTriggered: sketch.startStamp(Sketching.StampCircle)
        }
        Connections { target: menus.menuItem("sketch_stamp_cross")
            onTriggered: sketch.startStamp(Sketching.StampCross)
        }
        Keys.onPressed: {
            if (sketch.isStamping()) {
                if (event.key === keys.back || event.key === keys.select || event.key === keys.left ||
                    event.key === keys.right || event.key === keys.up || event.key === keys.down) {
                    event.accepted = true
                }
            }
            if (event.key === keys.camera && !event.isAutoRepeat) {
                sketch.sketchMode = Sketching.SketchModeMove;
                event.accepted = true;
                // A little bit of ugliness here - shut off the lamp if it is on (no use)
                if (flirSystem.lampActive)
                    flirSystem.lampActive = false
            }
        }
        Keys.onReleased: {
            if (event.key === keys.camera && !event.isAutoRepeat) {
                sketch.sketchMode = Sketching.SketchModeEdit;
                event.accepted = true;
            }
            else if (sketch.isStamping()) {
                if (event.key === keys.back || event.key === keys.archive) {
                    sketchHandler.cancelStamp();
                    event.accepted = true
                } else if (event.key ===  keys.select) {
                    sketchHandler.commitStamp();
                    event.accepted = true
                } else if (event.key === keys.left || event.key === keys.right ||
                           event.key === keys.up || event.key === keys.down) {
                    sketch.moveStamp(event.key);
                    event.accepted = true
                }
            }
            else
            {
                if (event.key === keys.back || event.key === keys.archive)
                {
                    sketchHandler.requestCancel()
                    event.accepted = true
                }
            }
        }
    }
}
