import qs.modules.common
import qs.modules.common.widgets
import qs.services
import qs
import QtQuick
import QtQuick.Layouts

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool alwaysShowAllResources: false
    property real autoHideYOffset: 0
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: true

    RowLayout {
        id: rowLayout

        spacing: 0
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        Resource {
            iconName: "memory"
            percentage: ResourceUsage.memoryUsedPercentage
            warningThreshold: (Config?.options?.resources?.ramHigh ?? 80)
            transform: Translate {
                readonly property real ramThreshold: (Config?.options?.resources?.ramHigh ?? 80) / 100
                y: ((ResourceUsage.memoryUsedPercentage ?? 0) >= ramThreshold) ? root.autoHideYOffset : 0
            }
        }

        Resource {
            iconName: "swap_horiz"
            percentage: ResourceUsage.swapUsedPercentage
            warningThreshold: (Config?.options?.resources?.ramHigh ?? 80)
            shown: (Config.options.bar.resources.alwaysShowSwap && percentage > 0) ||
                (MprisController.activePlayer?.trackTitle == null) ||
                root.alwaysShowAllResources
            Layout.leftMargin: shown ? 6 : 0
        }

        Resource {
            iconName: "planner_review"
            percentage: ResourceUsage.cpuUsage
            warningThreshold: (Config?.options?.resources?.cpuHigh ?? 80)
            shown: Config.options.bar.resources.alwaysShowCpu ||
                !(MprisController.activePlayer?.trackTitle?.length > 0) ||
                root.alwaysShowAllResources
            Layout.leftMargin: shown ? 6 : 0
            transform: Translate {
                readonly property real cpuThreshold: (Config?.options?.resources?.cpuHigh ?? 80) / 100
                y: ((ResourceUsage.cpuUsage ?? 0) >= cpuThreshold) ? root.autoHideYOffset : 0
            }
        }

        OvCpuTempIndicator {
            Layout.leftMargin: 6
            temperatureC: ResourceUsage.cpuTempC
            transform: Translate {
                readonly property real tempThresholdC: (Config?.options?.resources?.cpuTempHighC ?? 70)
                y: ((ResourceUsage.cpuTempC ?? 0) >= tempThresholdC) ? root.autoHideYOffset : 0
            }
        }
    }

    ResourcesPopup {
        hoverTarget: root
    }
}
