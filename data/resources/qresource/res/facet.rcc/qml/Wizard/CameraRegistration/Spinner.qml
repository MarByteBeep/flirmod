import QtQuick 1.1

FocusScope {
    id: spinner
    property QtObject model

    Image {
        id: upArrow
        anchors.top: spinner.top
        source: "../../../images/Ic_List_ArrowUp_Sel.png"

        MouseArea {
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                model.next();
                model.select();
            }
        }
    }

    Text {
        id: theText
        text: model.value
        font.family: fonts.family
        font.pixelSize: fonts.mediumSize
        font.weight: Font.Light
        width: upArrow.width
        color: model.isSelected ? "steelblue" : "white"
        anchors.top: upArrow.bottom
        anchors.topMargin: -15
        horizontalAlignment: TextEdit.AlignHCenter
    }

    Image {
        id: downArrow
        anchors.top: theText.bottom
        anchors.topMargin: -15
        source: "../../../images/Ic_List_ArrowDown_Sel.png"

        MouseArea {
            width: parent.width
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                model.prev();
                model.select();
            }
        }
    }
}
