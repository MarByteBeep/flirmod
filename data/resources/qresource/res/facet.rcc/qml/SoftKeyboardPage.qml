import QtQuick 1.1

//! @TODO use SettingsPage functionality to operate this one (in-out sliding, keyboard navigation), or otherwise strange effects will be taking place

// Soft keyboard evaluation
import "SoftKeyboard"

FocusScope {
    property variant model
    signal focusDesktopFocusGroup

    id: softKeyboardPage

    x: 0
    y: grid.height
    width: grid.width
    height: grid.height

    visible: false
    state: "hide"

    property double topOpacity: 1
    Rectangle {
        color: colors.background
        anchors.bottom: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        opacity: parent.topOpacity
    }

    //! @todo eliminate
    states: [
        State {
            name: "show"
            PropertyChanges {
                target: softKeyboardPage
                y: 0
                visible: true
                topOpacity: 1
            }
        }
        ,
        State {
            name: "hide"
            PropertyChanges {
                target: softKeyboardPage
                y: grid.height
                visible: false
                topOpacity: 0
            }
        }
        ,
        State {
            when: (softKeyboardPage.model.row0TotalWeight > 0)
            name: "modelAssigned"
            StateChangeScript {
                 name: "Init"
                 script: keyboard.init();
             }
        }
    ]

    transitions: [
        Transition {
            to: "hide"
            SequentialAnimation {
                // Slide out.
                PropertyAnimation {
                    properties: "y,topOpacity"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
                // Change visibility.
                PropertyAction {
                    property: "visible"
                }
            }
        },
        Transition {
            to: "show"
            SequentialAnimation {
                // Change visibility.
                PropertyAction {
                    property: "visible"
                }
                // Slide in.
                PropertyAnimation {
                    properties: "y,topOpacity"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
    ]


    //! @todo eliminate
    // Functions used to show and hide pages
    function show() {
        if (state === "show") {
            return
        }
        state = "show"
        greenbox.system.blockAutoShutdown()
        if (keyboardHasJoystickFocus)
            forceActiveFocus()
        else
            textEditBox.forceActiveFocus()
        //keyboard.setDefaultKeyboardShiftState()

        if (keyboardHasJoystickFocus)
            keyboard.showKeyFocus()
    }

    function hide(cancel) {
        if (state === "hide") {
            return
        }
        if (cancel)
        {
            model.keyboardCancelled = true  // Will check need for confirmation question
            if (model.keyboardCancelled)    // Confirmation needed?
                return
        }

        state = "hide"
        model.keyboardShown = false
        keyEverPressed = false
        greenbox.system.allowAutoShutdown()
        focusDesktopFocusGroup()
    }

    property bool refocusProp: model.refocus
    onRefocusPropChanged: {
        if (state === "show")
            recoverFocusTimer.start()
    }
    Timer {
        id: recoverFocusTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (keyboardHasJoystickFocus)
                forceActiveFocus()
            else
                textEditBox.forceActiveFocus()
        }
    }

    //! @todo eliminate
    // Key handling
    property bool keyEverPressed: false
    Keys.onPressed: {
        if (!keyEverPressed)
            keyEverPressed = true
        if (event.key === keys.onOff) {
            hide(true)
            event.accepted = true
        }
        else if (event.key === keys.trigger || event.key === keys.back)
            event.accepted = true
        else if (keyboardHasJoystickFocus)
        {
            if (event.key === keys.select)
            {
                keyboard.pressSelectedKey()
                event.accepted = true
            }
            else if (event.key === keys.left || event.key === keys.right || event.key === keys.up || event.key === keys.down)
            {
                event.accepted = true
            }
        }
    }

    Keys.onReleased: {
        if (!keyEverPressed)
            return
        if (event.key === keys.back || event.key === keys.archive || event.key === keys.power) {
            hide(true)
            event.accepted = true
        }
        else if (event.key === keys.trigger)
        {
            model.result = true
            hide(false)
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
        else if (keyboardHasJoystickFocus)
        {
            if (event.key === keys.left && !event.isAutoRepeat)
            {
                keyboard.moveKeyFocusLeft()
                event.accepted = true
            }
            else if (event.key === keys.right && !event.isAutoRepeat)
            {
                keyboard.moveKeyFocusRight()
                event.accepted = true
            }
            else if (event.key === keys.up && !event.isAutoRepeat)
            {
                keyboard.moveKeyFocusUp()
                event.accepted = true
            }
            else if (event.key === keys.down && !event.isAutoRepeat)
            {
                keyboard.moveKeyFocusDown()
                event.accepted = true
            }
            else if (event.key === keys.select && !event.isAutoRepeat)
            {
                keyboard.releaseSelectedKey()
                event.accepted = true
            }
        }
    }


    // The page itself, and its contents
    Rectangle {
        color: colors.background
        anchors.fill: parent

        MouseArea { // eat any stray mouse clicks.
            anchors.fill: parent
        }

        Item {
                     id: topMargin
                  width: parent.width
                 height: grid.topBorder
            anchors.top: parent.top
        }

        // Header
        SettingsPageHeader {
                       id: header
                     text: model.header
              anchors.top: topMargin.bottom
             anchors.left: parent.left
            anchors.right: parent.right
                   height: grid.cellHeight

            onClicked: hide(true)
        }

        property bool keyboardShown: model.keyboardShown
        onKeyboardShownChanged: {
            if (model.keyboardShown === true) {
                parent.show()
            }
            else {
                parent.hide(false)
            }
        }

        Item {
            id: flickableBase

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 3
            anchors.leftMargin: 3
            anchors.top: header.bottom
            anchors.bottom: keyboard.top
            property bool maxTextReached: textEditBox.height > textEditFlickable.height * 4.5

            Image{
                id: textBoxBackground
                source:  "../images/Kb_Bg_TextBox_Def.png"
                anchors.margins: 5
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: scrollBar.left

                Image{
                    id: removeButton
                    source:  "../images/Kb_Bg_TextBox_Clear_Def.png"
                    anchors.margins: grid.horizontalSpacing*2
                    anchors.top: parent.top
                    anchors.right: parent.right

                    MouseArea{
                        anchors.fill: parent
                        anchors.margins: -5
                        onClicked: keyboard.removeAll()
                    }
                }

                Flickable {
                    id: textEditFlickable
                    anchors.topMargin: 4
                    anchors.bottomMargin: 4
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.right: removeButton.left

                    contentWidth: textEditFlickable.width
                    contentHeight: textEditBox.height

                    flickableDirection: Flickable.HorizontalAndVerticalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    clip: true

                    function ensureVisible(r) {
                        if (contentY >= r.y)
                            contentY = r.y;
                        else if (contentY + height <= r.y + r.height)
                            contentY = r.y + r.height - height;
                    }

                    TextEdit {
                        id: textEditBox
                        wrapMode: TextEdit.Wrap
                        width: parent.width
                        textFormat: TextEdit.PlainText
                        text: model.textValue
                        onTextChanged: {
                            model.textValue = text
                            cursorPosition = text.length
                        }
                        readOnly: flickableBase.maxTextReached
                        focus: !keyboardHasJoystickFocus

                        color: colors.textFocused
                        font.pixelSize: fonts.primaryKeySize

                        onCursorRectangleChanged: textEditFlickable.ensureVisible(cursorRectangle)

                        Keys.onPressed: {
                            if (event.key === keys.trigger_half ||
                                event.key === keys.zoom ||
                                event.key === keys.zoomOut ||
                                event.key === keys.focusIn ||
                                event.key === keys.focusOut)
                                event.accepted = true   // Block these as their keycodes translates to valid ascii chars
                        }
                        Keys.onReleased: {
                            if (event.key === keys.trigger_half ||
                                event.key === keys.zoom ||
                                event.key === keys.zoomOut ||
                                event.key === keys.focusIn ||
                                event.key === keys.focusOut)
                                event.accepted = true   // Block these as their keycodes translates to valid ascii chars
                        }
                    }
                }
            }

            // Scroll bar
            Rectangle {
                id: scrollBar
                visible: textEditBox.height > textEditFlickable.height
                anchors.right: parent.right
                anchors.top: textBoxBackground.top
                anchors.bottom: textBoxBackground.bottom
                width: 3
                clip: true
                color: "#323232"    // Background

                // Foreground
                Rectangle {
                    color: "#0066cc"
                    anchors.right: parent.right
                    width: parent.width
                    height: Math.pow(scrollBar.height, 2) / textEditBox.height
                    y: textEditFlickable.visibleArea.yPosition * scrollBar.height
                }
            }
        }

        Keyboard {
            id: keyboard
            anchors.fill: parent
            anchors.topMargin: parent.height * 0.4
            anchors.rightMargin: grid.horizontalSpacing
            anchors.leftMargin: grid.horizontalSpacing
            anchors.bottomMargin: grid.verticalSpacing + grid.bottomMargin
            model: softKeyboardPage.model
            maxTextReached: flickableBase.maxTextReached

            Binding {
                target: keyboard
                property: "textField"
                value: textEditBox
            }
        }
    }
}
