import QtQuick 1.1
import se.flir 1.0

/**
 * This page shows the global Message box, which is a normal MessageBox but there is one C++ object
 * that drives it, allowing users to show a box from C++.
 */

MessageBox {
    iconStyle: messageboxHandler.icon === "" ? "" : "../images/" + messageboxHandler.icon + "_Sel.png"
    focus:     messageboxHandler.showing
    visible:   messageboxHandler.showing && !pogo
    title:     qsTrId(messageboxHandler.title) + translation.update
    text:      qsTrId(messageboxHandler.body)  + translation.update
    opacity: 1
    onVisibleChanged: if (visible) show(); else hide()

    onCancelSelected:    messageboxHandler.onButtonSelected(MessageBoxHandler.Button_Cancel);
    onOkSelected:        messageboxHandler.onButtonSelected(MessageBoxHandler.Button_Ok);
    onMidSelected:       messageboxHandler.onButtonSelected(MessageBoxHandler.Button_Mid);
    // implement this functionality in the Button.qml rather than here
//  onMidButtontextChanged: midButtontext === "" ? midButtonVisible = false : midButtonVisible = true

    okButtontext:        qsTrId(messageboxHandler.okButtonText) + translation.update
    okButtonVisible:     messageboxHandler.okButtonVisible
    okButtonEnabled:     messageboxHandler.okButtonEnabled

    midButtontext:       qsTrId(messageboxHandler.midButtonText) + translation.update
    midButtonVisible:    messageboxHandler.midButtonVisible
    midButtonEnabled:    messageboxHandler.midButtonEnabled

    cancelButtonText:    qsTrId(messageboxHandler.cancelButtonText) + translation.update
    cancelButtonVisible: messageboxHandler.cancelButtonVisible
    cancelButtonEnabled: messageboxHandler.cancelButtonEnabled

    // focus change request
    property bool focusRequest: messageboxHandler.focusRequest
    onFocusRequestChanged: {
        okButtonFocused     = messageboxHandler.okButtonFocused
        midButtonFocused    = messageboxHandler.midButtonFocused
        cancelButtonFocused = messageboxHandler.cancelButtonFocused
        if (!okButtonFocused && !midButtonFocused && !cancelButtonFocused)
            forceActiveFocus()
    }
    // focus update loopback
    onOkButtonFocusedChanged: {
        messageboxHandler.okButtonFocused = okButtonFocused
    }
    onCancelButtonFocusedChanged: {
        messageboxHandler.cancelButtonFocused = cancelButtonFocused
    }
    onMidButtonFocusedChanged: {
        messageboxHandler.midButtonFocused = midButtonFocused
    }

    hasButtons:          messageboxHandler.hasButtons
    backgroundImage:     messageboxHandler.backgroundImage
    liveBackground:      messageboxHandler.hasLiveBackground
    tableModel:          messageboxHandler.useModel ? archiveHandler.infoModel : null
}
