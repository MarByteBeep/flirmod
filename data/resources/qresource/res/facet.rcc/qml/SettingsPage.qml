import QtQuick 1.1
import se.flir 1.0

/**
 * SettingsPage - the typical Settings page, with a header, list of items, and optional footer.
 */

Rectangle {
                       id: settingsPage
                    width: grid.width
                   height: grid.height
    property int pageSlot: settingsViewMgr.pageSlot(parent, settingsPage)                   // required by SettingsViewMgr
    property variant page: (pageSlot === 0 ? settingsViewMgr.page0 : settingsViewMgr.page1) // required by SettingsViewMgr
                  visible: page.visible
                    color: "black"

    property Item mousePressedItem: null
    property int mousePressedIndex: -1

    signal backClicked
    signal itemTriggered(int item)

    Component {
        id: undefinedDelegate
        Item {
            // empty
            anchors.fill: parent
        }
    }

    Component {
        id: defaultDelegate
        SettingsDefaultDelegate {
        }
    }

    Component {
        id: radioGroupDelegate
        SettingsRadioGroupDelegate {
        }
    }

    Component {
        id: radioValuesDelegate
        SettingsRadioValuesDelegate {
        }
    }

    Component {
        id: radioLanguageDelegate
        SettingsRadioLanguageDelegate {
        }
    }
    
    Component {
        id: nameValueDelegate
        SettingsNameValueDelegate {
        }
    }

    Component {
        id: nameValueSelectorDelegate
        SettingsNameValueSelectorDelegate {
             width: list.width/page.model.itemsCount
        }
    }

    Component {
        id: valueSelectorDelegate
        SettingsValueSelectorDelegate {
             width: list.width/page.model.itemsCount
        }
    }

    Component {
        id: spreadSheetDelegate
        SettingsSpreadSheetDelegate {
        }
    }
    
    Component {
        id: extendedDelegate
        SettingsExtendedDelegate {
        }
    }

    Component {
        id: mixedDelegate
        SettingsMixedDelegate { }
    }

    Connections {
        target: page

        onScrollToIndexRequest: {
            list.positionViewAtIndex(index, ListView.Contain)
        }
    }

    Item {
        anchors.fill: parent

        Item {
                     id: topMargin
                  width: parent.width
                 height: grid.topBorder
            anchors.top: parent.top
        }

        SettingsPageHeader {
                       id: header
                     text: page.header
              anchors.top: topMargin.bottom
             anchors.left: parent.left
            anchors.right: parent.right
                   height: grid.cellHeight

            onClicked: {
                if (page.orientation == ListView.Horizontal && !cancelInSettings)
                    page.triggerIndex(list.currentIndex)
                else
                    page.goBack()
            }
        }

        Item {  // Spacer
            id: topSpacer
            anchors.top: header.bottom
            width: 1;
            height: grid.settingsRowSpacing
        }

        ListView {
                                      id: list
                                   model: page.model
                             orientation: model.orientation
                            currentIndex: model.currentIndex
            property bool needsScrollbar: contentHeight > height && orientation == ListView.Vertical
                                   focus: true
                          anchors.  left: parent.left
                          anchors. right: parent.right
                          anchors.   top: topSpacer.bottom
                          anchors.bottom: bottomSpacer.top
                                    clip: true
                          boundsBehavior: Flickable.StopAtBounds
                                 spacing: 0
             highlightFollowsCurrentItem: false
                 preferredHighlightBegin: grid.cellHeight + grid.verticalSpacing
                   preferredHighlightEnd: list.height - grid.cellHeight - grid.verticalSpacing
                      highlightRangeMode: ListView.ApplyRange

            
        //  onModelChanged: {
        //      console.debug("SettingsPage[" + pageSlot + "][" + page.ptr + "].list.onModelChanged(): model[" + model.ptr + "]={delegateType=" + model.delegateType + ", itemsCount=" + model.itemsCount + "}")
        //  }

        //  onCurrentIndexChanged: {
        //      console.debug("SettingsPage[" + pageSlot + "][" + page.ptr + "].list.onCurrentIndexChanged(" + currentIndex + ")")
        //  }

            delegate: {
                switch (page.model.delegateType) {
                    case SettingsModel.DELEGATE_DEFAULT:           return defaultDelegate
                    case SettingsModel.DELEGATE_RADIOGROUP:        return radioGroupDelegate
                    case SettingsModel.DELEGATE_RADIOVALUES:       return radioValuesDelegate
                    case SettingsModel.DELEGATE_RADIOLANGUAGE:     return radioLanguageDelegate
                    case SettingsModel.DELEGATE_NAMEVALUE:         return nameValueDelegate
                    case SettingsModel.DELEGATE_NAMEVALUESELECTOR: return nameValueSelectorDelegate
                    case SettingsModel.DELEGATE_VALUESELECTOR:     return valueSelectorDelegate
                    case SettingsModel.DELEGATE_SPREADSHEET:       return spreadSheetDelegate
                    case SettingsModel.DELEGATE_EXTENDED:          return extendedDelegate
                    case SettingsModel.DELEGATE_MIXED:             return mixedDelegate // Mix of slider and default
                }
                // sadly, QML does not understand negative enums, or negative values inside switch()
                return undefinedDelegate
            }

            highlight: BorderImage {
                               visible: page.highlightVisible
                property Item currItem: touchBased ? mousePressedItem : list.currentItem
                                     x: grid.horizontalSpacing
                                     y: currItem ? currItem.y + (grid.cellHeight - height) / 2 : 0
                                 width: list.width - scrollBar.width - grid.horizontalSpacing*2
                                height: grid.settingsRowHeight
                                source: "../images/Bg_FullScreen_MarkerStretch_Foc.png"
                                border { left: 10; top: 10; right: 10; bottom: 10 }
            }

            Item { // decorations :)
                anchors.fill: parent
                visible: list.needsScrollbar;

                // Top scroll fader
                Image {
                    id: topScrollCover
                    visible: list.visibleArea.yPosition > 0
                    source: "../images/Bg_Options_ScrollCoverTop.png"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Bottom scroll fader
                Image {
                    id: bottomScrollCover
                    visible: list.visibleArea.yPosition < 1 - list.visibleArea.heightRatio - 0.01;
                    source: "../images/Bg_Options_ScrollCoverBottom.png"
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // Scroll bar
                Rectangle {
                    id: scrollBar
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: grid.horizontalSpacing
                    color: "#323232"

                    // Slider
                    Rectangle {
                        color: "#0066cc"
                        anchors.right: parent.right
                        width: parent.width
                        height: list.height * list.visibleArea.heightRatio
                        y: list.visibleArea.yPosition * list.height
                    }
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

        Item {  // Spacer
            id: bottomSpacer
            anchors.bottom: footer.top
            width: 1;
            height: grid.settingsRowSpacing
        }

        // Footer
        SettingsPageFooter {
                        id: footer
                   visible: page.footerEnabled
                      text: page.footer
                      icon: page.footerIcon === "" ? "" : "../images/" + page.footerIcon + "_Def.png"
              anchors.left: parent.left
             anchors.right: parent.right
            anchors.bottom: bottomMargin.top
                    height: visible ? grid.cellHeight : 0
        }

        Item {
                        id: bottomMargin
                     width: parent.width
                    height: grid.bottomBorder
            anchors.bottom: parent.bottom
        }
    }
}
