import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import Quickshell
import Quickshell.Hyprland

ShellRoot {
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
                    color: "#2E3440"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        /* ---------- Workspaces (filter special) ---------- */
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

                                    color: isActive ? "#81A1C1" : "#3B4252"
                                    border.color: "#434C5E"; border.width: 1

                                    Text {
                                        anchors.centerIn: parent
                                        text: ws.name && ws.name.length ? ws.name : ((ws.id !== undefined) ? ws.id.toString() : "?")
                                        color: isActive ? "#ECEFF4" : "#D8DEE9"
                                        font.pixelSize: 13
                                        font.bold: isActive
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = "#4C566A"
                                        onExited: parent.color = isActive ? "#81A1C1" : "#3B4252"
                                        onClicked: Hyprland.dispatch("workspace " + (ws.name || ws.id))
                                    }
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }

                        /* ---------- Clock ---------- */
                        Rectangle {
                            width: 90; height: 28; radius: 6
                            color: "#3B4252"
                            border.color: "#434C5E"; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                id: clock
                                anchors.centerIn: parent
                                color: "#88C0D0"
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
                            color: "#3B4252"
                            border.color: "#434C5E"; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                anchors.centerIn: parent
                                text: ""
                                color: "#ECEFF4"
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
                            color: "#3B4252"
                            border.color: "#434C5E"; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                anchors.centerIn: parent
                                text: "󰍉"
                                color: "#88C0D0"
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

                        /* ---------- Power Button ---------- */
                        Rectangle {
                            id: powerBtn
                            width: 36; height: 24; radius: 6
                            color: "#3B4252"
                            border.color: "#434C5E"; border.width: 1
                            Layout.alignment: Qt.AlignVCenter
                            anchors.topMargin: 4
                            anchors.bottomMargin: 4

                            Text {
                                anchors.centerIn: parent
                                text: "⏻"
                                color: "#ECEFF4"
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
                        color: "#434C5E"
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
                    NumberAnimation { id: slideDown; target: powerMenu; property: "y"; duration: 200; easing.type: Easing.OutCubic }

                    onVisibleChanged: {
                        if (visible) {
                            Hyprland.dispatch("windowrulev2 float, class:^(quickshell)$")
                            Hyprland.dispatch("windowrulev2 size 260 200, class:^(quickshell)$")
                            Hyprland.dispatch("windowrulev2 move 40% 20%, class:^(quickshell)$")
                            slideDown.from = screen.geometry.y + 40
                            slideDown.to = screen.geometry.y + 100
                            slideDown.start()
                            fadeIn.start()
                        } else fadeOut.start()
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: "#2E3440"
                        border.color: "#434C5E"; border.width: 1
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
                                    { label: "⏻", text: "Power Off", color: "#BF616A", cmd: "systemctl poweroff" },
                                    { label: "", text: "Reboot", color: "#EBCB8B", cmd: "systemctl reboot" },
                                    { label: "", text: "Logout", color: "#81A1C1", cmd: "hyprctl dispatch exit" },
                                    { label: "", text: "Cancel", color: "#5E81AC", cmd: "" }
                                ]

                                delegate: Rectangle {
                                    radius: 8
                                    color: modelData.color
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 6
                                        Text { text: modelData.label; color: "#ECEFF4"; font.pixelSize: 24; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: modelData.text; color: "#ECEFF4"; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = Qt.darker(modelData.color, 1.2)
                                        onExited: parent.color = modelData.color
                                        onClicked: {
                                            if (modelData.cmd !== "")
                                                Quickshell.execDetached(["sh","-c", modelData.cmd])
                                            powerMenu.visible = false
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
