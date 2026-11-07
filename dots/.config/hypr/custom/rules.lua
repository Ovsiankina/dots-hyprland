-- You can put custom rules here
-- Window/layer rules: https://wiki.hypr.land/configuring/core/rules/window-rules/
-- Workspace rules: https://wiki.hypr.land/configuring/core/rules/workspace-rules/

-- ######## Window rules ########

-- Uncomment to apply global transparency to all windows:
-- (was `windowrule = opacity 0.89 override 0.89 override, match:class .*`)
-- hl.window_rule({ match = { class = ".*" }, opacity = "0.89 override 0.89 override" })

-- Disable blur for all xwayland apps
-- (was `windowrule = no_blur on, match:xwayland 1`)
-- hl.window_rule({ match = { xwayland = true }, no_blur = true })
