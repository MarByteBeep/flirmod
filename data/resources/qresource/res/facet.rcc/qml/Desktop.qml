import QtQuick 1.1

import se.flir 1.0
import System 1.0
import "MeasureTools"


// Desktop
// -------
// The "transparent" item that is the parent of all other QML elements.

FocusScope {

    // Signals

    signal showArchive
    signal triggerActionRequest
    signal exitEdit()

    // slots (called from the xml file for the globalMessageSpinner)
    function focusDesktopFocusGroup() {
//        console.log("focusDesktopFocusGroup() called")
        // Don't steal it from the toolbar
        var toolbars = greenbox.GetNamedObject("globalToolbars")
        if (toolbars !== null && toolbars.focus)
            return
        focus = true;
    }

    // Called from cameraInfoModel when user selects register camera in the settings menu
    function goForCameraRegistration() {
        wizardTimer.restart()
    }
    // This is an ugly way of solving the problem with next button in wizard responding to key up event. When coming to
    // wizard from settings menu the user might still hold the select key down, this would then lead the wizard to skip
    // the first page if it is loaded when the key is released. Add this short delay to give user time for a "normal" click
    Timer {
        id: wizardTimer
        interval: 500
        onTriggered: {
            settingsViewMgr.closeSettings();
            greenbox.system.goForCameraRegistration = true
        }
    }
//    onFocusChanged: console.log("Desktop focus: " + focus)

    //
    // camera registration nag box, only run when in live view
    //
    signal notifyTextButton(variant msg, variant btnTxt)
    signal notifyNagMessageBox()

    function notificationButtonPressed() {
        greenbox.system.goForCameraRegistration = true
    }

    // The running condition is pretty horrible here.... we want it running IFF we are in LiveView and not during startup wizard
    Timer {
        id: cameraRegistrationNagBox
        interval: 4000; running: true; repeat: false;
        onTriggered: {
            if (!greenbox.system.isCameraRegistered && !greenbox.system.initialStartup &&
               !messageboxHandler.showing){
                if ( registrationNag==="notification"){
                    notifyTextButton("REGISTER_CAMERA_REMINDER_TEXT", "REGISTER_CAMERA_REMINDER_BTN")
                }
                else if (registrationNag==="box"){
                    notifyNagMessageBox()
                }
            }

        }
    }

    //todo: review if this is the right way to dispatch arrow keys
    signal key_down(int key, int repeat)
    signal key_up(int key, int repeat)

    // Property values

    id: desktop
    anchors.fill: parent
    width: grid.width
    height: grid.height

    property bool longTapped: false

    MouseArea {
        id: desktopMouseArea
        objectName: "desktopMouseArea"

        property bool startDrag: false
        anchors.fill: parent
        onPressed: {
            if (pip.selected)
                return
            else if (!menus.menuOpen) {
                longTapTimer.start()
                greenbox.system.setDragStart(mouse.x, mouse.y)
                startDrag = true
            }
        }

        onMouseXChanged: {
            if (!startDrag)
                return
            if (greenbox.appState === GreenBox.FacetEditView || greenbox.appState === GreenBox.FacetPreviewView)
            {
                greenbox.system.setDragTo(mouse.x, mouse.y)
            }
        }

        onMouseYChanged: {
            if (!startDrag)
                return
            if (greenbox.appState === GreenBox.FacetEditView || greenbox.appState === GreenBox.FacetPreviewView)
            {
                greenbox.system.setDragTo(mouse.x, mouse.y)
            }
        }

        onReleased: {
            if (!greenbox.system.isDragged || menus.menuOpen)
            {
                if (menus.activeMenu === Menus.ZoomPopupMenu)
                {
                    if (!longTapTimer.running) {
                        menus.closeMenu();
                    }
                }
                else
                {
                    if (pip.selected)
                        pip.selected = false
                    else if (greenbox.appState !== GreenBox.FacetPresetsView &&
                             greenbox.appState !== GreenBox.FacetArchiveView)
                    {
                        startDrag = false
                        menus.toggleMenu();
                    }
                }
            }
            greenbox.system.isDragged = false
            startDrag = false

            longTapTimer.stop()
        }
    }

    Timer {
        id: longTapTimer
        interval: 500
        repeat: true
        onTriggered: {
            if (running && !greenbox.system.isDragged && !menus.menuOpen) {
                desktopMouseArea.startDrag = false
                if (!greenbox.mediaControl.busyStore && !greenbox.system.showZoomControl)
                    menus.openTemporary(Menus.ZoomPopupMenu);
            }
        }
    }

    Timer {
        id: longPressArchiveTimer
        interval: 1000
        onTriggered: {
            if (greenbox.appState !== GreenBox.FacetEditView)
                greenbox.system.doNuc()
        }
    }

    Timer {
        id: halfPressTriggerTimer
        interval: 150
        onTriggered: {
            if (greenbox.system.contAutoFocus)
                greenbox.system.pauseContAutoFocus(true)
            else
                greenbox.system.doOneShotAutoFocus()
        }
    }

	Timer {
        id: warningTimer
        interval: 8000
		running:true
		repeat:false
        onTriggered: {
			myBackgroundImage.visible=false
			event.accepted = true
        }
	}

	Timer {
        id: creditsTimer
        interval: 5000
        onTriggered: {
            if (greenbox.appState === GreenBox.FacetLiveView && !menus.menuOpen)
				myCreditsText.visible=true
            	myCredits.visible=true
        }
	}

    Connections {
        target: menus
        onMenuClosed: {
            var toolbars = greenbox.GetNamedObject("globalToolbars")
            if (toolbars !== null && !toolbars.focus && !toolbars.hasPopupOpen)
                return
            desktop.focus = true
        }
    }

    Item{
        width: grid.width - grid.irLeftMargin - grid.irRightMargin
        height: grid.height
        x: grid.irLeftMargin
        visible: !greenbox.hideGuiLayer && (cameraHasStaticFocus || greenbox.system.viewMode !== System.VIEW_MODE_VISUAL)

        Rectangle {
            id: idLineToolProfileBackground
            objectName: "profileToolBackground"
            color: colors.underbright
            visible: measureFuncs.lineProfile.lineVisible && measureFuncs.lineProfile.active
            width: measureFuncs.lineProfile.vertical ? measureFuncs.lineProfile.graphHeight : measureFuncs.lineProfile.end - measureFuncs.lineProfile.start
            height: measureFuncs.lineProfile.vertical ? measureFuncs.lineProfile.end - measureFuncs.lineProfile.start : measureFuncs.lineProfile.graphHeight

            x: measureFuncs.lineProfile.vertical
                ? (measureFuncs.lineProfile.graphXOffset > 0 ? parent.width - (measureFuncs.lineProfile.graphXOffset-1) - width : - (measureFuncs.lineProfile.graphXOffset+1) )
                : measureFuncs.lineProfile.start
            y: measureFuncs.lineProfile.vertical
               ? measureFuncs.lineProfile.start
               : (measureFuncs.lineProfile.graphYOffset > 0 ? grid.height - (measureFuncs.lineProfile.graphYOffset-1) - height : - (measureFuncs.lineProfile.graphYOffset+1) )

            LineProfile{
                id: idLineToolProfile
                anchors.fill: parent
                objectName: "profileTool"
                visible: measureFuncs.lineProfile.lineVisible && measureFuncs.lineProfile.active
            }

            Binding { target: measureFuncs.lineProfile; property: "graphHeight"; value: grid.iconHeight }
            Binding { target: measureFuncs.lineProfile; property: "graphXOffset"; value: grid.lineGraphOffset }
            Binding { target: measureFuncs.lineProfile; property: "graphYOffset"; value: grid.lineGraphOffset }

            Behavior on y {
                NumberAnimation {
                    id: bouncebehavior
                    easing {
                        type: Easing.OutElastic
                        amplitude: 1.0
                        period: 1.0
                    }
                }
            }
        }
    }

    Image{
        source: "../images/Sc_Status_LaserIndicator_Def.png"
        x: grid.irLeftMargin + flirSystem.laserPosX - (sourceSize.width/2)
        y: flirSystem.laserPosY - (sourceSize.height/2)
        visible: flirSystem.laserActive && flirSystem.laserCalibrated && flirSystem.laserPosX !== -1 && flirSystem.laserPosY !== -1 && greenbox.appState !== GreenBox.FacetEditView
    }

    Connections {
        target: measureFuncs
        onHasSelectionChanged: {
            if (! measureFuncs.hasSelection && !menus.menuOpen) {
                greenbox.adaptMenu()
                desktop.focus = true
            }
        }
    }
    Connections {
        target: messageboxHandler
        onBoxVisibleChanged: {
            if (!messageboxHandler.showing)
            {
                if (menus.modal)
                    menus.refocus = true
                else if (!messageSpinnerHandler.showing) {
                    focusDesktopFocusGroup()
                }
            }
        }
    }
    Connections {
        target: messageSpinnerHandler
        onSpinnerVisibleChanged: {
            if (messageSpinnerHandler.showing === false)
                focusDesktopFocusGroup()
        }
    }

    Keys.onPressed: {
        if (greenbox.appState === GreenBox.FacetSettingsView && event.key !== keys.camera)
        {
            return
        }

        if (event.key === keys.trigger && !event.isAutoRepeat) {
            if (halfPressTriggerTimer.running)
                halfPressTriggerTimer.stop()
            if (measureFuncs.hasSelection) {
                measureFuncs.unselectAll();
            }
            if (menus.menuOpen)
            {
                menus.closeMenu()
            }
            else
            {
                triggerActionRequest()
            }
            event.accepted = true
        }

		else if (event.key === keys.program && greenbox.appState === GreenBox.FacetLiveView && !menus.menuOpen)
		{

			if (keys.program === keys.down)
			{
			}
			else if (keys.program === keys.back && !pip.selected ) {
				key_down(GreenBox.UI_KEY_PROGRAM,event.isAutoRepeat === true?1:0)
                event.accepted = true
			}

		}

 		if (event.key === keys.up) {

			if (greenbox.system.viewMode === System.VIEW_MODE_PIP && pip.selected === true) {

				if (pip.selectionMoveMode)
					greenbox.system.setPIPRect(greenbox.system.pipX1, greenbox.system.pipY1-10, greenbox.system.pipX2, greenbox.system.pipY2-10)
				else
					greenbox.system.setPIPRect(greenbox.system.pipX1, greenbox.system.pipY1-5, greenbox.system.pipX2, greenbox.system.pipY2+5)
				event.accepted = true
			}

			else if(greenbox.scale.manual === false &&
				!(greenbox.scale.interactionMode === Scale.InteractionObjectIsotherm ||
				  greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMax ||
				  greenbox.scale.interactionMode === Scale.InteractionObjectIsothermMin) &&
				  !(greenbox.appState === GreenBox.FacetArchiveView ||
				  greenbox.appState === GreenBox.FacetPresetsView) )
				{
				menus.openTemporary(Menus.ZoomPopupMenu)
				event.accepted = true
			}
			else{
            key_down(GreenBox.UI_KEY_UP,event.isAutoRepeat === true?1:0)
            event.accepted = true
			}

        }
        else if (event.key === keys.down) {

			if (greenbox.system.viewMode === System.VIEW_MODE_PIP) {

				if (pip.selected && !myVar.pipJustSelected) {

					if (pip.selectionMoveMode) {

						if (greenbox.system.pipY2+10 < 240)
							greenbox.system.setPIPRect(greenbox.system.pipX1, greenbox.system.pipY1+10, greenbox.system.pipX2, greenbox.system.pipY2+10)
					}
					else {

						if (greenbox.system.pipY2-greenbox.system.pipY1 >50)
							greenbox.system.setPIPRect(greenbox.system.pipX1, greenbox.system.pipY1+5, greenbox.system.pipX2, greenbox.system.pipY2-5)
					}
					event.accepted = true
				}
				else if (event.isAutoRepeat === false)	{
					timerPipSelect.start()
				}

			}
			else if (event.isAutoRepeat === false && greenbox.system.viewMode === System.VIEW_MODE_VISUAL && !menus.menuOpen)
		    {

				if (!creditsTimer.running)  {
					if (myCreditsText.visible === true)
						myCreditsText.visible=false
					else
						myCredits.visible=false
				}
				 creditsTimer.start()
				 event.accepted = true

		    }

			if (!pip.selected) {
				key_down(GreenBox.UI_KEY_DOWN,event.isAutoRepeat === true?1:0)
				event.accepted = true
			}

        }
        else if (event.key === keys.left) {
			if (greenbox.system.viewMode === System.VIEW_MODE_PIP && pip.selected === true){
				if (pip.selectionMoveMode) {
					greenbox.system.setPIPRect(greenbox.system.pipX1-10, greenbox.system.pipY1, greenbox.system.pipX2-10, greenbox.system.pipY2)
				}
				else {
					if (greenbox.system.pipX2-greenbox.system.pipX1 >60) //limit minimum PIP width
						greenbox.system.setPIPRect(greenbox.system.pipX1+5, greenbox.system.pipY1, greenbox.system.pipX2-5, greenbox.system.pipY2)
				}
				event.accepted = true
			}
			else {
				key_down(GreenBox.UI_KEY_LEFT,event.isAutoRepeat === true?1:0)
				event.accepted = true
			}
        }
        else if (event.key === keys.right) {
			if (greenbox.system.viewMode === System.VIEW_MODE_PIP && pip.selected === true) {
				if (pip.selectionMoveMode) {
					if (greenbox.system.pipX2+10 < 320)
						greenbox.system.setPIPRect(greenbox.system.pipX1+10, greenbox.system.pipY1, greenbox.system.pipX2+10, greenbox.system.pipY2)
				}
				else {
					greenbox.system.setPIPRect(greenbox.system.pipX1-5, greenbox.system.pipY1, greenbox.system.pipX2+5, greenbox.system.pipY2)
				}
				event.accepted = true
			}
			else {
				key_down(GreenBox.UI_KEY_RIGHT,event.isAutoRepeat === true?1:0)
				event.accepted = true
			}
        }
        else if (event.key === keys.onOff) {
            key_down(GreenBox.UI_KEY_ONOFF,event.isAutoRepeat === true?1:0)
            event.accepted = true
        }
        else if (event.key === keys.archive)
        {
            if (event.isAutoRepeat === false)
                longPressArchiveTimer.start()
            event.accepted = true
        }
		else if (event.key === keys.select) {
            if (event.isAutoRepeat === false)
            {
				if (greenbox.system.viewMode === System.VIEW_MODE_PIP && pip.selected === false)
					timerPipSelect.start()
			}
		}
        else
        {
            console.log("got un-handled key " + event.key)
         }
    }

    Keys.onReleased: {
        if (greenbox.appState === GreenBox.FacetSettingsView && event.key !== keys.camera)
        {
            return
        }

        if (event.key === keys.zoom)
        {
            greenbox.system.zoomInStop()
            event.accepted = true
        }
        else if (event.key === keys.zoomOut)
        {
            greenbox.system.zoomOutStop()
            event.accepted = true
        }
        else if (event.key === keys.archive) {
            if (event.isAutoRepeat === false && !greenbox.mediaControl.busyStore)
            {
                if (greenbox.appState === GreenBox.FacetEditView)
                    editHandler.checkCancelEdit()
                else if (greenbox.appState === GreenBox.FacetPreviewView)
                    previewHandler.checkCancelPreview()
                else if (longPressArchiveTimer.running)
                {
                    longPressArchiveTimer.stop()

                    if (greenbox.appState === GreenBox.FacetMediaControlState) {
                        console.log("Ignore going into archive while recording/saving.")
                    }
                    else {
                        showArchive()
                    }
                }
            }
            if (event.isAutoRepeat === false)
                longPressArchiveTimer.stop()
            event.accepted = true
        }
        else if (event.key === keys.back && !event.isAutoRepeat)
        {
			if (greenbox.system.viewMode === System.VIEW_MODE_PIP && pip.selected === true) {
				pip.selected=false
				pip.selectionMoveMode=true
				timerPipHelp.start()
			}
            else if (greenbox.appState === GreenBox.FacetEditView) {
                editHandler.checkCancelEdit()
			}
            else if (greenbox.appState === GreenBox.FacetPreviewView) {
                previewHandler.checkCancelPreview()
			}
        }
        else if (event.key === keys.select) {
            if (event.isAutoRepeat === false)
            {
				timerPipSelect.stop()
				if (greenbox.system.viewMode === System.VIEW_MODE_PIP && pip.selected === true) {
					if (pip.selectionMoveMode)
						pip.selectionMoveMode=false
					else
						pip.selectionMoveMode=true
				}
				else if (menus.menuOpen || !greenbox.mediaControl.busyStore) {
                    menus.toggleMenu()
				}
            }
            event.accepted = true
        }
		if (event.key === keys.program && !event.isAutoRepeat && greenbox.appState === GreenBox.FacetLiveView && !menus.menuOpen)
		{
			if (keys.program === keys.down)
			{
			}
			else if (keys.program === keys.back && !pip.selected ) {
				key_up(GreenBox.UI_KEY_PROGRAM,event.isAutoRepeat === true?1:0)
                event.accepted = true
			}
		}

        if (event.key === keys.up) {
            key_up(GreenBox.UI_KEY_UP,event.isAutoRepeat === true?1:0)
            if (!pip.selected)
				tempScale.upKeyPressed()

            event.accepted = true
        }
        else if (event.key === keys.down) {
            if (!pip.selected) {
				tempScale.downKeyPressed()
			}
			else {
				if (event.isAutoRepeat === false ) {
					if (myVar.pipJustSelected)
						myVar.pipJustSelected=false
				}
			}
			if (event.isAutoRepeat === false && timerPipSelect.running)
				timerPipSelect.stop()

			if (event.isAutoRepeat === false) {
				if (creditsTimer.running)
					creditsTimer.stop()
			}
			key_up(GreenBox.UI_KEY_DOWN,event.isAutoRepeat === true?1:0)
	        event.accepted = true
        }
        else if (event.key === keys.left) {
            key_up(GreenBox.UI_KEY_LEFT,event.isAutoRepeat === true?1:0)
            if (!pip.selected)
				tempScale.leftKeyPressed()

            event.accepted = true
        }
        else if (event.key === keys.right) {
            key_up(GreenBox.UI_KEY_RIGHT,event.isAutoRepeat === true?1:0)
            if (!pip.selected)
				tempScale.rightKeyPressed()

            event.accepted = true
        }
        else if (event.key === keys.onOff) {
			key_up(GreenBox.UI_KEY_ONOFF,event.isAutoRepeat === true?1:0)
            event.accepted = true
        }
        else if (event.key === keys.trigger)
        {
            greenbox.system.pauseContAutoFocus(false)
            event.accepted = true
        }
    }

    Item {
        id: liveControls
        anchors.fill: parent
        visible: greenbox.appState !== GreenBox.FacetArchiveView
        objectName: "desktopTools"

        Connections {
            target: greenbox
            onAppStateChanged: {
                if (greenbox.hasSketchSupport &&
                        (greenbox.appState == GreenBox.FacetSketchView || greenbox.appState == GreenBox.FacetEditView) &&
                        sketchLoader.source == "") {
                    sketchLoader.source = "Sketch.qml"
                }
            }
            onSetDesktopFocus: desktop.forceActiveFocus()

        }

        Item {
            id: focusArea
            width: grid.width - grid.irLeftMargin - grid.irRightMargin
            height: grid.height
            x: grid.irLeftMargin
            Rectangle {
                id: autoFocusRegion
                x: greenbox.system.autoFocusRegionX1
                y: greenbox.system.autoFocusRegionY1
                width: greenbox.system.autoFocusRegionX2 - greenbox.system.autoFocusRegionX1
                height: greenbox.system.autoFocusRegionY2 - greenbox.system.autoFocusRegionY1
                color: colors.transparent
                border.color: colors.underbright
                border.width: 1
                visible: greenbox.system.autoFocusActive
            }
        }

        Pip {
            id: pip
            width: grid.width - grid.irLeftMargin - grid.irRightMargin
            height: grid.height
            x: grid.irLeftMargin
        }

        StatusRow {
            id: statusRow
            visible: !greenbox.hideGuiLayer
        }

        RoundedRect {
            anchors.fill: sketchStatus
            visible:  sketchStatus.visible
        }
        Image {
            id: sketchStatus
            x: statusRow.x + statusRow.rightEdge
            anchors.top: statusRow.top
            height: grid.resultTableRowHeight
            fillMode: Image.PreserveAspectCrop

            source: greenbox.appState === GreenBox.FacetSketchView ? flirSystem.sketchStatusImage : ""
            visible: greenbox.appState === GreenBox.FacetSketchView && !pogo
        }
        MouseArea {
            id: sketchMouseArea
            anchors.fill: sketchStatus
            enabled: sketchStatus.visible
            onPressed: menus.toggleMenu()
            z: 10
        }

        MeasureTools {
            width: grid.width - grid.irLeftMargin - grid.irRightMargin
            height: grid.height
            x: grid.irLeftMargin
            visible: !greenbox.hideGuiLayer && (cameraHasStaticFocus || greenbox.system.viewMode !== System.VIEW_MODE_VISUAL)
        }

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: grid.cellHeight * 2
            text: "Service mode"
            color: colors.textFocused
            font.pixelSize: fonts.largeSize
            font.family: fonts.family
            visible: greenbox.system.serviceMode && !greenbox.hideGuiLayer
        }

		BorderImage {
        id: myBackgroundImage
		anchors.centerIn: parent
		source: "../images/Bg_DialoguePopUp_SmallBg_Def.png"
		visible: true


        Text {
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
			id: myText
			text: "This device has unsupported \nsoftware for personal learning.\n\n    Not for commercial use.\n           Not for resell.\n\n    Restore original software\n    before selling this device."
			horizontalAlignment: Text.AlignLeft
            color: colors.textFocused
			font.pixelSize: fonts.mediumSize
            font.family: fonts.family
			wrapMode: Text.WordWrap
             }
		}

		BorderImage {
        id: myCredits
		anchors.centerIn: parent
		source: "../images/Bg_DialoguePopUp_MedBg_Def.png"
		visible: false

        Text {
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
			id: myCreditsText
            text: "This camera has enhanced capabilities\n\nUnlocked and brought you by Bud \n\nFor details visit EEVBlog forum:\nhttps://www.eevblog.com/forum/\nthermal-imaging/flir-e4-wifi-resolution-\nand-menu-hack-thread\n\nRestore original software before selling.\nPress Down to continue."
			horizontalAlignment: Text.AlignLeft
            color: colors.textFocused
			font.pixelSize: fonts.smallSize
            font.family: fonts.family
			wrapMode: Text.WordWrap
            visible: true
        }

		Image {
			id: myCreditsImageWe
			anchors.horizontalCenter: parent.horizontalCenter
			y: 4
			source: "../images/we.gif"
			visible: !myCreditsText.visible
		}

		}

		Image{
            id: imagePipMove
            x: greenbox.system.pipX2-34
			y: greenbox.system.pipY1+4
 			source: pip.selectionMoveMode ? "../images/Ic_MeasureToolAdjust_Move_Sel.png" : "../images/Ic_MeasureToolAdjust_Resize_Sel.png"
			property int myX: greenbox.system.pipX2
			property int myY: greenbox.system.pipY1
			onMyXChanged: x = myX-34
			onMyYChanged: y = myY+4
			visible: pip.selected

		    Item {
				id: myVar
				property bool pipJustSelected: false
			}
        }

		Timer {
			id: timerPipSelect
			interval: 1000
			onTriggered: {
				pip.selected=true
				myVar.pipJustSelected=true
				timerPipHelp.start()
				}
		}

		Timer {
			id: timerPipHelp
			running:greenbox.system.viewMode === System.VIEW_MODE_PIP
			interval: 100
			onTriggered: {
				pipMsgShow.start()
				timerPipHelpHide.start()
				}
		}
		Timer {
			id: timerPipHelpHide
			interval: 2000
			onTriggered: {
				pipMsgHide.start()
				}
		}

		NumberAnimation {
        id: pipMsgShow
        target: imgPipControl; property: "y"; to: 4;
        duration: 1000; easing.type: Easing.OutQuad
		}

		NumberAnimation {
        id: pipMsgHide
        target: imgPipControl; property: "y"; to: -40;
        duration: 1000; easing.type: Easing.InQuad
		}

		RoundedRect {
		id: imgPipControl
		y: -40
		anchors.horizontalCenter: parent.horizontalCenter

        height: grid.resultTableRowHeight
		width: pip.selected ? 200 : 140
		visible: greenbox.system.viewMode === System.VIEW_MODE_PIP

		Text {
            id: textPipControl
            anchors.verticalCenter: parent.verticalCenter
			anchors.horizontalCenter: parent.horizontalCenter
			text: pip.selected ?  "Select:Move/Resize,  Back:Exit" : "Hold Down: Edit PIP"
			font.family: fonts.family
            font.pixelSize: fonts.smallSize
            color: colors.textFocused
        }

    }

        Image{
            id: leftBorderOfSorrow
            anchors.top: parent.top
            anchors.left: parent.left
            source: grid.irLeftMargin > 0 ? "../images/Bg_Live_NonWidescreen.png" : ""
        }

        Image{
            id: rightBorderOfSorrow
            anchors.top: parent.top
            anchors.right: parent.right
            source: grid.irRightMargin > 0 ? "../images/Bg_Live_NonWidescreen.png" : ""
        }

        LeftSide {
            id: leftSide
            visible: grid.irLeftMargin > 0

            rotation: 0
            transformOrigin: Item.TopLeft
            state: greenbox.system.tilt === 180 ? "180" : "0"

            states: [
                State {
                    name: "0"
                    PropertyChanges { target: leftSide; rotation: 0 }
                    PropertyChanges { target: leftSide; x: 0 }
                    PropertyChanges { target: leftSide; y: 0 }
                },
                State {
                    name: "180"
                    PropertyChanges { target: leftSide; rotation: 180 }
                    PropertyChanges { target: leftSide; x: grid.width}
                    PropertyChanges { target: leftSide; y: grid.height }
                }
            ]
        }

        TempScale {
            id: tempScale
        }

        Rectangle {
            visible: greenbox.hideGuiLayer
            color: colors.transparent
            width: grid.width - grid.irLeftMargin - grid.irRightMargin
            height: grid.height
            x: grid.irLeftMargin
        }

        NiceLoader {
            id: sketchLoader
            source: ""
        }

        Image {
            id: logo
            source: "../images/Sc_Logo_FlirHardEdges.png"
 			visible: false

            rotation: 0
            transformOrigin: Item.BottomLeft
            state: {
                if (greenbox.system.tilt === 0)
                    return "0"
                else if (greenbox.system.tilt === 90)
                    return "90"
                else if (greenbox.system.tilt === 180)
                    return "180"
                else
                    return "270"
            }

            states: [
                State {
                    name: "0"
                    PropertyChanges { target: logo; rotation: 0 }
                    PropertyChanges { target: logo; x: grid.leftMargin + grid.irLeftMargin + grid.horizontalSpacing }
                    PropertyChanges { target: logo; y: grid.height - grid.bottomMargin - grid.verticalSpacing - height }
                },
                State {
                    name: "90"
                    PropertyChanges { target: logo; rotation: 90 }
                    PropertyChanges { target: logo; x: grid.leftMargin + grid.irLeftMargin + grid.horizontalSpacing }
                    PropertyChanges { target: logo; y: grid.topMargin + grid.verticalSpacing - height }
                },
                State {
                    name: "180"
                    PropertyChanges { target: logo; rotation: 180 }
                    PropertyChanges { target: logo; x: grid.width - grid.leftMargin - grid.irLeftMargin - grid.horizontalSpacing }
                    PropertyChanges { target: logo; y: -height + grid.topMargin + grid.verticalSpacing }
                },
                State {
                    name: "270"
                    PropertyChanges { target: logo; rotation: 270 }
                    PropertyChanges { target: logo; x: grid.width - grid.horizontalSpacing - grid.rightMargin - grid.irRightMargin }
                    PropertyChanges { target: logo; y: grid.height - grid.bottomMargin - grid.verticalSpacing - height }
                }
            ]
        }

        Inclinometer {
            id: inclinometer
            visible: flirSystem.pitchRollAvailable
            anchors.bottom: logo.top
            anchors.bottomMargin: 10
        }

        OverlayInfoDisplay {
            id:overlay
        }

        MouseArea {
            id: scaleTouchBottom
            visible: touchBased && (greenbox.system.viewMode !== System.VIEW_MODE_VISUAL)

            width: grid.cellWidth
            height: grid.cellHeight

            onPressed: {
                if (greenbox.scale.manual)
                    greenbox.scale.manual = false
                else
                    greenbox.scale.manual = true
            }
        }
        MouseArea {
            id: scaleTouch
            visible: touchBased && (greenbox.system.viewMode !== System.VIEW_MODE_VISUAL)

            width: grid.cellWidth
            height: grid.cellHeight

            state: {
                if (greenbox.system.tilt === 0)
                    return "0"
                else if (greenbox.system.tilt === 90)
                    return "90"
                else if (greenbox.system.tilt === 180)
                    return "180"
                else
                    return "270"
            }

            onPressed: {
                if (greenbox.scale.manual)
                    greenbox.scale.manual = false
                else
                    greenbox.scale.manual = true
            }

            // Tilt states
            states: [
                State {
                    name: "0"
                    PropertyChanges { target: scaleTouch; x: grid.width - grid.rightMargin - grid.cellWidth }
                    PropertyChanges { target: scaleTouch; y: 0 }
                    PropertyChanges { target: scaleTouchBottom; x: grid.width - grid.rightMargin - grid.cellWidth}
                    PropertyChanges { target: scaleTouchBottom; y: grid.height - grid.cellHeight }
                },
                State {
                    name: "90"
                    PropertyChanges { target: scaleTouch; x: grid.width - grid.rightMargin - grid.cellWidth}
                    PropertyChanges { target: scaleTouch; y: grid.height - grid.cellHeight }
                    PropertyChanges { target: scaleTouchBottom; x: grid.irLeftMargin}
                    PropertyChanges { target: scaleTouchBottom; y: grid.height - grid.cellHeight }
                },
                State {
                    name: "180"
                    PropertyChanges { target: scaleTouch; x: grid.irLeftMargin}
                    PropertyChanges { target: scaleTouch; y: grid.height - grid.cellHeight }
                    PropertyChanges { target: scaleTouchBottom; x: grid.irLeftMargin }
                    PropertyChanges { target: scaleTouchBottom; y: 0 }
                },
                State {
                    name: "270"
                    PropertyChanges { target: scaleTouch; x: grid.irLeftMargin }
                    PropertyChanges { target: scaleTouch; y: 0 }
                    PropertyChanges { target: scaleTouchBottom; x: grid.width - grid.rightMargin - grid.cellWidth }
                    PropertyChanges { target: scaleTouchBottom; y: 0 }
                }
            ]
        }
        // Registration Wizard
        NiceLoader {
            id: registrationWizardLoader
            source: (!greenbox.system.isCameraRegistered && greenbox.system.goForCameraRegistration) ? "Wizard/Wizard.qml" : ""
            onSourceChanged: {
                if (item !== null)
                {
                    item.model = registrationWizardModel
                    item.forceActiveFocus()
                }
            }

            Connections {
                target: registrationWizardLoader.item
                onDone: {
                    registrationWizardLoader.item.reset()
                    // Strangely this neeeds to be here, look into this abit more.
                    // Stopped is set in the model when done is clicked, guess
                    // it is a timing issue
                    registrationWizardLoader.item.state = "STOPPED"
                    greenbox.system.goForCameraRegistration = false
                    greenbox.system.isCameraRegistered = true
                }
                onSkip: {
                    greenbox.system.goForCameraRegistration = false
                 }
            }
       }
    }
}
