import QtQuick 1.1
import se.flir 1.0

// RetailDemoView
// -------
// The slide show screen saver for retail demo purpose

Rectangle {
    id: retailDemoView
    color: "gray"
    anchors.fill: parent

    Text{
        id:texten
        text: "no demo images present"
        color: "white"
        anchors.centerIn: parent
    }
    Image{
        id: slideShowImage
        anchors.fill: parent
        anchors.margins: 0
        source : retailModeModel.imageFile
    }



}
