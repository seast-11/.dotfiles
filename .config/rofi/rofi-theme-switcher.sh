#!/usr/bin/env bash
#
# Rofi Theme Switcher
# Usage: ./rofi-theme-switcher.sh [theme-name]
#   If no theme name is provided, it will show a rofi menu to choose from.
#
# Available themes:
#   catppuccin    - Catppuccin Mocha
#   kanagawa      - Kanagawa
#   tokyo-night   - Tokyo Night
#   gruvbox-material - Gruvbox Material

ROFI_CONFIG_DIR="${HOME}/.config/rofi"
THEMES_DIR="${ROFI_CONFIG_DIR}/themes"
CONFIG_FILE="${ROFI_CONFIG_DIR}/config"
RASI_CONFIG="${ROFI_CONFIG_DIR}/config.rasi"

THEMES=(
    "catppuccin"
    "kanagawa"
    "tokyo-night"
    "gruvbox-material"
)

THEME_NAMES=(
    "Catppuccin Mocha"
    "Kanagawa"
    "Tokyo Night"
    "Gruvbox Material"
)

get_current_theme() {
    if [ -f "$RASI_CONFIG" ]; then
        local current
        current=$(head -1 "$RASI_CONFIG" 2>/dev/null)
        # Extract the theme name from @import "themes/name"
        current=$(echo "$current" | grep -oP 'themes/\K[^"]+' | sed 's/\.rasi//')
        echo "$current"
    fi
}

set_theme() {
    local theme="$1"
    local theme_file="${THEMES_DIR}/${theme}.rasi"

    if [ ! -f "$theme_file" ]; then
        echo "Error: Theme file not found: $theme_file"
        exit 1
    fi

    # Update the rasi config
    echo "@import \"themes/${theme}.rasi\"" > "$RASI_CONFIG"

    # Also update the text config for backward compatibility
    echo "rofi.theme: ${theme_file}" > "$CONFIG_FILE"

    echo "Theme switched to: ${theme}"
}

show_menu() {
    local current_theme
    current_theme=$(get_current_theme)

    local menu_items=""
    for i in "${!THEMES[@]}"; do
        local name="${THEME_NAMES[$i]}"
        local id="${THEMES[$i]}"
        local indicator=""
        if [ "$id" = "$current_theme" ]; then
            indicator="✓ "
        fi
        menu_items+="${indicator}${name}\n"
    done

    local selected
    selected=$(echo -e "$menu_items" | rofi -dmenu -p "Theme Switcher" -i -theme-str "listview { spacing: 5px; } element { padding: 10px; }")

    if [ -z "$selected" ]; then
        exit 0
    fi

    # Find the matching theme
    local selected_name
    selected_name=$(echo "$selected" | sed 's/^✓ *//')

    for i in "${!THEME_NAMES[@]}"; do
        if [ "${THEME_NAMES[$i]}" = "$selected_name" ]; then
            set_theme "${THEMES[$i]}"
            return
        fi
    done

    echo "Unknown theme selected: $selected"
    exit 1
}

# Main
if [ $# -eq 0 ]; then
    show_menu
elif [ $# -eq 1 ]; then
    set_theme "$1"
else
    echo "Usage: $0 [theme-name]"
    echo "Available themes: ${THEMES[*]}"
    exit 1
fi
