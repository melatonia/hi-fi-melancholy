import QtQuick
import QtQuick.Layouts
import "../theme"
import "../services"
import "../panel"

Item {
    id: indicators
    implicitWidth: row.implicitWidth
    implicitHeight: Theme.barHeight

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.sp3

        IndicatorDot {
            dotColor: Audio.muted ? Theme.text2 : Theme.amberIndicator
            label: Audio.muted ? "mute" : Audio.volume + "%"
        }

        IndicatorDot {
            dotColor: Network.connected ? Theme.blueIndicator : Theme.text2
            label: Network.connected ? Network.name : "off"
        }

        IndicatorDot {
            dotColor: Battery.charging ? Theme.greenIndicator : Theme.amberIndicator
            label: Battery.percent + "%"
        }
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        onClicked: ShellState.panelOpen = !ShellState.panelOpen
    }

    component IndicatorDot: Row {
        property color dotColor: Theme.text2
        property string label: ""
        spacing: Theme.sp1

        Rectangle {
            width: 5
            height: 5
            radius: width / 2
            color: parent.dotColor
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                anchors.centerIn: parent
                width: 9
                height: 9
                radius: width / 2
                color: parent.color
                opacity: 0.2
                z: -1
            }
        }

        Text {
            text: parent.label
            font.family: Theme.fontMono
            font.pixelSize: 11
            color: Theme.text1
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
