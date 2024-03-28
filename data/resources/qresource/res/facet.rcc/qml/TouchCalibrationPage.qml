import QtQuick 1.1
import se.flir 1.0

/**
 * TouchCalibrationPage - page where the user calibrates the touch screen
 */

Item {
                       id: touchCalibrationPage
                    width: grid.width
                   height: grid.height
    property int pageSlot: settingsViewMgr.pageSlot(parent, touchCalibrationPage)           // required by SettingsViewMgr
    property variant page: (pageSlot === 0 ? settingsViewMgr.page0 : settingsViewMgr.page1) // required by SettingsViewMgr
                  opacity: 1

    // Key handling
    Keys.onPressed: {
        if (settingsViewMgr.onKeyPressed(event.key, event.isAutoRepeat))
            event.accepted = true
    }

    Keys.onReleased: {
        if (settingsViewMgr.onKeyReleased(event.key, event.isAutoRepeat))
            event.accepted = true
    }

    // The page itself, and its contents
    Rectangle {
        anchors.fill: parent
        color: "black"

        // Cross hair
        Image {
            x: greenbox.touchCalibration.markerX - width / 2
            y: greenbox.touchCalibration.markerY - height / 2
            source: "../images/Sc_MeasureToolPlaced_Spot_Def.png"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                greenbox.touchCalibration.setPosition(mouseX, mouseY)
            }
        }

        Text {
            //: Instruction on how to calibrate the touch screen.
            //% "Tap the crosshair"
            text: qsTrId("ID_TOUCH_CALIBRATION_INSTRUCTION") + translation.update
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: - parent.height / 4
            color: colors.mediumGrey
            font.pixelSize: fonts.smallSize
            font.family: fonts.family
        }
    }
}
