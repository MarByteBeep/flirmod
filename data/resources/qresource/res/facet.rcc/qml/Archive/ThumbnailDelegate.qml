import QtQuick 1.1
import se.flir 1.0

// ThumbnailDelegate
// -----------------
// Delegate for the ThumbnailArchive element.

Item {
    id: delegateRootItem

    // Property values
    width: grid.archiveCellWidth
    height: grid.archiveCellHeight
    objectName: "archiveThumbDelegate"

    // Multi select highlight
    Rectangle {
       id: multiSelectHighlightId
       visible: isMultiSelectSetMember
       width: grid.archiveCellWidth
       height: grid.archiveCellHeight
       color: "#A0A0A0"
    }

    // The "stack" background
    Rectangle {
        id: secondThumbTop
        anchors.horizontalCenter: parent.horizontalCenter
        y: grid.archiveTopMargin
        width: grid.archiveThumb2Width
        height: grid.archiveThumb2Height
        visible: groupSize > 1
        color: colors.darkGrey
        border.color: colors.mediumGrey
        border.width: 1
    }

    // Thumbnail
    Image {

        id: thumbnail
        y: grid.archiveTopMargin + grid.archiveThumb2Height
        width: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ? grid.pdfThumbWidth : grid.thumbnailWidth
        height: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ? grid.pdfThumbHeight : grid.thumbnailHeight
        sourceSize.width: width
        sourceSize.height: height
        anchors.horizontalCenter: parent.horizontalCenter
        asynchronous: true
        cache: false
        source: thumbnailArchive.visible ?
                    (groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ?
                        "image://reportImageProvider/thumb|" + groupPrimaryPath :
                        "image://archiveImageProvider/thumb|" + currentPrimaryImageKey + "|" + thumbVersion) : ""

        BorderImage {
            anchors.fill: parent
            asynchronous: false
            cache: true
            border { left: 5; top: 5; right: 5; bottom: 5 }
            source: thumbnail.status === Image.Ready ?
                        "../../images/Bg_ArchiveViewThumb_ImgOutline_" +
                        (delegateRootItem.GridView.isCurrentItem && !archiveHandler.model.multiSelectMode && !touchBased ? "Sel.png" : "Def.png") :
                        "../../images/Bg_ArchiveViewThumb_ImgNotLoaded_Def.png"
        }

        Image {
            anchors.centerIn: parent
            source: groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_IMAGE ? "" :
                    groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_VIDEO ? "../../images/Sc_Video_DirectplayThumb_Def.png" :
                    groupModel.itemType === ArchiveGroupModel.ITEM_TYPE_REPORT ?
                        thumbnail.status === Image.Ready ? "" :
                           (thumbnail.status === Image.Loading ?
                                "../../images/Bg_ArchiveViewThumb_ImgNotLoadedCenter_Def.png" :
                                "../../images/Bg_ArchiveViewThumb_ImgNotFoundCenter_Def.png") : ""
        }
    }

    // File name
    Text {
        anchors.horizontalCenter: thumbnail.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: grid.archiveVerticalSpace
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideMiddle
        font.family: fonts.family
        font.pixelSize: fonts.smallSize
        color: archiveHandler.model.multiSelectMode ? (isMultiSelectSetMember ? colors.textFocused : colors.textNormal) :
                                                      (delegateRootItem.GridView.isCurrentItem && (!touchBased || highLightTimer.running) ? colors.textFocused :colors.textNormal)
        text: groupName
    }
}
