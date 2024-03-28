import QtQuick 1.1

Item {
    id: listShadow
    property string color: "black"
    property real radius: 0

    height: grid.cellHeight

    Rectangle {
        id: main
        anchors.fill: parent
        radius: parent.radius
        smooth: true

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 0.30; color: "#00000000" }
            GradientStop { position: 0.70; color: listShadow.color }
            GradientStop { position: 1.0; color: listShadow.color }
        }
    }
}


