import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: panel

    width: 280
    implicitHeight: layout.implicitHeight + Theme.sp4

    color: Theme.bg1
    radius: Theme.radiusLg

    border.color: Theme.border1
    border.width: Theme.borderInactive

    // Dismiss on click outside
    focus: true
    Keys.onPressed: function(e) {
        if (e.key === Qt.Key_Escape)
            panel.visible = false
    }

    ColumnLayout {
        id: layout
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: Theme.sp3
        }
        spacing: Theme.sp3

        VolumeSlider {}
        BrightnessSlider {}
        NetworkInfo {}
        BatteryInfo {}
        PowerButton {}
    }

    // Click outside to dismiss — handled by parent Indicators via panelOpen toggle
}
