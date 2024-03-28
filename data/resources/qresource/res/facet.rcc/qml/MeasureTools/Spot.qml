import QtQuick 1.1
import se.flir 1.0
//import ".."

// Spot
// ----
// The graphical representation of a spot meter. It uses the c++ class crossHair to draw the actual spot.

Item {

    id: spotId
    width: crossHair.width
    height: crossHair.height
    x: measureFunctionModel.toolScreenX - width / 2
    y: measureFunctionModel.toolScreenY - height / 2

    // Selection marker
    Image {
        id: spotSelectionMarker
        anchors.centerIn: parent
        visible: measureFunctionModel.selected
        source: "../../images/Sc_MeasureToolPlaced_MarkerSpotSemi_Def.png"
    }

    // The spot itself
    Item {      // This item wrapping CrossHair is needed to translate coordinates due to CrossHair being in c++. Do not know why.
        id: crossHair
        width: grid.spotSize * greenbox.system.zoom
        height: width

        CrossHair{
            width: crossHair.width
            height: crossHair.height
        }
    }

    // The ID & local params indicator
    RoundedMRect {
        id: idRect
        anchors.horizontalCenter: crossHair.right
        anchors.top: crossHair.top
        width: idLabel.width + grid.horizontalSpacing
        height: idLabel.height
        visible: measureFuncs.spotCount > 1 || localParams ? true : false

        Text {
            id: idLabel
            anchors.centerIn: parent
            text: (measureFuncs.spotCount > 1 ? (resIndex + 1) + (localParams ? " " : "") : "") +
                  //: One letter abbreviation of 'parameters'. It is used as a flag indicating that a measurement tool has parameter settings that differs from default.
                  //% "P"
                  (localParams ? qsTrId("ID_MEASURE_LOCAL_PARAMS_P") + translation.update : "")
            font.family: fonts.family
            font.pixelSize: fonts.miniSize
            color: colors.textNormal
        }
    }

    // Touch handling
    MouseArea {
        anchors.fill: crossHair
        anchors.margins: -10
        visible: measureFunctionModel.selectable

        onPositionChanged: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mousePositionChanged(0, cursor.x, cursor.y, mouse.wasHeld)
        }

        onPressAndHold: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mousePressed(0, cursor.x, cursor.y, mouse.wasHeld)
        }

        onPressed: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mousePressed(0, cursor.x, cursor.y, mouse.wasHeld)
        }

        onReleased: {
            var cursor = mapToItem(measureTools, mouse.x, mouse.y)
            mouse.accepted = measureFunctionModel.mouseReleased(0, cursor.x, cursor.y, mouse.wasHeld)
        }

        onCanceled: {
            measureFunctionModel.mouseCanceled(0)
        }
    }
}
