import QtQuick 1.1
import se.flir 1.0
//import "../QuickSettings"
import ".."

/// This settings delegate implements a mixture of the settings delegate types.
/// This type is needed as I did not find a way to use item data in SettingsPage list delegate code.
/// Use only when different types of delegates are needed in same settings page list.
/// Otherwise use individual settings delegates.

Item {

    id: listItem
    visible: item.visible
    width: parent.width
    height: visible ? Math.max(iconId.height, defaultId.height) : 0

    property bool current: (listItem.ListView.isCurrentItem && !touchBased) || settingsPage.mousePressedItem === listItem
    property bool slider: item.itemType === "slider"
    property bool icon: item.itemType === "icon"

//    function increaseSlider()
//    {
//        sliderId.percent = Math.min(sliderId.percent + 10, 100)
//    }

//    function decreaseSlider()
//    {
//        sliderId.percent = Math.max(sliderId.percent - 10, 0)
//    }

//    SettingsSliderDelegate {
//        id: sliderId
//        visible: slider
//        current: parent.current
//    }

    SettingsIconDelegate {
        id: iconId
        visible: icon
        current: parent.current
    }

    SettingsDefaultDelegate {
        id: defaultId
        hideSeparator : true
        visible: !slider && !icon
        current: parent.current
    }
}
