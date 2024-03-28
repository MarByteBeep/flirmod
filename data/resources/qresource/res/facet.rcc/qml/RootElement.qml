import QtQuick 1.1
import se.flir 1.0
import System 1.0


// RootElement
// -------
// The root Item is the parent of all other QML elements.
Rectangle {
    id: root
    width: grid.width
    height: grid.height
	color: colors.transparent
    visible: !hideAll

    // We want to read all touch events if viewFinder is enabled
    // Below Item is top level item that reads all touch events
    Item {
        id: touchBlockerId
        anchors.fill: parent
        z: 1000000000
        visible: flirSystem.LCDEnabled === false
        onVisibleChanged: {
            if (visible)
                console.log("Blocking all touch events. The view finder is enabled.")
        }
        MouseArea {
            enabled: touchBlockerId.visible
            anchors.fill: parent
            preventStealing: true
            onClicked: console.log("RootElement is blocking touch.")
        }
    }

    Image {
        id: laserOnIndicator
        objectName: "laserOnIndicator"
        source: flirSystem.laserActive ? "../images/Sc_Status_Laser.png" : ""
        z: 10000
        transformOrigin: Item.TopLeft
        visible: flirSystem.laserActive

        function updateLocation(coordinateReference, placeholderItem) {
            var localTransform = mapFromItem(coordinateReference,
                                             placeholderItem.x,
                                             placeholderItem.y)
            var rootTransform = mapToItem(root, localTransform.x,
                                          localTransform.y)

            laserOnIndicator.x = rootTransform.x
            laserOnIndicator.y = rootTransform.y
            laserOnIndicator.rotation = coordinateReference.rotation
        }
    }
}
