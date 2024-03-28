import QtQuick 1.1
import se.flir 1.0
// Holder for the touch controls on the left side of the live/edit image
// IF we create more we could abstract this and LastImageControl into something more general

Item {
    width: grid.irLeftMargin
    height: grid.height

    // The zoom control
    ZoomControl {
        anchors.left: parent.left
        anchors.leftMargin: 2
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.rightMargin: 2
        width: parent.width
        visible: greenbox.system.showZoomControl && greenbox.appstate !== GreenBox.FacetSketchView
    }

    // The last image control
    LastImageControl {
        anchors.left: parent.left
        anchors.leftMargin: grid.horizontalSpacing
        anchors.bottom: parent.bottom
        anchors.bottomMargin: grid.verticalSpacing*2
        width: parent.width - grid.horizontalSpacing*2

        visible: greenbox.appState === GreenBox.FacetLiveView
    }
}
