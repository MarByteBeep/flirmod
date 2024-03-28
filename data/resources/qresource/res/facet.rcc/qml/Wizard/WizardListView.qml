import QtQuick 1.1
//import QtGraphicalEffects 1.0
import "../Toolbar"

// WizardListView
// ----------------
// List view for initial startup wizard

Item {
    id: listItem
    property alias model: view.model
    property alias selected: view.selected
    property alias currentIndex: view.currentIndex
    property int selectionWidth: width
    property alias alignment: view.alignment
    property int visibleOffsetX: 100

    function incrementCurrentIndex() {
        view.incrementCurrentIndex()
    }
    function decrementCurrentIndex() {
        view.decrementCurrentIndex()
    }

    signal listClicked
    onListClicked: wizardPageList.selected = true

    anchors.top: parent.top
    anchors.topMargin: 25
    anchors.bottomMargin: 25
    anchors.bottom: parent.bottom

    ListView {

        id: view
        clip: true
        model: pageModel
        anchors.fill: parent

        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 50
        preferredHighlightBegin: wizardPageList.numberOfModels > 1 ? (height - grid.listItemHeight ) / 2 : grid.cellHeight + grid.verticalSpacing
        preferredHighlightEnd:   wizardPageList.numberOfModels > 1 ? (height + grid.listItemHeight) / 2 : view.height - grid.cellHeight - grid.verticalSpacing
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true

        currentIndex: 0
        onCurrentIndexChanged: model.currentIndex = currentIndex        // Update model with current view state

        property int alignment: Text.AlignLeft
        property bool selected: wizardPageList.selected

        delegate: Item {
            id: delegate
            height: grid.listItemHeight
            width: parent.width

            Text {
                text: item === undefined ? value : (item.label === undefined ? "" : qsTrId(item.label)) + (item.value === undefined ? "" : qsTrId(item.value)) + (item.ID === undefined || item.value !== "" ? "": item.ID)
                width: parent.width - visibleOffsetX
                x: visibleOffsetX
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: alignment
                font.pixelSize: fonts.mediumSize
                font.family: item === undefined ? fonts.family : item.font === "" ? fonts.family : item.font
                color: parent.ListView.isCurrentItem ? (selected ? "#3e9dff" : (enabled ? colors.textFocused : colors.textNormal)) : colors.textDisabled
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on font.pixelSize { NumberAnimation { duration: 100 } }
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: delegate
                onClicked: {
                    if (parent.ListView.isCurrentItem)
                    {
                        console.log("item had focus. click()")
                        listItem.listClicked()
                    }
                    else
                    {
                        console.log("item did not have focus. select()")
                        //view.currentItem = listItem
                        view.currentIndex = index
                    }
                }
            }
        }

        Keys.onPressed: console.log("wizardListView.onPressed")
        Keys.onReleased: console.log("wizardListView.onReleased")
    }

//    LinearGradient {
//        anchors.fill: view
//        start: Qt.point(0, 0)
//        end: Qt.point(0, view.height)
//        gradient: Gradient {
//            GradientStop {
//              position: 0.0
//              color: "#FF101010"
//            }
//            GradientStop {
//              position: 0.2
//              color: "#00101010"
//            }
//            GradientStop {
//              position: 0.8
//              color: "#00101010"
//            }
//            GradientStop {
//              position: 1.0
//              color: "#FF101010"
//            }
//        }
//    }
}
