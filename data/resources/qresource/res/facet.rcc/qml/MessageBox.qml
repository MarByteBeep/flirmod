import QtQuick 1.1

/**
 MessageBox
 A modal message box, with buttons.

 The message box has two sizes, and depending on content (main-text length essentially)
 it will choose the preferred size.

 Another feature is that you can choose which buttons to show; there are up to 3.
   * okButton which is always left. (Maybe should be renamed to leftButton).
     See property okButtontext, okButtonVisible and the signal okSelected()

   * midButton which is default invisible.
     See property midButtontext, midButtonVisible and the signal midSelected()

   * cancelButton which is always right-most (maybe should be renamed to rightButton)
     see property cancelButtontext, cancelButtonVisible and the signal cancelSelected()

 Another feature is how to present text:
   * Set text property to present the text as one left aligned box. This is default.

   * Set the table model to present the text as a table with two columns (left and right aligned.)
     This is done e.g. in archive info dialog.
 */


Item {
    id: messageBoxRoot

    // Own properties
    property alias title: titleItem.text
    property alias text: textBoxItem.text

    // @todo clean-up these backward-compatibility props
    property alias okButtontext: okButton.text
    property alias midButtontext: midButton.text
    property alias cancelButtontext: cancelButton.text

    property bool  okButtonVisible:     true
    property alias okButtonEnabled:     okButton.enabled
    property alias okButtonText:        okButton.text
    property alias okButtonFocused:     okButton.focused

    property bool  cancelButtonVisible: true
    property alias cancelButtonEnabled: cancelButton.enabled
    property alias cancelButtonText:    cancelButton.text
    property alias cancelButtonFocused: cancelButton.focused

    property bool  midButtonVisible:    false
    property alias midButtonEnabled:    midButton.enabled
    property alias midButtonText:       midButton.text
    property alias midButtonFocused:    midButton.focused

    property bool hasButtons: true

    property alias tableModel: textTableItem.model
    property bool acceptKeyRelease : false
    property bool liveBackground: false
    property string backgroundImage

    // not settable properties.
    property bool tableMode: (tableModel === null || tableModel === undefined) ? false : true
    property int numberOfButtons : (midButtonVisible ? 1 : 0) + (okButtonVisible ? 1 : 0) + (cancelButtonVisible ? 1 : 0)

    // Property values
    width: grid.width
    height: grid.height
    opacity: 0
    state: "small"

    // Signals
    signal okSelected
    signal cancelSelected
    signal midSelected

    // Pseudo icon enum
    property string iconStyle: iconEnum.warning
    property alias iconEnum: iconEnum
    QtObject {
        id: iconEnum
        property string warning:  "../images/Ic_GlobalDialogue_Warning_Sel.png"
        property string info:     "../images/Ic_GlobalDialogue_Info_Sel.png"
        property string question: "../images/Ic_GlobalDialogue_Questionmark_Sel.png"
        property string error:    "../images/Ic_GlobalDialogue_Error_Sel.png"
    }

    // Big or small state
    states: [
        State {
            name: "small"
            PropertyChanges { target: messageBox; width: grid.messageBoxWidth }
            PropertyChanges { target: messageBox; height: grid.messageBoxHeight }
        },
        State {
            name: "big"
            PropertyChanges { target: messageBox; width: grid.messageBoxBigWidth }
            PropertyChanges { target: messageBox; height: grid.messageBoxBigHeight }
        }
    ]

    onTableModeChanged: {
        if (tableMode || titleItem.lineCount >= 2 || textBoxItem.lineCount >= 3 || backgroundImage !== "")
            messageBoxRoot.state = "big"
        else
            messageBoxRoot.state = "small"
    }
    onTextChanged: {
        if (tableMode || titleItem.lineCount >= 2 || textBoxItem.lineCount >= 3 || backgroundImage !== "")
            messageBoxRoot.state = "big"
        else
            messageBoxRoot.state = "small"
    }
    onTitleChanged: {
        if (tableMode || titleItem.lineCount >= 2 || textBoxItem.lineCount >= 3 || backgroundImage !== "")
            messageBoxRoot.state = "big"
        else
            messageBoxRoot.state = "small"
    }
    onBackgroundImageChanged: {
        if (tableMode || titleItem.lineCount >= 2 || textBoxItem.lineCount >= 3 || backgroundImage !== "")
            messageBoxRoot.state = "big"
        else
            messageBoxRoot.state = "small"
    }

    // Show and hide functions

    function show() {
        opacity = 1
        forceActiveFocus()
    }

    function hide() {
        opacity = 0
        focus = false
        acceptKeyRelease = false
    }

    // Cancel dialog
    MouseArea {
        anchors.fill: parent
        onClicked: cancelSelected()
    }

    // Semi-transparent background
    Rectangle{
       id: shadow
       visible: !liveBackground
       anchors.fill: parent
       color: "#A0000000"
    }

    // The message box
    BorderImage {
        id: messageBoxImage
        border { left: 12; top: 12; right: 12; bottom: 12 }
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        source: liveBackground ? "../images/Bg_DialoguePopUp_GeneralHardEdges_Def.png" : "../images/Bg_DialoguePopUp_General_Def.png"

        // Make /messageBox/ fit exactly within the visual black rectangle (the messageBoxImage images have transparent margins of different size)
        width: messageBox.width + 12
        height: messageBox.height + (liveBackground ? 12 : 13)

        Item {
            id: messageBox
            // Make /messageBox/ fit exactly within the visual black rectangle (the images have transparent margins of different size)
            x: 6
            y: liveBackground ? 6 : 7

            Row {   // We need a row element for Arabic
                id: rowId
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: grid.horizontalSpacing
                anchors.right: parent.right
                anchors.rightMargin: grid.horizontalSpacing
                height: Math.max(titleItem.height, grid.messageBoxHeader)
                spacing: grid.horizontalSpacing * 2
                layoutDirection: translation.layoutDirection
                property alias lineCount: titleItem.lineCount

                // The icon
                Image {
                    id: icon
                    anchors.verticalCenter: titleItem.verticalCenter
                    source: iconStyle
                    mirror: translation.layoutDirection === Qt.RightToLeft
                }

                // The title text
                Text {
                    id: titleItem
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: grid.messageBoxHeader > titleItem.height ? 0 : grid.verticalSpacing * 3
                    width: parent.width - icon.width - grid.horizontalSpacing * 4
                    font.family: fonts.family
                    font.pixelSize: fonts.smallSize
                    font.bold: true
                    color: colors.textFocused
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                }
            }

            // The blue line
            BorderImage {
                id: blueLine
                anchors.top: rowId.bottom
                anchors.topMargin: grid.messageBoxHeader > titleItem.height ? 0 : rowId.lineCount === 1 ? grid.verticalSpacing * 5 : grid.verticalSpacing * 4
                anchors.left: parent.left
                anchors.leftMargin: grid.horizontalSpacing
                anchors.right: parent.right
                anchors.rightMargin: grid.horizontalSpacing
                border { left: 50; top: 0; right: 50; bottom: 0 }
                source: "../images/Bg_DialoguePopUp_Line_Def.png"
            }

            // The background/body image
            Image {
                id:                       backgroundItem
                source:                   backgroundImage != "" ? "../images/" + backgroundImage + ".png" : ""
                anchors.top:              blueLine.bottom
                anchors.topMargin:        grid.verticalSpacing * 3
                anchors.horizontalCenter: parent.horizontalCenter
                clip:                     false
                visible:                  backgroundImage != ""
                width:                    sourceSize.width
                height:                   sourceSize.height
            }

            // The message
            Item {
                id: textItem
                //property alias text: textBoxItem.text
                anchors.top: blueLine.bottom
                anchors.topMargin: textBoxItem.lineCount > 4 ? grid.verticalSpacing * 2 : grid.verticalSpacing * 5
                anchors.left: parent.left
                anchors.leftMargin: grid.horizontalSpacing * 7
                anchors.right: parent.right
                anchors.rightMargin: grid.horizontalSpacing * 7
                anchors.bottom: parent.bottom
                anchors.bottomMargin: grid.verticalSpacing * (tableMode ? 5 : 2) + (hasButtons ? buttonRow.height : 0)
                clip: true
                property bool showScrollbar: textTableItem.contentHeight > textTableItem.height ? true : false
                property int scrollHeight: textTableItem.height * textTableItem.visibleArea.heightRatio
                property int scrollPos: textTableItem.visibleArea.yPosition * textTableItem.height
                property alias contentY: textTableItem.contentY
                property alias contentHeight: textTableItem.contentHeight

                // Show text in text box
                Text {
                    id: textBoxItem
                    visible: tableMode === false
                    anchors.fill: parent
                    maximumLineCount: 6
                    wrapMode: Text.WordWrap
                    font.family: fonts.family
                    font.pixelSize: fonts.smallSize
                    color: colors.textFocused
                }

                // or: Show text from model in a table (see archive info)
                ListView {
                    id: textTableItem
                    visible: tableMode
                    anchors.fill: parent
                    spacing: grid.verticalSpacing
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Item {
                        id: delegateId
                        width: parent.width
                        height: delegateLabel.height
                        Row {       // We need a row element for Arabic
                            layoutDirection: translation.layoutDirection
                            anchors.fill: parent
                            Text {
                                id: delegateLabel
                                font.family: fonts.family
                                font.pixelSize: fonts.smallSize
                                color: colors.textFocused
                                    width: parent.width / 2
                                text: label
                            }
                            Text {
                                id: delegateValue
                                font.family: fonts.family
                                font.pixelSize: fonts.smallSize
                                color: colors.textFocused
                                    width: parent.width / 2
                                    horizontalAlignment: translation.layoutDirection === Qt.LeftToRight ? Text.AlignRight : Text.AlignLeft
                                text: value
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: cancelSelected()
                    }
                }
            }

            // Scroll bar
            Item {
                id: scrollBar
                visible: tableMode && textItem.showScrollbar
                anchors.right: parent.right
                anchors.rightMargin: width + 3
                anchors.top: textItem.top
                anchors.bottom: textItem.bottom
                width: 3

                // Background
                Rectangle {
                    color: "#323232"
                    anchors.fill: parent
                }

                // Slider
                Rectangle {
                    color: "#0066cc"
                    anchors.right: parent.right
                    width: parent.width
                    height: textItem.scrollHeight
                    y: textItem.scrollPos
                }
            }

            // The buttons
            Row {
                id: buttonRow
                objectName: "messageButtonRow"
                property int buttonWidth : (buttonRow.width) / messageBoxRoot.numberOfButtons - 4
                layoutDirection: translation.layoutDirection
                spacing: grid.horizontalSpacing * 2

                anchors.left: parent.left
                anchors.leftMargin: grid.horizontalSpacing * 1
                anchors.right: parent.right
                anchors.rightMargin: grid.horizontalSpacing * 1
                anchors.bottom: parent.bottom
                anchors.bottomMargin: grid.verticalSpacing * 1

                Button {
                    id:      okButton
                    text:    "YES"
                    visible: okButtonVisible && hasButtons
                    width:   buttonRow.buttonWidth

                    onFocusedChanged: {
                        if (focused) {
                            midButton.focused    = false
                            cancelButton.focused = false
                        }
                    }

                    onClicked: {
                        if (enabled)
                            okSelected()
                    }
                }

                Button {
                    id:      midButton
                    text:    "MAYBE" // Never shown...
                    visible: midButtonVisible && hasButtons
                    width:   buttonRow.buttonWidth

                    onFocusedChanged: {
                        if (focused) {
                            okButton.focused     = false
                            cancelButton.focused = false
                        }
                    }

                    onClicked: {
                        if (enabled)
                            midSelected()
                    }
                }

                Button {
                    id:      cancelButton
                    text:    "NO"
                    visible: cancelButtonVisible && hasButtons
                    focused: true
                    width:   buttonRow.buttonWidth

                    onFocusedChanged: {
                        if (focused) {
                            okButton.focused  = false
                            midButton.focused = false
                        }
                    }

                    onClicked: {
                        if (enabled)
                            cancelSelected()
                    }
                }
            }
        }
    }

    // Keyboard handling
    Keys.onPressed: {
        if (event.isAutoRepeat && event.key === keys.trigger)
        {
            event.accepted = true
            return
        }

        acceptKeyRelease = true

        if (event.key !== keys.onOff)
            event.accepted = true

        if (event.key === keys.camera)
        {
            if (flirSystem.lampActive)
                flirSystem.lampActive = false
            else
                flirSystem.lampActive = true
        }
    }

    Keys.onReleased: {
        if (acceptKeyRelease)
        {
            if (!hasButtons)
            {
                if (textItem.showScrollbar)
                {
                    if (event.key === keys.up)
                    {
                        textItem.contentY -= 20
                        if (textItem.contentY < 0)
                            textItem.contentY = 0
                    }
                    else if (event.key === keys.down)
                    {
                        textItem.contentY += 20
                        if (textItem.contentY + textItem.height > textItem.contentHeight)
                            textItem.contentY = textItem.contentHeight - textItem.height
                    }
                    else if(!event.isAutoRepeat)
                        cancelSelected()
                }
                else if(!event.isAutoRepeat)
                    cancelSelected()
                event.accepted = true
            }
            else
            {
                if (event.key === keys.left && translation.layoutDirection === Qt.LeftToRight ||
                    event.key === keys.right && translation.layoutDirection === Qt.RightToLeft)
                {
                    if (cancelButton.focused)
                    {
                        if (midButton.visible && midButton.enabled)
                            midButton.focused = true
                        else if (okButton.enabled)
                            okButton.focused = true
                    } else if (midButton.focused && okButton.enabled)
                        okButton.focused = true
                    event.accepted = true
                }
                else if (event.key === keys.right && translation.layoutDirection === Qt.LeftToRight ||
                         event.key === keys.left && translation.layoutDirection === Qt.RightToLeft) {
                    if (okButton.focused)
                    {
                        if (midButton.visible && midButton.enabled)
                            midButton.focused = true
                        else // always assume cancelButton.enabled = true
                            cancelButton.focused = true
                    } else if (midButton.focused) // always assume cancelButton.enabled = true
                        cancelButton.focused = true
                    event.accepted = true
                }
                else if (event.key === keys.select) {
                    if (okButton.focused)
                    {
                        if (okButton.enabled)
                            okSelected()
                        else
                            console.log("Inconsistent state: okButton.focused=true, okButton.enabled=false");
                    }
                    else if (midButton.focused)
                    {
                        if (midButton.enabled)
                            midSelected()
                        else
                            console.log("Inconsistent state: midButton.focused=true, midButton.enabled=false");
                    }
                    else if (cancelButton.focused)
                    {
                        // always assume cancelButton.enabled = true
                        cancelSelected()
                    }
                    event.accepted = true
                }
                else if (textItem.showScrollbar)
                {
                    if (event.key === keys.up)
                    {
                        textItem.contentY -= 20
                        if (textItem.contentY < 0)
                            textItem.contentY = 0
                        event.accepted = true
                    }
                    else if (event.key === keys.down)
                    {
                        textItem.contentY += 20
                        if (textItem.contentY + textItem.height > textItem.contentHeight)
                            textItem.contentY = textItem.contentHeight - textItem.height
                        event.accepted = true
                    }
                    else if(!event.isAutoRepeat)
                    {
                        cancelSelected()
                        event.accepted = true
                    }
                }
                else if (event.key === keys.up || event.key === keys.down)
                    event.accepted = true   // Prevent leaking keys to parent
                else if(!event.isAutoRepeat)
                {
                    event.accepted = true
                    cancelSelected()
                }
            }
        }
    }
}
