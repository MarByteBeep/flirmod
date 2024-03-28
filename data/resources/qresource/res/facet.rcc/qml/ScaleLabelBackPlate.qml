import QtQuick 1.1

//! Rounded rect, a special rect for devices that do not support partial-transparancy
//!
//! On some of our hardware the transparancy is done using a single color that is
//! replaced by the compositor.  This means that Qts standard partial transparancy
//! will leave ugly artifacts.
//! This item was invented to use a simple png that has rounded corners, using
//! just a 0/100% transparancy mask.

//! @ingroup QML

Image {
    source: activelySelected ? "../images/Bg_Scale_Bar_Act.png" : selected ? "../images/Bg_Scale_Bar_Dis.png" : "../images/Bg_Scale_Bar_Def.png"
    property bool selected: false
    property bool activelySelected: false
}

