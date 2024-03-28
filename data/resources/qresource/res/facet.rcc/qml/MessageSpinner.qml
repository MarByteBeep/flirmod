import QtQuick 1.1
import se.flir 1.0

FocusScope {
    id: messageSpinner

    property string title
    property string icon
    signal focusDesktopFocusGroup

    x: 0
    y: 0
    width: grid.width
    height: grid.height

    title: qsTrId(messageSpinnerHandler.title)
    icon: messageSpinnerHandler.icon === "" ? "" : "../images/" + messageSpinnerHandler.icon
    visible: messageSpinnerHandler.showing && ! pogo
    opacity: 1

    onVisibleChanged: {
        if (visible) {
            transparentBorder.forceActiveFocus()
        } else {
            // TODO: should this return focus instead of setting it to desktop?
            focusDesktopFocusGroup()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {} // just catch it
    }

    Rectangle {
        id: transparentBorder
        anchors.fill: messageSpinner
        opacity: messageSpinnerHandler.useTransparent ? 0.5 : 0
        color: "black"
    }

    BorderImage {
        id: frameImage
        anchors.centerIn: transparentBorder
        visible: messageSpinnerHandler.type !== MessageSpinnerHandler.TypeProgressTop

        height: messageSpinnerHandler.type === MessageSpinnerHandler.TypeSpinner ? grid.spinnerBoxHeight :
                                                                                   grid.spinnerBoxBigHeight
        width: grid.spinnerBoxWidth
        border { left: 12; top: 12; right: 12; bottom: 12 } // Avoid scaling the (semi-)transparent border...

        source: messageSpinnerHandler.useTransparent ? "../images/Bg_DialoguePopUp_General_Def.png" :
                                                       "../images/Bg_DialoguePopUp_GeneralHardEdges_Def.png"
    }

    BorderImage {
        id: frameImageTop
        anchors.horizontalCenter: messageSpinner.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: grid.verticalSpacing
        visible: messageSpinnerHandler.type === MessageSpinnerHandler.TypeProgressTop

        height: grid.resultTableRowHeight
        width: grid.spinnerBoxWidth
        border { left: grid.unit; top: grid.unit; right: grid.unit; bottom: grid.unit }
        source: "../images/Bg_Notification_Bar_Def.png"
    }

    Item {
        id: spinnerHolder
        visible: messageSpinnerHandler.type === MessageSpinnerHandler.TypeSpinner
        anchors.centerIn: frameImage
        width: frameImage.width -20 // avoid the edges
        height: frameImage.height -20 // avoid the edges

        Row {           // Row element needed for Arabic layout
            anchors.fill: parent
            anchors.leftMargin: grid.horizontalSpacing * 2
            anchors.rightMargin: grid.horizontalSpacing * 2
            spacing: grid.horizontalSpacing * 2
            layoutDirection: translation.layoutDirection

            Image {
                id: infoImage
                source: "../images/Ic_GlobalDialogue_Info_Sel.png"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: titleText
                text: qsTrId(messageSpinner.title) + translation.update
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - infoImage.width - spinner.width - grid.horizontalSpacing * 4
                font.family: fonts.family
                font.pixelSize: fonts.smallSize
                font.bold: true
                color: colors.textFocused
                wrapMode: Text.Wrap
            }

            // The spinner version of the spinner
            Spinner {
                id: spinner
                anchors.verticalCenter: parent.verticalCenter
                //! @todo Fixed size, fix?
                height: parent.height * 0.8
                width: height
            }
        }
    }

    Column {
        id: progressHolder
        visible: messageSpinnerHandler.type === MessageSpinnerHandler.TypeProgress
        anchors.centerIn: frameImage
        width: frameImage.width - grid.horizontalSpacing * 6 // avoid the edges
        height: progressTitleText.height + grid.verticalSpacing + progressBarHolder.height
        spacing: grid.verticalSpacing * 3

        Text {
            id: progressTitleText

            text: qsTrId(messageSpinner.title) + translation.update
            width: parent.width - grid.unit
            font.family: fonts.family
            font.pixelSize: fonts.smallSize
            font.bold: true
            color: colors.textFocused
            wrapMode: Text.Wrap
        }

        Item
        {
            id: progressBarHolder
            width: parent.width
            height: 2

            // The progress version
            Rectangle {
                id: progressBack
                anchors.fill: parent
                color: colors.darkGrey
            }

            Rectangle {
                id: progressBar
                anchors.verticalCenter: progressBack.verticalCenter
                anchors.left:  translation.layoutDirection === Qt.LeftToRight ? progressBack.left : undefined
                anchors.right: translation.layoutDirection === Qt.LeftToRight ? undefined : progressBack.right
                width: 1+(progressBack.width - 4 -1) * (messageSpinnerHandler.progress /100)
                height: parent.height
                color: "#ff0066cc"
            }
        }
    }

    Column {
        id: progressHolderTop
        visible: messageSpinnerHandler.type === MessageSpinnerHandler.TypeProgressTop
        anchors.centerIn: frameImageTop
        width: frameImageTop.width - grid.horizontalSpacing * 6 // avoid the edges
        height: progressTitleTextTop.height + progressBarHolderTop.height

        Text {
            id: progressTitleTextTop
            text: qsTrId(messageSpinner.title) + translation.update
            width: parent.width - grid.unit
            height: messageSpinner.title === "" ? 0 : undefined
            font.family: fonts.family
            font.pixelSize: fonts.smallSize
            font.bold: true
            color: colors.textFocused
            wrapMode: Text.Wrap
        }

        Row {
            id: progressBarHolderTop
            width: parent.width
            height: progressbarTopIcon.visible ? progressbarTopIcon.height : progressBarHolderTopBar.height
            layoutDirection: translation.layoutDirection
            spacing: grid.horizontalSpacing * 2

            Image {
                id: progressbarTopIcon
                visible: messageSpinner.icon !== ""
                source: messageSpinner.icon
                anchors.verticalCenter: parent.verticalCenter
            }

            Item {
                id: progressBarHolderTopBar
                width: parent.width - progressbarTopIcon.width - progressBarHolderTop.spacing
                height: 2
                anchors.verticalCenter: parent.verticalCenter

                // The top progress version
                Rectangle {
                    id: progressBackTop
                    anchors.fill: parent
                    color: colors.darkGrey
                }

                Rectangle {
                    id: progressBarTop
                    anchors.verticalCenter: progressBarHolderTopBar.verticalCenter
                    anchors.left:  translation.layoutDirection === Qt.LeftToRight ? progressBarHolderTopBar.left : undefined
                    anchors.right: translation.layoutDirection === Qt.LeftToRight ? undefined : progressBarHolderTopBar.right
                    width: 1+(progressBarHolderTopBar.width - 4 -1) * (messageSpinnerHandler.progress /100)
                    height: parent.height
                    color: "#ff0066cc"
                }
            }
        }
    }

    // Just catch the key input
    Keys.onPressed: event.accepted = true
    Keys.onReleased: event.accepted = true
}
