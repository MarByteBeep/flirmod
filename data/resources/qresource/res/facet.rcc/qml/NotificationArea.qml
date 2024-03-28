import QtQuick 1.1

// NotificationArea
// ----------
// Notification area that displays short transient non-modal messages

Item {

    signal notificationAreaClosed()
    signal notificationButtonPressed()

    id: notificationArea

    x: (grid.width - notificationArea.width) / 2
    y: grid.topMargin + grid.verticalSpacing
    width: grid.horizontalSpacing * 4 + messageLabel.width + iconImage.width + iconImage2.width
    height: (grid.resultTableRowHeight + grid.verticalSpacing) * messageLabel.lineCount - grid.verticalSpacing
    visible: !pogo && messageLabel.text !== ""
    property bool showingUntimed: false
    property bool normalMessage: true
    rotation: 0
    transformOrigin: Item.BottomLeft

    Timer {
        id: minimumDisplayTimeTimer
        interval: 4000
        onTriggered: {
            minimumDisplayTimeTimer.stop();
            hide()
        }
    }

    function show(error) {
        if (showingUntimed)
            return
        normalMessage = true
        iconImage.visible = false
        iconImage2.visible = false
        doShow(error)
    }

    function showIconText(icon, error) {
        if (showingUntimed)
            return
        iconImage2.visible = false
        if (icon === "EXCLAMATION")
        {
            iconImage.source = "../images/Sc_Status_Warning_Def.png"
            iconImage.visible = true
        }
        else
        {
            iconImage.source = icon
            iconImage.visible = true
        }
        normalMessage = true
        doShow(error)
    }

    function showIconTextIcon(icon1, error, icon2) {
        if (showingUntimed)
            return
        normalMessage = true
        iconImage.source = icon1
        iconImage.visible = true
        iconImage2.source = icon2
        iconImage2.visible = true

        doShow(error)
    }


    function showUntimed(msg) {
        normalMessage = true
        iconImage.visible = false
        doShow(msg)
        minimumDisplayTimeTimer.stop()
        showingUntimed = true
    }

    function showTextButton(msg, btnTxt) {
        if (showingUntimed)
            return
        iconImage.visible = false
        normalMessage = false
        notificationButton.text = qsTrId(btnTxt)
        doShow(msg)
    }

    function doShow(error) {
        if (error !== undefined)
        {
            minimumDisplayTimeTimer.interval = 200 + error.length * 200

            messageLabel.text = qsTrId(error)
            if (greenbox.system.tilt === 90 || greenbox.system.tilt === 270)
            {
                if (messageLabel.implicitWidth > grid.height - 2 * grid.cellWidth)
                    messageLabel.width = grid.height - 2 * grid.cellWidth
            }
            else
            {
                if (messageLabel.implicitWidth > grid.width - 2 * grid.cellWidth)
                    messageLabel.width = grid.width - 2 * grid.cellWidth
            }

            minimumDisplayTimeTimer.restart()

        }
    }

    function hide() {

        if (minimumDisplayTimeTimer.running === false)
        {
            normalMessage = true
            messageLabel.text = ""
            messageLabel.width = undefined
            notificationAreaClosed()
            iconImage.visible = false
            showingUntimed = false
        }
    }

    // The background
    BorderImage {
        id: backgroundImage
        anchors.fill: parent
        border { left: grid.unit; top: grid.unit; right: grid.unit; bottom: grid.unit }
        source: "../images/Bg_Notification_Bar_Def.png"
    }

    Image {
        id: iconImage
        anchors.left: notificationArea.left
        anchors.leftMargin:  grid.horizontalSpacing
        anchors.verticalCenter: parent.verticalCenter
        width: visible ? sourceSize.width : 0
        visible: false
    }

    // The message
    Text {
        id: messageLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.visible ? 0 : 2 * grid.horizontalSpacing
        anchors.verticalCenter: parent.verticalCenter
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: colors.textFocused
        wrapMode: Text.WordWrap
    }

    Image {
        id: iconImage2
        anchors.left: messageLabel.right
        anchors.leftMargin:  grid.horizontalSpacing
        anchors.verticalCenter: parent.verticalCenter
        width: visible ? sourceSize.width : 0
        visible: false
    }
    BasicButton {
        id: notificationButton
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        visible: !normalMessage
        anchors.rightMargin: 5
        onClicked: {
            minimumDisplayTimeTimer.stop()
            hide()
            notificationButtonPressed()
        }

    }
    states: [
        State {
            name: "0"
            when: greenbox.system.tilt === 0
            PropertyChanges { target: notificationArea; rotation: 0 }
            PropertyChanges {
                target: notificationArea; x: (grid.width - notificationArea.width)/2
            }
            PropertyChanges {
                target: notificationArea; y: (grid.topMargin + grid.verticalSpacing)
            }
        },
        State {
            name: "90"
            when: greenbox.system.tilt === 90
            PropertyChanges { target: notificationArea; rotation: 90 }
            PropertyChanges {
                target: notificationArea;
                x: grid.width
                   - grid.irLeftMargin
                   - notificationArea.height
                   - (grid.topMargin + grid.verticalSpacing)
            }
            PropertyChanges {
                target: notificationArea; y: (grid.height - notificationArea.width)/2 - notificationArea.height
            }
        },
        State {
            name: "180"
            when: greenbox.system.tilt === 180
            PropertyChanges { target: notificationArea; rotation: 180 }
            PropertyChanges {
                target: notificationArea; x: (grid.width + notificationArea.width)/2
            }
            PropertyChanges {
                target: notificationArea; y: grid.height - 2*notificationArea.height
                                             - (grid.topMargin + grid.verticalSpacing)
            }
        },
        State {
            name: "270"
            when: greenbox.system.tilt === 270
            PropertyChanges { target: notificationArea; rotation: 270 }
            PropertyChanges {
                target: notificationArea;
                x: grid.irLeftMargin
                   + notificationArea.height
                   + (grid.topMargin + grid.verticalSpacing)
            }
            PropertyChanges {
                target: notificationArea; y: (grid.height + notificationArea.width)/2 - notificationArea.height
            }
        }
    ]

}
