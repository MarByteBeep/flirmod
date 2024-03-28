import QtQuick 1.1
import se.flir 1.0
import System 1.0

Image {
    id: screeningID
    source: "../images/screening_button_def.png"

    MouseArea {
        anchors.fill: screeningID
        onPressed: {
            longPresTimer.start()
            screeningID.source = "../images/screening_button_sel.png"
        }
        onReleased: {
            if (longPresTimer.running)
            {
                longPresTimer.stop()
                onClicked: greenbox.system.screeningSample()
            }
            screeningID.source = "../images/screening_button_def.png"
        }
    }

    Timer {
        id: longPresTimer
        interval: 2000
        repeat: false
        onTriggered: {
            onClicked: greenbox.system.screeningReset()
        }
    }
}
