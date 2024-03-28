import QtQuick 1.1

FocusScope {
    id: root
    property alias currentIndex: view.currentIndex
    property alias viewDelegate: view.delegate
    property alias model: view.model
    property bool showScrollArrows: true
    property alias listViewHeight: view.height
    property int visibleRows: 3

    signal activated

    function setFullHeight(fullSize)
    {
        if (visibleRows === 3)
        {
            if (fullSize)
                view.height = root.height - upArrow.height - downArrow.height
            else
                view.height = grid.cellHeight
        }
        else
        {
            upArrow.y = grid.cellHeight
            downArrow.y = parent.height - grid.cellHeight - downArrow.height + 5
            view.height = grid.cellHeight
        }
    }

    Image {
        id: upArrow
        anchors.top: parent.top
        x: (root.width - width ) / 2
        source: "../../images/Ic_List_ArrowUp_Sel.png"
        property int repeatCount: 0
        visible: showScrollArrows

        MouseArea {
            anchors.fill: parent
            onPressed: { upArrow.repeatCount = 0; upArrowTapRepeat.interval = 200; upArrowTapRepeat.start() }
            onReleased: upArrowTapRepeat.stop()
        }

        Timer {
            id: upArrowTapRepeat
            interval: 200
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                upArrow.repeatCount = upArrow.repeatCount + 1
                view.decrementCurrentIndex()
                if (upArrow.repeatCount == 10)
                    interval = 50
            }
        }
    }

    ListView {
        clip: true
        focus: true
        id: view
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 50
        width: parent.width
        anchors.top: upArrow.bottom
        anchors.bottom: downArrow.top
        height:  parent.height
        preferredHighlightBegin: (height - grid.listItemHeight) / 2
        preferredHighlightEnd: (height + grid.listItemHeight) / 2
        highlightRangeMode: ListView.StrictlyEnforceRange

        delegate: Item {
            height: grid.listItemHeight
            id: delegate
            width: view.width
            Text {
                text: modelData
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.centerIn: parent
                font.pixelSize: fonts.smallSize
                font.family: model.label !== "" ? fonts.family : (model.specialFont === "" ? fonts.family : model.specialFont)
                color: parent.ListView.isCurrentItem ? (parent.activeFocus ? colors.textFocused : colors.textNormal) : colors.textDisabled
                Behavior on color { ColorAnimation { duration: 50 } }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (parent.activeFocus === false)
                    {
                        parent.forceActiveFocus()
                        view.currentIndex = index
                    }
                    else
                    {
                        view.currentIndex = index
                    }
                }
            }
            Keys.onReleased: {
                if (event.key === keys.select)
                    root.activated()
            }
        }
    }

    Image {
        id: downArrow
//        anchors.bottom: visibleRows === 3 ? parent.bottom : undefined
        anchors.bottom: parent.bottom
        x: (root.width - width ) / 2
        source: "../../images/Ic_List_ArrowDown_Sel.png"
        property int repeatCount: 0
        visible: showScrollArrows

        MouseArea {
            anchors.fill: parent
            onPressed: { downArrow.repeatCount = 0; downArrowTapRepeat.interval = 200; downArrowTapRepeat.start() }
            onReleased: downArrowTapRepeat.stop()
        }

        Timer {
            id: downArrowTapRepeat
            interval: 200
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                downArrow.repeatCount = downArrow.repeatCount + 1
                view.incrementCurrentIndex()
                if (downArrow.repeatCount == 10)
                    interval = 50
            }
        }
    }
}
