import QtQuick
import Quickshell
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

BasePill {
    id: root

    Ref {
        service: DMSNetworkService
    }

    property var popoutTarget: null
    property bool isHovered: clickArea.containsMouse

    signal toggleVpnPopup()

    content: Component {
        Item {
            implicitWidth: root.widgetThickness - root.horizontalPadding * 2
            implicitHeight: root.widgetThickness - root.horizontalPadding * 2

            DankIcon {
                id: icon

                name: DMSNetworkService.connected ? "vpn_lock" : "vpn_key_off"
                size: Theme.barIconSize(root.barThickness, -4)
                color: DMSNetworkService.connected ? Theme.primary : Theme.surfaceText
                opacity: DMSNetworkService.isBusy ? 0.5 : 1.0
                anchors.centerIn: parent

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.shortDuration
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    Loader {
        id: tooltipLoader
        active: false
        sourceComponent: DankTooltip {}
    }

    MouseArea {
        id: clickArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: DMSNetworkService.isBusy ? Qt.BusyCursor : Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        enabled: !DMSNetworkService.isBusy
        onPressed: {
            if (popoutTarget && popoutTarget.setTriggerPosition) {
                const globalPos = root.visualContent.mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const pos = SettingsData.getPopupTriggerPosition(globalPos, currentScreen, barThickness, root.visualWidth)
                popoutTarget.setTriggerPosition(pos.x, pos.y, pos.width, section, currentScreen)
            }
            root.toggleVpnPopup();
        }
        onEntered: {
            if (root.parentScreen && !(popoutTarget && popoutTarget.shouldBeVisible)) {
                tooltipLoader.active = true
                if (tooltipLoader.item) {
                    let tooltipText = ""
                    if (!DMSNetworkService.connected) {
                        tooltipText = "VPN Disconnected"
                    } else {
                        const names = DMSNetworkService.activeNames || []
                        if (names.length <= 1) {
                            const name = names[0] || ""
                            const maxLength = 25
                            const displayName = name.length > maxLength ? name.substring(0, maxLength) + "..." : name
                            tooltipText = "VPN Connected • " + displayName
                        } else {
                            const name = names[0]
                            const maxLength = 20
                            const displayName = name.length > maxLength ? name.substring(0, maxLength) + "..." : name
                            tooltipText = "VPN Connected • " + displayName + " +" + (names.length - 1)
                        }
                    }

                    if (root.isVerticalOrientation) {
                        const globalPos = mapToGlobal(width / 2, height / 2)
                        const screenX = root.parentScreen ? root.parentScreen.x : 0
                        const screenY = root.parentScreen ? root.parentScreen.y : 0
                        const relativeY = globalPos.y - screenY
                        const tooltipX = root.axis?.edge === "left" ? (Theme.barHeight + SettingsData.dankBarSpacing + Theme.spacingXS) : (root.parentScreen.width - Theme.barHeight - SettingsData.dankBarSpacing - Theme.spacingXS)
                        const isLeft = root.axis?.edge === "left"
                        tooltipLoader.item.show(tooltipText, screenX + tooltipX, relativeY, root.parentScreen, isLeft, !isLeft)
                    } else {
                        const globalPos = mapToGlobal(width / 2, height)
                        const tooltipY = Theme.barHeight + SettingsData.dankBarSpacing + Theme.spacingXS
                        tooltipLoader.item.show(tooltipText, globalPos.x, tooltipY, root.parentScreen, false, false)
                    }
                }
            }
        }
        onExited: {
            if (tooltipLoader.item) {
                tooltipLoader.item.hide()
            }
            tooltipLoader.active = false
        }
    }
}
