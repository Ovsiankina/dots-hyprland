pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io

/*
 * AUR updates tracker. Complements Updates.qml which counts official repo updates.
 * Uses `yay -Qua` to count available AUR package updates.
 */
Singleton {
    id: root

    property int aurCount: 0

    Timer {
        interval: Config.options.updates.checkInterval * 60 * 1000
        repeat: true
        running: Config.ready && Config.options.updates.enableCheck
        onTriggered: {
            aurCheck.running = true
        }
    }

    Process {
        id: aurCheck
        command: ["sh", "-c", "yay -Qua 2>/dev/null | wc -l || echo 0"]
        stdout: SplitParser {
            onRead: data => {
                const n = parseInt((data || "").trim())
                root.aurCount = isFinite(n) && n > 0 ? n : 0
            }
        }
    }
}
