import QtQuick 1.1
import se.flir 1.0

// Wizard
// ------
// Main component of wizard

Rectangle {
    // Properties
    id: wizardRoot
    color: pageRequestedColor === "" ? "#101010" : pageRequestedColor
    height: grid.height
    width: grid.width
    property alias model: wizardPageList.model
    property int currentIndex: (model !== undefined ) ?  model.currentIndex : 0
    property bool isList: true
    property bool shouldTransit: false
    property string pageRequestedColor: ""


    signal done
    signal skip
    signal lastPage

    function reset() {
        model.reset();
    }

    ColorAnimation on color { id: pageSwitchAnim; duration: 500 }

    state: "STOPPED"
//    onStateChanged: {console.log("state changed",state);}

    states: [
        State {
            name: "STARTED"
            PropertyChanges {
                target: wizardRoot
                opacity: 1
            }
        },
        State {
            name: "STOPPED"
            PropertyChanges {
                target: wizardRoot
                opacity: 0
            }
        },
        State {
            name: "TRANSIT"
            PropertyChanges {
                target: wizardPageList
                opacity: 0
            }
        }

    ]


    transitions: [
        Transition {
            from: "STOPPED"
            to: "STARTED"
            SequentialAnimation {
                NumberAnimation {
                    target: wizardRoot
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.Linear
                }
                ScriptAction {
                    script: {
                        if (model) model.activateWizard()
                    }
                }

            }
        },
        Transition {
            from: "STARTED"
            to: "STOPPED"

            SequentialAnimation {
                NumberAnimation {
                    target: wizardRoot
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.Linear
                }
                ScriptAction {
                    script: {
                        wizFooter.lastClick == "done" ? done() : skip()
                        if (model) model.deactivateWizard()
                    }
                }
            }
        },
        Transition {
            from: "STARTED"
            to: "TRANSIT"
            SequentialAnimation {
                NumberAnimation {
                    target: wizardPageList
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.Linear
                }
                ScriptAction {
                    script: {
                        shouldTransit = false
                        wizFooter.lastClick == "done" ? done() : skip()
                    }
                }
            }
        },
        Transition {
            from: "TRANSIT"
            to: "STARTED"
            SequentialAnimation {
                NumberAnimation {
                    target: wizardPageList
                    property: "opacity"
                    duration: 500
                    easing.type: Easing.Linear
                }
                ScriptAction {
                    script: {
                        if (model) model.activateWizard()
                    }
                }
            }
        }
    ]

    onActiveFocusChanged: {
        if (!activeFocus && visible)
        {
            if (!wizardPageList.hasKeyFocus) {
                forceActiveFocus()
            }
        }
    }

    // Synch page content
    onModelChanged:{
        if (model !== undefined) syncTab()
    }
    onCurrentIndexChanged: {
        if (model !== undefined) syncTab()
    }
    function syncTab() {
        // Do switch the page
        wizardPageList.gotoIndex(model.currentIndex)
        //wizardPageList.positionViewAtIndex(currentIndex, ListView.SnapPosition)
        wizardPageList.wantsKeyFocus = model.wantsKeyFocus
        wizardPageList.hasKeyFocus = wizardPageList.wantsKeyFocus
        wizardPageList.numberOfModels = model.numberOfSubModels
        wizardPageList.selected = true
        wizardPageList.subSelection = model.numberOfSubModels - 1
        wizardPageList.currentTabName = model.currentTabName

        wizardRoot.isList = model.isList

        wizHeader.staticHeader = wizardRoot.model.staticHeader
        wizHeader.title = wizardRoot.model.title
        wizHeader.currentTab = model.currentTab
        wizHeader.currentTabName = model.currentTabName
        wizHeader.currentTabTitle = model.currentTabTitle

        // Initialize footer properties
        wizFooter.leftVisible = model.navigateLeftButton
        wizFooter.rightVisible = model.navigateRightButton// || model.lastPage
        wizFooter.skipVisible = model.skipButton
        wizFooter.leftLblOverride = model.leftLblOverride
        wizFooter.skipLblOverride = model.skipLblOverride
        wizFooter.rightLblOverride = model.rightLblOverride
        wizFooter.lastPage = model.lastPage
        if (wizardRoot.model.opaque(model.currentIndex) === "FullOpacity")
            wizFooter.textStyle = Text.Outline

        // If we are a list and dont have any models then select the next button
        if(!isList && wizardPageList.numberOfModels <= 0)
            wizFooter.selectRight()

        if (model.lastPage)
        {
            wizHeader.visible = false
            wizFooter.selectMid()
            lastPage();
        }

        // Start the wizard
        if(wizardRoot.state === "STOPPED" || wizardRoot.state === "TRANSIT")
            wizardRoot.state = "STARTED"

        // In some cases (e.g. the initialStartupWizard), the activate event is lost in space på Qt
        // probably due to that receiver is not ready yet. Check this here and activate if this is
        // the case
        if(wizardRoot.state === "STARTED" && greenbox.appState !== GreenBox.FacetWizardView)
            model.activateWizard()

    }

    // Capture all uncaught mouse events
    MouseArea {
        id: wizardMouseArea
        anchors.fill: parent
        onClicked: console.log("wizardroot click")
    }

    // Header
    WizardHeader {
        id: wizHeader
        anchors.top: parent.top
        currentTab: 1
        numberOfTabs: (model !== undefined) ? model.numberOfTabs - 1 : 0 // Don't show last page in header
    }

    // List of pages (scrolled side ways)
    ListView {
        id: wizardPageList
        anchors.top: wizHeader.bottom
        anchors.bottom: wizFooter.top
        anchors.bottomMargin: -40
        property int mid: wizardPageList.y + wizardPageList.height / 2
        width: grid.width
        orientation: ListView.Horizontal
        snapMode: ListView.SnapToItem
        boundsBehavior: Flickable.StopAtBounds
        interactive: false  // Do not allow dragging. Only interaction is through navigation icons
        highlightMoveDuration: 400       

        property bool selected: false
        onSelectedChanged: {
            if (selected)
                wizFooter.setSelected(wizardPageList)
        }
        property int subSelection: 0
        property int numberOfModels: 1
        property bool wantsKeyFocus: false
        property bool hasKeyFocus: false
        property string currentTabName: ""

        onHasKeyFocusChanged: {
            if (hasKeyFocus)
            {
                wizFooter.visible = false
                wizFooter.selectList()
            }
            else
            {
                wizFooter.visible = true
                wizFooter.selectRight()
            }
        }

        function gotoIndex(idx) {
            pageSwitchAnim.running = false
            pageSwitchAnim.from = wizardRoot.color
            var opq = wizardRoot.model.opaque(idx)
            if (opq === "FullOpacity")
                pageSwitchAnim.to = "#101010"
            else if (opq === "SemiOpacity")
                pageSwitchAnim.to = "#d0000000"
            else if (opq === "Transparent")
                pageSwitchAnim.to = "#00000000"
            else
                console.error("Wizard.qml: Opacity not specified!")

            // Only do page switch animation if we are in STARTED or
            // STOPPED state
            if(wizardRoot.state !== "TRANSIT")
                pageSwitchAnim.running = true
            else
                color = pageSwitchAnim.to

            wizardPageList.currentIndex = model.currentIndex
        }

        function scrollPageModelUp() { currentItem.item.scrollUp() }
        function scrollPageModelDown() { currentItem.item.scrollDown() }

        delegate: Loader {
            source: qml === undefined ? "" : qml
            onSourceChanged: {
                gc()
                if (item !== null)
                {
                    item.width = wizardPageList.width
                    item.height = wizardPageList.height
                }
            }
        }
    }

    function enableRightButton(enable) { wizFooter.rightVisible = enable }
    function enableSkipButton(enable) { wizFooter.skipVisible = enable }

    // Footer
    WizardFooter {
        id: wizFooter
        anchors.bottom: parent.bottom
        property string lastClick: ""

        onLeftClicked: {
            lastClick = "left"
            model.stepBackward()
        }
        onRightClicked: {
            lastClick = "right"
            model.stepForward()
        }
        onSkipClicked: {
            lastClick = "skip"
            wizardRoot.state = shouldTransit ? "TRANSIT" : "STOPPED"
        }
        onDoneClicked: {
            lastClick = "done"
            wizardRoot.state = shouldTransit ? "TRANSIT" : "STOPPED"
        }

    }

    // Key handling
    Keys.onPressed: {
        if (event.key === keys.left)
            wizFooter.handleLeftKey()
        else if (event.key === keys.right)
            wizFooter.handleRightKey()
        else if (event.key === keys.up)
        {
            if (wizardPageList.selected)
                wizardPageList.scrollPageModelUp()
        }
        else if (event.key === keys.down)
        {
            if (wizardPageList.selected)
                wizardPageList.scrollPageModelDown()
        }
        else
            model.handleNonNavigationKeyPress(event.key);
        event.accepted = true
    }

    Keys.onReleased: {
        if (event.key === keys.select) {
            wizFooter.handleSelectKey()
        }
        else if (event.key === keys.back && model.currentIndex > 0 && !wizFooter.lastPage && model.allowBackButton) {
            wizardPageList.gotoIndex(model.currentIndex - 1)
            model.stepBackward()
        }
        else
            model.handleNonNavigationKeyRelease(event.key);
        event.accepted = true
    }
}
