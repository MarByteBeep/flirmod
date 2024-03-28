import QtQuick 1.1

/**
 *  This QML file is the delegate for the C++ class BimodalListMenuItem. This is a double
 *  list, one (compact) formed out of simple string list, and the other (expanded) of the 
 *  SettingsModel.{label, value} pair. An example of use is the custom/material emissivity
 *  listing.
 */
FocusScope {
    height: grid.spinlistHeight
    id: root
    property QtObject model: null
    property int mode_Undefined: -1
    property int mode_Compact:    0
    property int mode_Expanded:   1
    property int mode: model != null ? model.mode : mode_Undefined

    function close() {
        if (model !== null) {
            model.close()
        }
    }

    onModelChanged: {
        // initialize sub-models and selection indexes
        compactList .model        = model.compactModel
        compactList .currentIndex = model.compactModelIndex
        expandedList.model        = model.expandedModel
        expandedList.currentIndex = model.expandedModelIndex
    }
    
    onModeChanged: {
        if (model != null)
        {
            switch (mode)
            {
                case mode_Expanded: {
                    // perform these actions in order
                    compactList .visible = false
                    width                = model.widthHint*grid.cellWidth
                    expandedList.visible = true
                    expandedList.forceActiveFocus()
                    break
                }
                case mode_Compact: {
                    // perform these actions in order
                    expandedList.visible = false
                    width                = model.widthHint*grid.cellWidth
                    compactList .visible = true
                    compactList .forceActiveFocus()
                    break
                }
            }
        }
    }

    BorderImage {
        id: borderImage
        anchors.fill: parent
        border { left: 10; top: 10; right: 10; bottom: 10 }
        source: "../../images/Bg_MenuMiniWidget_Def.png"

        NewValueSelectorList {
            id: compactList
            anchors.fill: parent

            onActivated: {
                if (root.model != null)
                    root.model.commit()
            }
  
            onCurrentIndexChanged: {
                if (activeFocus && root.model != null)
                    root.model.setSelected(mode_Compact, currentIndex);
            }
        }

        NewValueSelectorList {
            id: expandedList
            anchors.fill: parent

            viewDelegate: Item {
                id: delegate
                height: grid.listItemHeight
                width:  parent.width

                Text {
                    text: model.label
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    font.pixelSize: fonts.smallSize
                    font.family: model.label !== "" ? fonts.family : (model.specialFont === "" ? fonts.family : model.specialFont)
                    color: parent.ListView.isCurrentItem ? (parent.activeFocus ? colors.textFocused : colors.textNormal) : colors.textDisabled
                    Behavior on color { ColorAnimation { duration: 50 } }
                }
                Text {
                    text: "(" + model.value + ")"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    font.pixelSize: fonts.smallSize
                    font.family: model.label !== "" ? fonts.family : (model.specialFont === "" ? fonts.family : model.specialFont)
                    color: parent.ListView.isCurrentItem ? (parent.activeFocus ? colors.textFocused : colors.textNormal) : colors.textDisabled
                    Behavior on color { ColorAnimation { duration: 50 } }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (parent.activeFocus === false)
                        {
                            parent.forceActiveFocus()
                            currentIndex = index
                        }
                        else
                        {
                            if (index == currentIndex)
                                root.activated()
                            else // provide an even bigger area for the user to change current
                                currentIndex = index
                        }
                    }
                }
                Keys.onReleased: {
                    if (event.key === keys.select)
                        root.activated()
                }
            }
            onActivated: {
                if (root.model != null)
                    root.model.commit()
            }

            onCurrentIndexChanged: {
                if (activeFocus && root.model != null)
                    root.model.setSelected(mode_Expanded, currentIndex);
            }
        }
    }

    Keys.onReleased: {
        event.accepted = false
        if (event.key === keys.back) {
            if (root.model != null)
                root.model.revert()
            root.visible = false
            event.accepted = true
        }
    }

    Keys.onUpPressed: ;  // eat those events in order to prevent view closure at the top item
    Keys.onLeftPressed: ;  // eat those events or the toolbar menu will become unresponsive
    Keys.onRightPressed: ; // eat those events or the toolbar menu will become unresponsive
    Keys.onDownPressed: ;  // eat those events in order to prevent view closure at the bottom item
}
