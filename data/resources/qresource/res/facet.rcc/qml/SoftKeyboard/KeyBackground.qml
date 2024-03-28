import QtQuick 1.1



BorderImage {
    property bool keyDown : false
    property bool popup : false
    property bool longPressActive : false
    property bool dark : false
    property bool keyFocus: false

    id: key_background_default
    //visible: (!keyDown && !popup)
    anchors.fill: parent
    border { left: popup ? 8 : 2; top: popup ? 9 : 2; right: popup ? 8 : 2; bottom:  popup ? 12 : 2 }
    source: (!keyDown && !popup) ?
                ( dark ? "../../images/Kb_Btn_ActionBg_Def.png" : "../../images/Kb_Btn_LetterBg_Def.png") :
                ((keyDown && !popup) ? (dark ? "../../images/Kb_Btn_ActionBg_Down.png" : "../../images/Kb_Btn_LetterBg_Down.png") :
                                       ((popup && !longPressActive) ? "../../images/Kb_Btn_LetterPopUpDark_Def.png" :
                                                                      ((popup && longPressActive) ? "../../images/Kb_Btn_LetterPopUpLight_Def.png" : "")))

    Rectangle {
        anchors.fill: key_background_default
        visible: keyFocus
        color: "dodgerblue"
        radius: 2
    }
}

