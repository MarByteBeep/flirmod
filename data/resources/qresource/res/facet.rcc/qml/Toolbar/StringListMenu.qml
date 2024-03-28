import QtQuick 1.1

/**
 *  This QML file is the delegate for the C++ class StringlistMenuItem.
 */
FocusScope {
    width: (model == null ? 1 : Math.min(6, Math.max(1, model.widthHint))) * grid.cellWidth
    height: grid.spinlistHeight
    id: root
    property QtObject model: null

    function close() {
        if (model !== null) {
            model.close()
        }
    }

    onModelChanged: {
        // console.debug("StringListMenu.onModelChanged()")
        // initialize sub-models and selection indexes
        list.currentIndex = root.model.initialIndex(0)
        list.model        = root.model.choices(0)
        root.model.setColumn(0)
    }
    
    BorderImage {
        anchors.fill: parent
        border { left: 10; top: 10; right: 10; bottom: 10 }
        source: "../../images/Bg_MenuMiniWidget_Def.png"

        NewValueSelectorList {
            id: list;
            anchors.fill: parent
            focus: true

            onCurrentIndexChanged: {
                // console.debug("StringListMenu.list.onCurrentIndexChanged(" + currentIndex + "), activeFocus=" + activeFocus)
                if (activeFocus && root.model != null)
                    root.model.setSelected(currentIndex);
            }

            onActivated: {
                // console.debug("StringListMenu.list.onActivated()")
                if (root.model != null)
                    root.model.commit()
            }
        }
    }

    Keys.onReleased: {
        // console.debug("StringListMenu.Keys.onReleased(" + event.key + ")")
        event.accepted = false;
        if (event.key === keys.back) {
            if (root.model)
                root.model.revert()
            root.visible =  false
            event.accepted = true
        }
    }
    Keys.onUpPressed:  ; // eat those events
    Keys.onDownPressed:  ; // eat those events
    Keys.onLeftPressed:  ; // eat those events
    Keys.onRightPressed: ; // eat those events
    // debug
    // Text { text: "StringListMenu has focus " + parent.activeFocus; x: -180; y: 30; color:"yellow"; visible: isCurrent }
}
