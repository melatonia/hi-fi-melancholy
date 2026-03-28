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
        color: Battery.charging ? Theme.greenIndicator : Theme.amberIndicator
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: Battery.charging ? "charging — " + Battery.percent + "%" : "battery — " + Battery.percent + "%"
        font.family: Theme.fontMono
        font.pixelSize: 11
        color: Theme.text1
        Layout.fillWidth: true
    }
}
