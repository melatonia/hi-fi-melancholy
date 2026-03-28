import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"

RowLayout {
    spacing: Theme.sp2

    Rectangle {
        width: 5
        height: 5
        radius: width / 2
        color: Network.connected ? Theme.blueIndicator : Theme.text2
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: Network.connected ? Network.type + " — " + Network.name : "disconnected"
        font.family: Theme.fontMono
        font.pixelSize: 11
        color: Theme.text1
        elide: Text.ElideRight
        Layout.fillWidth: true
    }
}
