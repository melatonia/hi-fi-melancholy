pragma Singleton
import QtQuick
import Quickshell.Io

// ============================================================
//  Melancholy — Theme.qml v1.4
//  Single source of truth for all design tokens in QML.
//
//  Manual mirror of: ../../melancholy-colors.css v1.4
//  SYNC RULE: Any change to melancholy-colors.css must be
//  reflected here. Do not hardcode tokens anywhere else.
//
//  Light/dark driven by Time.qml via setDark(bool).
//  Nothing else should write isDark.
// ============================================================

QtObject {
    id: root

    // --------------------------------------------------------
    //  Mode toggle — set by Time.qml only
    // --------------------------------------------------------
    property bool isDark: false

    property var _themeWatcher: Process {
        command: ["gsettings", "monitor", "org.gnome.desktop.interface", "color-scheme"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                root.isDark = line.indexOf("prefer-dark") !== -1
            }
        }

        onExited: function(code, status) {
            running = true
        }
    }

    property var _themeInit: Process {
        command: ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]
        running: true

        stdout: SplitParser {
            onRead: function(line) {
                root.isDark = line.indexOf("prefer-dark") !== -1
            }
        }
    }

    // --------------------------------------------------------
    //  Backgrounds
    // --------------------------------------------------------
    readonly property color bg0: isDark ? "#16130f" : "#f5f0e8"
    readonly property color bg1: isDark ? "#1e1b16" : "#ede7db"
    readonly property color bg2: isDark ? "#26231d" : "#e2ddd4"

    // --------------------------------------------------------
    //  Borders
    // --------------------------------------------------------
    readonly property color border0: isDark ? "#2e2a24" : "#d4cec4"
    readonly property color border1: isDark ? "#3a352e" : "#c2bcb2"

    readonly property real borderActive:   1.5
    readonly property real borderInactive: 0.5

    // --------------------------------------------------------
    //  Text
    // --------------------------------------------------------
    readonly property color text0: isDark ? "#f0ebe2" : "#28241e"
    readonly property color text1: isDark ? "#b8b2a8" : "#5a5248"
    readonly property color text2: isDark ? "#908a82" : "#625c56"

    // --------------------------------------------------------
    //  Accent — TE Orange
    //  ONLY for: active workspace border+number, knob hover/press
    // --------------------------------------------------------
    readonly property color accentBorder: isDark ? "#e8844a" : "#c4601a"
    readonly property color accentText:   isDark ? "#e8844a" : "#8a4418"

    readonly property color accent100: isDark ? "#3a1e0a" : "#f5d9c8"
    readonly property color accent200: isDark ? "#6a3418" : "#e8a882"
    readonly property color accent400: isDark ? "#c46030" : "#c4601a"
    readonly property color accent600: isDark ? "#e8844a" : "#8a4418"
    readonly property color accent800: isDark ? "#f0a870" : "#5c2c0e"

    // --------------------------------------------------------
    //  Functional: Network — Blue
    //  blueIndicator: shape only, never as text color
    // --------------------------------------------------------
    readonly property color blueIndicator: isDark ? "#78b4d4" : "#3a7ca8"
    readonly property color blueText:      isDark ? "#9ec4d8" : "#1e4a6a"
    readonly property color blueSubtle:    isDark ? "#1a2e3a" : "#d6e8f2"

    // --------------------------------------------------------
    //  Functional: System Health — Green
    // --------------------------------------------------------
    readonly property color greenIndicator: isDark ? "#7ec48a" : "#4e8c5a"
    readonly property color greenText:      isDark ? "#a8d8b0" : "#2a5230"
    readonly property color greenSubtle:    isDark ? "#1a2e1e" : "#d8ebd8"

    // --------------------------------------------------------
    //  Functional: Audio / Knob — Amber
    // --------------------------------------------------------
    readonly property color amberIndicator: isDark ? "#d4a870" : "#8a6a3a"
    readonly property color amberText:      isDark ? "#e8c898" : "#5c4220"
    readonly property color amberSubtle:    isDark ? "#2e2010" : "#ede3ce"

    // --------------------------------------------------------
    //  Typography
    // --------------------------------------------------------
    readonly property string fontSans: "Geist"
    readonly property string fontMono: isDark ? "CommitMono-400" : "CommitMono-450"

    // --------------------------------------------------------
    //  Geometry
    // --------------------------------------------------------
    readonly property real radiusSm: 4
    readonly property real radiusMd: 8
    readonly property real radiusLg: 12

    readonly property real barHeight: 34

    // --------------------------------------------------------
    //  Spacing
    // --------------------------------------------------------
    readonly property real sp1:  4
    readonly property real sp2:  8
    readonly property real sp3:  12
    readonly property real sp4:  16
    readonly property real sp5:  20
    readonly property real sp6:  24
    readonly property real sp8:  32
    readonly property real sp10: 40
}
