pragma Singleton
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
    }

    // Brightness has no native watch — poll on a short interval
    property var _poll: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root._query()
    }

    function _query() {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
        proc.command = ["brightnessctl", "-m", "g"]
        proc.stdout = Qt.createQmlObject('import Quickshell.Io; SplitParser {}', root)
        proc.stdout.onRead = function(line) { root._parse(line) }
        proc.running = true
    }

    function _parse(line) {
        // brightnessctl -m g output: name,class,current,max,percent%
        var parts = line.split(",")
        if (parts.length >= 5) {
            var pct = parts[4].replace("%", "").trim()
            root.percent = parseInt(pct)
        }
    }

    function set(value) {
        var proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
        proc.command = ["brightnessctl", "s", value + "%"]
        proc.running = true
    }
}
