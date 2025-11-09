import QtQuick
import qs.Common
import qs.Modules.Settings

Item {
    id: root

    property int currentIndex: 0
    property var parentModal: null

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 0
        anchors.rightMargin: Theme.spacingS
        anchors.bottomMargin: Theme.spacingM
        anchors.topMargin: 0
        color: "transparent"

        Loader {
            id: personalizationLoader

            anchors.fill: parent
            active: root.currentIndex === 0
            visible: active

            sourceComponent: Component {
                PersonalizationTab {
                    parentModal: root.parentModal
                }

            }

        }

        Loader {
            id: timeWeatherLoader

            anchors.fill: parent
            active: root.currentIndex === 1
            visible: active

            sourceComponent: TimeWeatherTab {
            }

        }

        Loader {
            id: topBarLoader

            anchors.fill: parent
            active: root.currentIndex === 2
            visible: active

            sourceComponent: DankBarTab {
                parentModal: root.parentModal
            }

        }

        Loader {
            id: widgetsLoader

            anchors.fill: parent
            active: root.currentIndex === 3
            visible: active

            sourceComponent: WidgetTweaksTab {
            }

        }

        Loader {
            id: dockLoader

            anchors.fill: parent
            active: root.currentIndex === 4
            visible: active

            sourceComponent: Component {
                DockTab {
                }

            }

        }

        Loader {
            id: displaysLoader

            anchors.fill: parent
            active: root.currentIndex === 5
            visible: active

            sourceComponent: DisplaysTab {
            }

        }

        Loader {
            id: launcherLoader

            anchors.fill: parent
            active: root.currentIndex === 6
            visible: active

            sourceComponent: LauncherTab {
            }

        }

        Loader {
            id: themeColorsLoader

            anchors.fill: parent
            active: root.currentIndex === 7
            visible: active

            sourceComponent: ThemeColorsTab {
            }

        }

        Loader {
            id: powerLoader

            anchors.fill: parent
            active: root.currentIndex === 8
            visible: active

            sourceComponent: PowerSettings {
            }

        }

        Loader {
            id: pluginsLoader

            anchors.fill: parent
            active: root.currentIndex === 9
            visible: active

            sourceComponent: PluginsTab {
                parentModal: root.parentModal
            }

        }

        Loader {
            id: aboutLoader

            anchors.fill: parent
            active: root.currentIndex === 10
            visible: active

            sourceComponent: AboutTab {
            }

        }

    }

}
