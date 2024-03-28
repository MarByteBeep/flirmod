import QtQuick 1.1
import se.flir 1.0

// KeyDelegate
// ---------------
// Delegate for one Key in the keyboard


Item {
    id: key

    property alias keyWidth : key.width
    property string _lowerChar: lower_case
    property string _upperChar: upper_case
    property string _special1: special1
    property string _special2: special2
    property string _control: control
    property alias keyPressed: keyBackGround.keyDown
    property bool hasKeyFocus: false
    property alias backgroundVisible: keyBackGround.visible

    height: keyboard.rowHeight

    //Key background
    KeyBackground{
        id: keyBackGround
        visible: (control !== "BLANK")
        anchors.fill: key
        anchors.margins: keyboard.keyBackgroundMargin
        dark: (control === "DONE" || control === "?123")
        keyFocus: hasKeyFocus
    }

    //Alphanum key foreground
    Text {
        id: secondary_character_surface
        visible: (control === "")
        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.leftMargin: keyboard.keySecondaryMargin
        anchors.topMargin: keyboard.keySecondaryMarginTop
        color: hasKeyFocus ? colors.textFocused : colors.textNormal
        font.pixelSize: fonts.secondaryKeySize
        text:  special1Visible ? special2 : special1
    }
    Text {
        id: primary_character_surface
        visible: (control === "")
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: keyboard.keyPrimaryMargin
        font.bold: true
        color: colors.textFocused
        font.pixelSize: fonts.primaryKeySize
        text: lowerCaseVisible ? lower_case : (upperCaseVisible ?  upper_case : (special1Visible ? special1 : special2))
    }

    // Text based control key foreground
    Text {
        id: text_control_key
        visible: (control !== "")
        text: (control === "?123" ? ((keyboardShiftState & keyboardShiftStates.alternate) ? "ABC" : "?123") : (control === "DONE" ? "Done" : ( control === "SHIFT" ? ((keyboardShiftState & keyboardShiftStates.alternate && !(keyboardShiftState & keyboardShiftStates.shifted)) ? "1/2" : ( (keyboardShiftState & keyboardShiftStates.alternate && keyboardShiftState & keyboardShiftStates.shifted) ? "2/2" : "")  ) : "")))
        anchors.centerIn: parent
        font.bold: true
        font.pixelSize: fonts.primaryKeySize
        color: hasKeyFocus ? colors.textFocused : colors.textNormal
    }

    // Image based control key foreground
    Image {
        id: image_control_key
        visible: (control !== "")
        anchors.centerIn: parent
        source: (control === "BACKSPACE" ? "../../images/Kb_Ic_Backspace_Def.png" : (control === "SPACE" ? "../../images/Kb_Ic_Space_Def.png" : (control == "ENTER" ? "../../images/Kb_Ic_Enter_Def.png" : (control === "SHIFT" ? ((!(keyboardShiftState & keyboardShiftStates.alternate)) ?  "../../images/Kb_Ic_Shift_Def.png" : ""):""))))
    }

    // Caps lock indicator
    Image {
        id: control_caps_lock
        visible: (control === "SHIFT")
        source: (!(keyboardShiftState & keyboardShiftStates.caps_lock) && !(keyboardShiftState & keyboardShiftStates.alternate)) ? "../../images/Kb_Btn_ShiftIndicator_Def.png" : ((keyboardShiftState & keyboardShiftStates.caps_lock) && !(keyboardShiftState & keyboardShiftStates.alternate) ? "../../images/Kb_Btn_ShiftIndicator_Sel.png" : "" )
        anchors.margins: keySecondaryMargin
        anchors.top: parent.top;
        anchors.left: parent.left;
    }
}
