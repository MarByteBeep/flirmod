import QtQuick 1.1
import se.flir 1.0

// Circle
// ---
// The graphical representation of a circle measure tool

Item {
    // Properties
    id: circleId
    x: measureFunctionModel.toolScreenX
    y: measureFunctionModel.toolScreenY
    width: measureFunctionModel.toolScreenWidth
    height: measureFunctionModel.toolScreenHeight

    Item {
        id: idCircleElement
        anchors.fill: circleId
        CircleTool {
            anchors.fill: idCircleElement
            toolSelected: measureFunctionModel.selected
        }
    }

    // Grab boxes
    Repeater {
        model: 3
        delegate: CircleToolGrabBoxDelegate {}
    }

    // Cold spot
    Item {          // For performance reasons it seems better to put CrossHair inside an Item.
        id: coldSpotCrossHair

        x: minX - measureFunctionModel.toolScreenX - width / 2
        y: minY - measureFunctionModel.toolScreenY - height / 2
        visible: minActive  && x >= -width/2 && x < circleId.width-width/2 && y >= -height/2 && y < circleId.height-height/2

        width: grid.spotSize * greenbox.system.zoom
        height: width

        CrossHair { // C++
            crossHairType: CrossHair.CROSSHAIR_COLD
            width: coldSpotCrossHair.width
            height: coldSpotCrossHair.height
        }
    }

    // Hot spot
    Item {          // For performance reasons it seems better to put CrossHair inside an Item.
        id: hotSpotCrossHair

        x: maxX - measureFunctionModel.toolScreenX - width / 2
        y: maxY - measureFunctionModel.toolScreenY - height / 2
        visible: maxActive && x >= -width/2 && x < circleId.width-width/2 && y >= -height/2 && y < circleId.height-height/2

        width: grid.spotSize * greenbox.system.zoom
        height: width

        CrossHair { // C++
            crossHairType: CrossHair.CROSSHAIR_HOT
            width: hotSpotCrossHair.width
            height: hotSpotCrossHair.height
        }
    }

    // The ID & local params indicator
    RoundedMRect {
        id: idRect
        anchors.right: circleId.right
        anchors.top: circleId.top
        width: idLabel.width + grid.horizontalSpacing
        height: idLabel.height
        visible: measureFuncs.circleCount > 1 || localParams ? true : false

        Text {
            id: idLabel
            anchors.centerIn: parent
            text: (measureFuncs.circleCount > 1 ? (resIndex + 1) + (localParams ? " " : "") : "") +
                  //: One letter abbreviation of 'parameters'. It is used as a flag indicating that a measurement tool has parameter settings that differs from default.
                  //% "P"
                  (localParams ? qsTrId("ID_MEASURE_LOCAL_PARAMS_P") + translation.update : "")
            font.family: fonts.family
            font.pixelSize: fonts.miniSize
            color: colors.textNormal
        }
    }
}
