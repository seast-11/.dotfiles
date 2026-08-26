#!/usr/bin/env bash
#
# Rofi Theme + Icons Setup Script
# Installs themes, icon theme, and configures rofi for program picking with icons.
#
# Usage: ./setup.sh
#   Run this once to set everything up.

set -e

ROFI_CONFIG_DIR="${HOME}/.config/rofi"
THEMES_DIR="${ROFI_CONFIG_DIR}/themes"
ICONS_DIR="${HOME}/.local/share/icons"
ICONS_THEME_DIR="${ICONS_DIR}/Papirus"
BIN_DIR="${HOME}/.local/bin"

PAPIRUS_VERSION="20250501"
PAPIRUS_URL="https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/refs/tags/${PAPIRUS_VERSION}.tar.gz"

echo "=== Rofi Theme + Icons Setup ==="
echo ""

# ---------- 1. Create directory structure ----------
echo "[1/6] Creating directory structure..."
mkdir -p "$THEMES_DIR"
mkdir -p "$ICONS_DIR"
mkdir -p "$BIN_DIR"
echo "  ✓ Directories created"

# ---------- 2. Download & install Papirus icon theme ----------
echo "[2/6] Installing Papirus icon theme..."

if [ -d "$ICONS_THEME_DIR" ]; then
    echo "  Papirus already installed at ${ICONS_THEME_DIR}"
else
    echo "  Downloading Papirus v${PAPIRUS_VERSION}..."
    curl -sL "$PAPIRUS_URL" -o /tmp/papirus.tar.gz
    echo "  Extracting..."
    tar -xzf /tmp/papirus.tar.gz -C /tmp/
    echo "  Installing..."
    cp -r "/tmp/papirus-icon-theme-${PAPIRUS_VERSION}/Papirus" "${ICONS_DIR}/Papirus"
    cp -r "/tmp/papirus-icon-theme-${PAPIRUS_VERSION}/Papirus-Dark" "${ICONS_DIR}/Papirus-Dark"
    cp -r "/tmp/papirus-icon-theme-${PAPIRUS_VERSION}/Papirus-Light" "${ICONS_DIR}/Papirus-Light"
    rm -rf /tmp/papirus.tar.gz "/tmp/papirus-icon-theme-${PAPIRUS_VERSION}"
    echo "  ✓ Papirus installed to ${ICONS_DIR}"
fi

# ---------- 3. Create theme files ----------
echo "[3/6] Creating rofi theme files..."

# Common layout
cat > "${THEMES_DIR}/common.rasi" << 'COMMONEOF'
/* ==========================================================================
   Common layout for all themes
   ========================================================================== */

window {
    background-color: @background;
    border:           2;
    padding:          2;
}

mainbox {
    border:  0;
    padding: 0;
}

message {
    border:       2px 0 0;
    border-color: @separatorcolor;
    padding:      1px;
}

textbox {
    highlight:  @highlight;
    text-color: @foreground;
}

listview {
    border:       2px solid 0 0;
    padding:      2px 0 0;
    border-color: @separatorcolor;
    spacing:      2px;
    scrollbar:    @scrollbar;
}

element {
    border:  0;
    padding: 2px;
}

element.normal.normal {
    background-color: @normal-background;
    text-color:       @normal-foreground;
}

element.normal.urgent {
    background-color: @urgent-background;
    text-color:       @urgent-foreground;
}

element.normal.active {
    background-color: @active-background;
    text-color:       @active-foreground;
}

element.selected.normal {
    background-color: @selected-normal-background;
    text-color:       @selected-normal-foreground;
}

element.selected.urgent {
    background-color: @selected-urgent-background;
    text-color:       @selected-urgent-foreground;
}

element.selected.active {
    background-color: @selected-active-background;
    text-color:       @selected-active-foreground;
}

element.alternate.normal {
    background-color: @alternate-normal-background;
    text-color:       @alternate-normal-foreground;
}

element.alternate.urgent {
    background-color: @alternate-urgent-background;
    text-color:       @alternate-urgent-foreground;
}

element.alternate.active {
    background-color: @alternate-active-background;
    text-color:       @alternate-active-foreground;
}

element-icon {
    background-color: inherit;
    text-color:       inherit;
    size:             24px;
}

element-text {
    background-color: inherit;
    text-color:       inherit;
    vertical-align:   center;
    margin:           0 0 0 10px;
}

scrollbar {
    width:        4px;
    border:       0;
    handle-color: @scrollbar-handle;
    handle-width: 8px;
    padding:      0;
}

mode-switcher {
    border:       2px 0 0;
    border-color: @separatorcolor;
}

inputbar {
    spacing:    0;
    text-color: @normal-foreground;
    padding:    2px;
    children:   [ prompt, textbox-prompt-sep, entry, case-indicator ];
}

case-indicator,
entry,
prompt,
button {
    spacing:    0;
    text-color: @normal-foreground;
}

button.selected {
    background-color: @selected-normal-background;
    text-color:       @selected-normal-foreground;
}

textbox-prompt-sep {
    expand:     false;
    str:        ":";
    text-color: @normal-foreground;
    margin:     0 0.3em 0 0;
}
COMMONEOF

# Catppuccin Mocha
cat > "${THEMES_DIR}/catppuccin.rasi" << 'CATPPUCCINEOF'
* {
    highlight: bold italic;
    scrollbar: true;

    bg:              #1e1e2e;
    bg-alt:          #181825;
    surface:         #313244;
    mantle:          #181825;
    crust:           #11111b;
    overlay:         #6c7086;
    subtext:         #a6adc8;
    text:            #bac2de;
    white:           #cdd6f4;

    rosewater:       #f5e0dc;
    flamingo:        #f2cdcd;
    pink:            #f5c2b7;
    maroon:          #eba0bc;
    red:             #f38fa8;
    peach:           #fab387;
    yellow:          #f9e2af;
    green:           #a6e3a1;
    teal:            #94e2d5;
    blue:            #89b4fa;
    lavender:        #b8b8f8;
    mauve:           #cba6f8;

    background:                  @bg;
    background-color:            @background;
    foreground:                  @text;
    border-color:                @overlay;
    separatorcolor:              @border-color;
    scrollbar-handle:            @border-color;

    normal-background:           @background;
    normal-foreground:           @foreground;
    alternate-normal-background: @mantle;
    alternate-normal-foreground: @foreground;
    selected-normal-background:  @surface;
    selected-normal-foreground:  @white;

    active-background:           @blue;
    active-foreground:           @background;
    alternate-active-background: @active-background;
    alternate-active-foreground: @active-foreground;
    selected-active-background:  @teal;
    selected-active-foreground:  @active-foreground;

    urgent-background:           @red;
    urgent-foreground:           @background;
    alternate-urgent-background: @urgent-background;
    alternate-urgent-foreground: @urgent-foreground;
    selected-urgent-background:  @peach;
    selected-urgent-foreground:  @urgent-foreground;
}

@import "common"
CATPPUCCINEOF

# Kanagawa
cat > "${THEMES_DIR}/kanagawa.rasi" << 'KANAGAWAEOF'
* {
    highlight: bold italic;
    scrollbar: true;

    bg:              #1f1b28;
    bg-alt:          #252232;
    surface:         #2c2838;
    mantle:          #252232;
    crust:           #15131d;
    overlay:         #5f5f64;
    subtext:         #a6a6ab;
    text:            #c3c3c7;
    white:           #c3c3c7;

    red:             #e46868;
    green:           #87a987;
    yellow:          #e6b86e;
    blue:            #6588b4;
    magenta:         #b47ea8;
    cyan:            #74a7a7;
    violet:          #a89db8;

    background:                  @bg;
    background-color:            @background;
    foreground:                  @text;
    border-color:                @overlay;
    separatorcolor:              @border-color;
    scrollbar-handle:            @border-color;

    normal-background:           @background;
    normal-foreground:           @foreground;
    alternate-normal-background: @mantle;
    alternate-normal-foreground: @foreground;
    selected-normal-background:  @surface;
    selected-normal-foreground:  @white;

    active-background:           @blue;
    active-foreground:           @background;
    alternate-active-background: @active-background;
    alternate-active-foreground: @active-foreground;
    selected-active-background:  @cyan;
    selected-active-foreground:  @active-foreground;

    urgent-background:           @red;
    urgent-foreground:           @background;
    alternate-urgent-background: @urgent-background;
    alternate-urgent-foreground: @urgent-foreground;
    selected-urgent-background:  @yellow;
    selected-urgent-foreground:  @urgent-foreground;
}

@import "common"
KANAGAWAEOF

# Tokyo Night
cat > "${THEMES_DIR}/tokyo-night.rasi" << 'TOKYOEOF'
* {
    highlight: bold italic;
    scrollbar: true;

    bg:              #1a1b26;
    bg-alt:          #292b3a;
    surface:         #292b3a;
    mantle:          #292b3a;
    crust:           #16171e;
    overlay:         #565f89;
    subtext:         #7a8ba8;
    text:            #9aa5b4;
    white:           #c0caf5;

    red:             #f7768e;
    green:           #9ece6a;
    yellow:          #e0af68;
    blue:            #7aa2f7;
    magenta:         #bb9af7;
    cyan:            #7dc4f0;
    violet:          #7aa2f7;

    background:                  @bg;
    background-color:            @background;
    foreground:                  @text;
    border-color:                @overlay;
    separatorcolor:              @border-color;
    scrollbar-handle:            @border-color;

    normal-background:           @background;
    normal-foreground:           @foreground;
    alternate-normal-background: @mantle;
    alternate-normal-foreground: @foreground;
    selected-normal-background:  @surface;
    selected-normal-foreground:  @white;

    active-background:           @blue;
    active-foreground:           @background;
    alternate-active-background: @active-background;
    alternate-active-foreground: @active-foreground;
    selected-active-background:  @cyan;
    selected-active-foreground:  @active-foreground;

    urgent-background:           @red;
    urgent-foreground:           @background;
    alternate-urgent-background: @urgent-background;
    alternate-urgent-foreground: @urgent-foreground;
    selected-urgent-background:  @yellow;
    selected-urgent-foreground:  @urgent-foreground;
}

@import "common"
TOKYOEOF

# Gruvbox Material
cat > "${THEMES_DIR}/gruvbox-material.rasi" << 'GRUVBOXEOF'
* {
    highlight: bold italic;
    scrollbar: true;

    bg:              #282828;
    bg-alt:          #32302f;
    surface:         #32302f;
    mantle:          #32302f;
    crust:           #202020;
    overlay:         #928374;
    subtext:         #a89984;
    text:            #d5c4a1;
    white:           #ebdbb2;

    red:             #ea6962;
    green:           #a9b665;
    yellow:          #d8a657;
    blue:            #7b8f9c;
    magenta:         #b3767e;
    cyan:            #89b482;
    violet:          #7b8f9c;

    background:                  @bg;
    background-color:            @background;
    foreground:                  @text;
    border-color:                @overlay;
    separatorcolor:              @border-color;
    scrollbar-handle:            @border-color;

    normal-background:           @background;
    normal-foreground:           @foreground;
    alternate-normal-background: @mantle;
    alternate-normal-foreground: @foreground;
    selected-normal-background:  @surface;
    selected-normal-foreground:  @white;

    active-background:           @blue;
    active-foreground:           @background;
    alternate-active-background: @active-background;
    alternate-active-foreground: @active-foreground;
    selected-active-background:  @cyan;
    selected-active-foreground:  @active-foreground;

    urgent-background:           @red;
    urgent-foreground:           @background;
    alternate-urgent-background: @urgent-background;
    alternate-urgent-foreground: @urgent-foreground;
    selected-urgent-background:  @yellow;
    selected-urgent-foreground:  @urgent-foreground;
}

@import "common"
GRUVBOXEOF

echo "  ✓ Theme files created"

# ---------- 4. Create config files ----------
echo "[4/6] Creating config files..."

# Main config (settings file)
cat > "${ROFI_CONFIG_DIR}/config" << 'CONFIGEOF'
rofi.theme: /home/pop/.config/rofi/themes/catppuccin.rasi
rofi.icon-theme: Papirus
rofi.show-icons: true
rofi.dpi-aware: true
CONFIGEOF

# Theme config (rasi import file)
echo '@import "themes/catppuccin.rasi"' > "${ROFI_CONFIG_DIR}/config.rasi"

# Theme switcher script
cat > "${ROFI_CONFIG_DIR}/rofi-theme-switcher.sh" << 'SWITCHEREOF'
#!/usr/bin/env bash
ROFI_CONFIG_DIR="${HOME}/.config/rofi"
THEMES_DIR="${ROFI_CONFIG_DIR}/themes"
RASI_CONFIG="${ROFI_CONFIG_DIR}/config.rasi"
CONFIG_FILE="${ROFI_CONFIG_DIR}/config"

THEMES=("catppuccin" "kanagawa" "tokyo-night" "gruvbox-material")
THEME_NAMES=("Catppuccin Mocha" "Kanagawa" "Tokyo Night" "Gruvbox Material")

get_current_theme() {
    if [ -f "$RASI_CONFIG" ]; then
        current=$(head -1 "$RASI_CONFIG" 2>/dev/null)
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
    echo "@import \"themes/${theme}.rasi\"" > "$RASI_CONFIG"
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
        [ "$id" = "$current_theme" ] && indicator="✓ "
        menu_items+="${indicator}${name}\n"
    done
    selected=$(echo -e "$menu_items" | rofi -dmenu -p "Theme Switcher" -i -theme-str "listview { spacing: 5px; } element { padding: 10px; }")
    [ -z "$selected" ] && exit 0
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

[ $# -eq 0 ] && show_menu || set_theme "$1"
SWITCHEREOF
chmod +x "${ROFI_CONFIG_DIR}/rofi-theme-switcher.sh"

echo "  ✓ Config files created"

# ---------- 5. Create run_rofi.sh launcher ----------
echo "[5/6] Creating launcher script..."
mkdir -p "${HOME}/.local/bin"

cat > "${HOME}/.local/bin/run_rofi.sh" << 'LAUNCHEREOF'
#!/usr/bin/env bash
exec rofi -show combi -modi window,run,combi -combi-modi window,run -show-icons -icon-theme Papirus
LAUNCHEREOF
chmod +x "${HOME}/.local/bin/run_rofi.sh"
echo "  ✓ Created ~/.local/bin/run_rofi.sh"
echo ""

# ---------- 6. Set GTK icon theme ----------
echo "[6/6] Setting GTK icon theme to Papirus..."
if [ -f "${HOME}/.config/gtk-3.0/settings.ini" ]; then
    sed -i 's/^gtk-icon-theme-name=.*/gtk-icon-theme-name=Papirus/' "${HOME}/.config/gtk-3.0/settings.ini"
    echo "  ✓ Updated gtk-3.0 settings"
fi
echo ""

echo "=== Setup complete! ==="
echo ""
echo "To launch rofi with icons, run:"
echo "  run_rofi.sh"
echo ""
echo "Or use the full command:"
echo "  rofi -show combi -modi window,run,combi -combi-modi window,run -show-icons -icon-theme Papirus"
echo ""
echo "To switch themes, run:"
echo "  ~/.config/rofi/rofi-theme-switcher.sh"
echo ""
echo "Available themes: catppuccin, kanagawa, tokyo-night, gruvbox-material"
echo "Quick theme switch: ~/.config/rofi/rofi-theme-switcher.sh <theme-name>"
