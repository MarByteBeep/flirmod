import QtQuick 1.1

//! Spinner, a progress-less status indicator.
//!
//! Provides an item for rotating an selection of circles for as long as it is visible.
//! For instance until the current action have been finished.
//! @ingroup QML
Item {
    id: spinner

    width: 24
    height: width

    // 8 circles
    Repeater {
        model: 8
        Rectangle {
            width: spinner.width / 4
            radius: width
            smooth: true
            height: spinner.width / 4
            color: "white"
            opacity: 1 / (index)
            x: (spinner.width - height) / 2 + Math.sin(Math.PI * index / 4) * ((spinner.width - width) / 2)
            y: (spinner.height - height)/ 2 + Math.cos(Math.PI * index / 4) * ((spinner.height - height) / 2)
        }
    }

    // Is there a better way to do this?
    property int steps: 0
    rotation: steps * 45

    NumberAnimation on steps {
        running: spinner.visible; from: 0; to: 8
        loops: Animation.Infinite; duration: 800
    }
}
