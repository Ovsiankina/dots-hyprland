import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts

BarGroup {
    id: root
    property real autoHideYOffset: 0
    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    Layout.rightMargin: 6
    implicitHeight: Appearance.sizes.baseBarHeight

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: event => {
            if (event.button === Qt.LeftButton) {
                Quickshell.execDetached(["bash", "-c", `${Config.options.apps.terminal} zsh -lc '${StringUtils.shellSingleQuoteEscape("yay -Syu")}'`]);
            } else if (event.button === Qt.RightButton) {
                Quickshell.execDetached(["bash", "-c", `${Config.options.apps.terminal} zsh -lc '${StringUtils.shellSingleQuoteEscape("sudo pacman -Syu")}'`]);
            }
        }
    }

    RowLayout {
        spacing: 6

        Loader {
            active: Updates.count > 0
            visible: active
            sourceComponent: RowLayout {
                spacing: 6
                StyledText {
                    text: "󰮯"
                    font.pixelSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer0
                }
                StyledText {
                    text: Updates.count
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer0
                }
            }
            transform: Translate {
                y: root.autoHideYOffset
            }
        }

        Loader {
            active: (Updates.count > 0) && (OvUpdates.aurCount > 0)
            visible: active
            sourceComponent: StyledText {
                text: "|"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer0
            }
            transform: Translate {
                y: root.autoHideYOffset
            }
        }

        Loader {
            active: OvUpdates.aurCount > 0
            visible: active
            sourceComponent: RowLayout {
                spacing: 6
                StyledText {
                    text: ""
                    font.pixelSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer0
                }
                StyledText {
                    text: OvUpdates.aurCount
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: Appearance.colors.colOnLayer0
                }
            }
            transform: Translate {
                y: root.autoHideYOffset
            }
        }
    }
}
