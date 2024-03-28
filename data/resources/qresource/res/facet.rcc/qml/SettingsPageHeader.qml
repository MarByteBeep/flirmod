import QtQuick 1.1


Item {  // Header (with back button and view title).
    id: headerItem

    property alias text: headerText.text

    signal clicked()

    Column {
        id: headerColumn
        anchors.fill: parent

        Row {   // Row containing the back button and view title.
            id: headerRow
            height: headerItem.height - grid.separatorThickness
            spacing: grid.unit + 2 * grid.settingsRowSpacing
            x: grid.unit * 3
            width: headerColumn.width - x

            Item {  // Top left arrow button
                id: arrow
                anchors.verticalCenter: parent.verticalCenter
                height: grid.settingsRowHeight - 2 * grid.settingsRowSpacing
                width:  height

                ShadedRectangle {   // Background image when the button is pressed.
                    id: arrowBkgr
                    anchors.fill: parent
                    visible: arrowArea.pressed
                }

                Image {
                    id: arrowIcon
                    anchors.centerIn: parent
                    source: "../images/Ic_List_ArrowLeft_Def.png"
                }

                MouseArea {
                    id: arrowArea
                    anchors.fill: parent
                    onClicked: {
                        headerItem.clicked()
                    }
                }
            }

            Text {
                id: headerText
                color: colors.textFocused
                anchors.verticalCenter: parent.verticalCenter
                width: headerRow.width - arrow.width - headerRow.spacing - (translation.layoutDirection === Qt.LeftToRight ? 0 : 3 * grid.unit)
                font.pixelSize: fonts.smallSize
                font.family: fonts.family
                font.bold: true
                horizontalAlignment: translation.layoutDirection === Qt.LeftToRight ? Text.AlignLeft : Text.AlignRight
            }
        }

        HorizontalSeparatorLine {
            width: parent.width
            height: grid.separatorThickness
        }
    }
}
