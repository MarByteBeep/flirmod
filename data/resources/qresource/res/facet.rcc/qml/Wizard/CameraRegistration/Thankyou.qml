import QtQuick 1.1

Item {
    id: thankyouRoot
    function scrollUp() {  }
    function scrollDown() { }

    property bool currentPage: wizardPageList.currentIndex === index

    // Header
    Text {
        id: myHeaderId
        text: qsTrId("ID_REGISTRATION_THANKYOU_HEADER") + translation.update
        font.family: fonts.family
        font.pixelSize: fonts.largeSize
        height: implicitHeight
        color: colors.textFocused
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40
    }

    // Text
    Text {
        id: myinstructionId
        text: qsTrId("ID_REGISTRATION_THANKYOU_TEXT") + translation.update
        font.family: fonts.family
        font.pixelSize: fonts.mediumSize
        font.weight: Font.Light
        color: colors.textFocused
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 82
        horizontalAlignment: Text.AlignHCenter
        width: parent.width * 2/ 3
        wrapMode: Text.WordWrap
    }

    Image {
        id: myCheckImageId
        source: "../../../images/RegistrationWizard_CorrectCode_Def.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 162
        scale: 1
    }
}

