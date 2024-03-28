import QtQuick 1.1
import se.flir 1.0

// Line
// ---
// The graphical representation of a line measure tool

Item {
    // Properties
    id: lineId
    x: measureFunctionModel.toolScreenX
    y: measureFunctionModel.toolScreenY
    width: measureFunctionModel.toolScreenWidth
    height: measureFunctionModel.toolScreenHeight
    property bool vertical: measureFuncs.lineProfile.vertical

    LineTool{
        id: idLineElement
        anchors.fill: lineId
        toolSelected: measureFunctionModel.selected
        grabBoxWidth: lineGrabBoxRepeater.children[1].width
    }


    // Grab boxes
    Item{
        id: lineGrabBoxRepeater
        anchors.fill: parent
        Repeater {
            model: 3
            delegate: LineToolGrabBoxDelegate {}
        }
    }

    // Cold spot
    Item {          // For performance reasons it seems better to put CrossHair inside an Item.
        id: coldSpotCrossHair

        x: minX - measureFunctionModel.toolScreenX - width / 2
        y: minY - measureFunctionModel.toolScreenY - height / 2
        visible: minActive && x >= -width/2-1 && x < lineId.width-width/2+1 && y >= -height/2-1 && y < lineId.height-height/2+1

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
        visible: maxActive && x >= -width/2-1 && x < lineId.width-width/2+1 && y >= -height/2-1 && y < lineId.height-height/2+1

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
        anchors.centerIn: lineId
        width: idLabel.width + grid.horizontalSpacing
        height: idLabel.height
        visible: measureFuncs.lineCount > 1 || localParams ? true : false

        Text {
            id: idLabel
            anchors.centerIn: parent
            text: (measureFuncs.lineCount > 1 ? (resIndex + 1) + (localParams ? " " : "") : "") +
                  //: One letter abbreviation of 'parameters'. It is used as a flag indicating that a measurement tool has parameter settings that differs from default.
                  //% "P"
                  (localParams ? qsTrId("ID_MEASURE_LOCAL_PARAMS_P") + translation.update : "")
            font.family: fonts.family
            font.pixelSize: fonts.miniSize
            color: colors.textNormal
        }
    }
}
