import QtQuick 1.1
import se.flir 1.0

/// A delegate for the SettingsPage

Item {
         id: listItem
    visible: item.visible
      width: parent.width
     height: visible ? grid.cellHeight : 0

    property bool current: (listItem.ListView.isCurrentItem && !touchBased) || settingsPage.mousePressedItem === listItem

    HorizontalSeparatorLine {
               visible: touchBased && index > 0
           anchors.top: parent.top
                 width: parent.width
                height: visible ? grid.separatorThickness : 0
                source: visible ? "../images/Bg_Options_LineGray_Def.png" : ""
    }

    MouseArea {
        anchors.fill: parent

        onPressed: {
            if (touchBased)
                settingsPage.mousePressedItem = listItem;
            mouse.accepted = settingsPage.page.onMousePressed(index);
        }
        onReleased: {
            mouse.accepted = settingsPage.page.onMouseReleased(index);
            if (touchBased)
                settingsPage.mousePressedItem = null;
        }
        onCanceled: {
            settingsPage.page.onMouseCanceled(index);
            if (touchBased)
                settingsPage.mousePressedItem = null;
        }
        onExited: {
            settingsPage.page.onMouseCanceled(index);
            if (touchBased)
                settingsPage.mousePressedItem = null;
        }
        onPressAndHold: {
            mouse.accepted = settingsPage.page.onLongPress(index);
        }
    }

    Text {
        id: settingTextItem
        anchors.verticalCenter: parent.verticalCenter
        x: grid.settingsLeftMargin

        color: current ? colors.textFocused : colors.textNormal
        font.pixelSize: fonts.smallSize
        font.family: item.font == "" ? fonts.family : item.font
        text: item.label
    }

    Image {
        anchors.right: parent.right
        anchors.rightMargin: grid.horizontalSpacing * 3
        anchors.verticalCenter: parent.verticalCenter
        source: "../images/Ic_ListChoice_RadioButton" +
                    (item.checked ? "Checked" : "") +
                    (current ? "_Sel.png" : "_Def.png")
    }
}
