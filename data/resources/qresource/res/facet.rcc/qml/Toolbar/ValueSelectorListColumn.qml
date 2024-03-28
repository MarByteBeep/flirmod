import QtQuick 1.1

FocusScope {
    id: listColumn
    property alias currentIndex: view.currentIndex
    property alias model: view.model
    property bool showScrollArrows: true

    signal activated

    MouseArea {
        width: parent.width
        height: grid.cellHeight*3
        anchors.verticalCenter: parent.verticalCenter
        onClicked: {
            if (parent.activeFocus === false)
                parent.forceActiveFocus()
        }
    }

    Image {
        id: upArrow
        x: (listColumn.width - width ) / 2
        anchors.top: parent.top
        source: "../../images/Ic_List_ArrowUp_Sel.png"
        property int repeatCount: 0
        height: grid.cellHeigh
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
        preferredHighlightBegin: (height - grid.listItemHeight ) / 2
        preferredHighlightEnd: (height + grid.listItemHeight) / 2
        highlightRangeMode: ListView.StrictlyEnforceRange

        delegate: Item {
            height: grid.listItemHeight
            id: delegate
            width: view.width

            Text {
                text: modelData
                anchors.centerIn: parent
                font.pixelSize: fonts.smallSize
                font.family: model.label !== "" ? fonts.family : (model.specialFont === "" ? fonts.family : model.specialFont)
                color: parent.ListView.isCurrentItem ? (parent.activeFocus ? colors.textFocused : (enabled ? colors.textNormal : colors.textDisabled)) : colors.textDisabled
                Behavior on color { ColorAnimation { duration: 50 } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (parent.activeFocus === false)
                        parent.forceActiveFocus()
                }
            }
            Keys.onReleased: {
                if (event.key === keys.select)
                {
                    listColumn.activated()
                    event.accepted = true
                }
            }
        }
    }

    Image {
        id: downArrow
        x: (listColumn.width - width ) / 2
        anchors.bottom: parent.bottom
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
