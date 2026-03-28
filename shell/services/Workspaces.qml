pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property int activeTag: 0       // 0-indexed
    property int totalTags: 9       // MangoWM default
    property var occupiedTags: []   // 0-indexed list of tags with clients

    property var _proc: Process {
        command: ["mmsg", "-w"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                root._parseLine(line.trim())
            }
        }

        onExited: function(code, status) {
            running = true
        }
    }

    function _parseLine(line) {
        var parts = line.split(" ")
        if (parts.length < 5 || parts[1] !== "tag") return

        var tagIndex = parseInt(parts[2]) - 1  // 0-indexed
        var selected = parseInt(parts[3])
        var hasClients = parseInt(parts[4]) > 0

        if (selected === 1)
            root.activeTag = tagIndex

        // rebuild occupiedTags
        var occ = root.occupiedTags.slice()
        var pos = occ.indexOf(tagIndex)
        if (hasClients && pos === -1) occ.push(tagIndex)
        else if (!hasClients && pos !== -1) occ.splice(pos, 1)
        root.occupiedTags = occ
    }

    function _lowestBit(n) {
        for (var i = 0; i < 32; i++) {
            if (n & (1 << i)) return i
        }
        return 0
    }

    property var _initProc: Process {
        command: ["mmsg"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                root._parseLine(line.trim())
            }
        }
    }
}
