#!/usr/bin/env python3
"""
Check for conflicting keybinds in hyprland keybinds.conf
Handles case-insensitive modifiers and different separator styles
"""

import re
import sys
from pathlib import Path
from collections import defaultdict

def normalize_combo(modifiers, key):
    """Normalize modifiers and key to a canonical form for comparison"""
    # Normalize modifiers: SUPER -> Super, ALT -> Alt, SHIFT -> Shift, CTRL -> Ctrl
    mod_map = {
        'super': 'Super',
        'alt': 'Alt',
        'shift': 'Shift',
        'ctrl': 'Ctrl',
    }

    # Split by + and normalize each part
    mods = []
    for mod in re.split(r'[\+,\s]+', modifiers.strip()):
        mod_lower = mod.lower()
        if mod_lower in mod_map:
            mods.append(mod_map[mod_lower])
        elif mod:
            mods.append(mod)

    mods.sort()  # Sort for consistency

    # Normalize key
    key = key.strip()

    # Create canonical form
    if mods:
        return '+'.join(mods) + ',' + key
    else:
        return key

def parse_keybinds(filepath):
    """Parse keybinds from config file"""
    keybinds = defaultdict(list)  # normalized_combo -> list of (bind_type, modifiers, key, action, line_num, full_line)

    with open(filepath, 'r') as f:
        for line_num, line in enumerate(f, 1):
            # Match bind declarations: bind, bindle, bindm, etc.
            match = re.match(r'^(bind[a-z]*)\s*=\s*([^,]+),\s*([^,]+),', line)
            if match:
                bind_type = match.group(1)
                modifiers = match.group(2).strip()
                key = match.group(3).strip()

                # Normalize the combo
                normalized = normalize_combo(modifiers, key)

                # Extract action (everything after the second comma)
                action_start = line.find(',', line.find(',') + 1) + 1
                action = line[action_start:].strip()

                keybinds[normalized].append({
                    'bind_type': bind_type,
                    'modifiers': modifiers,
                    'key': key,
                    'action': action,
                    'line_num': line_num,
                    'full_line': line.rstrip()
                })

    return keybinds

def normalize_action(action):
    """Normalize action for duplicate detection"""
    # Extract the core action (first meaningful part)
    # Remove [hidden] comments and fallback info
    action = re.sub(r'#\s*\[hidden\].*', '', action)
    action = re.sub(r'#.*', '', action)  # Remove comments
    action = action.strip()

    # For quickshell actions, just keep the main command
    if 'quickshell:' in action:
        match = re.search(r'quickshell:\w+', action)
        if match:
            return match.group(0)

    return action

def main():
    script_dir = Path(__file__).parent
    keybinds_file = script_dir.parent / 'hyprland' / 'keybinds.conf'

    if not keybinds_file.exists():
        print(f"Error: {keybinds_file} not found")
        sys.exit(1)

    print(f"Checking {keybinds_file}...\n")

    keybinds = parse_keybinds(keybinds_file)

    conflicts = {combo: binds for combo, binds in keybinds.items() if len(binds) > 1}

    # Find duplicates (same action on different keys)
    actions_map = defaultdict(list)  # normalized_action -> list of (combo, bind)
    for combo, binds in keybinds.items():
        for bind in binds:
            norm_action = normalize_action(bind['action'])
            if norm_action:
                actions_map[norm_action].append((combo, bind))

    duplicates = {action: combos for action, combos in actions_map.items() if len(combos) > 1}

    has_issues = False

    if conflicts:
        has_issues = True
        print(f"🔴 Found {len(conflicts)} CONFLICTING key combination(s):\n")

        for normalized_combo, binds in sorted(conflicts.items()):
            print(f"Conflict: {normalized_combo}")
            for bind in binds:
                action_preview = bind['action'][:60] + ('...' if len(bind['action']) > 60 else '')
                print(f"  Line {bind['line_num']:3d} ({bind['bind_type']:8s}): {action_preview}")
            print()
    else:
        print("✓ No conflicting keybinds found!\n")

    if duplicates:
        print(f"ℹ️ Found {len(duplicates)} duplicate actions (same action on different keys):\n")

        for action, combos in sorted(duplicates.items()):
            print(f"Duplicate: {action}")
            for combo, bind in combos:
                print(f"  Line {bind['line_num']:3d}: {combo}")
            print()

    if not has_issues:
        print("✓ All keybinds are unique!")

    return 1 if has_issues else 0

if __name__ == '__main__':
    sys.exit(main())
