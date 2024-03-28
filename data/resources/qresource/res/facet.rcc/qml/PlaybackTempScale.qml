import QtQuick 1.1
import System 1.0
import se.flir 1.0

//! Temperature Scale
//!
//! The scale with the palette gradient on the side of the screen.
//! @ingroup QML

Item {
    id: playBackTempScaleId

    width: fonts.smallSize * 2 + grid.horizontalSpacing * 2
    height: grid.height - grid.topMargin - grid.bottomMargin - 2 * grid.verticalSpacing
    x: grid.width - grid.rightMargin - grid.horizontalSpacing - width
    y: grid.topMargin + grid.verticalSpacing

    Item {
        id: scaleItem
        anchors.fill: parent

        // The gradient visualising the scale
        Item{
            id: scaleGradient
            anchors.right: parent.right
            anchors.top: upperRow.bottom
            anchors.bottom: lowerRow.top
            width: grid.horizontalSpacing * 4


            ScaleImage{
                id: activeScaleGradientId
                anchors.fill: tempScaleFrameId
                anchors.margins: 2

                // The isotherm above color
                Rectangle {
                    id: isothermAboveLevel
                    anchors.left: activeScaleGradientId.left
                    anchors.top: activeScaleGradientId.top
                    anchors.right: activeScaleGradientId.right

                    height: Math.max(activeScaleGradientId.height - ((activeScaleGradientId.height * greenbox.isotherm.pos ) / 100), 2)

                    color: greenbox.isotherm.color
                    visible: greenbox.isotherm.type === 1 ||
                             (greenbox.isotherm.type === 5 && greenbox.isotherm.actualType === 1)
                }

                // The isotherm below color
                Rectangle {
                    id: isothermBelowLevel
                    anchors.left: activeScaleGradientId.left
                    anchors.bottom: activeScaleGradientId.bottom
                    anchors.right: activeScaleGradientId.right

                    height: Math.max((activeScaleGradientId.height * greenbox.isotherm.pos ) / 100, 2)

                    color: greenbox.isotherm.color
                    visible: greenbox.isotherm.type === 2 || greenbox.isotherm.type === 4 ||
                             (greenbox.isotherm.type === 5 && greenbox.isotherm.actualType === 2)
                }

                // The isotherm interval color
                Rectangle {
                    id: isothermIntervalLevel
                    anchors.left: activeScaleGradientId.left
                    anchors.top: activeScaleGradientId.top
                    anchors.topMargin: activeScaleGradientId.height - ((activeScaleGradientId.height * greenbox.isotherm.pos ) / 100)
                    anchors.right: activeScaleGradientId.right

                    height: Math.min((activeScaleGradientId.height * greenbox.isotherm.lowPos ) / 100,
                                     (activeScaleGradientId.height * greenbox.isotherm.pos ) / 100)

                    color: greenbox.isotherm.color
                    visible: greenbox.isotherm.type === 3
                }
            }

            // Gradient border
            BorderImage {
                id: tempScaleFrameId
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right

                border { left: grid.unit; top: grid.unit; right: grid.unit; bottom: grid.unit }
                source: "../images/Bg_Scale_Outline_Def.png"
            }
        }


        // The upper label (max value)
        ScaleLabelBackPlate {
            id: upperRow
            selected: false
            anchors.right: parent.right
            anchors.top: parent.top

            // The value text
            Text {
                id: upperLabel
                anchors.centerIn: parent
                font.family: fonts.latinFamily
                font.pixelSize: fonts.mediumSize
                color: upperRow.selected ? colors.background : colors.textFocused
                text: greenbox.scale.levelHigh
            }
        }

        // The lower label (min value)
        ScaleLabelBackPlate {
            id: lowerRow
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            selected: false

            // The text value
            Text {
                id: lowerLabel
                anchors.centerIn: parent
                font.family: fonts.latinFamily
                font.pixelSize: fonts.mediumSize
                color: lowerRow.selected ? colors.background : colors.textFocused
                text: greenbox.scale.levelLow
            }
        }
    }

    // The isotherm lable
    Row {
        id: isotherm
        anchors.bottom: parent.bottom
        x: (-width - playBackTempScaleId.x + playBackTempScaleId.width) / 2
        visible: greenbox.isotherm.type === 0 ? false : true
        property bool selected: false
        property bool intervalSelected: false
        spacing: grid.horizontalSpacing

        // Isotherm value(s)
        RoundedRect {
            id: isothermContent
            anchors.verticalCenter: parent.verticalCenter
            selected: isotherm.selected
            width: isoRow.width + 4 * grid.horizontalSpacing

            Row {
                id: isoRow
                anchors.centerIn: parent
                anchors.leftMargin: 2 * grid.horizontalSpacing

                // Color "icon"
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    color: greenbox.isotherm.color
                    width: 10
                    height: 10
                }

                // Value 1
                Item {
                    width: isoLowVal.text === "" ? 0: isoLowVal.width + isoSymbol.width
                    height: grid.resultTableRowHeight

                    // Interval background 1
                    Rectangle {
                        id: isoLowValRect
                        anchors.verticalCenter: parent.verticalCenter
                        visible: greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMin && isotherm.intervalSelected
                        color: colors.textFocused
                        width: visible ? isoLowVal.width + grid.horizontalSpacing - 2 : 0
                        height: parent.height - 4
                        radius: 2
                        x: grid.horizontalSpacing
                    }

                    // Isotherm type icon (</>)
                    Image {
                        id: isoSymbol
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        width: visible ? undefined : 0
                        visible: greenbox.isotherm.type !== 3 ? true : false
                        source: (greenbox.isotherm.type === 1 || (greenbox.isotherm.type === 5 && greenbox.isotherm.actualType === 1)) ?
                                    (isotherm.selected ? "../images/Sc_Arrow_AboveValue_Act.png" : "../images/Sc_Arrow_AboveValue_Def.png") :
                                    (isotherm.selected ? "../images/Sc_Arrow_BelowValue_Act.png" : "../images/Sc_Arrow_BelowValue_Def.png")
                    }

                    // Isotherm value 1
                    Text {
                        id: isoLowVal
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: isoLowValRect.visible ? isoLowValRect.left : isoSymbol.right
                        anchors.leftMargin: isoLowValRect.visible ? 1 : grid.horizontalSpacing
                        font.family: fonts.latinFamily
                        font.pixelSize: fonts.smallSize
                        font.bold: true
                        color: (isotherm.selected ||
                               (isotherm.intervalSelected && greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMin)) ?
                                   colors.background : colors.textFocused
                        text: {
                            if (greenbox.isotherm.type === 1)
                                return greenbox.isotherm.level
                            else if (greenbox.isotherm.type === 2)
                                return greenbox.isotherm.level
                            else if (greenbox.isotherm.type === 3)
                                return greenbox.isotherm.lowLevel + (greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMax ? " - " : "")
                            else if (greenbox.isotherm.type === 4)
                                return greenbox.isotherm.level
                            else if (greenbox.isotherm.type === 5)
                            {
                                if (greenbox.isotherm.actualType === 1)
                                    return greenbox.isotherm.level
                                else
                                    return greenbox.isotherm.level
                            }
                            else
                                return ""       // Default to avoid warnings during startup
                        }

                    }
                }

                // Value 2 (for type interval)
                Item {
                    width: greenbox.isotherm.type === 3 ? isoHighVal.width : 0
                    height: grid.resultTableRowHeight

                    // Interval background 2
                    Rectangle {
                        id: isoHighValRect
                        anchors.verticalCenter: parent.verticalCenter
                        visible: greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMax ?
                                     (!pogo && !measureFuncs.hasSelection ? true : false) : false
                        color: colors.textFocused
                        width: isoHighVal.width + 2
                        height: parent.height - 4
                        radius: 2
                        x: -1
                    }

                    // Isotherm value 2
                    Text {
                        id: isoHighVal
                        anchors.verticalCenter: parent.verticalCenter
                        font.family: fonts.latinFamily
                        font.pixelSize: fonts.smallSize
                        font.bold: true
                        color: isoHighValRect.visible ? "black" : colors.textFocused
                        visible: greenbox.isotherm.type === 3 ? true : false
                        text: (greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMax ? "" : " - ") + greenbox.isotherm.level

                    }
                }
            }
        }
    }
}
