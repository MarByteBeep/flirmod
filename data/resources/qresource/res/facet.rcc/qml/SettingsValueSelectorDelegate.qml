import QtQuick 1.1

Item {
                              id: listItem
                         visible: item.visible
//                         width: parent.width/settingsPage.page.model.itemsCount // listItem.ListView.count
                          height: parent.height
    property variant nestedModel: item.nestedModel

    MouseArea {
        anchors.fill: parent

        onPressed:      {mouse.accepted = settingsPage.page.onMousePressed(index);}
        onReleased:     {mouse.accepted = settingsPage.page.onMouseReleased(index);}
        onCanceled:     {settingsPage.page.onMouseCanceled(index);}
        onExited:       {settingsPage.page.onMouseCanceled(index);}
        onPressAndHold: {mouse.accepted = settingsPage.page.onLongPress(index);}
    }

    // column of navigation arrows and sub-model list
    Item {
        anchors.   top: parent.top
        anchors.  left: parent.left
        anchors. right: delimiter.left
        anchors.bottom: parent.bottom

        Connections {
            target: nestedModel

            onScrollToIndexRequest: {
                list.positionViewAtIndex(index, ListView.Center)
            }
            onActiveChanged: {
                if (active) {
                    focus = true
                    list.forceActiveFocus()
                }
            }
        }

        NavigationArrow {
                                  id: arrowUp
                             visible: nestedModel.active
                           isUpArrow: true
            anchors.horizontalCenter: parent.horizontalCenter
                         anchors.top: parent.top

            onTriggered: {
                nestedModel.decCurrentIndex()
            }
        }
       
        ListView {
                                     id: list
                                  model: nestedModel
                           currentIndex: model.currentIndex
                                   clip: true
                   anchors.        fill: parent
                   anchors.   topMargin: grid.settingsSpinArrowHeight
                   anchors.bottomMargin: grid.settingsSpinArrowHeight
                         boundsBehavior: Flickable.StopAtBounds
                  highlightMoveDuration: 0
                                spacing: grid.settingsRowSpacing
            highlightFollowsCurrentItem: true
                preferredHighlightBegin: (height - grid.settingsSpinRowHeight) / 2
                  preferredHighlightEnd: preferredHighlightBegin
                     highlightRangeMode: ListView.StrictlyEnforceRange

            delegate: Rectangle {
                height: grid.settingsSpinRowHeight
                 width: parent.width
                 color: "black"

                // center-aligned value
                Text {
                                          id: itemValue
                    anchors.  verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                                        text: value
                                       color: parent.ListView.isCurrentItem ? (nestedModel.active ? colors.textFocused : colors.textNormal) : colors.textDisabled
                              font.pixelSize: fonts.smallSize
                              font.   family: fonts.family


                    Behavior on color {
                        ColorAnimation { duration: 50 }
                    }
                }
                MouseArea {
                    anchors.fill: parent

                    onPressed:      {mouse.accepted = nestedModel.onMousePressed(index);}
                    onReleased:     {mouse.accepted = nestedModel.onMouseReleased(index);}
                    onCanceled:     {nestedModel.onMouseCanceled(index);}
                    onExited:       {nestedModel.onMouseCanceled(index);}
                    onPressAndHold: {mouse.accepted = nestedModel.onLongPress(index);}
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
        } // list
        
        NavigationArrow {
                                  id: arrowDown
                             visible: nestedModel.active
                           isUpArrow: false
            anchors.horizontalCenter: parent.horizontalCenter
                      anchors.bottom: parent.bottom

            onTriggered: {
                nestedModel.incCurrentIndex()
            }
        }
    } // Item

    Text {
                            id: delimiter
                          text: nestedModel.delimiter
                         color: colors.textNormal
                font.pixelSize: fonts.smallSize
                font.   family: fonts.family
        anchors.         right: parent.right
        anchors.verticalCenter: parent.verticalCenter
                         width: grid.horizontalSpacing
    } // delimiter
}
