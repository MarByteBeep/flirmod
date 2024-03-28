import QtQuick 1.1
// WizardHeader
// ------
// Header at top of Wizard

Item {

    // Properties
    id: wizardHeader
    height: 0//80
    width: parent.width
    property int currentTab: 0
    property string currentTabName: ""
    property string currentTabTitle: ""
    property int numberOfTabs: 1
    property int horMarging: 40
    property bool staticHeader: false
    property string title: ""

    // This is for static headers, just display the label
    Rectangle {
        height: wizardHeader.height
        visible: staticHeader
        anchors.fill: parent
        color: "#00000000"

        Text {
            id: staticHeaderText
           // text: (currentTabTitle != "" ? qsTrId(currentTabTitle) : qsTrId(title)) + translation.update
            font.family: fonts.family
            font.pixelSize: fonts.mediumSize
            height: 0//48
            color: colors.textFocused
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }
    }

    // This is for dynamic headers, display current page label et.c.
    Row {

        id: headerRow
        anchors.fill: parent
        anchors.leftMargin: horMarging
        anchors.rightMargin: horMarging
        visible: !staticHeader

        Repeater {
            model: numberOfTabs

            Item {
                width: headerRow.width / numberOfTabs
                height: wizardHeader.height

                function placeX (textWidth) {
                    if (index !== currentTab)
                        return 0
                    else
                    {
                        var desiredX = -(textWidth - width) / 2
                        var parentCoords = mapToItem(wizardHeader, desiredX, 0)
                        if (parentCoords.x < horMarging)
                            desiredX += horMarging - parentCoords.x
                        else if (parentCoords.x + textWidth > grid.width - horMarging)
                            desiredX -= textWidth + parentCoords.x - grid.width + horMarging
                        return desiredX
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    x: parent.placeX(implicitWidth)
                    text: index === currentTab ? qsTrId(currentTabName) + translation.update : ""
                    font.family: fonts.family
                    font.pixelSize: fonts.miniSize
                    color: "white"
                }

                Rectangle {
                    width: parent.width - 10
                    height: 1//2//(index + 1) === currentTab ? 2 : 1
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: index === currentTab ? colors.textFocused : colors.textDisabled//"gray"
                }
            }
        }
    }
}
