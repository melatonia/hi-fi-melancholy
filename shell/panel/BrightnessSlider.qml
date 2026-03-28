import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int percent: 0

    property var _init: Process {
        command: ["brightnessctl", "-m", "g"]
        running: true

        stdout: SplitParser {
            onRead: function(line) { root._parse(line) }
        }

        onExited: function(code, status) { running = false }
    }

    property var _poll: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: _query.running = true
    }

    property var _query: Process {
        command: ["brightnessctl", "-m", "g"]
        running: false

        stdout: SplitParser {
            onRead: function(line) { root._parse(line) }
        }

        onExited: function(code, status) { running = false }
    }

    function _parse(line) {
        var parts = line.split(",")
        if (parts.length >= 5) {
            var pct = parts[4].replace("%", "").trim()
            root.percent = parseInt(pct)
        }
    }

    function set(value) {
        _setter.command = ["brightnessctl", "s", value + "%"]
        _setter.running = true
    }

    property var _setter: Process {
        running: false
        onExited: function(code, status) {
            running = false
            _query.running = true
        }
    }
}
