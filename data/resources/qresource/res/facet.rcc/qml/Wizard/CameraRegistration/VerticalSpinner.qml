import QtQuick 1.1

FocusScope {
    id: spinner
    property QtObject model
    property bool isCurrentItem: false
    implicitWidth: 60
    width: implicitWidth
    implicitHeight: upArrow.implicitHeight + theText.implicitHeight + downArrow.implicitHeight + 0 // Add the internal padding
    height: implicitHeight

    signal spinnerClicked

    Image {
        id: upArrow
        anchors.top: spinner.top
        source: "../../../images/RegistrationWizard_Spinwheel_arrow.png"

        MouseArea {
            width: spinner.width
            height: spinner.width
            anchors.centerIn: parent
            onClicked: {
                model.next();
                spinner.spinnerClicked();
            }
        }
    }

    Text {
        id: theText
        objectName: "spinnerTextField"
        text:  (model !== null) ? model.value :""
        font.family: fonts.family
        font.pixelSize: fonts.largeSize
        font.weight: Font.Light
        width: upArrow.width
        color: isCurrentItem ? "#3e9dff" : colors.textNormal
        anchors.top: upArrow.bottom
        anchors.topMargin: 15
        horizontalAlignment: TextEdit.AlignHCenter

    }

    Image {
        id: downArrow
        anchors.top: theText.bottom
        anchors.topMargin: 15
        source: "../../../images/RegistrationWizard_Spinwheel_arrow.png"
        rotation: 180

        MouseArea {
            width: spinner.width
            height: spinner.width
            anchors.centerIn: parent
            onClicked: {
                model.prev();
                spinner.spinnerClicked();
            }
        }
    }
}
