import QtQuick 1.1

/**
 *  This QML file is the delegate for the C++ class TripleListMenu.
 */

FocusScope {
    width: firstList.width + secondList.width + thirdList.width
    height: grid.spinlistHeight
    id: root
    property QtObject model: null

    function close() { /* Needed for consistency */  }

    MouseArea {
        anchors.fill: parent
        // Catch and ignore all mouse clicks in dialog not handled  specifically
    }

    onModelChanged: {
        // initialize sub-models and selection indexes
        if (root.model)
        {
            // console.debug("TripleListMenu.onModelChanged()")
            firstList .model        = model.choices(0)
            firstList .currentIndex = model.initialIndex(0)
            firstList .width        = Math.max(1, model.widthHint(0)) * grid.cellWidth
            secondList.model        = model.choices(1)
            secondList.currentIndex = model.initialIndex(1)
            secondList.width        = Math.max(1, model.widthHint(1)) * grid.cellWidth
            thirdList .model        = model.choices(2)
            thirdList .currentIndex = model.initialIndex(2)
            thirdList .width        = Math.max(1, model.widthHint(2)) * grid.cellWidth
        }
    //  else
    //      console.error("TripleListMenu.onModelChanged(null)")
    }
    
    BorderImage {
        anchors.fill: parent
        border { left: 10; top: 10; right: 10; bottom: 10 }
        source: "../../images/Bg_MenuMiniWidget_Def.png"

        // Header
        Text {
            id: headerText
            anchors.top: parent.top
            anchors.topMargin: 3*grid.verticalSpacing
            anchors.left: parent.left
            anchors.leftMargin: 4*grid.horizontalSpacing
            font.pixelSize: fonts.smallSize
            font.family: fonts.family
            color: colors.white
            text: root.model === null ? "" : qsTrId(root.model.header) + translation.update
        }

        // Blue line
        BorderImage {
            id: toplineImage
            source: "../../images/Bg_DialoguePopUp_Line_Def.png"
            border { left: 50; top: 0; right: 50; bottom: 0 }
            height: sourceSize.height
            anchors.left: parent.left
            anchors.leftMargin: grid.horizontalSpacing
            anchors.right: parent.right
            anchors.rightMargin: grid.horizontalSpacing
            anchors.top: headerText.bottom
            anchors.topMargin: 3*grid.verticalSpacing
        }

        // Row of lists
        Row {
            anchors.top: toplineImage.bottom
            anchors.bottom: bottomlineImage.top
            anchors.right: parent.right
            anchors.left: parent.left

            NewValueSelectorList {
                id: firstList
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                focus: true
                Keys.onRightPressed: secondList.focus = true
                showScrollArrows: true
                visibleRows: 1

                onActiveFocusChanged: {
                    // console.debug("TripleListMenu.firstList.onActiveFocusChanged(" + activeFocus + "), focus=" + focus)
                    if (focus)
                    {
                        root.model.setColumn(0)
                        setFullHeight(false)
                        showScrollArrows = true
                        footerText.text = root.model.firstFooterArg === "" ? qsTrId(root.model.firstFooter) : qsTrId(root.model.firstFooter).arg(qsTrId(root.model.firstFooterArg))
                    }
                    else
                    {
                        setFullHeight(false)
                        showScrollArrows = false
                    }
                }

                onCurrentIndexChanged: {
                    // console.debug("TripleListMenu.firstList.onCurrentIndexChanged(" + currentIndex + "), activeFocus=" + activeFocus)
                    if (activeFocus && root.model != null)
                        root.model.setSelected(0, currentIndex);
                }

                onActivated: {
                    // console.debug("TripleListMenu.firstList.onActivated()")
                    if (root.model != null)
                        root.model.commit()
                        root.model.closeWholeMenu()
                }
            }

            NewValueSelectorList {
                id: secondList
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                listViewHeight: grid.cellHeight
                Keys.onLeftPressed: firstList.focus = true
                Keys.onRightPressed: thirdList.focus = true
                showScrollArrows: false
                visibleRows: 1

                onActiveFocusChanged: {
                    // console.debug("TripleListMenu.secondList.onActiveFocusChanged(" + activeFocus + "), focus=" + focus)
                    if (focus)
                    {
                        root.model.setColumn(1)
                        setFullHeight(false)
                        showScrollArrows = true
                        footerText.text = root.model.secondFooterArg === "" ? qsTrId(root.model.secondFooter) : qsTrId(root.model.secondFooter).arg(qsTrId(root.model.secondFooterArg))
                    }
                    else
                    {
                        setFullHeight(false)
                        showScrollArrows = false
                    }
                }

                onCurrentIndexChanged: {
                    // console.debug("TripleListMenu.secondList.onCurrentIndexChanged(" + currentIndex + "), activeFocus=" + activeFocus)
                    if (activeFocus && root.model != null)
                        root.model.setSelected(1, currentIndex);
                }

                onActivated: {
                    // console.debug("TripleListMenu.secondList.onActivated()")
                    if (root.model != null)
                        root.model.commit()
                        root.model.closeWholeMenu()
                }
            }

            NewValueSelectorList {
                id: thirdList
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                listViewHeight: grid.cellHeight
                Keys.onLeftPressed: secondList.focus = true
                showScrollArrows: false
                visibleRows: 1

                onActiveFocusChanged: {
                    // console.debug("TripleListMenu.thirdList.onActiveFocusChanged(" + activeFocus + "), focus=" + focus)
                    if (focus)
                    {
                        root.model.setColumn(2)
                        setFullHeight(false)
                        showScrollArrows = true
                        footerText.text = root.model.thirdFooterArg === "" ? qsTrId(root.model.thirdFooter) : qsTrId(root.model.thirdFooter).arg(qsTrId(root.model.thirdFooterArg))
                    }
                    else
                    {
                        setFullHeight(false)
                        showScrollArrows = false
                    }
                }

                onCurrentIndexChanged: {
                    // console.debug("TripleListMenu.thirdList.onCurrentIndexChanged(" + currentIndex + "), activeFocus=" + activeFocus)
                    if (activeFocus && root.model)
                        root.model.setSelected(2, currentIndex);
                }

                onActivated: {
                    // console.debug("TripleListMenu.thirdList.onActivated()")
                    if (root.model)
                        root.model.commit()
                        root.model.closeWholeMenu()
                }
            }
        }

        // Blue line
        BorderImage {
            id: bottomlineImage
            source: "../../images/Bg_DialoguePopUp_Line_Def.png"
            border { left: 50; top: 0; right: 50; bottom: 0 }
            height: sourceSize.height
            anchors.left: parent.left
            anchors.leftMargin: grid.horizontalSpacing
            anchors.right: parent.right
            anchors.rightMargin: grid.horizontalSpacing
            anchors.bottom: footerText.top
            anchors.bottomMargin: 2*grid.verticalSpacing
        }

        // Footer
        Text {
            id: footerText
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3*grid.verticalSpacing
            anchors.left: parent.left
            anchors.leftMargin: 4*grid.horizontalSpacing
            font.pixelSize: fonts.smallSize
            font.family: fonts.family
            color: colors.white
            text: ""
        }
    }

    Keys.onReleased: {
        // console.debug("TripleListMenu.Keys.onReleased(" + event.key + ")")
        event.accepted = false
        if (event.key === keys.back) {
            if (root.model)
                root.model.revert()
            root.visible =  false
            event.accepted = true
        }
    }
    Keys.onUpPressed:    ; // eat those events
    Keys.onDownPressed:  ; // eat those events
    Keys.onLeftPressed:  ; // eat those events
    Keys.onRightPressed: ; // eat those events
}
