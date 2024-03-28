import QtQuick 1.1
import se.flir 1.0
import ".."

Item {
    id: root
    property alias model: list.model
    property bool isRootLevelToolbar: false
    property alias hasPopupOpen: row.hasPopupOpen
    property int numWidth: 1
    height: grid.cellHeight
    Component.onCompleted: menus.setupTouch(grid.cellWidth + grid.horizontalSpacing, grid.cellHeight, grid.horizontalCellCount) // Setup touch area

    function updateSubItemXPos(menuItem)
    {
        var subItemX
        var leftBound
        var rightBound

        // center on top of the current item
        subItemX = menuItem.x + (menuItem.width - subItem.item.width)/2;
        // fit within the screen
        leftBound = -toolbarBackground.x + grid.leftMargin + grid.horizontalSpacing
        rightBound = grid.width - toolbarBackground.x - grid.rightMargin - grid.horizontalSpacing - subItem.width
        if (subItemX < leftBound) {
            // align with the left edge
            subItemX = leftBound;
        }
        else if (subItemX > rightBound) {
            // align with the right edge
            subItemX = rightBound;
        }
        subItem.item.x = subItemX
    }

    function execute(modelData, menuItem) {
        if (modelData.enabled) {
            modelData.activate();
            if (modelData.targetQmlFile !== "") {
                // open a QML popup, and position it.
                subItem.source = modelData.targetQmlFile
                subItem.returnMenuItem = menuItem
                if (subItem.item !== undefined) {
                    row.hasPopupOpen = true
                    subItem.item.model = modelData
                    subItem.item.y = -subItem.item.height - 3 + (menuItem.y > 0 ? grid.cellHeight : 0)
                    updateSubItemXPos(menuItem)
                    subItem.item.forceActiveFocus()
                }
            }
        }
    }

    // The toolbar
    BorderImage {
        property bool isRootEditMenu: isRootLevelToolbar &&
                                      (menus.activeMenu === Menus.EditMenu || menus.activeMenu === Menus.SketchingMenu)
        border {
            left: 5 + (isRootEditMenu ? grid.cellWidth : 0)
            right: 5 + (isRootEditMenu ? grid.cellWidth : 0)
            top: 10
            bottom: 10
        }
        source: toolbarSeparators ? ("../../images/Bg_MenuHorizontalMain_Bar_0" + numWidth + "_Def.png") :
                                    "../../images/Bg_MenuHorizontalMain_Bar_" + (isRootEditMenu ? "01_Edit_" : "") +  "Def.png"

        id: toolbarBackground
        width: row.width
        height: row.height
        y: root.height - row.height
        x: root.isRootLevelToolbar ? (root.width - width) / 2 : calculateChildX()

        function calculateChildX()
        {
            var hSpace = touchBased ? 0 : grid.horizontalSpacing
            var cellWidth = grid.cellWidth + hSpace;
            var level1Width = cellWidth * menus.menuLevel1.length - hSpace
            if (level1Width <= 0)
                return 0;
            var level1ToolBarXPos = (root.width - level1Width) / 2
            // start centered over the level1 toolbar item that is selected.
            var desiredX = cellWidth * (menus.selectedLevel1Menu + 0.5) - row.width / 2;

            // align to grid.
            desiredX -= desiredX % cellWidth;
            desiredX += level1ToolBarXPos; // add this after aligning to grid.

            if (row.width > level1Width) {  // wider than parent
                desiredX = level1ToolBarXPos;
                while (desiredX + row.width > grid.width)
                {
                    desiredX -= cellWidth;
                }
                if (desiredX < (root.x + grid.horizontalSpacing))
                    desiredX = root.x + grid.horizontalSpacing
            }
            else if (desiredX + row.width > level1Width + level1ToolBarXPos) { // right align with parent toolbar
                desiredX = level1Width + level1ToolBarXPos - row.width
            }
            else if (desiredX < level1ToolBarXPos) { // left align with parent toolbar
                desiredX = level1ToolBarXPos;
            }
            return desiredX
        }

        // Toolbar items
        Flow {
            id: row
            property bool hasPopupOpen: false
            anchors.horizontalCenter: parent.horizontalCenter
            width: !touchBased ? Math.min(root.width, Math.min(numWidth, grid.horizontalCellCount) * (grid.cellWidth + grid.horizontalSpacing)) - grid.horizontalSpacing :
                                  Math.min(root.width, Math.min(numWidth, grid.horizontalCellCount) * grid.cellWidth)
            spacing: !touchBased ? grid.horizontalSpacing : 0

            Repeater {
                id: list

                // Toolbar item
                Item {
                    width: grid.cellWidth
                    height: grid.cellHeight
                    id: menuItem
                    objectName: modelData.objectName + "QmlObject"
                    property bool isCurrent: mouseArea.pressed ? menus.currentTouchItem === modelData :
                                             !touchBased ? menus.currentItem === modelData :
                                             (!root.isRootLevelToolbar && menus.currentItem === modelData)

                    focus: isCurrent
                    onXChanged: if (isCurrent) tooltip.parentX = x  // triggered when entering toolbar
                    onIsCurrentChanged: {                           // triggered when stepping in toolbar
                        if (isCurrent)
                        {
                            tooltip.parentX = x
                            tooltip.parentY = y
                            tooltip.lable = modelData.tooltip
                            tooltip.value = modelData.toolValue
                        }
                    }
                    property string forcedTooltip: menus.forceTooltipUpdate
                    onForcedTooltipChanged: {                       // triggered when current item has its tooltip changed (functionality toggled)
                        if (isCurrent)
                        {
                            tooltip.lable = modelData.tooltip
                            tooltip.value = modelData.toolValue
                        }
                    }

                    property bool openSubProperty: modelData.openSub
                    onOpenSubPropertyChanged: if (menus.currentItem === modelData) root.execute(modelData, menuItem)

                    // Highlight
                    Image {
                        id: highLight
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: grid.toolbarItemVOffset
                        visible: menuItem.isCurrent || (root.isRootLevelToolbar && menus.selectedLevel1Menu === index) ||
                                 (!root.isRootLevelToolbar && menus.currentItem === modelData)
                        source: (!mouseArea.pressed && (row.hasPopupOpen || (root.isRootLevelToolbar && menus.selectedLevel1Menu !== -1))) ?
                                    "../../images/Bg_MenuHorizontalMain_Marker_Sel.png" :
                                    (!touchBased || !root.isRootLevelToolbar) && !mouseArea.pressed ? "../../images/Bg_MenuHorizontalMain_Marker_Foc.png" : ""
                    }

                    // The main icon
                    Image {
                        id: icon
                        objectName: modelData.icon + "QmlObject"
                        source: visible ? ("../../images/" + modelData.icon +
                                (mouseArea.pressed && modelData.enabled && menuItem.isCurrent ?
                                     "_Down.png" : (menuItem.isCurrent ?  "_Sel.png" : "_Def.png"))) : ""
                        anchors.centerIn: parent
                        opacity: modelData.enabled ? 1 : 0.3
                    }

                    // Checked icon
                    Image {
                        id: checkedOverlay
                        anchors.top: parent.top
                        anchors.right: parent.right
                        visible: modelData.showCheckIndicator
                        source: "../../images/Bg_MenuHorizontalMain_RadioButton" + (modelData.checked ? "On" : "Off") + "_Def.png"
                    } 
                }

                onItemAdded: if (item.isCurrent) item.forceActiveFocus()
                onItemRemoved: root.focus = false
            }
        }

        // Key handling
        Keys.onPressed: {
            event.accepted = false
            if (event.key === keys.up) {
                if (!archiveHandler.model.multiSelectMode) {
                    if (menus.navigateUp() === true)
                        event.accepted = true
                    else if (menus.currentItem.targetQmlFile !== "")
                    {
                        // open the item, as if OK was pressed
                        menus.executeCurrentItem()
                        event.accepted = true
                    }
                }
            }
        }
        Keys.onReleased: {
            event.accepted = false
            if (event.key === keys.select) {
                menus.executeCurrentItem()
                event.accepted = true
            }
        }

        // Tooltip
        RoundedRect {
            id: tooltip
            visible: menus.menuOpen && (!row.hasPopupOpen || (mouseArea.pressed && menus.touchValid)) &&
                        (((!touchBased || (mouseArea.pressed && menus.touchValid)) && root.isRootLevelToolbar && menus.selectedLevel1Menu === -1) ||
                         (!root.isRootLevelToolbar && menus.selectedLevel1Menu !== -1))
            width:  tooltipLable.width + tooltipValue.width + grid.horizontalSpacing * 3 + (value === "" ? 0 : grid.unit)
            height: tooltipLable.height + grid.verticalSpacing
            y: - grid.verticalSpacing - height + parentY
            property alias lable: tooltipLable.text
            property alias value: tooltipValue.text
            property int parentX: 0
            property int parentY: 0
            onWidthChanged: calculateX()
            onParentXChanged: calculateX()

            function calculateX()
            {
                var wantedX = parentX + (grid.cellWidth - width) / 2
                if (wantedX < grid.leftMargin + grid.horizontalSpacing - toolbarBackground.x)
                    wantedX = grid.leftMargin + grid.horizontalSpacing - toolbarBackground.x
                else if (wantedX > grid.width - toolbarBackground.x - width - grid.rightMargin - grid.horizontalSpacing)
                    wantedX = grid.width - toolbarBackground.x - width - grid.rightMargin - grid.horizontalSpacing
                if (wantedX !== x)
                    x = wantedX

                //align to pixels or the rotated text will look bad. kind of a HACK!
                // map to this item...
                var mappedTip = mapFromItem(tooltipLable, tooltipLable.x, tooltipLable.y)
                // ..and then to root
                var tf = mapToItem(null, mappedTip.x, mappedTip.y)
                // Check for misalignment there
                if (Math.floor(tf.x) !== tf.x) {
                    x = x +0.5
//                    console.log("changed X")
                }
//                console.log("("+x+","+y+") -> ("+tf.x+","+tf.y+")");
            }

            Row {       // We need Row element to support Arabic
                spacing: grid.unit
                anchors.fill: parent
                anchors.leftMargin: 1.5 * grid.horizontalSpacing
                anchors.rightMargin: 1.5 * grid.horizontalSpacing
                layoutDirection: translation.layoutDirection
                Text {
                    id:                  tooltipLable
                    text:                ""
                    anchors.top:         parent.top
                    anchors.topMargin:   grid.tooltipVOffset
                    font.family:         fonts.family
                    font.pixelSize:      fonts.smallSize
                    color:               colors.white
                }
                Text {
                    id:                  tooltipValue
                    text:                ""
                    visible:             text !== ""
                    anchors.top:         parent.top
                    anchors.topMargin:   grid.tooltipVOffset
                    font.family:         fonts.family
                    font.pixelSize:      fonts.smallSize
                    color:               colors.textNormal
                }
            }
        }

        // Popup loader
        NiceLoader {
            id: subItem
            property Item returnMenuItem: null
        }

        // Popup connections
        Connections {
            target: subItem.item
            onVisibleChanged: {         // 'back' is pressed
                if (subItem.item.visible)
                    return
                subItem.item.close()
                subItem.source = ""
                row.hasPopupOpen = false
                if (subItem.returnMenuItem === null)
                    list.forceActiveFocus()
                else
                    subItem.returnMenuItem.forceActiveFocus()
            }
        }

        // Menu connections
        Connections {
            target: menus
            onMenuClosing: {            // The entire menu is closed (by tapping outside)
                row.hasPopupOpen = false
                if (subItem.item !== null)
                {
                    subItem.item.close()
                    subItem.source = ""
                }
            }
            onCurrentItemChanged: {
                // Close popup
                row.hasPopupOpen = false
                if (subItem.item !== null)
                {
                    subItem.item.close()
                    subItem.source = ""
                }
            }
        }
    }

    // Mouse handling
    MouseArea {
        id: mouseArea
        anchors.fill: toolbarBackground
        enabled: menus.menuOpen
        onExited: if (pressed) menus.touchOnExited(mouseY, isRootLevelToolbar)
        onMouseXChanged: menus.touchXChanged(mouseX, mouseY)
        onPressed: {
            menus.touchPressed(mouseX, mouseY, isRootLevelToolbar)
            if(subItem.item !== null)
            {
                subItem.item.close()
                subItem.source = ""
            }
        }
        onReleased: if (mouseY >= 0) menus.touchReleased()
    }

    // Save button timer
    Timer {
        id: halfPressTriggerTimer
        interval: 100
        onTriggered: {
            greenbox.system.doOneShotAutoFocus()
        }
    }

    // Key handling
    Keys.onPressed: {
        // console.debug(">> ToolBar.menuItem.Keys.onPressed(" + event.key + ")")
        event.accepted = false;
        if (event.key === keys.onOff)
        {
            greenbox.system.key_down(GreenBox.UI_KEY_ONOFF,event.isAutoRepeat === true?1:0)
            event.accepted = true
        }
        else if (event.key === keys.trigger)
        {
            if (halfPressTriggerTimer.running)
                halfPressTriggerTimer.stop()
            event.accepted = true
        }
        else if (event.key === keys.camera)
        {
            if (flirSystem.lampActive)
                flirSystem.lampActive = false
            else
                flirSystem.lampActive = true
            event.accepted = true
        }
        else if (event.key === keys.zoom)
        {
            greenbox.system.nextZoom()
            event.accepted = true
        }
        else if (event.key === keys.program)
        {
            greenbox.system.key_down(GreenBox.UI_KEY_PROGRAM,event.isAutoRepeat === true?1:0)
            event.accepted = true
        }
        else if (event.key === keys.trigger_half)
        {
            if (greenbox.appState === GreenBox.FacetLiveView ||
                greenbox.appState === GreenBox.FacetMediaControlState ||
                greenbox.appState === GreenBox.FacetPresetsView)
            {
                halfPressTriggerTimer.start()
            }
            event.accepted = true
        }
        else if (event.key === keys.focusIn)
        {
            if (event.isAutoRepeat === false)
                greenbox.system.setFocusSpeed(-40)
            event.accepted = true
        }
        else if (event.key === keys.focusOut)
        {
            if (event.isAutoRepeat === false)
                greenbox.system.setFocusSpeed(40)
            event.accepted = true
        }
        else if (event.key === keys.down) {
            if (!archiveHandler.model.multiSelectMode)
                event.accepted = menus.navigateDown()
        }
        else if (event.key === keys.left)
            event.accepted = menus.navigateLeft()
        else if (event.key === keys.right)
            event.accepted = menus.navigateRight()
    }

    Keys.onReleased: {
        event.accepted = false;
        if (event.key === keys.back)
        {
            if(archiveHandler.model.multiSelectMode)
            {
                archiveHandler.model.cancelMultiSelect()
            }
            else
            {
                menus.navigateCancel()
            }
            event.accepted = true

        }
        else if (event.key === keys.archive || event.key === keys.trigger)
        {
            if(archiveHandler.model.multiSelectMode)
            {
                archiveHandler.model.cancelMultiSelect()
            }
            else if (menus.hasCancelCheck)
            {
                menus.navigateCancel()
            }
            else
            {
                menus.triggerPressed()
                menus.closeMenu()
            }
            event.accepted = true
        }
        else if (event.key === keys.onOff)
        {
            menus.closeMenu()
            greenbox.system.key_up(GreenBox.UI_KEY_ONOFF,event.isAutoRepeat === true?1:0)
            event.accepted = true
        }
        else if (event.key === keys.program)
        {
            greenbox.system.key_up(GreenBox.UI_KEY_PROGRAM,event.isAutoRepeat === true?1:0)
            event.accepted = true
        }
        else if (event.key === keys.focusIn)
        {
            if (event.isAutoRepeat === false)
                greenbox.system.setFocusSpeed(0)
            event.accepted = true
        }
        else if (event.key === keys.focusOut)
        {
            if (event.isAutoRepeat === false)
                greenbox.system.setFocusSpeed(0)
            event.accepted = true
        }
    }
}
