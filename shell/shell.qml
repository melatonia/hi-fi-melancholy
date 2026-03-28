import Quickshell
import Quickshell.Wayland
import QtQuick
import "theme"
import "services"
import "bar"
import "panel"

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: Theme.barHeight
            color: "transparent"
            exclusiveZone: Theme.barHeight

            Bar {
                anchors.fill: parent
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            anchors {
                top: true
                right: true
            }
            implicitWidth: 280
            implicitHeight: visible ? panelContent.implicitHeight + Theme.sp4 : 0
            color: "transparent"
            exclusiveZone: 0
            visible: ShellState.panelOpen

            QuickPanel {
                id: panelContent
                anchors.top: parent.top
                anchors.right: parent.right
            }
        }
    }
}
