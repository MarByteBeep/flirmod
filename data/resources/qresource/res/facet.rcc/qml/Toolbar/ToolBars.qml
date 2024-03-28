import QtQuick 1.1
import se.flir 1.0

//! Toolbars overlay.
//!
//! This Item is positioned to be full-screen and show the toolbars.
//! We have two toolbars, one for each row, which are fed by data owned by the 'menus' QObject.
//! Notice that each toolbar only shows something when the datamodel has data, they are zero width otherwise.
//!
//! @ingroup QML

FocusScope {
    anchors.fill: parent
    id: toolbarsLayer
    visible: !pogo
    property bool hasPopupOpen: toolbarLevel1.hasPopupOpen || toolbarLevel2.hasPopupOpen
    property bool myRefocus: menus.refocus
    onMyRefocusChanged: {
        // Don't set focus if we already have it!
        if (!toolbarsLayer.focus)
            toolbarLevel1.forceActiveFocus()
    }

    Item {
        id: toolbarTransform
        anchors.fill: parent

        MouseArea {
            id: modalBackground
            anchors.fill: parent    // Eat all mouse events outside toolbar when in modal mode
            enabled: menus.modal
            //onClicked: console.log("Toolbars.onClicked")
        }

        ToolBar {
            id: toolbarLevel1
            objectName: "toolbarLevel1QmlObject"
            width: parent.width
            anchors.bottom: parent.bottom
            anchors.bottomMargin: grid.bottomMargin + grid.verticalSpacing
            model: menus.menuLevel1
            isRootLevelToolbar: true
            numWidth: menus.firstLevel1RowLength
        }

        ToolBar {
            id: toolbarLevel2
            objectName: "toolbarLevel2QmlObject"
            width: parent.width
            anchors.bottom: toolbarLevel1.top
            anchors.bottomMargin: grid.verticalSpacing
            model: menus.menuLevel2
            numWidth: menus.firstLevel2RowLength
        }

        rotation: 0
        state: {
            if (greenbox.system.tilt === 180 && has180Tilt && greenbox.appState !== GreenBox.FacetArchiveView)
                return "180"
            else
                return "0"
        }

        // tilt states
        states: [
            State {
                name: "0"
                PropertyChanges { target: toolbarTransform; rotation: 0 }
            },
            State {
                name: "180"
                PropertyChanges { target: toolbarTransform; rotation: 180 }
            }
        ]

    }
}
