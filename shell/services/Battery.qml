pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int percent: 0
    property bool charging: false
    property string supply: ""

    property var _finder: Process {
        command: ["sh", "-c", "ls /sys/class/power_supply/"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                var name = line.trim()
                if (name.indexOf("BAT") !== -1)
                    root.supply = name
            }
        }

        onExited: function(code, status) {
            if (root.supply !== "")
                _poll.running = true
        }
    }

    property var _poll: Timer {
        interval: 30000
        running: false
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            _capacityQuery.running = true
            _statusQuery.running = true
        }
    }

    property var _capacityQuery: Process {
        command: ["sh", "-c", "cat /sys/class/power_supply/" + root.supply + "/capacity"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root.percent = parseInt(line.trim())
            }
        }

        onExited: function(code, status) { running = false }
    }

    property var _statusQuery: Process {
        command: ["sh", "-c", "cat /sys/class/power_supply/" + root.supply + "/status"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root.charging = line.trim() === "Charging"
            }
        }

        onExited: function(code, status) { running = false }
    }
}
