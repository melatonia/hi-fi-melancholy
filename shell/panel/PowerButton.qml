import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../theme"

Rectangle {
    Layout.fillWidth: true
    height: 32
    radius: Theme.radiusSm
    color: powerArea.containsMouse ? Theme.bg2 : "transparent"
    border.color: powerArea.containsMouse ? Theme.border1 : Theme.border0
    border.width: Theme.borderInactive

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Text {
        anchors.centerIn: parent
        text: "power"
        font.family: Theme.fontMono
        font.pixelSize: 11
        color: powerArea.containsMouse ? Theme.text0 : Theme.text2

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    MouseArea {
        id: powerArea
        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', parent)
            proc.command = ["systemctl", "poweroff"]
            proc.running = true
        }
    }
}
