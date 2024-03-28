import QtQuick 1.1

// ToolBar
// -------
// Generic tool bar element, used for all tool bars.


import QtQuick 1.0
//import "keyboard.js" as JsContext

Item {
    id: keyboard

    property QtObject model
    property TextEdit textField
    property bool maxTextReached: false

//    property int cursorPosition: textField.cursorPosition
//    onCursorPositionChanged: console.log("Keyboard::onCursor " + cursorPosition)

    // keyboard case Enum declaration (qml-style)
    property alias keyboardShiftStates: keyboardShiftStatesEnum
    QtObject {
        id: keyboardShiftStatesEnum
        property int shifted: 1
        property int caps_lock: 2
        property int alternate: 4
        property int shiftstate_default: 0
    }

    property bool lowerCaseVisible: (!(keyboardShiftState & keyboardShiftStates.shifted) && !(keyboardShiftState & keyboardShiftStates.alternate))
    property bool upperCaseVisible: (keyboardShiftState & keyboardShiftStates.shifted && !(keyboardShiftState & keyboardShiftStates.alternate))
    property bool special1Visible: (!(keyboardShiftState & keyboardShiftStates.shifted) && keyboardShiftState & keyboardShiftStates.alternate)
    property bool special2Visible: (keyboardShiftState & keyboardShiftStates.shifted && keyboardShiftState & keyboardShiftStates.alternate)


    // "Public" properties
    property string language: "en_US.xml"
//    property int primaryCharacterSize:15 // 13
//    property int secondaryCharacterSize: 9
//    property color primaryCharacterColor: "#FFFFFF"
//    property color secondaryCharacterColor: "#888888"
    property int keyBackgroundMargin: 3
    property int keySecondaryMargin: 5
    property int keySecondaryMarginTop: 4
    property int keyPrimaryMargin: 6
    property int keyMouseAreaMargin: 1
    property int keyboardShiftState: keyboardShiftStates.shiftstate_default

    property bool longpressValue: false
    property string charLowValue: "x"
    property string charUpValue: "x"
    property string charSpec1Value: "x"
    property string charSpec2Value: "x"

    property int keyFocusCurrentRow: 3
    property int keyFocusCurrentKey: 4

    // "Internal" properties
    property int rowHeight : keyboard.height / 4


    function init() {
        initCursor()
    }

    function initCursor() {
        textField.cursorVisible = true;
        textField.cursorPosition = textField.text.length
    }

    function setDefaultKeyboardShiftState() {
        keyboardShiftState = keyboardShiftStates.shifted
    }

    function insertChar(character) {
        if(character.length === 0 || keyboard.maxTextReached)
            return;
        var previousCursorPos = textField.cursorPosition;
        keyboard.model.textValue = keyboard.model.textValue.substring(0,textField.cursorPosition) + character + keyboard.model.textValue.substring(textField.cursorPosition, keyboard.model.textValue.length)
        textField.cursorPosition = previousCursorPos+1;
    }

    function getActiveChar() {
        var shift = keyboardShiftState & keyboardShiftStates.shifted
        var alt =   keyboardShiftState & keyboardShiftStates.alternate
        if (!shift && !alt && !longpressValue) {
            return charLowValue
        } else if (shift && !alt && !longpressValue) {
            return charUpValue
        } else if ((!shift && alt && !longpressValue) ||
                 (shift && alt && longpressValue) ||
                 (!alt && longpressValue)) {
            return charSpec1Value
        }
        return charSpec2Value
    }

    function insertSelectedChar() {
        insertChar(getActiveChar())
        // Reset the shifting
        if( keyboardShiftState & keyboardShiftStates.shifted
                && !(keyboardShiftState & keyboardShiftStates.caps_lock)
                && !(keyboardShiftState & keyboardShiftStates.alternate)) {
            keyboardShiftState &=  ~keyboardShiftStates.shifted ;
        }
    }

    function removeChar() {
        var previousCursorPos = textField.cursorPosition;
        if(textField.cursorPosition > 0) {
            keyboard.model.textValue = keyboard.model.textValue.substring(0,textField.cursorPosition-1) + keyboard.model.textValue.substring(textField.cursorPosition, keyboard.model.textValue.length)
            textField.cursorPosition = previousCursorPos-1;
        }
    }

    function removeAll() {
        var previousCursorPos = textField.cursorPosition;
        if(textField.cursorPosition >= 0) {
            keyboard.model.textValue = ""
            textField.cursorPosition = 0;
        }
    }

    function adaptPopupText() {
        var newVal = getActiveChar()

        if (newVal !== popup_foreground.text) {
            popup_foreground.text = newVal
        }
    }

    function showPopup(child, row) {
        adaptPopupText()
        popup.visible = true
    }

    function showKeyPopup(child, row) {
        popup.width = child.width * 1.5
        popup.x = child.x - child.width/4
        popup.y = child.y - rowHeight + row * rowHeight
        charLowValue = child._lowerChar
        charUpValue = child._upperChar
        charSpec1Value = child._special1
        charSpec2Value = child._special2
        adaptPopupText()
        popup.visible = true
    }

    function setLongpress(active) {
        longpressValue = active
        if (popup.visible)
            adaptPopupText()
    }

    function hidePopup() {
        popup.visible = false
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function showKeyFocus()
    {
        // Remove old key focus
        var child = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        if (child !== undefined)
            child.hasKeyFocus = false

        // Focus new key
        keyFocusCurrentRow = 3  // "Done"
        keyFocusCurrentKey = 4  // "Done"
        child = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        if (child !== undefined)
            child.hasKeyFocus = true
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function moveKeyFocusRight()
    {
        var currChild = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        var newChild = getChild(keyFocusCurrentRow, keyFocusCurrentKey + 1)
        if (newChild !== currChild && newChild !== undefined && newChild.backgroundVisible)
        {
            keyFocusCurrentKey++
            currChild.hasKeyFocus = false
            newChild.hasKeyFocus = true
        }
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function moveKeyFocusLeft()
    {
        var currChild = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        var newChild = getChild(keyFocusCurrentRow, keyFocusCurrentKey - 1)
        if (newChild !== currChild && newChild !== undefined && newChild.backgroundVisible)
        {
            keyFocusCurrentKey--
            currChild.hasKeyFocus = false
            newChild.hasKeyFocus = true
        }
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function moveKeyFocusUp()
    {
        var currChild = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        var newChild
        if (keyFocusCurrentRow === 1)
            newChild = row1.childAt(currChild.x + currChild.width / 2, currChild.y + currChild.height / 2)
        else if (keyFocusCurrentRow === 2)
            newChild = row2.childAt(currChild.x + currChild.width / 2, currChild.y + currChild.height / 2)
        else if (keyFocusCurrentRow === 3)
            newChild = row3.childAt(currChild.x + currChild.width / 2, currChild.y + currChild.height / 2)

        if (newChild !== currChild && newChild !== undefined)
        {
            if (!newChild.backgroundVisible)
            {
                if (keyFocusCurrentKey === 0)
                    newChild = getChild(keyFocusCurrentRow - 1, keyFocusCurrentKey + 1)
                else if (keyFocusCurrentKey > 0)
                    newChild = getChild(keyFocusCurrentRow - 1, keyFocusCurrentKey - 1)
            }

            if (newChild.backgroundVisible)
            {
                keyFocusCurrentRow--
                keyFocusCurrentKey = getIndex(keyFocusCurrentRow, newChild)
                currChild.hasKeyFocus = false
                newChild.hasKeyFocus = true
            }
        }
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function moveKeyFocusDown()
    {
        var currChild = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        var newChild
        if (keyFocusCurrentRow === 0)
            newChild = row2.childAt(currChild.x + currChild.width / 2, currChild.y + currChild.height / 2)
        else if (keyFocusCurrentRow === 1)
            newChild = row3.childAt(currChild.x + currChild.width / 2, currChild.y + currChild.height / 2)
        else if (keyFocusCurrentRow === 2)
            newChild = row4.childAt(currChild.x + currChild.width / 2, currChild.y + currChild.height / 2)

        if (newChild !== currChild && newChild !== undefined)
        {
            if (!newChild.backgroundVisible)
            {
                if (keyFocusCurrentKey === 0)
                    newChild = getChild(keyFocusCurrentRow + 1, keyFocusCurrentKey + 1)
                else if (keyFocusCurrentKey > 0)
                    newChild = getChild(keyFocusCurrentRow + 1, keyFocusCurrentKey - 1)
            }

            if (newChild.backgroundVisible)
            {
                keyFocusCurrentRow++
                keyFocusCurrentKey = getIndex(keyFocusCurrentRow, newChild)
                currChild.hasKeyFocus = false
                newChild.hasKeyFocus = true
            }
        }
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function getChild(row, index)
    {
        var child
        if (row === 0)
        {
            if (index >= 0 && index < row1.children.length - 1)
                child = row1.children[index]
        }
        else if (row === 1)
        {
            if (index >= 0 && index < row2.children.length - 1)
            child = row2.children[index]
        }
        else if (row === 2)
        {
            if (index >= 0 && index < row3.children.length - 1)
            child = row3.children[index]
        }
        else if (row === 3)
        {
            if (index >= 0 && index < row4.children.length - 1)
                child = row4.children[index]
        }

        return child
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function getIndex(rowIndex, child)
    {
        var index = 0
        var row
        if (rowIndex === 0)
            row = row1
        else if (rowIndex === 1)
            row = row2
        else if (rowIndex === 2)
            row = row3
        else if (rowIndex === 3)
            row = row4

        for (index = 0; index < row.children.length; index++)
        {
            if (row.children[index] === child)
                return index;
        }
        return index
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    property bool ignoreRelease: true   // Filter out first release event (if not preceeded by press).
    function pressSelectedKey()
    {
        ignoreRelease = false
        var currKey = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        if (currKey)
        {
            currKey.keyPressed = true
            if (currKey._control === "")
            {
                keyboard.showKeyPopup(currKey, keyFocusCurrentRow)
//                var point = mapToItem(child.x, child.y)
//                keyboard.showPopup(currKey._lowerChar, currKey._upperChar, currKey._special1, currKey._special2, child.width, point)
            }
            keyFocusLongPress.start()
        }
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    function releaseSelectedKey()
    {
        if (ignoreRelease)
            return
        keyFocusLongPress.stop()
        var currKey = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
        if (currKey)
            keyboard.keyDelegateReleased(currKey)
    }

    // Method for visual keyboard focus (used only in no-touch ui:s)
    Timer {
        id: keyFocusLongPress
        interval: 500
        onTriggered: {
            var currKey = getChild(keyFocusCurrentRow, keyFocusCurrentKey)
            if (currKey)
                keyDelegatePressAndHold(currKey)
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 1

        Row {
            id: row1
            Repeater {
                model: keyboard.model.row0cppModel
                KeyDelegate {
                    keyWidth: weight/keyboard.model.row0TotalWeight*keyboard.width
                }
            }
        }

        Row {
            id: row2
            Repeater {
                model: keyboard.model.row1cppModel
                KeyDelegate {
                    keyWidth: weight/keyboard.model.row1TotalWeight*keyboard.width
                }
            }
        }

        Row {
            id: row3
            Repeater {

                model: keyboard.model.row2cppModel
                KeyDelegate {
                    keyWidth: weight/keyboard.model.row2TotalWeight*keyboard.width
                }
            }
        }

        Row {
            id: row4
            Repeater {
                model: keyboard.model.row3cppModel
                KeyDelegate {
                    keyWidth: weight/keyboard.model.row3TotalWeight*keyboard.width
                }
            }
        }
    }

    function keyDelegatePressAndHold(cntrl)
    {
        keyboard.setLongpress(true)

        if (cntrl._control === "SHIFT" && !(keyboardShiftState & keyboardShiftStates.alternate)) {
            if(keyboardShiftState & keyboardShiftStates.caps_lock) {
                keyboardShiftState &=  ~(keyboardShiftStates.shifted | keyboardShiftStates.caps_lock);
            }
            else {
                keyboardShiftState |= keyboardShiftStates.caps_lock | keyboardShiftStates.shifted;
            }
        }
        if (cntrl._control === "BACKSPACE") {
            backspaceRepeatTimerId.start()
        }
    }

    function keyDelegateReleased(cntrl)
    {
        keyboard.hidePopup()
        if (cntrl === null)
            return
        // Case: Clicking printable key
        if(cntrl._control === "") {
            keyboard.insertSelectedChar()
        }
        // Case: Clicking control key
        else if (cntrl._control === "SPACE") {
            keyboard.insertChar(" ")
        }
        else if (cntrl._control === "ENTER") {
            keyboard.insertChar("\n")
        }
        else if (cntrl._control === "BACKSPACE") {
            if(!keyboard.longpressValue) {
                keyboard.removeChar()
            }
            backspaceRepeatTimerId.stop()
        }
        else if (cntrl._control === "?123") {
            keyboardShiftState ^= keyboardShiftStates.alternate;
            keyboardShiftState &= ~(keyboardShiftStates.shifted | keyboardShiftStates.caps_lock);
        }
        else if (cntrl._control === "DONE")
        {
            softKeyboardPage.model.result = true
            softKeyboardPage.hide()
        }
        else if (cntrl._control === "SHIFT") {
            if (!(keyboardShiftState & keyboardShiftStates.alternate)) {
                // Current state: alpha layout
                if (keyboard.longpressValue) {
                    // Already handled in onPressAndHold, just exit
                }
                else if (keyboardShiftState & keyboardShiftStates.shifted) {
                    if (!(keyboardShiftState & keyboardShiftStates.caps_lock)) {
                        // If shift go to caps lock
                        keyboardShiftState |= keyboardShiftStates.caps_lock;
                    }
                    else {
                        // If caps lock go to normal (unshifted)
                        keyboardShiftState &=  ~(keyboardShiftStates.shifted | keyboardShiftStates.caps_lock);
                    }
                }
                else {
                    // If normal(unshifted) go to shifted
                    keyboardShiftState |= keyboardShiftStates.shifted;
                }
            }
            else {
                // Current state: numeric and special char layout -> toggle shift
                keyboardShiftState ^= keyboardShiftStates.shifted;
            }

        }
        keyboard.setLongpress(false)
        cntrl.keyPressed = false
        // Touch handling
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: 1
        property Item cntrl: null
        onPressed: {
            var child = null
            var row = 0
            if (mouseY < keyboard.rowHeight)
                child = row1.childAt(mouseX, mouseY)
            else if (mouseY < 2 * keyboard.rowHeight)
            {
                child = row2.childAt(mouseX, mouseY - keyboard.rowHeight)
                row = 1
            }
            else if (mouseY < 3 * keyboard.rowHeight)
            {
                child = row3.childAt(mouseX, mouseY - 2 * keyboard.rowHeight)
                row = 2
            }
            else
            {
                child = row4.childAt(mouseX, mouseY - 3 * keyboard.rowHeight)
                row = 3
            }
            cntrl = child
            child.keyPressed = true
            if (child !== null && child._control === "") {
                keyboard.showKeyPopup(child, row)
            }
        }

        onReleased: {
            keyboard.hidePopup()
            if (cntrl === null)
                return
            // Case: Clicking printable key
            if(cntrl._control === "") {
                keyboard.insertSelectedChar()
            }
            // Case: Clicking control key
            else if (cntrl._control === "SPACE") {
                keyboard.insertChar(" ")
            }
            else if (cntrl._control === "ENTER") {
                keyboard.insertChar("\n")
            }
            else if (cntrl._control === "BACKSPACE") {
                if(!keyboard.longpressValue) {
                    keyboard.removeChar()
                }
                backspaceRepeatTimerId.stop()
            }
            else if (cntrl._control === "?123") {
                keyboardShiftState ^= keyboardShiftStates.alternate;
                keyboardShiftState &= ~(keyboardShiftStates.shifted | keyboardShiftStates.caps_lock);
            }
            else if (cntrl._control === "DONE")
            {
                softKeyboardPage.model.result = true
                softKeyboardPage.hide()
            }
            else if (cntrl._control === "SHIFT") {
                if (!(keyboardShiftState & keyboardShiftStates.alternate)) {
                    // Current state: alpha layout
                    if (keyboard.longpressValue) {
                        // Already handled in onPressAndHold, just exit
                    }
                    else if (keyboardShiftState & keyboardShiftStates.shifted) {
                        if (!(keyboardShiftState & keyboardShiftStates.caps_lock)) {
                            // If shift go to caps lock
                            keyboardShiftState |= keyboardShiftStates.caps_lock;
                        }
                        else {
                            // If caps lock go to normal (unshifted)
                            keyboardShiftState &=  ~(keyboardShiftStates.shifted | keyboardShiftStates.caps_lock);
                        }
                    }
                    else {
                        // If normal(unshifted) go to shifted
                        keyboardShiftState |= keyboardShiftStates.shifted;
                    }
                }
                else {
                    // Current state: numeric and special char layout -> toggle shift
                    keyboardShiftState ^= keyboardShiftStates.shifted;
                }

            }
            keyboard.setLongpress(false)
            cntrl.keyPressed = false
        }

        onPressAndHold: {
            keyboard.setLongpress(true)

            if (cntrl._control === "SHIFT" && !(keyboardShiftState & keyboardShiftStates.alternate)) {
                if(keyboardShiftState & keyboardShiftStates.caps_lock) {
                    keyboardShiftState &=  ~(keyboardShiftStates.shifted | keyboardShiftStates.caps_lock);
                }
                else {
                    keyboardShiftState |= keyboardShiftStates.caps_lock | keyboardShiftStates.shifted;
                }
            }
            if (cntrl._control === "BACKSPACE") {
                backspaceRepeatTimerId.start()
            }
        }
    }

    Item {
        id:popup

        height: rowHeight * 1.5
        z:1


        KeyBackground{
            id:popup_background
            anchors.fill: parent
            anchors.margins: keyBackgroundMargin
            popup: true
            longPressActive: longpressValue
        }

         Text {
            id: popup_foreground
            anchors.centerIn: parent;
            color: colors.textFocused
            font.bold: true
            font.pixelSize: fonts.primaryKeySize
        }
    }

    Timer{
        id:backspaceRepeatTimerId
        interval: 150
        repeat: true
        onTriggered: removeChar()
    }
}


