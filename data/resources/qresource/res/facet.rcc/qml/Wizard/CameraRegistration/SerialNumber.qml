import QtQuick 1.1

Item {
    id: serialRoot
    function scrollUp() {  }
    function scrollDown() { }

    property bool currentPage: wizardPageList.currentIndex === index    

    // Header
    Text {
        id: myHeaderId
        text: qsTrId("ID_REGISTRATION_SERIAL_HEADER") + translation.update
        font.family: fonts.family
        font.pixelSize: fonts.mediumSize
        height: implicitHeight
        color: colors.textFocused
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
    }

    // Text
    Text {
        id: myInstructionId
        text: qsTrId("ID_REGISTRATION_SERIAL_TEXT") + translation.update
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: colors.textFocused
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 72
        horizontalAlignment: Text.AlignHCenter
        width: parent.width * 2/ 3
        wrapMode: Text.WordWrap
        opacity: 0.7
    }

    // Bottom Component
    Text {
        id: mySerialNumber
        text: greenbox.system.serialNumber
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: colors.textFocused
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: myInstructionId.bottom
        anchors.topMargin: 15
        horizontalAlignment: Text.AlignHCenter
        width: parent.width * 2/ 3
        wrapMode: Text.WordWrap
    }

}

