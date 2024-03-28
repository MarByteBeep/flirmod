import QtQuick 1.1

Rectangle {
    id: root

    color: "#3E9DFF"
    radius: 2
    visible: false
    height: 36

    property string text: ""
    signal clicked()

    Text {
        id: notificationButtonText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 1
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: colors.textFocused
        wrapMode: Text.WordWrap
        text: root.text
        onTextChanged: {
            if (text === "")
                root.width = 0
            else
                root.width = 65//(contentWidth + 10) < 120 ? 120 : contentWidth + 10  // Text string width + margins
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: parent.color = "#377FD0"
        onReleased: parent.color = "#3E9DFF"
        onClicked:  {
            root.clicked()
            notificationArea.hide()
        }
    }
}
