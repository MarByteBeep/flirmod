import QtQuick 1.1
import se.flir 1.0

// PreviewDelegate
// ----------------
// Delegate for the PreviewArchiveGroupView element.

Rectangle {

    // Property values
    property variant videoPlayIcon

    id: previewDelegate
    width: grid.width
    height: grid.height
    color: colors.background

    Component.onCompleted: {
        groupView.highlightMoveDuration = 1
        groupView.currentIndex = groupView.model.currentIndex
        groupView.highlightMoveDuration = 100
    }

    // Functions
    function decrementCurrentIndex() {
        groupView.decrementCurrentIndex()
    }

    function incrementCurrentIndex() {
        groupView.incrementCurrentIndex()
    }

    function resetCurrentIndex() {
        groupView.currentIndex = 0
    }

    // The view showing the current image

    // Expose the current source path to the archive.
    property variant frontSource: groupView.currSource

    PathView {
        id: groupView
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -grid.verticalSpacing
        width: grid.previewWidth
        height: grid.previewHeight
        model: groupModel

        // The current path will be stored here by the delegate.
        property string currSource: "someValue"

        delegate: Image {
            id: imageItem
            width:  groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ? grid.pdfPreviewWidth  : grid.previewWidth
            height: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ? grid.pdfPreviewHeight : grid.previewHeight
            z: PathView.pathZ
            scale: PathView.pathScale
            opacity: PathView.pathOpacity
            asynchronous: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ? true : false
            cache: false
            smooth: true
            source: previewArchive.visible ? imageSource : ""
            fillMode: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ? Image.Stretch :Image.PreserveAspectFit
            property string imageSource: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ?
                                             "image://reportImageProvider/full|" + groupPrimaryPath +"|"+archiveHandler.model.reportPage :
                                             "image://archiveImageProvider/preview|" + imageKey + "|" +
                                                imageVersion + "|" + currentPrimaryImageKey

            // Propagate the current path up so it can be read from the outside! (slightly complicated...)
            Binding {
                property: "currSource"
                target: groupView
                value: imageSource
                when: imageItem.PathView.isCurrentItem
            }

            Binding {
                property: "videoPlayIcon"
                target: previewDelegate
                value: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_VIDEO ?videoIndicationOverlay : null
                when: imageItem.PathView.isCurrentItem
            }

            Rectangle {
                anchors.fill: parent
                border.color: "gray"
                color: "transparent"
            }

            Image {
                anchors.centerIn: parent
                source: (imageItem.status === Image.Ready) ||
                        (groupModel.itemSubType === ArchiveGroupModel.ITEM_SUBT_CSQ) ? "" :
                                                           (imageItem.status === Image.Loading ?
                                                                "../../images/Bg_ArchiveViewPreview_ImgNotLoadedCenter_Def.png" :
                                                                "../../images/Bg_ArchiveViewPreview_ImgNotFoundCenter_Def.png")
            }

            Image{
                id: videoIndicationOverlay
                objectName: "videoIndicationOverlayObject"
                visible: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_VIDEO
                anchors.centerIn: parent
                source: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_VIDEO ? "../../images/Sc_Video_Directplay_Def.png" : ""
            }
        }

        path: Path {
            startX: grid.previewWidth / 2
            startY: grid.previewHeight / 2
            PathAttribute { name: "pathZ"; value: 1.0 }
            PathAttribute { name: "pathScale"; value: 1.0 }
            PathAttribute { name: "pathOpacity"; value: 1.0 }
            PathQuad {
                x: grid.previewWidth / 2
                y: grid.previewHeight / 2 -grid.archiveImg2OffsetY
                controlX: grid.previewWidth / 2
                controlY: grid.previewHeight / 2 - (2*grid.archiveImg2OffsetY)
            }
            PathPercent{ value: 0.50 }
            PathAttribute { name: "pathZ"; value: 0.0 }
            PathAttribute { name: "pathScale"; value: grid.archiveImgScale }
            PathAttribute { name: "pathOpacity"; value: 0.5 }
        }

        onCurrentIndexChanged: model.currentIndex = currentIndex
    }
}
