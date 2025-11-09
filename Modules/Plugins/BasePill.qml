import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: root

    property var axis: null
    property string section: "center"
    property var popoutTarget: null
    property var parentScreen: null
    property real widgetThickness: 30
    property real barThickness: 48
    property alias content: contentLoader.sourceComponent
    property bool isVerticalOrientation: axis?.isVertical ?? false
    property bool isFirst: false
    property bool isLast: false
    property real sectionSpacing: 0
    property bool isLeftBarEdge: false
    property bool isRightBarEdge: false
    property bool isTopBarEdge: false
    property bool isBottomBarEdge: false
    readonly property real horizontalPadding: SettingsData.dankBarNoBackground ? 0 : Math.max(Theme.spacingXS, Theme.spacingS * (widgetThickness / 30))
    readonly property real visualWidth: isVerticalOrientation ? widgetThickness : (contentLoader.item ? (contentLoader.item.implicitWidth + horizontalPadding * 2) : 0)
    readonly property real visualHeight: isVerticalOrientation ? (contentLoader.item ? (contentLoader.item.implicitHeight + horizontalPadding * 2) : 0) : widgetThickness
    readonly property alias visualContent: visualContent
    readonly property real barEdgeExtension: 1000
    readonly property real gapExtension: sectionSpacing
    readonly property real leftMargin: !isVerticalOrientation ? (isLeftBarEdge && isFirst ? barEdgeExtension : (isFirst ? gapExtension : gapExtension / 2)) : 0
    readonly property real rightMargin: !isVerticalOrientation ? (isRightBarEdge && isLast ? barEdgeExtension : (isLast ? gapExtension : gapExtension / 2)) : 0
    readonly property real topMargin: isVerticalOrientation ? (isTopBarEdge && isFirst ? barEdgeExtension : (isFirst ? gapExtension : gapExtension / 2)) : 0
    readonly property real bottomMargin: isVerticalOrientation ? (isBottomBarEdge && isLast ? barEdgeExtension : (isLast ? gapExtension : gapExtension / 2)) : 0

    signal clicked()
    signal rightClicked()

    width: isVerticalOrientation ? barThickness : visualWidth
    height: isVerticalOrientation ? visualHeight : barThickness

    Rectangle {
        id: visualContent
        width: root.visualWidth
        height: root.visualHeight
        anchors.centerIn: parent
        radius: SettingsData.dankBarNoBackground ? 0 : Theme.cornerRadius
        color: {
            if (SettingsData.dankBarNoBackground) {
                return "transparent"
            }

            const isHovered = mouseArea.containsMouse || (root.isHovered ?? false)
            const baseColor = isHovered ? Theme.widgetBaseHoverColor : Theme.widgetBaseBackgroundColor
            return Qt.rgba(baseColor.r, baseColor.g, baseColor.b, baseColor.a * Theme.widgetTransparency)
        }

        Loader {
            id: contentLoader
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    MouseArea {
        id: mouseArea
        z: -1
        x: -root.leftMargin
        y: -root.topMargin
        width: root.width + root.leftMargin + root.rightMargin
        height: root.height + root.topMargin + root.bottomMargin
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: function (mouse) {
            if (mouse.button === Qt.RightButton) {
                root.rightClicked()
                return
            }
            if (popoutTarget && popoutTarget.setTriggerPosition) {
                const globalPos = root.visualContent.mapToGlobal(0, 0)
                const currentScreen = parentScreen || Screen
                const pos = SettingsData.getPopupTriggerPosition(globalPos, currentScreen, barThickness, root.visualWidth)
                popoutTarget.setTriggerPosition(pos.x, pos.y, pos.width, section, currentScreen)
            }
            root.clicked()
        }
    }
}
