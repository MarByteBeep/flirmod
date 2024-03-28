import QtQuick 1.1

Rectangle {
    id: templatesRoot

    // External properties:
    property string     viewTitle:  qsTrId("ID_ARCHIVE_TABLE_SELECT_DEFAULT_TEMPLATE") + translation.update
    property variant    model:      textTables.templateList

    x: 0
    y: 0
    width: grid.width
    height: grid.height

    visible: textTables.templatesVisible
    color: "black"

    // Connect this signal to some slot to change FocusScope. Fix this for Qt5.
    signal focusDesktopFocusGroup

    //onFocusChanged: console.log("templatesRoot " + focus)
    onVisibleChanged: {
        //console.log("templatesRoot.visible " + visible)
        if (visible)
            listView.focus = true
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
                        onClicked: {
                            close_view()
                        }
                    }
                }

                Item {  // Spacer
                    width: grid.unit*3
                    height: 1
                }

                Text {
                    color: colors.textFocused
                    anchors.verticalCenter: parent.verticalCenter
                    text: templatesRoot.viewTitle
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

    ListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: header.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: grid.bottomMargin

        clip: true
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds

        //onFocusChanged: console.log("listView.focus: " + focus)

        // Disable automatic highlight following, so we can controll it
        // ourselves (speed it up and prevent bugs in Qt for CE - see the
        // archive for examples how Qt will not do as told).
        highlightFollowsCurrentItem: false

        // Set the preferred highlight range so that navigating with the
        // physical keys don't go to the top or bottom of the list, unless
        // necessary.
        preferredHighlightBegin: grid.cellHeight + grid.verticalSpacing
        preferredHighlightEnd: height - grid.cellHeight - grid.verticalSpacing
        highlightRangeMode: ListView.ApplyRange

        model: templatesRoot.model

        delegate: Item {
            height: grid.cellHeight + grid.verticalSpacing
            width: parent.width

            // Expose the model item to the rest of the QML so we can use it for
            // selecting a certain item with the keyboard.
            property QtObject dataModel: modelData

            property bool isCurrentItem: listView.currentIndex === model.index
            property bool isChecked: textTables.selectedTemplate === modelData

            property int itemWidth: width

            Row {
                id: row
                height: parent.height

                Row {
                    id: iconRow
                    height: parent.height

                    Item {  // Spacer
                        width: grid.unit*3
                        height: 1
                    }

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../images/Ic_Annotation_TextTableTemplateDefault_" + (isCurrentItem ? "Sel" : "Def") + ".png"
                    }

                    Item {  // Spacer
                        width: grid.horizontalSpacing * 2
                        height: 1
                    }
                }

                Text {
                    font.pixelSize: fonts.smallSize
                    font.family: fonts.family

                    text: modelData.label
                    color: isCurrentItem ? colors.textFocused : colors.textNormal

                    anchors.verticalCenter: parent.verticalCenter

                    elide: Text.ElideRight

                    // Try to size the text field to fill the available space.
                    width: itemWidth - (iconRow.width + radioItem.width)
                }

                Row {
                    id: radioItem
                    height: parent.height

                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../images/Ic_ListChoice_RadioButton" + (isChecked ? "Checked" : "") + "_Def.png"
                    }

                    Item {  // Spacer
                        width: grid.unit*3
                        height: 1
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    textTables.selectedTemplate = modelData
                    listView.currentIndex = model.index
                    close_view()
                }
            }
        }

        highlight: Item {
            y: listView.currentItem.y
            height: grid.cellHeight + grid.verticalSpacing
            width: listView.width

            ShadedRectangle {
                anchors.fill: parent
                anchors.leftMargin: grid.unit*3
                anchors.rightMargin: grid.unit*3
                anchors.topMargin: grid.verticalSpacing
                anchors.bottomMargin: grid.verticalSpacing
            }
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

    // Steal all keyboard presses.
    Keys.onPressed: event.accepted = true

    Keys.onReleased: {
        event.accepted = true
        if (event.key === keys.select) {
            textTables.selectedTemplate = listView.currentItem.dataModel
        }
        else if (event.key === keys.back) {
            close_view()
        }
        else if (event.key === keys.camera)
        {
            if (flirSystem.lampActive)
                flirSystem.lampActive = false
            else
                flirSystem.lampActive = true
        }
    }

    function close_view() {
        textTables.templatesVisible = false
        focusDesktopFocusGroup()
    }
}
