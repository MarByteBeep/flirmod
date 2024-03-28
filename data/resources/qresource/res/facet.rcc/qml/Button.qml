import QtQuick 1.1

// Button
// ------
// A button, used by the MessageBox element.

BorderImage {

    // Properties and signals

    property bool focused: false
    property bool enabled: true
    property alias text: label.text

    signal clicked

    // Property values
    id: button
    border { left: 5; top: 5; right: 5; bottom: 5 }
    source: "../images/Btn_PopUp_" + (enabled ? (mouseArea.pressed ? "Down.png" : (focused && !touchBased ? "Sel.png" : "Def.png")) : "Def.png")
    height: grid.msgButtonHeight

    // The text label
    Text {
        id: label
        anchors.centerIn: parent
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: enabled ? (focused && !touchBased ? colors.textFocused : colors.textNormal) : colors.textDisabled
    }

    // Touch handling

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: {
            if (enabled)
            {
                focused = true
                button.clicked()
            }
        }
    }
    
    onEnabledChanged:
    {
        if (!enabled)
            focused = false
    }
}
