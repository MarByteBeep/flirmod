import QtQuick 1.1
import se.flir 1.0

/// SettingsPage delegate containing just an icon

Item {
    id: listItem
    visible: item.visible
    width: parent.width
    height: visible ? iconId.height : 0

    property bool current: false

    MouseArea {
        anchors.fill: parent
    }

    Image {
        id: iconId
        x: grid.settingsRowHeight / 4
        anchors.verticalCenter: parent.verticalCenter
        source: item.leftIcon === "" ? "" : "../images/" + item.leftIcon + "_Sel.png"
        height: sourceSize.height
        width: sourceSize.width
    }
}
