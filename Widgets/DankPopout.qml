import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.Common
import qs.Services

PanelWindow {
    id: root

    property string layerNamespace: "dms:popout"
    WlrLayershell.namespace: layerNamespace

    property alias content: contentLoader.sourceComponent
    property alias contentLoader: contentLoader
    property real popupWidth: 400
    property real popupHeight: 300
    property real triggerX: 0
    property real triggerY: 0
    property real triggerWidth: 40
    property string triggerSection: ""
    property string positioning: "center"
    property int animationDuration: Theme.expressiveDurations.expressiveDefaultSpatial
    property real animationScaleCollapsed: 0.96
    property real animationOffset: Theme.spacingL
    property list<real> animationEnterCurve: Theme.expressiveCurves.expressiveDefaultSpatial
    property list<real> animationExitCurve: Theme.expressiveCurves.emphasized
    property bool shouldBeVisible: false
    property int keyboardFocusMode: WlrKeyboardFocus.OnDemand

    signal opened
    signal popoutClosed
    signal backgroundClicked

    function open() {
        closeTimer.stop()
        shouldBeVisible = true
        visible = true
        opened()
    }

    function close() {
        shouldBeVisible = false
        closeTimer.restart()
    }

    function toggle() {
        if (shouldBeVisible)
            close()
        else
            open()
    }

    Timer {
        id: closeTimer
        interval: animationDuration
        onTriggered: {
            if (!shouldBeVisible) {
                visible = false
                popoutClosed()
            }
        }
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayershell.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: shouldBeVisible ? keyboardFocusMode : WlrKeyboardFocus.None 

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    readonly property real screenWidth: root.screen.width
    readonly property real screenHeight: root.screen.height
    readonly property real dpr: CompositorService.getScreenScale(root.screen)

    readonly property real alignedWidth: Theme.px(popupWidth, dpr)
    readonly property real alignedHeight: Theme.px(popupHeight, dpr)
    readonly property real alignedX: Theme.snap((() => {
        if (SettingsData.dankBarPosition === SettingsData.Position.Left) {
            return triggerY + SettingsData.dankBarBottomGap
        } else if (SettingsData.dankBarPosition === SettingsData.Position.Right) {
            return screenWidth - triggerY - SettingsData.dankBarBottomGap - popupWidth
        } else {
            const centerX = triggerX + (triggerWidth / 2) - (popupWidth / 2)
            return Math.max(Theme.popupDistance, Math.min(screenWidth - popupWidth - Theme.popupDistance, centerX))
        }
    })(), dpr)
    readonly property real alignedY: Theme.snap((() => {
        if (SettingsData.dankBarPosition === SettingsData.Position.Left || SettingsData.dankBarPosition === SettingsData.Position.Right) {
            const centerY = triggerX + (triggerWidth / 2) - (popupHeight / 2)
            return Math.max(Theme.popupDistance, Math.min(screenHeight - popupHeight - Theme.popupDistance, centerY))
        } else if (SettingsData.dankBarPosition === SettingsData.Position.Bottom) {
            return Math.max(Theme.popupDistance, screenHeight - triggerY - popupHeight)
        } else {
            return Math.min(screenHeight - popupHeight - Theme.popupDistance, triggerY)
        }
    })(), dpr)

    MouseArea {
        anchors.fill: parent
        enabled: shouldBeVisible && contentLoader.opacity > 0.1
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.x < alignedX || mouse.x > alignedX + alignedWidth ||
                mouse.y < alignedY || mouse.y > alignedY + alignedHeight) {
                backgroundClicked()
                close()
            }
        }
    }

    Item {
        id: contentContainer
        x: alignedX
        y: alignedY
        width: alignedWidth
        height: alignedHeight

        readonly property bool barTop: SettingsData.dankBarPosition === SettingsData.Position.Top
        readonly property bool barBottom: SettingsData.dankBarPosition === SettingsData.Position.Bottom
        readonly property bool barLeft: SettingsData.dankBarPosition === SettingsData.Position.Left
        readonly property bool barRight: SettingsData.dankBarPosition === SettingsData.Position.Right
        readonly property real offsetX: barLeft ? root.animationOffset : (barRight ? -root.animationOffset : 0)
        readonly property real offsetY: barBottom ? -root.animationOffset : (barTop ? root.animationOffset : 0)

        property real animX: 0
        property real animY: 0
        property real scaleValue: root.animationScaleCollapsed

        onOffsetXChanged: animX = Theme.snap(root.shouldBeVisible ? 0 : offsetX, root.dpr)
        onOffsetYChanged: animY = Theme.snap(root.shouldBeVisible ? 0 : offsetY, root.dpr)

        Connections {
            target: root
            function onShouldBeVisibleChanged() {
                contentContainer.animX = Theme.snap(root.shouldBeVisible ? 0 : contentContainer.offsetX, root.dpr)
                contentContainer.animY = Theme.snap(root.shouldBeVisible ? 0 : contentContainer.offsetY, root.dpr)
                contentContainer.scaleValue = root.shouldBeVisible ? 1.0 : root.animationScaleCollapsed
            }
        }

        Behavior on animX {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.shouldBeVisible ? root.animationEnterCurve : root.animationExitCurve
            }
        }

        Behavior on animY {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.shouldBeVisible ? root.animationEnterCurve : root.animationExitCurve
            }
        }

        Behavior on scaleValue {
            NumberAnimation {
                duration: root.animationDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.shouldBeVisible ? root.animationEnterCurve : root.animationExitCurve
            }
        }

        Loader {
            id: contentLoader
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            active: root.visible
            asynchronous: false
            layer.enabled: Quickshell.env("DMS_DISABLE_LAYER") !== "true" && Quickshell.env("DMS_DISABLE_LAYER") !== "1"
            layer.smooth: false
            layer.textureSize: Qt.size(width * root.dpr, height * root.dpr)
            layer.textureMirroring: ShaderEffectSource.NoMirroring
            opacity: shouldBeVisible ? 1 : 0
            visible: opacity > 0
            scale: contentContainer.scaleValue
            x: Theme.snap(contentContainer.animX + (parent.width - width) * (1 - contentContainer.scaleValue) * 0.5, root.dpr)
            y: Theme.snap(contentContainer.animY + (parent.height - height) * (1 - contentContainer.scaleValue) * 0.5, root.dpr)

            Behavior on opacity {
                NumberAnimation {
                    duration: animationDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.shouldBeVisible ? root.animationEnterCurve : root.animationExitCurve
                }
            }
        }
    }

    Item {
        parent: contentContainer
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                close()
                event.accepted = true
            }
        }
        Component.onCompleted: forceActiveFocus()
        onVisibleChanged: if (visible) forceActiveFocus()
    }
}
