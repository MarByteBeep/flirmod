import QtQuick 1.1

Item {
    property bool isUpArrow: true
    signal triggered()
    height: visible ? arrowBackground.height : 0
    width: arrowBackground.width

    BorderImage {
        id: arrowBackground
        border { left: 6; top: 6; right: 6; bottom: 6 }
        visible: arrowMouseArea.pressed
        source: "../images/Bg_MenuHorizontalMain_Marker_Foc.png"
        height: sourceSize.height * 2 / 3
    }

    Image {
        id: arrow
        anchors.centerIn: arrowBackground
        source: "../images/Ic_List_Arrow" + (parent.isUpArrow ? "Up" : "Down") + "_Sel.png"
    }

    MouseArea {
        id: arrowMouseArea
        anchors.fill: parent
        onPressed: arrowTapRepeat.start()
        onReleased: arrowTapRepeat.stop()
    }

    Timer {
        id: arrowTapRepeat
        interval: 100
        repeat: true
        triggeredOnStart: true
        onTriggered: parent.triggered()
    }
}

