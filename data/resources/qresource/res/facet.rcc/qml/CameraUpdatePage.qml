import QtQuick 1.1
import System 1.0
import se.flir 1.0


// CameraUpdatePage
// ----------
// A modal message box that presents info during camera software updates and blocks all interaction

Rectangle {

    // Property values
    id: root
    width: grid.width
    height: grid.height
    color: "#EEEEEE"
    z: 100
    state: {
        if (greenbox.system.cameraUpdateState === System.UpdateInactive)
            return "inactive"
        else if (greenbox.system.cameraUpdateState === System.UpdateActive)
            return "running"
        else if (greenbox.system.cameraUpdateState === System.UpdateBatteryError)
            return "battery"
        else if (greenbox.system.cameraUpdateState === System.UpdateCompatibilityError)
            return "incompatible"
        else if (greenbox.system.cameraUpdateState === System.UpdateGeneralError)
            return "general"
        else if (greenbox.system.cameraUpdateState === System.UpdateWriteProtectedError)
            return "writeProtected"
    }

    states: [
        State {
            name: "inactive"
            PropertyChanges { target: titleItem; text: "" }
            PropertyChanges { target: textItem; text: "" }
            PropertyChanges { target: root; visible: false }
            PropertyChanges { target: icon; source: "" }
        },
        State {
            name: "running"
            //: Verb. Header in message dialog displaying the status of a firmware upgrade.
            //% "Updating firmware"
            PropertyChanges { target: titleItem; text: qsTrId("ID_CAMERA_UPDATE_UPDATING_HEADER") }
            //: Message text in dialog displaying the status of a firmware upgrade.
            //% "Update has started. Do not turn off the camera. This update may take several minutes to complete..."
            PropertyChanges { target: textItem; text: qsTrId("ID_CAMERA_UPDATE_UPDATING_TEXT") }
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: icon; source: "../images/Ic_GlobalDialogue_InfoCu_Def.png" }
        },
        State {
            name: "battery"
            //: Header in message dialog displaying that the firmware upgrade process has failed.
            //% "Update failed"
            PropertyChanges { target: titleItem; text: qsTrId("ID_CAMERA_UPDATE_FAILED_HEADER") }
            //: Message text in dialog displaying that the camera update process has failed due to a low battery level.
            //% "The battery level is too low. Turn off the camera, charge the battery and please try again."
            PropertyChanges { target: textItem; text: qsTrId("ID_CAMERA_UPDATE_FAILED_BATTERY") }
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: icon; source: "../images/Ic_GlobalDialogue_ErrorCu_Def.png" }
        },
        State {
            name: "incompatible"
            PropertyChanges { target: titleItem; text: qsTrId("ID_CAMERA_UPDATE_FAILED_HEADER") }
            //: Message text in dialog displaying that the camera update process has failed because the firmware is incompatible with this camera model.
            //% "The new firmware is not compatible with this model. The camera was not updated. Please restart the camera."
            PropertyChanges { target: textItem; text: qsTrId("ID_CAMERA_UPDATE_FAILED_COMPATIBILITY") }
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: icon; source: "../images/Ic_GlobalDialogue_ErrorCu_Def.png" }
        },
        State {
            name: "general"
            PropertyChanges { target: titleItem; text: qsTrId("ID_CAMERA_UPDATE_FAILED_HEADER") }
            //: Message text in dialog displaying that the camera update process has failed because the firmware update package is corrupt.
            //% "There was an error in the update package. Please turn off the camera and try again."
            PropertyChanges { target: textItem; text: qsTrId("ID_CAMERA_UPDATE_FAILED_GENERAL") }
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: icon; source: "../images/Ic_GlobalDialogue_ErrorCu_Def.png" }
        },
        State {
            name: "writeProtected"
            PropertyChanges { target: titleItem; text: qsTrId("ID_CAMERA_UPDATE_FAILED_HEADER") }
            //: Message text in dialog displaying that the camera update process has failed because the memory card is write protected.
            //% "The memory card is write protected. Please remove the write protection."
            PropertyChanges { target: textItem; text: qsTrId("ID_CAMERA_UPDATE_WRITE_PROTECTION") }
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: icon; source: "../images/Ic_GlobalDialogue_ErrorCu_Def.png" }
        }
    ]

    onVisibleChanged: { if (visible) forceActiveFocus() }

    // Touch handling

    MouseArea {
        anchors.fill: parent
    }

    // The message box

    Image {
        id: messageBox
        anchors.fill: parent
        source: "../images/Bg_DialoguePopUp_BigBgCu_Def.png"

        Item {
            id: canvas
            anchors.fill: parent
            anchors.topMargin: grid.cellHeight
            anchors.bottomMargin: grid.cellHeight
            anchors.leftMargin: grid.cellWidth - 3 * grid.horizontalSpacing
            anchors.rightMargin: grid.cellWidth - 3 * grid.horizontalSpacing

            // The icon

            Image {
                id: icon
                anchors.verticalCenter: titleItem.verticalCenter
                anchors.left: parent.left
                source: ""
            }

            // The title text

            Text {
                id: titleItem
                anchors.top: parent.top
                anchors.left: icon.right
                width: parent.width - icon.width - grid.horizontalSpacing * 4
                font.family: fonts.family
                font.pixelSize: fonts.smallSize
                font.bold: true
                color: "#666666"
                wrapMode: Text.Wrap
                maximumLineCount: 3
            }

            // The blue line

            BorderImage {
                id: blueLine
                anchors.top: titleItem.bottom
                anchors.topMargin: titleItem.lineCount === 1 ? grid.verticalSpacing * 3 : grid.verticalSpacing * 2
                anchors.left: parent.left
                anchors.leftMargin: -grid.horizontalSpacing * 2
                anchors.right: parent.right
                anchors.rightMargin: -grid.horizontalSpacing * 2
                border { left: 50; top: 0; right: 50; bottom: 0 }
                source: "../images/Bg_DialoguePopUp_Line_Def.png"
            }

            // The message

            Text {
                id: textItem
                anchors.top: blueLine.bottom
                anchors.topMargin: grid.verticalSpacing * 3
                anchors.left: parent.left
                anchors.leftMargin: grid.horizontalSpacing * 3
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: grid.horizontalSpacing * 3

                maximumLineCount: 6
                wrapMode: Text.WordWrap
                font.family: fonts.family
                font.pixelSize: fonts.smallSize
                color: "#666666"
            }
        }
    }

    // Keyboard handling
    Keys.onPressed: {
        event.accepted = true
        if (event.key === keys.onOff)
        {
            if (state !== "inactive" && state !== "running")
                greenbox.system.powerDown()
        }
    }

    Keys.onReleased: {
        event.accepted = true
    }
}
