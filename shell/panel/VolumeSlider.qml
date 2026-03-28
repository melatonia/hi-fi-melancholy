import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

ColumnLayout {
    spacing: Theme.sp1

    Text {
        text: Audio.muted ? "volume — muted" : "volume — " + Audio.volume + "%"
        font.family: Theme.fontMono
        font.pixelSize: 11
        color: Theme.text2
        Layout.fillWidth: true
    }

    Item {
        Layout.fillWidth: true
        height: 20

        // Track
        Rectangle {
            id: track
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 2
            radius: 1
            color: Theme.border0

            // Fill
            Rectangle {
                width: parent.width * (Audio.volume / 100)
                height: parent.height
                radius: parent.radius
                color: Theme.amberIndicator
            }
        }

        // Knob
        Rectangle {
            id: knob
            width: 14
            height: 14
            radius: width / 2
            color: Theme.bg2
            border.color: Theme.amberIndicator
            border.width: 1.5
            anchors.verticalCenter: track.verticalCenter
            x: (track.width - width) * (Audio.volume / 100)

            // Hover glow ring
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 6
                height: parent.height + 6
                radius: width / 2
                color: Theme.accent200
                opacity: knobArea.containsMouse ? 0.4 : 0
                z: -1

                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }

            Behavior on x {
                NumberAnimation { duration: 80 }
            }
        }

        MouseArea {
            id: knobArea
            anchors.fill: parent
            hoverEnabled: true

            onClicked: function(mouse) {
                var val = Math.round((mouse.x / width) * 100)
                val = Math.max(0, Math.min(100, val))
                var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', parent)
                proc.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", val + "%"]
                proc.running = true
            }
        }
    }
}
