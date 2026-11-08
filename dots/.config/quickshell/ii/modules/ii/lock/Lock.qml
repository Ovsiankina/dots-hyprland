pragma ComponentBehavior: Bound
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.panels.lock
import QtQuick
import Quickshell
import Quickshell.Hyprland

LockScreen {
    id: root

    // Monitor name -> workspace id to restore on unlock (set when locking)
    property var savedWorkspaces: ({})

    Timer {
        id: restoreTimer
        interval: 150
        repeat: false
        onTriggered: {
            // Hyprland 0.57+: one Lua chunk via `hyprctl eval` replaces the old `hyprctl --batch`
            var lua = ""
            for (var j = 0; j < Quickshell.screens.length; ++j) {
                var monName = Quickshell.screens[j].name
                var wsId = root.savedWorkspaces[monName]
                if (wsId !== undefined) {
                    lua += root.focusMonitorWorkspaceLua(monName, wsId)
                }
            }
            if (lua.length > 0) {
                root.evalThenReload(lua)
            }
        }
    }

    function focusMonitorWorkspaceLua(monitor, workspace) {
        return `hl.dispatch(hl.dsp.focus({ monitor = "${monitor}" })); hl.dispatch(hl.dsp.focus({ workspace = ${workspace} })); `
    }

    // Lua is passed as $1, so it needs no shell quoting
    function evalThenReload(lua) {
        Quickshell.execDetached(["sh", "-c", 'hyprctl eval "$1" && hyprctl reload', "sh", lua])
    }

    lockSurface: LockSurface {
        context: root.context
    }

    // Single batch for lock and unlock so we don't race multiple hyprctl calls
    Connections {
        target: GlobalStates
        function onScreenLockedChanged() {
            if (GlobalStates.screenLocked) {
                // Lock: save workspace per monitor and move all to temp workspace in one batch
                var next = {}
                var lua = 'hl.animation({ leaf = "workspaces", enabled = true, speed = 7, bezier = "menu_decel", style = "slidevert" }); '
                for (var i = 0; i < Quickshell.screens.length; ++i) {
                    var mon = Quickshell.screens[i].name
                    var mData = HyprlandData.monitors.find(m => m.name === mon)
                    if (mData?.activeWorkspace == undefined) {
                        return;
                    }
                    var ws = (mData?.activeWorkspace?.id ?? 1)
                    next[mon] = ws
                    lua += root.focusMonitorWorkspaceLua(mon, 2147483647 - ws)
                }
                root.savedWorkspaces = next
                root.evalThenReload(lua)
            } else {
                restoreTimer.start()
            }
        }
    }

    // Push everything down (visual only; workspace switch is in Connections above)
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property ShellScreen modelData
            property bool shouldPush: GlobalStates.screenLocked
            property string targetMonitorName: modelData.name
            property int verticalMovementDistance: modelData.height
            property int horizontalSqueeze: modelData.width * 0.2
        }
    }
}
