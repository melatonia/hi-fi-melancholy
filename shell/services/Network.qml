pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string name: ""
    property string type: ""
    property bool connected: false

    property var _watcher: Process {
        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                if (line.indexOf("connectivity") !== -1 ||
                    line.indexOf("connected") !== -1 ||
                    line.indexOf("disconnected") !== -1)
                    _query.running = true
            }
        }

        onExited: function(code, status) { running = true }
    }

    property var _query: Process {
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show", "--active"]
        running: true

        stdout: SplitParser {
            onRead: function(line) { root._parseLine(line) }
        }

        onExited: function(code, status) { running = false }
    }

    function _parseLine(line) {
        if (line.indexOf("loopback") !== -1) return
        var parts = line.split(":")
        if (parts.length < 2) {
            root.connected = false
            root.name = ""
            root.type = ""
            return
        }
        root.name = parts[0]
        root.type = parts[1].indexOf("wireless") !== -1 ? "wifi" : "ethernet"
        root.connected = true
    }
}
