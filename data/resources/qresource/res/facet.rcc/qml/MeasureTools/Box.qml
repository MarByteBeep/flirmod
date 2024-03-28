import QtQuick 1.1
import se.flir 1.0

// Box
// ---
// The graphical representation of a box measure tool

Item {

    id: boxId
    x: measureFunctionModel.toolScreenX
    y: measureFunctionModel.toolScreenY
    width: measureFunctionModel.toolScreenWidth
    height: measureFunctionModel.toolScreenHeight

    // The selected box
    Item {
        id: selection
        visible: measureFunctionModel.selected
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            border.color: "white"
            border.width: 1
            color: Qt.rgba(0, 0, 0, 0)
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            border.color: colors.underbright
            border.width: 1
            color: Qt.rgba(0, 0, 0, 0)
        }
    }

    // Grab boxes
    Repeater {
        model: 5
        delegate: BoxToolGrabBoxDelegate {}
    }

    // Cold spot
    Item {          // For performance reasons it seems better to put CrossHair inside an Item.
        id: coldSpotCrossHair

        x: minX - measureFunctionModel.toolScreenX - width / 2
        y: minY - measureFunctionModel.toolScreenY - height / 2
        visible: minActive && x >= -width/2 && x < boxId.width-width/2 && y >= -height/2 && y < boxId.height-height/2

        width: grid.spotSize * greenbox.system.zoom
        height: width

        CrossHair{  // C++
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
        visible: maxActive && x >= -width/2 && x < boxId.width-width/2 && y >= -height/2 && y < boxId.height-height/2

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
        anchors.right: boxId.right
        anchors.top: boxId.top
        width: idLabel.width + grid.horizontalSpacing
        height: idLabel.height
        visible: measureFuncs.boxCount > 1 || localParams ? true : false

        Text {
            id: idLabel
            anchors.centerIn: parent
            text: (measureFuncs.boxCount > 1 ? (resIndex + 1) + (localParams ? " " : "") : "") +
                  //: One letter abbreviation of 'parameters'. It is used as a flag indicating that a measurement tool has parameter settings that differs from default.
                  //% "P"
                  (localParams ? qsTrId("ID_MEASURE_LOCAL_PARAMS_P") + translation.update : "")
            font.family: fonts.family
            font.pixelSize: fonts.miniSize
            color: colors.textNormal
        }
    }
}
