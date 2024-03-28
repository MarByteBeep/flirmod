import QtQuick 1.1

Rectangle {
    id: viewRoot

    // External properties:
    property string     viewTitle:  textTables.tableName
    property variant    model:      textTables.labelValueList

    x: 0
    y: 0
    width: grid.width
    height: grid.height

    visible: textTables.labelValuesVisible
    color: "black"

    // Connect this signal to some slot to change FocusScope. Fix this for Qt5.
    signal focusDesktopFocusGroup

    //onFocusChanged: console.log("viewRoot " + focus)
    onVisibleChanged: {
        //console.log("viewRoot.visible " + visible)
        if (visible) {
            listView.focus = true
            listView.currentIndex = 0
        }
        else {
            focusDesktopFocusGroup()
        }
    }

    MouseArea { // Steal all mouse presses which are not on a specific item.
        anchors.fill: parent
    }

    Item {  // Header (with back button and view title).
        id: header
        width: parent.width
        height: headerColumn.height

        Column {
            id: headerColumn
            width: parent.width

            Item {  // Spacer
                width: 1
                height: grid.topMargin + grid.verticalSpacing
            }

            Row {   // Row containing the back button and view title.
                height: grid.cellHeight

                Item {  // Spacer
                    width: grid.unit*2.5
                    height: 1
                }

                Item {  // Top left arrow button
                    anchors.verticalCenter: parent.verticalCenter
                    height: arrowIcon.height
                    width: arrowIcon.width

                    ShadedRectangle {   // Background image when the button is pressed.
                        anchors.fill: arrowIcon
                        anchors.margins: 1
                        visible: arrowArea.pressed
                    }

                    Image {
                        id: arrowIcon
                        source: "../images/Ic_List_ArrowLeft_Def.png"
                    }

                    MouseArea {
                        id: arrowArea
                        anchors.fill: parent
                        onClicked: close_view()
                    }
                }

                Item {  // Spacer
                    width: grid.unit*3
                    height: 1
                }

                Text {
                    color: colors.textFocused
                    anchors.verticalCenter: parent.verticalCenter
                    text: viewRoot.viewTitle
                    font.pixelSize: fonts.smallSize
                    font.family: fonts.family
                    font.bold: true
                }
            }

            Item {  // Spacer
                width: parent.width
                height: grid.verticalSpacing

                HorizontalSeparatorLine {
                    width: parent.width
                }
            }
        }
    }

    property bool refocus1Prop: textTables.refocus  // Retake focus after closing of soft keyboard
    onRefocus1PropChanged: {
        if (textTables.labelValuesVisible)
            recoverFocusTimer.start()
    }
    Timer {
        id: recoverFocusTimer
        interval: 200
        repeat: false
        onTriggered: listView.forceActiveFocus()
    }

    ListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: grid.bottomMargin

        property int itemHeight: grid.cellHeight + grid.verticalSpacing

        clip: true
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds

        // Set the preferred highlight range so that navigating with the
        // physical keys don't go to the top or bottom of the list, unless
        // necessary.
        preferredHighlightBegin: grid.cellHeight + grid.verticalSpacing
        preferredHighlightEnd: height - grid.cellHeight - grid.verticalSpacing
        highlightRangeMode: ListView.ApplyRange

        //onFocusChanged: console.log("listView.focus: " + focus)
        // When we're changing label-value we must at the same time update the
        // popup to use the correct dictionary model.
        onCurrentItemChanged: popup.popupIndex = currentItem.dataModel.dictIndex()

        // Disable automatic highlight following, so we can control it
        // ourselves (speed it up and prevent bugs in Qt for CE - see the
        // archive for examples how Qt will not do as told).
        highlightFollowsCurrentItem: false

        model: viewRoot.model
        property int listLength: model.length

        delegate: Item {
            // We must expose the modelData (the QObject (QList<QObject*>)) to
            // the rest of the ListView, so we can get the dictionary property
            // on the object when changing objects (the dictionary property is
            // used for the popup/groupbox).
            property QtObject dataModel: modelData

            height: listView.itemHeight
            width: parent.width

            HorizontalSeparatorLine {
                id: separator
                width: parent.width
                anchors.bottom: parent.bottom
                anchors.bottomMargin: grid.verticalSpacing
                source: "../images/Bg_Options_LineGray_Def.png"
                visible: model.index !== listView.listLength - 1
            }

            Row {
                id: row
                height: parent.height

                Item {  // Spacer
                    width: grid.unit*3
                    height: 1
                }

                Text {
                    font.pixelSize: fonts.smallSize
                    font.family: fonts.family

                    text: modelData.label
                    color: colors.textFocused

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -grid.verticalSpacing

                    // The width of the first column is not exactly matched to
                    // the grid (accordingly to the UX specifications - and
                    // von Braun).
                    width: grid.cellWidth*2.5

                    elide: Text.ElideRight
                }

                Rectangle { // Vertical separator line
                    width: 1
                    height: parent.height
                    color: "#ff333333"
                }

                Item {  // Spacer
                    width: grid.unit*3
                    height: 1
                }

                Text {
                    font.pixelSize: fonts.smallSize
                    font.family: fonts.family

                    width: (grid.horizontalCellCount - 2.5) * grid.cellWidth - grid.horizontalSpacing

                    text: modelData.value
                    color: listView.currentIndex === model.index
                           ? colors.textFocused
                           : colors.textNormal

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -grid.verticalSpacing

                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    listView.currentIndex = model.index
                    dataModel.triggered()
                }
            }
        }

        highlight: BorderImage {
            x: grid.width - width - grid.unit * 3
            y: listView.currentItem.y
            height: grid.cellHeight - grid.cellHeight / 10
            width: (grid.horizontalCellCount - 2.5) * grid.cellWidth + grid.horizontalSpacing

            source: "../images/Bg_FullScreen_MarkerStretch_Foc.png"
            border { left: 10; top: 10; right: 10; bottom: 10 }
        }

        ScrollBar {
            id: scrollBar
            view: listView
        }

        ListShadow {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width - scrollBar.width   // Save some clipping calculations.
            rotation: 180

            visible: listView.visibleArea.yPosition > 0 ? true : false
        }

        ListShadow {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width - scrollBar.width   // Save some clipping calculations.

            visible: (listView.contentHeight > listView.height) &&
                     (listView.visibleArea.yPosition < 1 - listView.visibleArea.heightRatio - 0.01) ? true : false
        }
    }

    Item {
        id: popup

        property int        popupWidth: (grid.horizontalCellCount - 2.5) * grid.cellWidth + grid.horizontalSpacing
        property int        popupHeight: 0
        property int        popupX: listView.width - popupWidth - grid.unit*3
        property int        popupY: 0
        property int        popupIndex: 0   //!< The listview default index is modified with this property.

        onPopupIndexChanged: popupList.currentIndex = popupIndex

        anchors.fill: parent
        visible: textTables.popupVisible

        onVisibleChanged: {
            if (visible && !popupList.focus) {
                popupList.focus = true
            }
        }

        //onFocusChanged: console.log("popup " + focus)

        MouseArea { // Steal the entire view, so the user cannot navigate back-
                    // ground elements.
            anchors.fill: parent
            onPressed: {
                listView.focus = true
                textTables.popupVisible = false
            }
        }

        Rectangle { // The popup.
            id: popupRect
            color: "#555555"

            // Keep the same radius as the highlight ShadedRectangle item.
            radius: (grid.cellHeight - grid.verticalSpacing * 2) * 0.1

            y: parent.popupY
            x: parent.popupX

            width: parent.popupWidth
            height: parent.popupHeight

            //onFocusChanged: console.log("popup-rect.focus " + focus)

            MouseArea { // Handle mouse presses on the top and bottom borders.
                anchors.fill: parent
            }

            ListView {
                property int itemHeight: grid.iconHeight
                property int topMargin: 1       // Yep! Hardcoded values. :P
                property int bottomMargin: 1    // Yep! Here too. :P
                property int verticalMargins: topMargin + bottomMargin

                id: popupList
                anchors.fill: parent
                anchors.topMargin: topMargin
                anchors.bottomMargin: bottomMargin

                model: textTables.popupList
                onModelChanged: recalculate_popup_geometry()

                clip: true

                snapMode: ListView.SnapOneItem
                boundsBehavior: Flickable.StopAtBounds

                // Disable automatic highlight following, so we can control it
                // ourselves (speed it up and prevent bugs in Qt for CE - see the
                // archive for examples how Qt will not do as told).
                highlightFollowsCurrentItem: false

                //onFocusChanged: console.log("popupList " + focus)

                delegate: Item {
                    property QtObject dataModel: modelData

                    height: popupList.itemHeight
                    width: parent.width

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width

                        Item {
                            id: leftRow
                            width: grid.unit*3
                            height: 1
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.label
                            color: colors.textFocused
                            font.pixelSize: fonts.smallSize
                            font.family: fonts.family

                            elide: Text.ElideRight

                            width: parent.width - (leftRow.width + rightRow.width)
                        }

                        Row {
                            id: rightRow
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: modelData.keyboardEntry
                                source: modelData.keyboardEntry
                                        ? "../images/Ic_Annotation_TextTableKb_Sel.png"
                                        : ""
                            }

                            Item {
                                width: grid.unit*3
                                height: 1
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            popup.popupIndex = model.index
                            modelData.itemSelected(model.index);

                            listView.focus = true
                            textTables.popupVisible = false

                            listView.incrementCurrentIndex()
                        }
                    }
                }

                highlight: Item {
                    y: popupList.currentItem !== null
                       ? popupList.currentItem.y
                       : 0
                    height: grid.iconHeight
                    width: popupList.width

                    ShadedRectangle {
                        anchors.fill: parent
                        anchors.leftMargin: grid.leftMargin
                        anchors.rightMargin: grid.rightMargin
                    }
                }

                ListShadow {
                    color: popupRect.color
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    rotation: 180
                    radius: parent.itemHeight * 0.1
                    height: parent.itemHeight * 0.75

                    visible: popupList.visibleArea.yPosition > 0 ? true : false
                }

                ListShadow {
                    color: popupRect.color
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    radius: parent.itemHeight * 0.1
                    height: parent.itemHeight * 0.75

                    visible: (popupList.contentHeight > popupList.height) &&
                             (popupList.visibleArea.yPosition < 1 - popupList.visibleArea.heightRatio - 0.01) ? true : false
                }

                ScrollBar {
                    id: popupScrollBar
                    view: popupList
                    background: false
                    anchors.rightMargin: grid.rightMargin
                }
            }
        }
    }

    // Steal all keyboard presses.
    Keys.onPressed: event.accepted = true

    Keys.onReleased: {
        event.accepted = true
        if (event.key === keys.select) {
            // Handle the rearangement of the popup depending on the current item's position and its content height.
            if ( ! textTables.popupVisible) {
                listView.currentItem.dataModel.triggered()
            } else {                                                                    // Handle presses from the popup.
                popupList.currentItem.dataModel.itemSelected(popupList.currentIndex)
                popup.popupIndex = popupList.currentIndex

                listView.focus = true
                textTables.popupVisible = false

                listView.incrementCurrentIndex()
            }
        }
        else if (event.key === keys.back) {
            if (textTables.popupVisible) {
                listView.focus = true
                textTables.popupVisible = false
            } else {
                close_view()
            }
        }
        else if (event.key === keys.camera)
        {
            if (flirSystem.lampActive)
                flirSystem.lampActive = false
            else
                flirSystem.lampActive = true
        }
        else if (event.key === keys.trigger)
        {
            textTables.storeValuesDirectly()
        }
    }

    // We should make this a generic popup geometry handler by giving it a
    // couple of reference parameters.
    //
    // (We'll keep it specialized for now though)
    function recalculate_popup_geometry() {
        if ( ! listView.currentItem)
            return

        var y_in_view = listView.currentItem.y - listView.contentY

        var y = y_in_view + listView.y + grid.verticalSpacing
        var height = 0

        var lower_height = listView.height - y_in_view
        var upper_height = (y_in_view + grid.cellHeight)

        var margins = popupList.topMargin + popupList.bottomMargin

        if (lower_height > upper_height) {                                              // Popup should go from top to bottom.
            if ((y_in_view + popupList.contentHeight + margins) < listView.height) {    // All contents fit the current view.
                height = popupList.contentHeight + margins
            } else {                                                                    // Not all contents fit the current view, so we'll resize the popup and then properly align it to the list item height.
                var max_height = listView.y + listView.height - y - (grid.verticalSpacing * 2)
                var floored = Math.floor(max_height / popupList.itemHeight)
                var corrected = floored * popupList.itemHeight + popupList.verticalMargins

                height = corrected
            }
        } else {                                                                        // Popup should go from bottom to top.
            var upper_max_height = y_in_view + popupList.itemHeight

            if (upper_max_height > popupList.contentHeight) {                           // All contents fit in the current view.
                height = popupList.contentHeight + popupList.verticalMargins
            } else {                                                                    // Not all contents fit the current view, so we'll resize the popup and then properly align it to the list item height.
                var a = upper_max_height - margins
                var b = Math.floor(a / popupList.itemHeight)
                var c = b * popupList.itemHeight + popupList.verticalMargins
                height = c
            }

            if (height + y_in_view > listView.height)                                   // Check if we need to change the popup's y, in case it's higher than the available space from y to the list view bottom.
                y = y - height + popupList.itemHeight - popupList.bottomMargin
        }

        popup.popupY = y
        popup.popupHeight = height

        popupList.focus = true
    }

    function close_view() {
        textTables.storeValues()
    }
}
