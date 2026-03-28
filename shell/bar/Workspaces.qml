import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../services"

Item {
    id: workspaces

    width: implicitWidth
    height: implicitHeight

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.barHeight

    // Provided by MangoWM via wlr-foreign-toplevel or similar.
    // Swap model source when wiring real workspace service.
    property int activeWorkspace: WorkspacesService.activeTag
    property int workspaceCount: WorkspacesService.totalTags

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Theme.sp2

        Repeater {
            model: workspaces.workspaceCount

            Item {
                id: dotContainer
                width: 10
                height: 10

                readonly property bool isActive: index === workspaces.activeWorkspace

                // Glow ring — visible on active only
                Rectangle {
                    anchors.centerIn: parent
                    width: 10
                    height: 10
                    radius: width / 2
                    color: dotContainer.isActive ? Theme.accentBorder : "transparent"
                    opacity: 0.25
                    visible: dotContainer.isActive
                }

                // Dot
                Rectangle {
                    anchors.centerIn: parent
                    width: 6
                    height: 6
                    radius: width / 2
                    color: dotContainer.isActive ? Theme.accentBorder : Theme.border0

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }
                }
            }
        }
    }
}
