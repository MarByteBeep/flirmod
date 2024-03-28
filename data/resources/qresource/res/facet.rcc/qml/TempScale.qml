import QtQuick 1.1
import System 1.0
import se.flir 1.0

//! Temperature Scale
//!
//! The scale with the palette gradient on the side of the screen.
//! @ingroup QML

Item {
    id: scaleAndIsothermItem

    // TODO: Compute this some more elaborate way
    //width: fonts.smallSize * 2 + grid.horizontalSpacing * 2
    width: lowerRow.width
    // NOTE: for some reason pogo needs to be first in this expression.
    visible: pogo || (greenbox.appState !== GreenBox.FacetArchiveView &&
                      greenbox.appState !== GreenBox.FacetPresetsView)

    Component.onCompleted: {
        greenbox.scale.interactive = manualInteraction;
        updateLaserPosDelay.restart()
    }
    onRotationChanged: updateLaserPosDelay.restart()

    // Tilt properties
    rotation: 0
    transformOrigin: Item.TopRight
    state: {
        if (greenbox.system.tilt === 0)
            return pogo ? "0_pogo" : "0"
        else if (greenbox.system.tilt === 90)
            return "90"
        else if (greenbox.system.tilt === 180)
            return pogo ? "180_pogo" : "180"
        else
            return "270"
    }

    function upKeyPressed() {
        keyUpFeedbackTimer.restart()
        keyDownFeedbackTimer.stop()
    }

    function downKeyPressed() {
        keyDownFeedbackTimer.restart()
        keyUpFeedbackTimer.stop()
    }

    property bool increaseSpan: true
    function leftKeyPressed() {
        if (greenbox.scale.levelSpanMode)
        {
            increaseSpan = false
            keyDownFeedbackTimer.restart()
            keyUpFeedbackTimer.restart()
        }
    }

    function rightKeyPressed() {
        if (greenbox.scale.levelSpanMode)
        {
            increaseSpan = true
            keyDownFeedbackTimer.restart()
            keyUpFeedbackTimer.restart()
        }
    }

    Timer {
        id: keyUpFeedbackTimer
        interval: 500
        repeat: false
    }
    Timer {
        id: keyDownFeedbackTimer
        interval: 500
        repeat: false
    }
    Timer {
        id: autoAdjustIndicationTimer
        interval: 100
        repeat: false
        onTriggered: greenbox.scale.autoAdjustInProgress = false
    }
    Connections{
        target: greenbox.scale
        onAutoAdjustInProgressChanged: autoAdjustIndicationTimer.start()
    }

    Item {
        id: scaleItem
        anchors.fill: parent
        visible: greenbox.system.viewMode !== System.VIEW_MODE_VISUAL

        // The gradient visualising the scale
        Item {
            id: scaleGradient
            anchors.right: parent.right
            anchors.top: upperRow.bottom
            anchors.bottom: lowerRow.top
            width: grid.horizontalSpacing * 4

            ScaleImage {
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

                // Isotherm interaction marker (arrows)
                Image {
                    id: arrowsID
                    source: y < 0 ? "../images/Sc_Status_ScaleArrowDown_Sel.png" :
                                    y > scaleGradient.height - height ? "../images/Sc_Status_ScaleArrowUp_Sel.png" :
                                                                            "../images/Sc_Status_ScaleArrowUpDown_Sel.png"
                    visible: greenbox.isotherm.type === 0 ?
                                 false :
                                 (greenbox.scale.interactionMode === Scale.InteractionObjectIsotherm ||
                                  greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMax ||
                                  greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMin) ? true : false
                    anchors.horizontalCenter: activeScaleGradientId.horizontalCenter
                    y: greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMin ?
                           isothermIntervalLevel.y + isothermIntervalLevel.height - height / 2 :
                           Math.min(
                               Math.max(activeScaleGradientId.height - ((activeScaleGradientId.height * greenbox.isotherm.pos ) / 100) - height / 2,
                                    -height / 3), activeScaleGradientId.height - 2 * height / 3)
                }
            }

            // Gradient border
            BorderImage {
                id: tempScaleFrameId
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: grid.verticalSpacing
                anchors.bottom: parent.bottom
                anchors.bottomMargin: grid.verticalSpacing
                border { left: grid.unit; top: grid.unit; right: grid.unit; bottom: grid.unit }
                source: greenbox.scale.useHistogram || greenbox.scale.autoAdjustInProgress ?
                            "../images/Bg_Scale_Outline_Def.png" :
                            "../images/Bg_Scale_OutlineLocked_Def.png"
            }

            MouseArea {
                id: scaleGradientMouseArea
                visible: !touchBased
                anchors.fill: scaleGradient
                anchors.leftMargin: -scaleGradient.width // increase area to accound for poor touch screen calibration
                anchors.rightMargin: -10

                onPressed: {
                    menus.closeMenu()
                    measureFuncs.unselectAll();

                    if (greenbox.appState === GreenBox.FacetEditView ||
                        greenbox.appState === GreenBox.FacetPreviewView)
                    {
                        if(greenbox.scale.interactionMode === Scale.InteractionObjectLevel)
                        {
                            greenbox.scale.doOneShotAutoAdjust()
                        }
                        else
                        {
                            greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                        }
                    }
                    else
                    {
                        if (!greenbox.scale.manual)
                        {
                            greenbox.scale.setInteractiveAndManual(manualInteraction, true)
                            greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                        }
                        else if(greenbox.scale.interactionMode === Scale.InteractionObjectLevel)
                        {
                            greenbox.scale.setInteractiveAndManual(false, false)
                            greenbox.scale.interactionMode = Scale.InteractionObject_BEYOND_LAST_KEY_MODE
                        }
                        else
                        {
                            if (manualInteraction)
                                greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                            else
                                greenbox.scale.setInteractiveAndManual(false, false)
                        }
                    }
                }
            }
        }

        // The upper label (max value)
        Row {
            id: upperRow
            anchors.right: parent.right
            anchors.top: parent.top
            property bool showLock: manualInteraction === false && !pogo && greenbox.scale.manual && !greenbox.scale.interactive
            property bool selected: (pogo || !greenbox.scale.manual ||
                                     !greenbox.scale.interactive || greenbox.scale.autoAdjustInProgress) ? false : true
            property bool activelySelected: selected && !measureFuncs.hasSelection && !menus.menuOpen &&
                                             (greenbox.scale.interactionMode === Scale.InteractionObjectLevel ||
                                              greenbox.scale.interactionMode === Scale.InteractionObjectMax)
            spacing: grid.horizontalSpacing * 2

            // Upper label interaction indicator
            RoundedRect {
                id: upperInterationId
                anchors.verticalCenter: parent.verticalCenter
                width: upperRow.activelySelected || upperRow.showLock ? topKeyUpIndicator.width + grid.horizontalSpacing - 1 : 0
                selected: upperRow.activelySelected || upperRow.showLock
                activelySelected: upperRow.activelySelected
                visible: upperRow.activelySelected || upperRow.showLock

                // Upper up-arrow
                Image {
                    id: topKeyUpIndicator
                    anchors.centerIn: parent
                    visible: greenbox.scale.levelSpanMode ? (keyDownFeedbackTimer.running && keyUpFeedbackTimer.running ? increaseSpan : !keyDownFeedbackTimer.running) : !keyDownFeedbackTimer.running
                    source: "../images/Sc_Status_ScaleArrowUp_Act.png"
                }

                // Upper down-arrow
                Image {
                    id: topKeyDownIndicator
                    anchors.centerIn: parent
                    visible: greenbox.scale.levelSpanMode ? (keyDownFeedbackTimer.running && keyUpFeedbackTimer.running ? !increaseSpan : !keyUpFeedbackTimer.running) : !keyUpFeedbackTimer.running
                    source: "../images/Sc_Status_ScaleArrowDown_Act.png"
                }

                // Lock icon (only for models without level/span)
                Image {
                    id: upperLock
                    anchors.centerIn: parent
                    visible: upperRow.showLock
                    source: "../images/Bg_Scale_BarLock_Dis.png"
                }
            }

            // The upper label text
            ScaleLabelBackPlate {
                selected: upperRow.selected || upperRow.showLock
                activelySelected: upperRow.activelySelected
                width: upperLabel.width + 2 * grid.horizontalSpacing

                // The value text
                Text {
                    id: upperLabel
                    anchors.centerIn: parent
                    font.family: fonts.latinFamily
                    font.pixelSize: fonts.mediumSize
                    color: upperRow.activelySelected || upperRow.selected || upperRow.showLock ? colors.background : colors.textFocused
                    text: greenbox.scale.levelHigh
                }

                MouseArea {
                    id: upperRowMouseArea
                    visible: !touchBased
                    anchors.fill: parent
                    anchors.margins: -10
                    onPressed: {
                        menus.closeMenu()
                        measureFuncs.unselectAll();
                        if (greenbox.scale.manual)
                        {
                            if (manualInteraction && !greenbox.scale.levelSpanMode)
                            {
                                if(greenbox.scale.interactionMode === Scale.InteractionObjectLevel)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectMin
                                else if(greenbox.scale.interactionMode === Scale.InteractionObjectMin)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                                else if(greenbox.scale.interactionMode === Scale.InteractionObjectMax)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectNone
                                else
                                    greenbox.scale.interactionMode = Scale.InteractionObjectMax
                            }
                            else
                            {
                                greenbox.scale.setInteractiveAndManual(false, false)
                            }
                        }
                        else
                        {
                            greenbox.scale.manual = true
                            if (manualInteraction)
                            {
                                greenbox.scale.interactive = true
                                if (greenbox.scale.levelSpanMode)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                                else
                                    greenbox.scale.interactionMode = Scale.InteractionObjectMax
                            }
                            else
                            {
                                greenbox.scale.interactive = false
                                greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                            }
                        }
                    }
                }
            }
        }

        // The lower label (min value)
        Row {
            id: lowerRow
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            property bool showLock: manualInteraction === false && !pogo && greenbox.scale.manual && !greenbox.scale.interactive
            property bool selected: (pogo || !greenbox.scale.manual ||
                                     !greenbox.scale.interactive || greenbox.scale.autoAdjustInProgress) ? false : true
            property bool activelySelected: selected && !measureFuncs.hasSelection && !menus.menuOpen &&
                                                         (greenbox.scale.interactionMode === Scale.InteractionObjectLevel ||
                                                          greenbox.scale.interactionMode === Scale.InteractionObjectMin)
            spacing: grid.horizontalSpacing * 2

            // Lower label interaction indicator
            RoundedRect {
                id: lowerInteractionId
                anchors.verticalCenter: parent.verticalCenter
                width: lowerRow.activelySelected || lowerRow.showLock ? bottomKeyUpIndicator.width + grid.horizontalSpacing - 1 : 0
                selected: lowerRow.activelySelected  || lowerRow.showLock
                activelySelected: lowerRow.activelySelected
                visible: lowerRow.activelySelected || lowerRow.showLock

                // Lower up-arrow
                Image {
                    id: bottomKeyUpIndicator
                    anchors.centerIn: parent
                    visible: greenbox.scale.levelSpanMode ? (keyDownFeedbackTimer.running && keyUpFeedbackTimer.running ? !increaseSpan : !keyDownFeedbackTimer.running) : !keyDownFeedbackTimer.running
                    source: "../images/Sc_Status_ScaleArrowUp_Act.png"
                }

                // Lower down-arrow
                Image {
                    id: bottomKeyDownIndicator
                    anchors.centerIn: parent
                    visible: greenbox.scale.levelSpanMode ? (keyDownFeedbackTimer.running && keyUpFeedbackTimer.running ? increaseSpan : !keyUpFeedbackTimer.running) : !keyUpFeedbackTimer.running
                    source: "../images/Sc_Status_ScaleArrowDown_Act.png"
                }

                // Lock icon (only for models without level/span)
                Image {
                    id: lowerLock
                    anchors.centerIn: parent
                    visible: lowerRow.showLock
                    source: "../images/Bg_Scale_BarLock_Dis.png"
                }
            }

            // The lower label text
            ScaleLabelBackPlate {
                selected: lowerRow.selected || lowerRow.showLock
                activelySelected: lowerRow.activelySelected
                width: lowerLabel.width + 2 * grid.horizontalSpacing

                // The text value
                Text {
                    id: lowerLabel
                    anchors.centerIn: parent
                    font.family: fonts.latinFamily
                    font.pixelSize: fonts.mediumSize
                    color: lowerRow.activelySelected || lowerRow.selected  || lowerRow.showLock ? colors.background : colors.textFocused
                    text: greenbox.scale.levelLow
                }

                MouseArea {
                    id: lowerRowMouseArea
                    visible: !touchBased
                    anchors.fill: parent
                    anchors.margins: -10
                    onPressed: {
                        menus.closeMenu()
                        measureFuncs.unselectAll();
                        if (greenbox.scale.manual)
                        {
                            if (manualInteraction && !greenbox.scale.levelSpanMode)
                            {
                                if(greenbox.scale.interactionMode === Scale.InteractionObjectLevel)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectMax
                                else if(greenbox.scale.interactionMode === Scale.InteractionObjectMax)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                                else if(greenbox.scale.interactionMode === Scale.InteractionObjectMin)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectNone
                                else
                                    greenbox.scale.interactionMode = Scale.InteractionObjectMin
                            }
                            else
                            {
                                greenbox.scale.setInteractiveAndManual(false, false)
                            }
                        }
                        else
                        {
                            greenbox.scale.manual = true
                            if (manualInteraction)
                            {
                                greenbox.scale.interactive = true
                                if (greenbox.scale.levelSpanMode)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                                else
                                    greenbox.scale.interactionMode = Scale.InteractionObjectMin
                            }
                            else
                            {
                                greenbox.scale.interactive = false
                                greenbox.scale.interactionMode = Scale.InteractionObjectLevel
                            }
                        }
                    }
                }
            }
        }
    }

    // The isotherm label
    Row {
        id: isotherm
        //anchors.bottom: parent.bottom
        anchors.top: parent.top
        x: {
            if (scaleAndIsothermItem.state === "0")
                return upperRow.activelySelected ?  (upperRow.x - width - grid.verticalSpacing) : (upperRow.x - width - grid.verticalSpacing*2)
            else if (scaleAndIsothermItem.state === "90")
                return upperRow.activelySelected ?  (upperRow.x - width - grid.verticalSpacing) : (upperRow.x - width - grid.verticalSpacing*2)
            else if (scaleAndIsothermItem.state === "180")
                return upperRow.activelySelected ?  (upperRow.x - width - grid.verticalSpacing) : (upperRow.x - width - grid.verticalSpacing*2)
            else
                return upperRow.activelySelected ?  (upperRow.x - width - grid.verticalSpacing) : (upperRow.x - width - grid.verticalSpacing*2)
        }        visible: greenbox.isotherm.type === 0 ? false : greenbox.system.viewMode === System.VIEW_MODE_VISUAL ? false : true
        property bool selected: greenbox.scale.interactionMode === Scale.InteractionObjectIsotherm ?
                                (!pogo && !measureFuncs.hasSelection && !menus.menuOpen ? true : false) : false
        property bool intervalSelected: (greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMax ||
                                         greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMin) ?
                                (!pogo && !measureFuncs.hasSelection && !menus.menuOpen ? true : false) : false
        spacing: grid.horizontalSpacing

        // Isotherm interaction indicator
        RoundedRect {
            id: isoInteractionId
            anchors.verticalCenter: parent.verticalCenter
            width: selected ? isoKeyUpIndicator.width + grid.horizontalSpacing - 1 : 0
            selected: isotherm.selected || isotherm.intervalSelected
            activelySelected: selected
            visible: selected

            // Isotherm up-arrow
            Image {
                id: isoKeyUpIndicator
                anchors.centerIn: parent
                visible: !keyDownFeedbackTimer.running
                source: "../images/Sc_Status_ScaleArrowUp_Act.png"
            }

            // Isotherm down-arrow
            Image {
                id: isoKeyDownIndicator
                anchors.centerIn: parent
                visible: !keyUpFeedbackTimer.running
                source: "../images/Sc_Status_ScaleArrowDown_Act.png"
            }
        }

        // Isotherm value(s)
        RoundedRect {
            id: isothermContent
            anchors.verticalCenter: parent.verticalCenter
            selected: !isotherm.selected && greenbox.isotherm.type < 4  // Isoterm type 4 and ab0ove have non modifiable parameters
            activelySelected: isotherm.selected
            width: isoRow.width + 4 * grid.horizontalSpacing

            MouseArea {
                id: isoMouseArea
                anchors.fill: parent
                onPressed: {
                    menus.closeMenu()
                    measureFuncs.unselectAll();
                    if (greenbox.isotherm.type <= 2)
                    {
                        if(greenbox.scale.interactionMode !== Scale.InteractionObjectIsotherm)
                            greenbox.scale.interactionMode = Scale.InteractionObjectIsotherm
                        else if (!greenbox.scale.levelSpanMode)
                            greenbox.scale.interactionMode = Scale.InteractionObjectNone
                    }
                }
            }

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
                        source: greenbox.isotherm.type === 1 ? "../images/Sc_Arrow_AboveValue_Act.png" :
                                greenbox.isotherm.type === 2 ? "../images/Sc_Arrow_BelowValue_Act.png" :
                                (greenbox.isotherm.type === 5 && greenbox.isotherm.actualType === 1) ? "../images/Sc_Arrow_AboveValue_Sel.png" :
                                     "../images/Sc_Arrow_BelowValue_Sel.png"
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
                        color: greenbox.isotherm.type > 3 ? colors.textFocused : colors.background
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

                        MouseArea {
                            id: iso1ValueMouseArea
                            anchors.fill: parent
                            enabled: greenbox.isotherm.type === 3
                            onPressed: {
                                menus.closeMenu()
                                measureFuncs.unselectAll();
                                if (greenbox.isotherm.type === 3)
                                {
                                    if(greenbox.scale.interactionMode !== Scale.InteractionObjectIsothermMin)
                                        greenbox.scale.interactionMode = Scale.InteractionObjectIsothermMin
                                    else
                                        greenbox.scale.interactionMode = Scale.InteractionObjectNone
                                }
                            }
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
                        color: colors.background
                        visible: greenbox.isotherm.type === 3 ? true : false
                        text: (greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMax ? "" : " - ") + greenbox.isotherm.level

                        MouseArea {
                            id: iso2ValueMouseArea
                            anchors.fill: parent
                            enabled: greenbox.isotherm.type === 3
                            onPressed: {
                                menus.closeMenu()
                                measureFuncs.unselectAll();

                                if(greenbox.scale.interactionMode !== Scale.InteractionObjectIsothermMax)
                                    greenbox.scale.interactionMode = Scale.InteractionObjectIsothermMax
                                else
                                    greenbox.scale.interactionMode = Scale.InteractionObjectNone
                            }
                        }
                    }
                }
            }
        }
    }

    // Tilt states
    states: [
        State {
            name: "0"
            PropertyChanges { target: scaleAndIsothermItem; rotation: 0 }
            PropertyChanges { target: scaleAndIsothermItem; height: grid.height - grid.topMargin - grid.bottomMargin - 2 * grid.verticalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; x: grid.width - grid.rightMargin - grid.horizontalSpacing - width }
            PropertyChanges { target: scaleAndIsothermItem; y: grid.topMargin + grid.verticalSpacing }
        },
        State {
            name: "0_pogo"
            PropertyChanges { target: scaleAndIsothermItem; rotation: 0 }
            PropertyChanges { target: scaleAndIsothermItem; height: grid.height - grid.topMargin - grid.bottomMargin - 2 * grid.verticalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; x: grid.width - grid.rightMargin - grid.horizontalSpacing - width - grid.irRightMargin}
            PropertyChanges { target: scaleAndIsothermItem; y: grid.topMargin + grid.verticalSpacing }
        },
        State {
            name: "90"
            PropertyChanges { target: scaleAndIsothermItem; rotation: 90 }
            PropertyChanges { target: scaleAndIsothermItem; height: grid.width - grid.leftMargin - grid.irLeftMargin - grid.rightMargin - grid.irRightMargin - 2 * grid.horizontalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; x: height - width + grid.leftMargin + grid.irLeftMargin + grid.horizontalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; y: grid.height - grid.bottomMargin - grid.verticalSpacing }
        },
        State {
            name: "180"
            PropertyChanges { target: scaleAndIsothermItem; rotation: 180 }
            PropertyChanges { target: scaleAndIsothermItem; height: grid.height - grid.topMargin - grid.bottomMargin - 2 * grid.verticalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; x: -width + grid.leftMargin + grid.horizontalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; y: grid.height - grid.verticalSpacing - grid.topMargin }
        },
        State {
            name: "180_pogo"
            PropertyChanges { target: scaleAndIsothermItem; rotation: 180 }
            PropertyChanges { target: scaleAndIsothermItem; height: grid.height - grid.topMargin - grid.bottomMargin - 2 * grid.verticalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; x: -width + grid.leftMargin + grid.horizontalSpacing + grid.irLeftMargin}
            PropertyChanges { target: scaleAndIsothermItem; y: grid.height - grid.verticalSpacing - grid.topMargin }
        },
        State {
            name: "270"
            PropertyChanges { target: scaleAndIsothermItem; rotation: 270 }
            PropertyChanges { target: scaleAndIsothermItem; height: grid.width - grid.leftMargin - grid.irLeftMargin - grid.rightMargin - grid.irRightMargin - 2 * grid.horizontalSpacing }
            PropertyChanges { target: scaleAndIsothermItem; x: grid.leftMargin + grid.irLeftMargin + grid.horizontalSpacing - width }
            PropertyChanges { target: scaleAndIsothermItem; y: grid.topMargin + grid.verticalSpacing }
        }
    ]


    Image {
        id: laserOnIndicatorPlaceholder
        source: "../images/Sc_Status_Laser.png"
        anchors.top: parent.top
        visible: false

        x: {
                updateLaserPosDelay.restart()

                if (greenbox.appState !== GreenBox.FacetLiveView && greenbox.appState !== GreenBox.FacetMediaControlState)
                    return grid.width - laserOnIndicatorPlaceholder.sourceSize.width - grid.horizontalSpacing;
                else if(scaleItem.visible)
                    return upperRow.x - laserOnIndicatorPlaceholder.sourceSize.width - grid.horizontalSpacing
                else
                    return parent.width - laserOnIndicatorPlaceholder.sourceSize.width
        }

        Timer {
            id: updateLaserPosDelay
            interval: 50
            repeat: false
            onTriggered: laserOnIndicatorPlaceholder.updateLaserPlaceHolder()

        }

        function updateLaserPlaceHolder()
        {
            var laserIndicatorElement = greenbox.GetNamedObject("laserOnIndicator")
            var coordReference = (greenbox.appState === GreenBox.FacetLiveView
                    || greenbox.appState === GreenBox.FacetMediaControlState) ?  scaleAndIsothermItem : greenbox.GetNamedObject("root")

            laserIndicatorElement.updateLocation(coordReference, laserOnIndicatorPlaceholder)
         }

    }
}
