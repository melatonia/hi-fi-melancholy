pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int volume: 0
    property bool muted: false

    property var _watcher: Process {
        command: ["pactl", "subscribe"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                if (line.indexOf("on sink") !== -1) {
                    _volumeQuery.running = true
                    _muteQuery.running = true
                }
            }
        }

        onExited: function(code, status) { running = true }
    }

    property var _volumeQuery: Process {
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                var match = line.match(/(\d+)%/)
                if (match) root.volume = parseInt(match[1])
            }
        }

        onExited: function(code, status) { running = false }
    }

    property var _muteQuery: Process {
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                root.muted = line.indexOf("yes") !== -1
            }
        }

        onExited: function(code, status) { running = false }
    }
}
