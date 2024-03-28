import QtQuick 1.1

Item {
    id: footerItem
    property alias text: footerText.text
    property alias icon: footerIcon.source

    width: grid.width
    height: grid.cellHeight + grid.bottomMargin

    Column {
        anchors.fill: parent

        HorizontalSeparatorLine {
            id: separator
            width: parent.width
        }

        Row {
            height: parent.height - separator.height
            width: footerItem.width - x - (translation.layoutDirection === Qt.LeftToRight || icon.width !== 0 ? 0 : 3 * grid.unit)
            spacing: grid.verticalSpacing
            layoutDirection: translation.layoutDirection
            x: grid.leftBorder * 2

            Image {
                id: footerIcon
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: footerText
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - icon.width - parent.spacing
                horizontalAlignment: translation.layoutDirection === Qt.LeftToRight ? Text.AlignLeft : Text.AlignRight
                color: colors.textNormal
                font.pixelSize: fonts.smallSize
                font.family: fonts.family
                wrapMode: Text.Wrap
            }
        }
    }
}
