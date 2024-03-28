import QtQuick 1.1
import se.flir 1.0
// Touch based control for showing the last taken image (if any). In addition provide a shortcut to the image in the archive

Item {
    id: rootControl

    height: 60 // todo: hardcoded!

    Image {
        id: lastImgBack
        source: !visible ? "":"../images/Bg_Leftbar_ArchiveLastImage_Def.png"
        anchors.fill: parent
    }

    Image {
        id: lastImgImg
        width: grid.lastImageWidth
        height: grid.lastImageHeight
        anchors.horizontalCenter: lastImgBack.horizontalCenter
        anchors.bottom: lastImgBack.bottom
        anchors.bottomMargin: 1 // border width

        source: !visible || archiveHandler.model.lastTakenIndex < 0 ? "" :
                    ("image://archiveImageProvider/thumb|" + archiveHandler.model.lastTakenKey +
                     "|" + archiveHandler.model.lastTakenVersion)
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (archiveHandler.model.lastTakenIndex >= 0) {
                archiveHandler.model.currentIndex = archiveHandler.model.lastTakenIndex
                showArchive()
            }

        }
    }
}
