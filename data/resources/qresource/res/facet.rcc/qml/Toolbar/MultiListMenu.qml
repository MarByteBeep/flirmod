import QtQuick 1.1

/**
 *  This QML file is the delegate for the C++ class MultiListMenuItem.
 */

FocusScope {
    width: multiListMenu.model === null?  grid.cellWidth * 5 : multiListMenu.model.cellsHorizontal * grid.cellWidth
    height: grid.spinlistHeight
    id: multiListMenu
    property QtObject model: null
    property bool cancelExit: false
    property bool closing: false

    onVisibleChanged: if (visible) { cancelExit = false; closing = false; }
    function close()
    {
        if (!closing)
        {
            closing = true
            if (cancelExit)
                multiListMenu.model.close()
            else
                multiListMenu.model.acceptChanges()
        }
    }

    MouseArea {
        anchors.fill: parent
        // Catch and ignore all mouse clicks in dialog not handled  specifically
    }

    BorderImage {
        anchors.fill: parent
        border { left: 10; top: 10; right: 10; bottom: 10 }
        source: "../../images/Bg_MenuMiniWidget_Def.png"

        // Header
        Text {
            id: headerText
            anchors.top: parent.top
            anchors.topMargin: 3*grid.verticalSpacing
            anchors.left: parent.left
            anchors.leftMargin: 4*grid.horizontalSpacing
            font.pixelSize: fonts.smallSize
            font.family: fonts.family
            color: colors.white
            text: multiListMenu.model === null ? "" : multiListMenu.model.headerText + translation.update
        }

        // Blue line
        BorderImage {
            id: toplineImage
            source: "../../images/Bg_DialoguePopUp_Line_Def.png"
            border { left: 50; top: 0; right: 50; bottom: 0 }
            anchors.left: parent.left
            anchors.leftMargin: grid.horizontalSpacing
            anchors.right: parent.right
            anchors.rightMargin: grid.horizontalSpacing
            anchors.top: headerText.bottom
            anchors.topMargin: 3*grid.verticalSpacing
        }

        // Row of lists
        Row {
            id: listRowId
            anchors.top: toplineImage.bottom
            anchors.bottom: bottomlineImage.top
            anchors.left: parent.left
            anchors.right: parent.right

            Repeater {
                id: lists
                model: multiListMenu.model === null ? null : multiListMenu.model.valueLists
                height: parent.height

                Item{
                    width: multiListMenu.width / multiListMenu.model.logicalColumns * (1 + modelData.rightSpacing)
                    height: listRowId.height

                    ValueSelectorListColumn {
                        id: valueList
                        model: modelData.valueList
                        enabled: modelData.enabled
                        onActivated: {
                            // acceptChanges() is called by closing!
                            multiListMenu.model.closeWholeMenu()
                        }
                        width: multiListMenu.width / multiListMenu.model.logicalColumns
                        height: parent.height
                        focus: multiListMenu.model.selectedColumn === modelData.column
                        showScrollArrows: multiListMenu.model.selectedColumn === modelData.column
                        Keys.onRightPressed: multiListMenu.model.navigateRight()
                        Keys.onLeftPressed: multiListMenu.model.navigateLeft()
                        currentIndex: modelData.selectedIndex
                        onCurrentIndexChanged: {
                            modelData.selectedIndex = currentIndex
                        }

                        onActiveFocusChanged: {
                            if (focus)
                                multiListMenu.model.selectedColumn = modelData.column
                        }
                    }

                    Text {
                        anchors.left: valueList.right
                        text: modelData.rightDelimiter
                        visible: modelData.rightDelimiter !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        font.pixelSize: fonts.smallSize
                        font.family: fonts.family
                        color: colors.textNormal
                    }
                }
            }
        }


        // Blue line
        BorderImage {
            id: bottomlineImage
            source: "../../images/Bg_DialoguePopUp_Line_Def.png"
            border { left: 50; top: 0; right: 50; bottom: 0 }
            anchors.left: parent.left
            anchors.leftMargin: grid.horizontalSpacing
            anchors.right: parent.right
            anchors.rightMargin: grid.horizontalSpacing
            anchors.bottom: footerText.top
            anchors.bottomMargin: 2*grid.verticalSpacing
        }

        // Footer
        Text {
            id: footerText
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3*grid.verticalSpacing
            anchors.left: parent.left
            anchors.leftMargin: 4*grid.horizontalSpacing
            font.pixelSize: fonts.smallSize
            font.family: fonts.family
            color: multiListMenu.model === null || multiListMenu.model.selectionValid ? colors.grey : colors.alarmRed
            text: multiListMenu.model === null ? "" : multiListMenu.model.footerText + translation.update
        }
    }

    Keys.onReleased: {
        event.accepted = false;
        if (event.key === keys.back) {
            cancelExit = true
            multiListMenu.visible = false
            event.accepted = true
        }
        else if (event.key === keys.up) {
            event.accepted = true
        }
        else if (event.key === keys.select) {
            console.log("select pressed")
            multiListMenu.visible = false
            event.accepted = true
        }
    }

    Keys.onUpPressed: ; // eat those events
    Keys.onDownPressed: ; // eat those events
    Keys.onLeftPressed: ; // eat those events
    Keys.onRightPressed: ; // eat those events
}
