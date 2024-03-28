import QtQuick 1.1
import "../../Toolbar"

FocusScope {
    id: root
    property string pageName: "verification"

    property QtObject model: pageModel
    clip: true

    function close() {
        if (model !== null) {
            model.close()
        }
    }

    function scrollUp() {
        // Subselection is counting right to left, we want it the other way
        model.select(model.rowCount() - wizardPageList.subSelection - 1)
        model.next();
    }

    function scrollDown() {
        // Subselection is counting right to left, we want it the other way
        model.select(model.rowCount() - wizardPageList.subSelection - 1)
        model.prev();
    }

    property bool currentPage: wizardPageList.currentIndex === index

    // Header
    Text {
        id: myHeaderId
        text: qsTrId("ID_REGISTRATION_CODE_SPINNER_HEADER") + translation.update
        font.family: fonts.family
        font.pixelSize: fonts.mediumSize
        height: implicitHeight
        color: colors.textFocused
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
    }


    Timer {
        id: wrongCodeTimer
        interval: 2000; running: false; repeat: false
        onTriggered: {
            fadeOutTextAnim.start()
            fadeOutImageAnim.start()
        }
    }

    Item {
        id: myItem
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 80
        width: codeSpinnerGroupView.width; height: codeSpinnerGroupView.height

        ListView {
            id: codeSpinnerGroupView
            objectName: "codeSpinnerGroup"
            width: codeSpinnerGroupView.contentItem.children[0].width*root.model.rowCount(); height: codeSpinnerGroupView.contentItem.children[0].height
            property int midX: codeSpinnerGroupView.contentItem.children[0].width/2
            x: midX
            model: root.model
            orientation: Qt.Horizontal
            layoutDirection: Qt.LeftToRight
            interactive: false
            highlightFollowsCurrentItem: false

            delegate: VerticalSpinner {
                id: spinner
                model: spinnerModel
                isCurrentItem: wizardPageList.selected && (root.model.rowCount() - wizardPageList.subSelection - 1) === index

                onSpinnerClicked: {
                    codeSpinnerGroupView.currentIndex = index;
                    wizardPageList.selected = true;
                    wizardPageList.subSelection = root.model.rowCount() - index - 1
                }
            }

            SequentialAnimation on x {
                id: wrongCodeShake
                running: false
                property int animOffset: 10
                property int animTime: 100

                NumberAnimation {
                    from: codeSpinnerGroupView.x; to: codeSpinnerGroupView.x - wrongCodeShake.animOffset
                    easing.type: Easing.Linear; duration: wrongCodeShake.animTime/2
                }

                NumberAnimation {
                    from: codeSpinnerGroupView.x - wrongCodeShake.animOffset; to: codeSpinnerGroupView.x + wrongCodeShake.animOffset
                    easing.type: Easing.Linear; duration: wrongCodeShake.animTime
                }

                NumberAnimation {
                    from: codeSpinnerGroupView.x + wrongCodeShake.animOffset; to: codeSpinnerGroupView.x
                    easing.type: Easing.Linear; duration: wrongCodeShake.animTime/2
                }

                onRunningChanged: {
                    if (!running) {
                        codeSpinnerGroupView.x = codeSpinnerGroupView.midX  // Mid screen
                    }
                }
            }
        }
    }


    Image {
        id: wrongCodeImage
        source: "../../../images/RegistrationWizard_WrongCode_Def.png"

        anchors.left: myItem.right
        anchors.leftMargin: 0
        anchors.top: myItem.top
        anchors.topMargin: myItem.height/2

        scale: 0.6
        visible: wizardPageList.model.wrongCode
        onVisibleChanged: {
           if(wizardPageList.model.wrongCode) {
               wrongCodeShake.start()
               wrongCodeTimer.start()
           }
        }

        NumberAnimation on opacity {
                id: fadeOutImageAnim
                to: 0
                duration: 500
                onRunningChanged: {
                     if (!running) {
                         wrongCodeImage.opacity = 1
                         wizardPageList.model.wrongCode = false
                     }
                }
            }
    }

    Image {
        id: correctCodeImage
        source: "../../../images/RegistrationWizard_CorrectCode_Def.png"

        anchors.left: myItem.right
        anchors.leftMargin: 0
        anchors.top: myItem.top
        anchors.topMargin: myItem.height/2
        visible: wizardPageList.model.correctCode
        scale: 0.6
    }

    Text {
        id: wrongCodeText
        anchors.bottom: root.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10
        width: parent.width
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        font.family: fonts.family
        font.pixelSize: fonts.miniSize
        text: qsTrId("ID_REGISTRATION_WRONG_CODE") + translation.update
        color: "#E9322F"
        visible: wizardPageList.model.wrongCode
        NumberAnimation on opacity {
            id: fadeOutTextAnim
            to: 0
            duration: 500
            onRunningChanged: {
                 if (!running) {
                     wrongCodeText.opacity = 1
                     wizardPageList.model.wrongCode = false
                 }
            }
        }
    }

}

