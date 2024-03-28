import QtQuick 1.1
import se.flir 1.0
import ".."

// Archive
// -------
// The archive. Uses a ThumbnailArchive and a PreviewArchive to show those views of the archive images.
// The PreviewArchive has in turn two sub states: groupView and fullView.

Rectangle {

    // Signals
    signal hideArchive

    // Properties
    id: root
    width: grid.width
    height: grid.height
    objectName: "archive"
    color: colors.background

    // Handle show and hide
    function hide() {
        if (greenbox.appState === GreenBox.FacetPlaybackView)
            return
        archiveHandler.view = ArchiveHandler.Invisible
    }

    function show() {
        root.visible = true // Needs this to accept focus
        scope.forceActiveFocus()
        if (greenbox.prevAppState === GreenBox.FacetEditView ||
            greenbox.prevAppState === GreenBox.FacetSketchView ||
            greenbox.prevAppState === GreenBox.FacetPlaybackView ||
            archiveHandler.view === ArchiveHandler.Fullscreen )
        {
            archiveHandler.view = ArchiveHandler.ImageSelector
        }
        else
        {
            if (archiveEnterThumbnails)
            {
                archiveHandler.view = ArchiveHandler.Thumbnails
                thumbnailArchive.forceActiveFocus()
            }
            else
                archiveHandler.view = ArchiveHandler.ImageSelector
        }
    }

    function requestFocusForPreview() {
        if (!messageSpinnerHandler.showing)
            previewArchive.forceActiveFocus()
    }

    FocusScope {
        anchors.fill: parent
        id: scope
        objectName: "archiveFocusScope"

        // Thumbnail archive
        ThumbnailArchive {
            id: thumbnailArchive
            onHideArchive: {
                root.hideArchive()
            }
            onShowPreviewArchive: {
                archiveHandler.view = ArchiveHandler.ImageSelector
            }
            focus: root.state == "thumbnailView"
        }

        // Preview archive
        PreviewArchive {
            id: previewArchive
            onShowThumbnailArchive: archiveHandler.view = ArchiveHandler.Thumbnails
            onShowArchiveToolBar: menus.navigateUp()
            focus: root.state == "imageSelectorView"
        }

        // No images message
        MessageBox {
            id: emptyArchiveNotification
            objectName: "emptyArchiveNotification"
            //: Message header. Displayed when user enters the image archive and there are no saved images on the memory card.
            //% "No images found"
            title: qsTrId("ID_ARCHIVE_NO_IMAGES_HEADER") + translation.update
            //: Message text body. Displayed with message header when no images are found.
            //% "There are no saved images."
            text: qsTrId("ID_ARCHIVE_NO_IMAGES_BODY") + translation.update
            hasButtons: false
            iconStyle: iconEnum.info
            focus: root.state == "archiveIsEmpty"

            // Keyboard handling
            Keys.onReleased: {
                if (event.key === keys.archive || event.key === keys.back || event.key === keys.trigger) {
                    hideArchive()
                }
                if (event.key !== keys.camera)
                    event.accepted = true
            }
            onCancelSelected: {
                hideArchive()
            }
        }

        // Indexing images message
        MessageBox {
            id: indexingNotification
            objectName: "indexingNotification"
            //: Message header. Displayed when user enters the image archive and the archive is indexing the data.
            //% "Indexing images"
            title: qsTrId("ID_ARCHIVE_INDEXING_IMAGES_HEADER") + translation.update
            //: Message text body. Displayed with message header when the archive is indexing the data.
            //% "Reading image data..."
            text: qsTrId("ID_ARCHIVE_INDEXING_IMAGES_BODY") + translation.update
            hasButtons: false
            iconStyle: iconEnum.info
            focus: root.state == "archive"

            // Keyboard handling
            Keys.onReleased: {
                if (event.key === keys.archive || event.key === keys.back || event.key === keys.trigger) {
                    hideArchive()
                }
                if (event.key !== keys.camera)
                    event.accepted = true
            }
        }

        // Keyboard handling
        Keys.onPressed: {
//            console.log("Archive.Keys.onPressed")
            if (event.key === keys.archive) {
                // Prevent this from falling through to desktop
                event.accepted = true
            }
            if (event.key === keys.trigger && event.isAutoRepeat === false) {
                hideArchive()
                archiveHandler.model.cancelMultiSelect()
                event.accepted = true
            }
            else if (event.key === keys.zoom) {
                event.accepted = true
            }
            // For some reason emptyArchive loses focus... so we set it back here
            if (!event.accepted && (root.state === "archiveIsEmpty" || root.state === "archiveIsIndexing"))
            {
                event.accepted = true
                if (root.state === "archiveIsEmpty")
                    emptyArchiveNotification.focus = true
                else
                    indexingNotification.focus = true
            }
        }
        Keys.onReleased: {
//            console.log("Archive.Keys.onReleased")
            if (event.key === keys.archive || event.key === keys.back) {
                hideArchive()
                event.accepted = true
            }
            else if (archiveHandler.model.currentGroupIsReport) {
                if (event.key === keys.down) {
                    event.accepted = true
                    if (archiveHandler.view === ArchiveHandler.ImageSelector) {
                        archiveHandler.model.nextReportPage()
                    }
                }
                else if (event.key === keys.up) {
                    event.accepted = true
                    if (archiveHandler.view === ArchiveHandler.ImageSelector) {
                        archiveHandler.model.prevReportPage()
                    }
                }
                else if (event.key === keys.zoom)
                {
                    if (root.state == "fullscreen" && !previewArchive.zoomModeFull)
                        previewArchive.zoomModeFull = true
                    else if (root.state == "fullscreen" && previewArchive.zoomModeFull)
                        archiveHandler.view = ArchiveHandler.ImageSelector
                    else {
                        archiveHandler.view = ArchiveHandler.Fullscreen
                        previewArchive.zoomModeFull = false
                    }
                    event.accepted = true
                }
            }
        }
    }

    // Listen to changes in the model and set the corresponding view.
    // Note: this generates an error at startup, as not everything is setup, but it works!
    Connections { target: archiveHandler.model
        onCurrentIndexChanged: {
            if (state == "thumbnailView") {
                if (thumbnailArchive.currentIndex !== archiveHandler.model.currentIndex) {
                    thumbnailArchive.positionViewAtIndex(archiveHandler.model.currentIndex, ListView.Contain)
                    thumbnailArchive.currentIndex = archiveHandler.model.currentIndex
                }
            } else if (state == "imageSelectorView") {
                if (previewArchive.currentIndex !== archiveHandler.model.currentIndex) {
                    previewArchive.positionViewAtIndex()
                    previewArchive.currentIndex = archiveHandler.model.currentIndex
                }
            }
        }
        // Invalidate the stored index when re-reading stuff
        onStatusChanged: {
            if (archiveHandler.model.status === ArchiveModel.StatusStarting) {
                thumbnailArchive.currentIndex = -1
            }
        }
    }

    // Connections
    Connections { // get keyboard focus from menu to the right thing after it closes.
        target: menus
        onMenuClosed: {
            // Only get the focus if the menu has it
            var toolbars = greenbox.GetNamedObject("globalToolbars")
            if (toolbars !== null && !toolbars.focus)
                return
            if (state == "fullscreen") {
                previewArchive.forceActiveFocus()
            } else if (state == "imageSelectorView") {
                previewArchive.forceActiveFocus()
            }
        }
    }

    // States
    states: [
        State {
            name: "hidden"
            when: archiveHandler.view == ArchiveHandler.Invisible
            PropertyChanges { target: root; visible: false }
        },
        State {
            name: "visible"
            PropertyChanges { target: root; visible: true }
            PropertyChanges { target: thumbnailArchive; visible: false }
            PropertyChanges { target: previewArchive; visible: false }
            PropertyChanges { target: emptyArchiveNotification; opacity: 0 }
            PropertyChanges { target: indexingNotification; opacity: 0 }
            PropertyChanges { target: previewArchive; fullscreenImageSource : "" }
            StateChangeScript { script: console.log("state = visible") }
        },
        State {
            name: "archiveIsEmpty"
            extend: "visible"
            when: archiveHandler.view != ArchiveHandler.Invisible && archiveHandler.model.empty &&
                  archiveHandler.model.status !== ArchiveModel.StatusIndexing
            PropertyChanges { target: emptyArchiveNotification; opacity: 1 }
            StateChangeScript {
                script: {
                    console.log("state = archiveIsEmpty")
                    // Active focus is lost here sometimes. Make sure it stays put.
                    if (scope.focus && !scope.activeFocus) {
                        emptyArchiveNotification.forceActiveFocus()
                    }
                }
            }
        },
        State {
            name: "archiveIsIndexing"
            extend: "visible"
            when: archiveHandler.view != ArchiveHandler.Invisible && archiveHandler.model.status === ArchiveModel.StatusIndexing
            PropertyChanges { target: indexingNotification; opacity: 1 }
            StateChangeScript { script: console.log("state = archiveIsIndexing") }
        },
        State {
            name: "thumbnailView"
            extend: "visible"
            when: archiveHandler.view == ArchiveHandler.Thumbnails &&
                  !archiveHandler.model.empty &&
                  archiveHandler.model.status === ArchiveModel.StatusReady
            PropertyChanges { target: thumbnailArchive; visible: true }
            StateChangeScript {
                script: {
                    console.log("state = thumbnailView")
                    if (thumbnailArchive.currentIndex !== archiveHandler.model.currentIndex) {
                        thumbnailArchive.positionViewAtIndex(archiveHandler.model.currentIndex, ListView.Contain)
                        thumbnailArchive.currentIndex = archiveHandler.model.currentIndex
                    }
                }
            }
        },
        State {
            name: "imageSelectorView"
            extend: "visible"
            when: archiveHandler.view == ArchiveHandler.ImageSelector &&
                  !archiveHandler.model.empty &&
                  archiveHandler.model.status === ArchiveModel.StatusReady
            PropertyChanges { target: previewArchive; visible: true }
            StateChangeScript {
                script: {
                    console.log("state = imageSelectorView")
                    requestFocusForPreview()
                    if (previewArchive.currentIndex !== archiveHandler.model.currentIndex) {
                        previewArchive.positionViewAtIndex()
                        previewArchive.currentIndex = archiveHandler.model.currentIndex
                    }
                }
            }
        },
        State {
            name: "fullscreen"
            extend: "visible"
            when: archiveHandler.view == ArchiveHandler.Fullscreen
            PropertyChanges { target: previewArchive; visible: true }
            PropertyChanges { target: previewArchive; fullscreenImageSource: previewArchive.currentItem.frontSource }
            PropertyChanges { target: previewArchive; zoomModeFull: true }
            StateChangeScript { script: requestFocusForPreview() }
            StateChangeScript { script: console.log("fullscreen state got started") }
        },

        State {
            name: "fullscreenVideo"
            extend: "visible"
            when: archiveHandler.view == ArchiveHandler.FullscreenVideo
            StateChangeScript { script: console.log("fullscreenvideo state got started") }
        }
    ]
}
