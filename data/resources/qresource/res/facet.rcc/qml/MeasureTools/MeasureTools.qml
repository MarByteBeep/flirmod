import QtQuick 1.1
import se.flir 1.0
//import System 1.0
//import ".."

// MeasureTools
// ------------
// Manages the Spots, boxes etc. graphics on screen

Item {
    // Property values
    id: measureTools
    property bool measureFuncSelected: measureFuncs.hasSelection

    MouseArea {

        enabled: measureFuncSelected
        anchors.fill: parent
        onClicked: {
            menus.closeMenu()
            measureFuncs.unselectAll();
            if (greenbox.appState === GreenBox.FacetPresetsView)
                menus.toggleMenu()
        }
    }

    // Repeater that creates and destroys spots and boxes according to model
    Repeater {
        model: measureFuncs
        Loader {
            source: type === "spot" ? "Spot.qml" : type === "box" ? "Box.qml" : type === "diff" ? "Diff.qml" : type === "line" ? "Line.qml" : type === "circle" ? "Circle.qml" : "Diff.qml"
            onSourceChanged: gc()
        }
    }

    onMeasureFuncSelectedChanged: {
        if (measureFuncs.hasSelection === true && activeFocus === false)
            forceActiveFocus()
        else if (measureFuncs.hasSelection === false)
            menus.closeMenu()
    }

    Connections {
        ignoreUnknownSignals: true
        target: menus.menuItem("measure_unselect_all")
        onTriggered: {
            if (greenbox.appState === GreenBox.FacetPresetsView)
                presetsHandler.measureToolbarDone()
        }
    }

    Connections {
        ignoreUnknownSignals: true
        target: menus.menuItem("measure_remove_selected")
        onTriggered: {
            if (greenbox.appState === GreenBox.FacetPresetsView)
                presetsHandler.measureToolbarDone()
        }
    }

    // Key events
    Keys.onPressed: {
        if (event.key === keys.up) {
            event.accepted = measureFuncs.keyPress(GreenBox.UI_KEY_UP)
        }
        else if (event.key === keys.down) {
            event.accepted = measureFuncs.keyPress(GreenBox.UI_KEY_DOWN)
        }
        else if (event.key === keys.left) {
            event.accepted = measureFuncs.keyPress(GreenBox.UI_KEY_LEFT)
        }
        else if (event.key === keys.right) {
            event.accepted = measureFuncs.keyPress(GreenBox.UI_KEY_RIGHT)
        }
        else if (event.key === keys.back && measureFuncs.hasSelection) {
            event.accepted = true // Don't leak this - we'll catch the release!
        }
    }

    Keys.onReleased: {
        if (event.key === keys.up) {
            event.accepted = measureFuncs.keyRelease(GreenBox.UI_KEY_UP, event.isAutoRepeat)
        }
        else if (event.key === keys.down) {
            event.accepted = measureFuncs.keyRelease(GreenBox.UI_KEY_DOWN, event.isAutoRepeat)
        }
        else if (event.key === keys.left) {
            event.accepted = measureFuncs.keyRelease(GreenBox.UI_KEY_LEFT, event.isAutoRepeat)
        }
        else if (event.key === keys.right) {
            event.accepted = measureFuncs.keyRelease(GreenBox.UI_KEY_RIGHT, event.isAutoRepeat)
        }
        else if (event.key === keys.back && measureFuncs.hasSelection) {
            measureFuncs.unselectAll();
            event.accepted = true

            if (greenbox.appState === GreenBox.FacetPresetsView)
                menus.toggleMenu()
        }
    }
}
