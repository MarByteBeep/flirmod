import QtQuick 1.1

// WizardFooter
// ------
// Footer at bottom of Wizard, containing navigation buttons. It handles navigation between wizard pages.

Item {

    // Properties
    id: wizardFooter
    height: 80
    width: parent.width

    property alias leftVisible: leftId.visible
    property alias rightVisible: rightId.visible
    property alias skipVisible: skipId.visible
    property bool lastPage: false
    property int margins: 20
    property string leftLblOverride: ""
    property string skipLblOverride: ""
    property string rightLblOverride: ""
    property int textStyle: Text.Normal

    signal leftClicked
    signal rightClicked
    signal skipClicked
    signal doneClicked

    function handleLeftKey()
    {
        //console.log("HandleLeftKey")
        if (rightId.selected)
        {
            if (skipId.visible)
                setSelected(skipId)
            else if (model !== null && wizardPageList.numberOfModels > 0)
                setSelected(wizardPageList)
            else if (leftId.visible)
                setSelected(leftId)
        }
        else if (skipId.selected)
        {
            if (model !== null && wizardPageList.numberOfModels > 0)
            {
                setSelected(wizardPageList)
                wizardPageList.subSelection = 0
            }
            else if (leftId.visible)
                setSelected(leftId)
        }
        else if (model !== null && wizardPageList.selected)
        {
            if (wizardPageList.numberOfModels > 1 && wizardPageList.subSelection < wizardPageList.numberOfModels - 1)
                wizardPageList.subSelection++
            else
            {
                if (leftId.visible)
                    setSelected(leftId)
            }
        }
    }
    function handleRightKey()
    {
        //console.log("HandleRightKey")
        if (leftId.selected)
        {
            if (model !== null && wizardPageList.numberOfModels > 0)
            {
                setSelected(wizardPageList)
                wizardPageList.subSelection = wizardPageList.numberOfModels - 1
            }
            else if (skipId.visible)
                setSelected(skipId)
            else if (rightId.visible)
                setSelected(rightId)
        }
        else if (model !== null && wizardPageList.selected)
        {
            if (wizardPageList.subSelection > 0)
                wizardPageList.subSelection--
            else
            {
                if (skipId.visible)
                    setSelected(skipId)
                else if (rightId.visible)
                    setSelected(rightId)
            }
        }
        else if (skipId.selected)
        {
            if (rightId.visible)
                setSelected(rightId)
        }
    }
    function handleSelectKey()
    {
        //console.log("HandleSelectKey")
        if (rightId.selected && rightId.visible)
        {
            if (lastPage)
                doneClicked()
            else
                rightClicked()
        }
        else if (leftId.selected && leftId.visible) {
                leftClicked()
        }
        else if (skipId.selected && skipId.visible)
        {
            if (lastPage)
                doneClicked()
            else
                skipClicked()
        }
        else if (wizardPageList.selected && wizardPageList.visible)
        {
            if (wizardPageList.wantsKeyFocus)
            {
                if (wizardPageList.hasKeyFocus)
                {
                    wizardPageList.hasKeyFocus = false
                    setSelected(rightId)
                }
                else {
                    wizardPageList.hasKeyFocus = true
                }
            }
            else {
                handleRightKey()
                if (rightId.selected && rightId.visible)
                {
                    if (lastPage)
                        doneClicked()
                    else
                        rightClicked()
                }
            }
        }
    }
    function setSelected(item)
    {
        if (item === leftId)
        {
            leftId.selected = true
            rightId.selected = false
            skipId.selected = false
            wizardPageList.selected = false
        }
        else if (item === skipId)
        {
            leftId.selected = false
            rightId.selected = false
            skipId.selected = true
            wizardPageList.selected = false
        }
        else if (item === rightId)
        {
            leftId.selected = false
            rightId.selected = true
            skipId.selected = false
            wizardPageList.selected = false
        }
        else if (item === wizardPageList)
        {
            leftId.selected = false
            rightId.selected = false
            skipId.selected = false
            wizardPageList.selected = true
        }
    }
    function selectRight() { setSelected(rightId) }
    function selectList() { setSelected(wizardPageList) }
    function selectMid() { setSelected(skipId) }

    // Left icon
    Text {
        id: leftId
        anchors.left: parent.left
        anchors.leftMargin: margins
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        text: (leftLblOverride == "" ? qsTrId("ID_STARTUP_BACK") : qsTrId(leftLblOverride)) + translation.update
        color: selected ? "#3e9dff"  : colors.textFocused
        style: wizardFooter.textStyle
        styleColor: "black" // Only used if style is set

        property bool selected: false

        // Touch handling
        MouseArea {
            id: leftmouseArea
            anchors.fill: parent
            anchors.margins: -20
            anchors.rightMargin: -30
            onPressed: setSelected(leftId)
            onReleased: {
                leftId.selected = false
                wizardFooter.leftClicked()
            }
        }
    }

    // Center text
    Text {
        id: skipId
        //text: (skipLblOverride != "" ? qsTrId(skipLblOverride) : lastPage ? qsTrId("ID_STARTUP_FINISH") + translation.update : qsTrId("ID_STARTUP_SKIP") + translation.update) + translation.update
        text: (skipLblOverride != "" ? qsTrId(skipLblOverride) : lastPage ? qsTrId("ID_STARTUP_FINISH") : qsTrId("ID_STARTUP_SKIP")) + translation.update
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: selected ?"#3e9dff"  : colors.textFocused
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        style: wizardFooter.textStyle
        styleColor: "black" // Only used if style is set

        property bool selected: lastPage

        // Touch handling
        MouseArea {
            id: skipmouseArea
            anchors.fill: parent
            anchors.margins: -20
            anchors.leftMargin: -30
            anchors.rightMargin: -30
            onPressed: setSelected(skipId)
            onReleased: {
                skipId.selected = false
                if (lastPage)
                    wizardFooter.doneClicked()
                else
                    wizardFooter.skipClicked()
            }
        }
    }

    // Right text
    Text {
        id: rightId
        text: (rightLblOverride != "" ? qsTrId(rightLblOverride) : lastPage ? "" : qsTrId("ID_STARTUP_NEXT")) + translation.update
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: selected ? "#3e9dff" : colors.textFocused
        anchors.right: parent.right
        anchors.rightMargin: margins
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        style: wizardFooter.textStyle
        styleColor: "black" // Only used if style is set

        property bool selected: false

        // Touch handling
        MouseArea {
            id: rightmouseArea
            anchors.fill: parent
            anchors.margins: -20
            anchors.leftMargin: -30
            onPressed: setSelected(rightId)
            onReleased: {
                rightId.selected = false
                if (lastPage)
                    wizardFooter.doneClicked()
                else
                    wizardFooter.rightClicked()
            }
        }
    }
}
