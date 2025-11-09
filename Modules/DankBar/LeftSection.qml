import QtQuick
import qs.Common

Item {
    id: root

    property var widgetsModel: null
    property var components: null
    property bool noBackground: false
    required property var axis
    property var parentScreen: null
    property real widgetThickness: 30
    property real barThickness: 48
    property bool overrideAxisLayout: false
    property bool forceVerticalLayout: false

    readonly property bool isVertical: overrideAxisLayout ? forceVerticalLayout : (axis?.isVertical ?? false)

    implicitHeight: layoutLoader.item ? (layoutLoader.item.implicitHeight || layoutLoader.item.height) : 0
    implicitWidth: layoutLoader.item ? (layoutLoader.item.implicitWidth || layoutLoader.item.width) : 0

    Loader {
        id: layoutLoader
        anchors.fill: parent
        sourceComponent: root.isVertical ? columnComp : rowComp
    }

    Component {
        id: rowComp
        Row {
            readonly property real widgetSpacing: noBackground ? 2 : Theme.spacingXS
            spacing: widgetSpacing
            Repeater {
                id: rowRepeater
                model: root.widgetsModel
                Item {
                    readonly property real rowSpacing: parent.widgetSpacing
                    width: widgetLoader.item ? widgetLoader.item.width : 0
                    height: widgetLoader.item ? widgetLoader.item.height : 0
                    WidgetHost {
                        id: widgetLoader
                        anchors.verticalCenter: parent.verticalCenter
                        widgetId: model.widgetId
                        widgetData: model
                        spacerSize: model.size || 20
                        components: root.components
                        isInColumn: false
                        axis: root.axis
                        section: "left"
                        parentScreen: root.parentScreen
                        widgetThickness: root.widgetThickness
                        barThickness: root.barThickness
                        isFirst: model.index === 0
                        isLast: model.index === rowRepeater.count - 1
                        sectionSpacing: parent.rowSpacing
                        isLeftBarEdge: true
                        isRightBarEdge: false
                    }
                }
            }
        }
    }

    Component {
        id: columnComp
        Column {
            width: Math.max(parent.width, 200)
            readonly property real widgetSpacing: noBackground ? 2 : Theme.spacingXS
            spacing: widgetSpacing
            Repeater {
                id: columnRepeater
                model: root.widgetsModel
                Item {
                    readonly property real columnSpacing: parent.widgetSpacing
                    width: parent.width
                    height: widgetLoader.item ? widgetLoader.item.height : 0
                    WidgetHost {
                        id: widgetLoader
                        anchors.horizontalCenter: parent.horizontalCenter
                        widgetId: model.widgetId
                        widgetData: model
                        spacerSize: model.size || 20
                        components: root.components
                        isInColumn: true
                        axis: root.axis
                        section: "left"
                        parentScreen: root.parentScreen
                        widgetThickness: root.widgetThickness
                        barThickness: root.barThickness
                        isFirst: model.index === 0
                        isLast: model.index === columnRepeater.count - 1
                        sectionSpacing: parent.columnSpacing
                        isTopBarEdge: true
                        isBottomBarEdge: false
                    }
                }
            }
        }
    }
}