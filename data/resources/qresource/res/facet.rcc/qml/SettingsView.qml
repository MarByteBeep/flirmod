import QtQuick 1.1
import se.flir 1.0

Item {
         id: settingsView
      width: grid.width
     height: grid.height
    visible: settingsViewMgr.visible

    onVisibleChanged: {
        if (visible)
            forceActiveFocus()
        else
            parent.focusDesktopFocusGroup()
    }

    FocusScope {
        anchors.fill: parent

        SequentialAnimation {
            id: slideForthTo0
            PropertyAction {target: loader0; property: "x"; value: settingsView.width}
            PropertyAction {target: loader0; property: "z"; value: 2}
            PropertyAction {target: loader1; property: "z"; value: 1}
            NumberAnimation{target: loader0; property: "x"; from: settingsView.width; to: 0;  duration: 300; easing.type: Easing.InQuad}
            ScriptAction   {script: {loader0.forceActiveFocus(); settingsViewMgr.endTransition();}}
        }

        SequentialAnimation {
            id: slideForthTo1
            PropertyAction {target: loader1; property: "x"; value: settingsView.width}
            PropertyAction {target: loader1; property: "z"; value: 2}
            PropertyAction {target: loader0; property: "z"; value: 1}
            NumberAnimation{target: loader1; property: "x"; from: settingsView.width; to: 0;  duration: 300; easing.type: Easing.InQuad}
            ScriptAction   {script: {loader1.forceActiveFocus(); settingsViewMgr.endTransition();}}
        }

        SequentialAnimation {
            id: slideBackTo0
            PropertyAction {target: loader0; property: "x"; value: 0}
            PropertyAction {target: loader1; property: "z"; value: 2}
            PropertyAction {target: loader0; property: "z"; value: 1}
            NumberAnimation{target: loader1; property: "x"; from: 0; to: settingsView.width;  duration: 300; easing.type: Easing.InQuad}
            ScriptAction   {script: {loader0.forceActiveFocus(); settingsViewMgr.endTransition();}}
        }

        SequentialAnimation {
            id: slideBackTo1
            PropertyAction {target: loader1; property: "x"; value: 0}
            PropertyAction {target: loader0; property: "z"; value: 2}
            PropertyAction {target: loader1; property: "z"; value: 1}
            NumberAnimation{target: loader0; property: "x"; from: 0; to: settingsView.width;  duration: 300; easing.type: Easing.InQuad}
            ScriptAction   {script: {loader1.forceActiveFocus(); settingsViewMgr.endTransition();}}
        }

        Connections {
            target: settingsViewMgr

            onSlideForthRequest: {
                if (toIndex == 0)
                    slideForthTo0.start();
                else
                    slideForthTo1.start();
            }
            
            onSlideBackRequest: {
                if (toIndex == 0)
                    slideBackTo0.start();
                else
                    slideBackTo1.start();
            }
        }

        // page deck - slot 0
        Loader {
                 id: loader0
                  x: settingsView.width // initial value outside the view
                  y: 0
                  z: 1                  // above parent
              width: settingsView.width
             height: settingsView.height
             source: settingsViewMgr.pageSource(loader0, 0)

            onSourceChanged: {
                gc()
            }
        }

        // page deck - slot 1
        Loader {
                 id: loader1
                  x: settingsView.width // initial value outside the view
                  y: 0
                  z: 1                  // above parent
              width: settingsView.width
             height: settingsView.height
             source: settingsViewMgr.pageSource(loader1, 1)

            onSourceChanged: {
                gc()
            }
        }

        Keys.onPressed: {
            if (settingsViewMgr.onKeyPressed(event.key, event.isAutoRepeat))
                event.accepted = true
        }

        Keys.onReleased: {
            if (settingsViewMgr.onKeyReleased(event.key, event.isAutoRepeat))
                event.accepted = true
        }
    }

    // Don't leak any key events!
    Keys.onPressed: {
        if (event.key !== keys.camera)
            event.accepted = true
    }
    Keys.onReleased: {
        if (event.key !== keys.camera)
            event.accepted = true
    }

    // Overlay, which is enabled once the page is in transition. This guards
    // against problems where the settings will let mouse and touch screen taps
    // continue further to the desktop (and cause the tool bar to show up).
    Item {
        id: mouseSuppressor
        anchors.fill: parent
        visible: settingsViewMgr.inTransition

        MouseArea {
            anchors.fill: parent
        }
    }
}
