import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    id: root

    // --- Theme Manager ---
    QtObject {
        id: theme
        property string currentTheme: "nord"

        // Nord color palette
        property var nord: {
            "base": "#2E3440",
            "surface0": "#3B4252",
            "surface1": "#434C5E",
            "surface2": "#4C566A",
            "text": "#D8DEE9",
            "subtext1": "#ECEFF4",
            "overlay2": "#81A1C1",
            "blue": "#88C0D0",
            "red": "#BF616A",
            "yellow": "#EBCB8B",
            "mauve": "#B48EAD"
        }

        // Gruvbox dark color palette
        property var gruvbox: {
            "base": "#282828",
            "surface0": "#3c3836",
            "surface1": "#504945",
            "surface2": "#665c54",
            "text": "#ebdbb2",
            "subtext1": "#fbf1c7",
            "overlay2": "#a89984",
            "blue": "#458588",
            "red": "#cc241d",
            "yellow": "#d79921",
            "mauve": "#b16286"
        }

        property var palette: nord // The currently active palette

        // Function to change theme and wallpaper using swww with 30° swipe
        function setTheme(themeName) {
            var wallpaperDir = ""
            if (themeName === "nord") {
                palette = nord;
                currentTheme = "nord";
                wallpaperDir = "~/.config/hypr/wallpapers/nord"
            } else if (themeName === "gruvbox") {
                palette = gruvbox;
                currentTheme = "gruvbox";
                wallpaperDir = "~/.config/hypr/wallpapers/gruvbox"
            }

            if (wallpaperDir !== "") {
                // Pick a random PNG and set with swww swipe transition at 30 degrees
                var cmd = "sh -c 'swww img \"$(find " + wallpaperDir + " -type f -name \"*.png\" | shuf -n 1)\" --transition-type wipe --transition-angle 30 --transition-fps 120 --transition-step 90'"
                Quickshell.execDetached(["sh", "-c", cmd])
            }
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
                screen: modelData

                anchors { top: true; left: true; right: true }
                implicitHeight: 40
                exclusiveZone: implicitHeight

                Rectangle {
                    anchors.fill: parent
                    color: theme.palette.base

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        /* ---------- Workspaces ---------- */
                        RowLayout {
                            spacing: 6
                            Repeater {
                                model: Hyprland.workspaces
                                delegate: Rectangle {
                                    property var ws: modelData
                                    visible: !ws.name || !ws.name.startsWith("special:")
                                    width: 28; height: 24; radius: 6
                                    Layout.alignment: Qt.AlignVCenter

                                    property bool isActive: (
                                        Hyprland.monitorFor(screen)
                                        && Hyprland.monitorFor(screen).activeWorkspace
                                        && Hyprland.monitorFor(screen).activeWorkspace.id === ws.id
                                    )

                                    color: isActive ? theme.palette.overlay2 : theme.palette.surface0
                                    border.color: theme.palette.surface1; border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: ws.name && ws.name.length ? ws.name : ((ws.id !== undefined) ? ws.id.toString() : "?")
                                        color: isActive ? theme.palette.subtext1 : theme.palette.text
                                        font.pixelSize: 13
                                        font.bold: isActive
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = theme.palette.surface2
                                        onExited: parent.color = isActive ? theme.palette.overlay2 : theme.palette.surface0
                                        onClicked: Hyprland.dispatch("workspace " + (ws.name || ws.id))
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        /* ---------- Clock ---------- */
                        Rectangle {
                            width: 90; height: 28; radius: 6
                            color: theme.palette.surface0
                            border.color: theme.palette.surface1; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                id: clock
                                anchors.centerIn: parent
                                color: theme.palette.blue
                                font.pixelSize: 14
                                font.bold: true
                            }

                            Timer {
                                interval: 1000; running: true; repeat: true
                                onTriggered: clock.text = Qt.formatDateTime(new Date(), "hh:mm AP")
                            }
                            Component.onCompleted: clock.text = Qt.formatDateTime(new Date(), "hh:mm AP")
                        }

                        Item { Layout.fillWidth: true }

                        /* ---------- Terminal Button ---------- */
                        Rectangle {
                            width: 36; height: 24; radius: 6
                            color: theme.palette.surface0
                            border.color: theme.palette.surface1; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: theme.palette.subtext1
                                font.pixelSize: 14
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached(["alacritty"])
                            }
                        }

                        /* ---------- Rofi Button ---------- */
                        Rectangle {
                            width: 36; height: 24; radius: 6
                            color: theme.palette.surface0
                            border.color: theme.palette.surface1; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                anchors.centerIn: parent
                                text: "󰍉"
                                color: theme.palette.blue
                                font.pixelSize: 15
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Quickshell.execDetached([
                                    "sh", "-c",
                                    "rofi -show drun -theme ~/.config/rofi/config.rasi -location 3 -yoffset 40 -width 30"
                                ])
                            }
                        }

                        /* ---------- Theme Button ---------- */
                        Rectangle {
                            id: themeBtn
                            width: 36; height: 24; radius: 6
                            color: theme.palette.surface0
                            border.color: theme.palette.surface1; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: theme.palette.subtext1
                                font.pixelSize: 15
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: themeMenu.visible = !themeMenu.visible
                            }
                        }

                        /* ---------- Power Button ---------- */
                        Rectangle {
                            id: powerBtn
                            width: 36; height: 24; radius: 6
                            color: theme.palette.surface0
                            border.color: theme.palette.surface1; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                anchors.centerIn: parent
                                text: "⏻"
                                color: theme.palette.subtext1
                                font.pixelSize: 15
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: powerMenu.visible = !powerMenu.visible
                            }
                        }
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: theme.palette.surface1
                    }
                }

                /* ---------- Theme Menu ---------- */
                Window {
                    id: themeMenu
                    visible: false
                    width: 130; height: 90
                    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
                    color: "transparent"
                    x: screen.geometry.x + screen.geometry.width - width - 50
                    y: screen.geometry.y + 50
                    opacity: 0

                    PropertyAnimation { id: themeFadeIn; target: themeMenu; property: "opacity"; from: 0; to: 1; duration: 200 }
                    PropertyAnimation { id: themeFadeOut; target: themeMenu; property: "opacity"; from: 1; to: 0; duration: 200; onStopped: themeMenu.visible = false }

                    onVisibleChanged: {
                        if (visible) themeFadeIn.start()
                        else themeFadeOut.start()
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: theme.palette.base
                        border.color: theme.palette.surface1; border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            Repeater {
                                model: [
                                    { name: "Nord", themeId: "nord" },
                                    { name: "Gruvbox", themeId: "gruvbox" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: 6
                                    color: theme.currentTheme === modelData.themeId ? theme.palette.overlay2 : theme.palette.surface0
                                    border.color: theme.palette.surface1
                                    border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.name
                                        color: theme.palette.subtext1
                                        font.bold: theme.currentTheme === modelData.themeId
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = theme.palette.surface2
                                        onExited: parent.color = theme.currentTheme === modelData.themeId ? theme.palette.overlay2 : theme.palette.surface0
                                        onClicked: {
                                            theme.setTheme(modelData.themeId)
                                            themeMenu.visible = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                /* ---------- Power Menu ---------- */
                Window {
                    id: powerMenu
                    visible: false
                    width: 260; height: 200
                    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
                    color: "transparent"
                    x: (screen.geometry.width - width) / 2
                    y: screen.geometry.y + 100
                    opacity: 0

                    PropertyAnimation { id: fadeIn; target: powerMenu; property: "opacity"; from: 0; to: 1; duration: 200 }
                    PropertyAnimation { id: fadeOut; target: powerMenu; property: "opacity"; from: 1; to: 0; duration: 200; onStopped: powerMenu.visible = false }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: theme.palette.base
                        border.color: theme.palette.surface1; border.width: 1
                        anchors.margins: 10

                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            columns: 2
                            rows: 2
                            columnSpacing: 10
                            rowSpacing: 10

                            Repeater {
                                model: [
                                    { label: "⏻", text: "Power Off", color: theme.palette.red, cmd: "systemctl poweroff" },
                                    { label: "", text: "Reboot", color: theme.palette.yellow, cmd: "systemctl reboot" },
                                    { label: "", text: "Logout", color: theme.palette.overlay2, cmd: "hyprctl dispatch exit" },
                                    { label: "", text: "Cancel", color: theme.palette.surface2, cmd: "" }
                                ]

                                delegate: Rectangle {
                                    radius: 8
                                    property color buttonColor: modelData.color
                                    color: buttonColor
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text { text: modelData.label; color: theme.palette.subtext1; font.pixelSize: 24; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: modelData.text; color: theme.palette.subtext1; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = Qt.darker(parent.buttonColor, 1.2)
                                        onExited: parent.color = parent.buttonColor
                                        onClicked: {
                                            powerMenu.visible = false
                                            if (modelData.cmd) {
                                                Quickshell.execDetached(modelData.cmd.split(" "))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
