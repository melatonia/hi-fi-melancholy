import QtQuick
import "../theme"

Item {
    id: clock

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.barHeight

    // Ticks every second
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.update()
    }

    property string timeString: ""
    property string dateString: ""

    function update() {
        var now = new Date()
        timeString = Qt.formatTime(now, "HH:mm")
        dateString = Qt.formatDate(now, "ddd dd")
    }

    Component.onCompleted: update()

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.sp2

        Text {
            id: timeText
            text: clock.timeString
            font.family: Theme.fontMono
            font.pixelSize: 13
            color: Theme.text0
        }

        Text {
            text: clock.dateString
            font.family: Theme.fontMono
            font.pixelSize: 13
            color: Theme.text2
        }
    }
}
