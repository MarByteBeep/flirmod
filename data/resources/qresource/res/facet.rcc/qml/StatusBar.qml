import QtQuick 1.1
import se.flir 1.0
import System 1.0

Item {
    id: statusBar
    width: row.width
    height: grid.resultTableRowHeight
    visible: (greenbox.system.tilt === 0 || greenbox.system.tilt === 180)

    function getIndex(percent) {
        if(percent < 20)
            return 0;
        else if(percent > 80)
            return 4;
        else
            return (percent / 20);
    }

    RoundedRect {
        anchors.fill: parent
        visible:  (powerStatus.visible || storageStatus.visible || zoomStatus.visible || wifiStatus.visible ||
                   bluetoothStatus.visible || gpsStatus.visible || compassStatus.visible || headsetStatus.visible ||
                   lampStatus.visible || usbStatus.visible  || emissivity.visible || manualStatus.visible)
    }

    Row {
        id: row
        height: parent.height
        y: -1

        // Power
        Image {
            id: powerStatus
            property int index: getIndex(flirSystem.power)
            source: "../images/Sc_Status_Battery0" + Math.max(index, flirSystem.powerCharging ? 0 : 1) + "_Def.png"
            visible: pogo ? false :
                            flirSystem.powerCharging ? true :
                                                       (menus.menuOpen && greenbox.appState !== GreenBox.FacetEditView)? true : index === 0

            anchors.verticalCenter: parent.verticalCenter
            onIndexChanged: {
                if (index === 0)
                    batteryBlinkTimer.start()
                else if (batteryBlinkTimer.running)
                {
                    batteryBlinkTimer.stop()
                    opacity = 1
                }
            }
            Component.onCompleted: {if (index === 0) batteryBlinkTimer.start() }
        }
        Timer {
            id: batteryBlinkTimer
            interval: 500
            repeat: true
            onTriggered: {
                if (powerStatus.opacity === 1 && !flirSystem.powerCharging)
                    powerStatus.opacity = 0.25
                else
                    powerStatus.opacity = 1
            }
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: powerStatus.visible && (storageStatus.visible || zoomStatus.visible ||
                                             wifiStatus.visible || bluetoothStatus.visible ||
                                             gpsStatus.visible || compassStatus.visible ||
                                             headsetStatus.visible || lampStatus.visible ||
                                             usbStatus.visible  || emissivity.visible || manualStatus.visible)
        }

        // Storage card
        Image {
            id: storageStatus
            property int index: flirSystem.storageStatusIndex !== undefined
                                ? flirSystem.storageStatusIndex
                                : 0
            source: "../images/Sc_Status_Memcard0" + index + "_Def.png"
            visible: !pogo &&
                     greenbox.appState !== GreenBox.FacetEditView &&
                     flirSystem.storageMounted &&
                     (menus.menuOpen || index === 4) // Only show the card when the menu is closed if it is nearly full
            anchors.verticalCenter: parent.verticalCenter
            onIndexChanged: {
                if (index === 4)
                    storageBlinkTimer.start()
                else if (storageBlinkTimer.running)
                {
                    storageBlinkTimer.stop()
                    opacity = 1
                }
            }
            Component.onCompleted: {if (index === 4) storageBlinkTimer.start() }
        }
        Timer {
            id: storageBlinkTimer
            interval: 500
            repeat: true
            onTriggered: {
                if (storageStatus.opacity === 1)
                    storageStatus.opacity = 0.25
                else
                    storageStatus.opacity = 1
            }
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: storageStatus.visible && (zoomStatus.visible || wifiStatus.visible ||
                                               bluetoothStatus.visible || gpsStatus.visible ||
                                               compassStatus.visible || headsetStatus.visible ||
                                               lampStatus.visible || usbStatus.visible  ||
                                               emissivity.visible || manualStatus.visible)
        }

        // WiFi
        Image {
            id: wifiStatus
            source: flirSystem.wifiEnabled ? flirSystem.wifiStatusImage : ""
            visible: flirSystem.wifiEnabled && !pogo && menus.menuOpen && greenbox.appState !== GreenBox.FacetEditView
            opacity: flirSystem.wifiActive ? 1.0 : 0.25
            anchors.verticalCenter: parent.verticalCenter
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: wifiStatus.visible && (bluetoothStatus.visible || gpsStatus.visible ||
                                            compassStatus.visible || headsetStatus.visible ||
                                            lampStatus.visible || usbStatus.visible ||
                                            emissivity.visible || manualStatus.visible || zoomStatus.visible)
        }

        // Bluetooth
        Image {
            id: bluetoothStatus
            source: flirSystem.bluetoothEnabled ? "../images/Sc_Status_Bluetooth_Def.png" : ""
            opacity: flirSystem.bluetoothActive ? 1.0 : 0.25
            visible: flirSystem.bluetoothEnabled && !pogo  && menus.menuOpen && greenbox.appState !== GreenBox.FacetEditView
            anchors.verticalCenter: parent.verticalCenter
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: bluetoothStatus.visible && (gpsStatus.visible || compassStatus.visible ||
                                                 headsetStatus.visible || lampStatus.visible ||
                                                 usbStatus.visible || emissivity.visible || manualStatus.visible || zoomStatus.visible)
        }

        // GPS
        Image {
            id: gpsStatus
            source: flirSystem.gpsEnabled ? "../images/Sc_Status_Gps_Def.png" : ""
            opacity: flirSystem.gpsActive ? 1.0 : 0.25
            visible: flirSystem.gpsEnabled && !pogo  && menus.menuOpen && greenbox.appState !== GreenBox.FacetEditView
            anchors.verticalCenter: parent.verticalCenter
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: gpsStatus.visible && (compassStatus.visible || headsetStatus.visible ||
                                           lampStatus.visible || usbStatus.visible ||
                                           emissivity.visible || manualStatus.visible || zoomStatus.visible)
        }

        // Compass
        Image {
            id: compassStatus
            source: flirSystem.compassEnabled ? ("../images/" + flirSystem.compassStatusIcon + "_Def.png") : ""
            opacity: flirSystem.compassActive ? 1.0 : 0.25
            visible: flirSystem.compassEnabled && !pogo
            anchors.verticalCenter: parent.verticalCenter
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: compassStatus.visible && (headsetStatus.visible || lampStatus.visible ||
                                               usbStatus.visible || emissivity.visible || manualStatus.visible || zoomStatus.visible)
        }

        // Headset
        Image {
            id: headsetStatus
            source: flirSystem.headsetActive ? "../images/Sc_Status_BluetoothHeadset_Def.png" : ""
            visible: flirSystem.headsetActive && !pogo  && menus.menuOpen && greenbox.appState !== GreenBox.FacetEditView
            anchors.verticalCenter: parent.verticalCenter
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: headsetStatus.visible && (lampStatus.visible || usbStatus.visible ||
                                               emissivity.visible || manualStatus.visible || zoomStatus.visible)
        }

        // Lamp
        Image {
            id: lampStatus
            source: "../images/Sc_Status_LampOn_Def.png"
            visible: flirSystem.lampActive && !pogo
            anchors.verticalCenter: parent.verticalCenter
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: lampStatus.visible && (usbStatus.visible || emissivity.visible || manualStatus.visible || zoomStatus.visible)
        }

        // USB
        Image {
            id: usbStatus
            source: "../images/Sc_Status_Usb_Def.png"
            visible: flirSystem.usbConnected && !pogo
            anchors.verticalCenter: parent.verticalCenter
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: usbStatus.visible && (emissivity.visible || manualStatus.visible || zoomStatus.visible)
        }

        // Emissivity (visible in pogo)
        Text {
            id: emissivity
            visible: greenbox.system.emissivityModified && greenbox.system.viewMode !== System.VIEW_MODE_VISUAL
            anchors.verticalCenter: parent.verticalCenter
            text: " " + greenbox.system.emissivity
            font.family: fonts.family
            font.pixelSize: fonts.smallSize
            color: colors.textFocused
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: emissivity.visible && (manualStatus.visible || zoomStatus.visible)
        }

        // Manual status
        Image {
            id: manualStatus
            source: "../images/Sc_Status_Tempscale_Def.png"
            visible: greenbox.scale.manual && !pogo && manualInteraction && greenbox.system.viewMode !== System.VIEW_MODE_VISUAL
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                id: manualStatusMouseArea
                anchors.fill: parent
                anchors.margins: -10
                onPressed: {
                    if (greenbox.appState === GreenBox.FacetEditView ||
                        greenbox.appState === GreenBox.FacetPreviewView)
                    {
                        greenbox.system.doOneShotAutoAdjust()
                    }
                    else
                    {
                        greenbox.scale.manual = false
                        greenbox.scale.interactive = false
                    }
                }
            }
        }

        // Divider
        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "../images/Bg_Status_Divider_Def.png"
            visible: manualStatus.visible && zoomStatus.visible
        }

        // Zoom (visible in pogo)
        Image {
            id: zoomStatus
            source: greenbox.system.zoom > 7 ? "../images/Sc_Status_Zoom8x_Def.png" :
                        greenbox.system.zoom > 3 ? "../images/Sc_Status_Zoom4x_Def.png" :
                            greenbox.system.zoom > 1.0 ? "../images/Sc_Status_Zoom2x_Def.png" : ""
            visible: !greenbox.system.showZoomControl && greenbox.system.zoom > 1.0
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StatusBarZoomPanIndicator {
        anchors.left: statusBar.right
        anchors.leftMargin: grid.horizontalSpacing
        height: parent.height - 1
        width: height*4/3
        visible: !greenbox.system.showZoomControl && greenbox.system.zoom > 1.0 &&
                 (greenbox.appState !== GreenBox.FacetLiveView &&
                    greenbox.appState !== GreenBox.FacetMediaControlState)
    }
}


