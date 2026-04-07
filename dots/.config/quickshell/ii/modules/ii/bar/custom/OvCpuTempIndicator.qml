import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property real temperatureC
    property real maxC: 100
    readonly property real warnThresholdC: (Config?.options?.resources?.cpuTempHighC ?? 70)
    readonly property bool hot: root.temperatureC >= warnThresholdC

    implicitHeight: Appearance.sizes.barHeight
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row
        spacing: 2
        anchors.verticalCenter: parent.verticalCenter

        ClippedFilledCircularProgress {
            id: circle
            Layout.alignment: Qt.AlignVCenter
            lineWidth: Appearance.rounding.unsharpen
            value: Math.max(0, Math.min(1, root.temperatureC / root.maxC))
            implicitSize: 20
            colPrimary: root.hot ? "#CD4A4F" : Appearance.colors.colPrimary
            enableAnimation: false

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: root.hot
                NumberAnimation { from: 1.0; to: 0.5; duration: 900; easing.type: Easing.InOutQuad }
                NumberAnimation { from: 0.5; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
            }

            Item {
                anchors.centerIn: parent
                width: circle.implicitSize
                height: circle.implicitSize

                MaterialSymbol {
                    anchors.centerIn: parent
                    font.weight: Font.DemiBold
                    fill: 1
                    text: "device_thermostat"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.m3colors.m3onSecondaryContainer
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: tempTextMetrics.width
            implicitHeight: tempText.implicitHeight

            TextMetrics {
                id: tempTextMetrics
                text: "100"
                font.pixelSize: Appearance.font.pixelSize.small
            }

            StyledText {
                id: tempText
                anchors.centerIn: parent
                color: Appearance.colors.colOnLayer1
                font.pixelSize: Appearance.font.pixelSize.small
                text: Math.round(root.temperatureC).toString()
            }
        }
    }
}
