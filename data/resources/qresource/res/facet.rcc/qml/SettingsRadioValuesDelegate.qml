import QtQuick 1.1
import se.flir 1.0

/// Reduced SettingsPage delegate for containing label, value, and radio-mark

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

    // left-aligned block
    Row {
                    height: parent.height
              anchors.left: parent.left
        anchors.leftMargin: grid.horizontalSpacing*3
                   spacing: grid.horizontalSpacing

        // label
        Text {
                                id: settingTextItem
            anchors.verticalCenter: parent.verticalCenter
                             color: current ? colors.textFocused : (item.enabled ? colors.textNormal : colors.textDisabled)
                    font.pixelSize: fonts.smallSize
                       font.family: fonts.family
                              text: item.label
        }
    }

    // right-aligned block
    Row {
                     height: parent.height
              anchors.right: parent.right
        anchors.rightMargin: grid.horizontalSpacing*3

        // value
        Text {
                                id: valueTextItem
            anchors.verticalCenter: parent.verticalCenter
                             color: current ? colors.textNormal : colors.textDisabled
                    font.pixelSize: fonts.smallSize
                       font.family: fonts.family
                              text: item.value
        }

        // bullet mark
        Image {
                                id: choiceIndicator
            anchors.verticalCenter: parent.verticalCenter
                           visible: item.hasCheckIndicator
                             width: grid.iconWidth
                            height: grid.iconHeight
                            source: "../images/Ic_ListChoice_RadioButton" + (item.checked ? "Checked" : "") + (current ? "_Sel.png" : "_Def.png")
        }
    }
}
