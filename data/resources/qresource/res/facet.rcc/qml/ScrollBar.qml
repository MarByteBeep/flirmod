import QtQuick 1.1

Item {
    property variant view
    property bool background: true

    visible: view.contentHeight > view.height ? true : false
    anchors.right: parent.right
    anchors.top: view.top
    anchors.bottom: view.bottom
    width: grid.horizontalSpacing

    Rectangle {
        color: "#323232"
        visible: parent.background
        anchors.fill: parent
    }

    Rectangle {
        color: "#0066cc"
        anchors.right: parent.right
        width: parent.width
        height: view.height * view.visibleArea.heightRatio
        y: view.visibleArea.yPosition * view.height
        opacity: parent.background ? 1.0 : 0.5
    }
}
