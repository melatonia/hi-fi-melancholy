import QtQuick
import QtQuick.Layouts
import "../theme"
import "."

Rectangle {
    id: bar

    anchors.fill: parent
    color: Theme.bg0

    // Bottom border only — thin separator between bar and desktop
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.borderInactive
        color: Theme.border0
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: Theme.sp3
        anchors.rightMargin: Theme.sp3

        Workspaces {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Clock {
            anchors.centerIn: parent
        }

        Indicators {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
