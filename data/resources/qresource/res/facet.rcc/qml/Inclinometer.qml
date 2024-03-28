import QtQuick 1.1

import se.flir 1.0
import System 1.0


// Inclinometer
// ----------------
// Display roll and pitch

Rectangle {

    // Properties and signals
    id: inclinometer
    width: 30
    height: 30
    radius: width / 2
    color: "#ffff00"
    border.color: "black"
    border.width: 1
    anchors.left: parent.left
    anchors.leftMargin: 10

    Rectangle {
        width: 14
        height: 14
        radius: width / 2
        color: (Math.abs(flirSystem.roll) > 2 || Math.abs(flirSystem.pitch) > 2) ? "#ff0000" : "#00ff00"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: {
            if (-flirSystem.roll < -(inclinometer.width - width)/2)
                return -(inclinometer.width - width)/2;
            else if (-flirSystem.roll > (inclinometer.width - width)/2)
                return (inclinometer.width - width)/2;
            else
                return -flirSystem.roll
        }
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: {
            if (-flirSystem.pitch < -(inclinometer.width - width)/2)
                return -(inclinometer.width - width)/2;
            else if (-flirSystem.pitch > (inclinometer.width - width)/2)
                return (inclinometer.width - width)/2;
            else
                return -flirSystem.pitch
        }
    }

    Rectangle {
        width: 14
        height: 14
        radius: width / 2
        color: "transparent"
        anchors.centerIn: parent
        border.color: "black"
        border.width: 1
    }
}
