import QtQuick 1.1
import se.flir 1.0

/// A delegate for the SettingsPage

Item {
         id: listItem
    visible: item.visible
      width: parent.width
     height: visible ? grid.cellHeight : 0

    property bool current: (listItem.ListView.isCurrentItem && !touchBased) || settingsPage.mousePressedItem === listItem

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

    Row {
        height: parent.height
        x: grid.leftMargin + grid.horizontalSpacing * 3

        Text {
            id: settingTextItem
            anchors.verticalCenter: parent.verticalCenter
            color: item.enabled ? (current ? colors.textFocused : colors.textNormal) : colors.textDisabled
            font.pixelSize: fonts.smallSize
            font.family: fonts.family
            text: item.label

            clip: true
            width: grid.cellWidth * ((grid.horizontalCellCount - 1) / 2)
        }

        Item {
            width: grid.horizontalSpacing * 2
            height: 1
        }

        Text {
            id: valueTextItem
            anchors.verticalCenter: parent.verticalCenter
            color: current ? colors.textNormal : colors.textDisabled
            font.pixelSize: fonts.smallSize
            font.family: fonts.family
            text: item.value

            clip: true
            width: grid.cellWidth * ((grid.horizontalCellCount - 1) / 2)
        }
    }

    Row {
        id: rightRow
        height: parent.height
        anchors.right: parent.right
        anchors.rightMargin: grid.horizontalSpacing
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: radioButton
            anchors.verticalCenter: parent.verticalCenter
            visible: item.hasCheckIndicator
            source: "../images/Ic_ListChoice_RadioButton" +
                        (item.checked ? "Checked" : "") +
                        (current ? "_Sel.png" : "_Def.png")
        //  MouseArea {
        //      anchors.fill: parent
        //      enabled: modelData.enabled
        //      onClicked: settings.triggerIndex(index)
        //  }
        }

        Item {
            width: grid.horizontalSpacing * 2
            height: parent.height
            visible: radioButton.visible
        }

        Row {
            visible: item.hasLeftIcon
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: iconImage
                source: parent.visible ?  "../images/" + item.leftIcon + (current ? "_Sel" : "_Def") + ".png" : ""
            }

            Item {
                width: grid.leftMargin + grid.horizontalSpacing * 3
                height: 1
            }
        }

        Image {
            id: arrowImage
            anchors.verticalCenter: parent.verticalCenter
            visible: item.hasSubMenu
            source:  item.hasSubMenu ? "../images/Ic_List_ArrowRight" + (current ? "_Sel.png" : "_Def.png") : ""
        }
    }

    HorizontalSeparatorLine {
        anchors.bottom: parent.bottom
        width: parent.width
        height: grid.separatorThickness
        source: "../images/Bg_Options_LineGray_Def.png"
        visible: touchBased && index < list.count - 1
    }
}
