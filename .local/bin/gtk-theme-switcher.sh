#!/usr/bin/env bash
# gtk-theme-switcher.sh — install GTK themes/icons from git and switch between them
#
# Usage:
#   ./gtk-theme-switcher.sh install          # clone + build everything (run once, re-run to update)
#   ./gtk-theme-switcher.sh list             # show available presets + which is active
#   ./gtk-theme-switcher.sh use <preset>     # switch active theme
#
# Presets: arc, catppuccin-mocha, catppuccin-macchiato, catppuccin-frappe,
#          gruvbox-material, gruvbox-plus

set -euo pipefail

THEMES_DIR="$HOME/.themes"
ICONS_DIR="$HOME/.local/share/icons"
SRC_DIR="$HOME/.local/src/gtk-themes"
CONF_DIR="$HOME/.config/gtk-theme-switcher"
NAMES_FILE="$CONF_DIR/names.conf"
GTK3_INI="$HOME/.config/gtk-3.0/settings.ini"
GTK4_INI="$HOME/.config/gtk-4.0/settings.ini"

mkdir -p "$THEMES_DIR" "$ICONS_DIR" "$SRC_DIR" "$CONF_DIR" \
         "$(dirname "$GTK3_INI")" "$(dirname "$GTK4_INI")"
touch "$NAMES_FILE"

log() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }

# --- helpers for resolving whatever name an upstream installer actually used ---
snap_themes() { ls -1 "$THEMES_DIR" 2>/dev/null || true; }
snap_icons()  { ls -1 "$ICONS_DIR" 2>/dev/null || true; }
diff_new()    { comm -13 <(sort <<<"$1") <(sort <<<"$2") || true; }

record() {  # record key value  -> stores into names.conf (last write wins)
    local key="$1" val="$2"
    grep -v "^${key}=" "$NAMES_FILE" > "$NAMES_FILE.tmp" 2>/dev/null || true
    mv "$NAMES_FILE.tmp" "$NAMES_FILE"
    echo "${key}=${val}" >> "$NAMES_FILE"
}
lookup() { grep "^${1}=" "$NAMES_FILE" 2>/dev/null | tail -1 | cut -d= -f2-; }

clone() {  # clone url dir
    local url="$1" dir="$2"
    if [ -d "$dir/.git" ]; then
        git -C "$dir" pull --ff-only --quiet || true
    else
        git clone --depth=1 --quiet "$url" "$dir"
    fi
}

# ---------------------------------------------------------------------------
cmd_install() {
    log "Installing build dependencies"
    sudo pacman -S --needed --noconfirm \
        git sassc gtk-engine-murrine gnome-themes-extra \
        papirus-icon-theme papirus-folders arc-gtk-theme lxappearance

    # --- Catppuccin GTK theme (Mocha / Macchiato / Frappe), built from source ---
    log "Cloning Catppuccin-GTK-Theme"
    clone https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme.git "$SRC_DIR/catppuccin-gtk"

    for flavor in mocha macchiato frappe; do
        log "Building Catppuccin ${flavor}"
        name="Catppuccin-$(tr '[:lower:]' '[:upper:]' <<<${flavor:0:1})${flavor:1}"
        before=$(snap_themes)
        (
            cd "$SRC_DIR/catppuccin-gtk"
            if [ "$flavor" = "mocha" ]; then
                ./install.sh -d "$THEMES_DIR" -n "$name" -t blue -c dark -l
            else
                ./install.sh -d "$THEMES_DIR" -n "$name" -t blue -c dark -l --tweaks "$flavor"
            fi
        )
        after=$(snap_themes)
        resolved=$(diff_new "$before" "$after" | grep -i "^${name}" | head -1)
        record "catppuccin-${flavor}-gtk" "${resolved:-$name}"
    done

    # --- Catppuccin folder colors for Papirus ---
    log "Cloning catppuccin/papirus-folders overlay"
    clone https://github.com/catppuccin/papirus-folders.git "$SRC_DIR/catppuccin-papirus-folders"
    sudo cp -r "$SRC_DIR/catppuccin-papirus-folders/src/"* /usr/share/icons/Papirus/
    papirus-folders -C cat-mocha-blue --theme Papirus-Dark
    record "catppuccin-icons" "Papirus-Dark"

    # --- Gruvbox Material (GTK theme + matching icon set) ---
    log "Cloning gruvbox-material-gtk"
    clone https://github.com/TheGreatMcPain/gruvbox-material-gtk.git "$SRC_DIR/gruvbox-material-gtk"

    before_t=$(snap_themes); before_i=$(snap_icons)
    cp -r "$SRC_DIR/gruvbox-material-gtk/themes/"* "$THEMES_DIR/"
    cp -r "$SRC_DIR/gruvbox-material-gtk/icons/"* "$ICONS_DIR/"
    after_t=$(snap_themes); after_i=$(snap_icons)

    gm_theme=$(diff_new "$before_t" "$after_t" | grep -i dark | head -1)
    gm_icons=$(diff_new "$before_i" "$after_i" | grep -i dark | head -1)
    record "gruvbox-material-gtk" "${gm_theme:-Gruvbox-Material-Dark}"
    record "gruvbox-material-icons" "${gm_icons:-Gruvbox-Material-Dark}"

    # --- Gruvbox Plus icon pack (icons only — pairs with the GTK theme above) ---
    log "Cloning gruvbox-plus-icon-pack"
    clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git "$SRC_DIR/gruvbox-plus-icons"
    for d in "$SRC_DIR/gruvbox-plus-icons"/Gruvbox-Plus-Dark "$SRC_DIR/gruvbox-plus-icons"/Gruvbox-Plus-Light; do
        [ -d "$d" ] && cp -r "$d" "$ICONS_DIR/"
    done
    record "gruvbox-plus-icons" "Gruvbox-Plus-Dark"

    # arc-dark / papirus-dark come straight from pacman, nothing to resolve
    record "arc-gtk" "Arc-Dark"
    record "arc-icons" "Papirus-Dark"

    gtk-update-icon-cache -f "$ICONS_DIR"/* 2>/dev/null || true
    log "Done. Resolved names:"
    cat "$NAMES_FILE"
}

# ---------------------------------------------------------------------------
write_settings() {  # write_settings gtk_theme icon_theme prefer_dark(0|1)
    local gtk="$1" icon="$2" dark="$3"
    cat > "$GTK3_INI" <<EOF
[Settings]
gtk-theme-name=$gtk
gtk-icon-theme-name=$icon
gtk-application-prefer-dark-theme=$dark
gtk-cursor-theme-name=Adwaita
EOF
    cat > "$GTK4_INI" <<EOF
[Settings]
gtk-theme-name=$gtk
gtk-icon-theme-name=$icon
gtk-application-prefer-dark-theme=$dark
EOF
}

cmd_use() {
    local preset="${1:-}"
    case "$preset" in
        arc)
            write_settings "$(lookup arc-gtk)" "$(lookup arc-icons)" 1 ;;
        catppuccin-mocha)
            write_settings "$(lookup catppuccin-mocha-gtk)" "$(lookup catppuccin-icons)" 1 ;;
        catppuccin-macchiato)
            write_settings "$(lookup catppuccin-macchiato-gtk)" "$(lookup catppuccin-icons)" 1 ;;
        catppuccin-frappe)
            write_settings "$(lookup catppuccin-frappe-gtk)" "$(lookup catppuccin-icons)" 1 ;;
        gruvbox-material)
            write_settings "$(lookup gruvbox-material-gtk)" "$(lookup gruvbox-material-icons)" 1 ;;
        gruvbox-plus)
            write_settings "$(lookup gruvbox-material-gtk)" "$(lookup gruvbox-plus-icons)" 1 ;;
        *)
            echo "Unknown preset: $preset"
            echo "Run '$0 list' to see options."
            exit 1 ;;
    esac
    log "Switched to $preset — relaunch pcmanfm / GTK apps to see it (pcmanfm -q; pcmanfm &)"
}

cmd_list() {
    echo "Available presets:"
    echo "  arc                  ($(lookup arc-gtk) / $(lookup arc-icons))"
    echo "  catppuccin-mocha     ($(lookup catppuccin-mocha-gtk) / $(lookup catppuccin-icons))"
    echo "  catppuccin-macchiato ($(lookup catppuccin-macchiato-gtk) / $(lookup catppuccin-icons))"
    echo "  catppuccin-frappe    ($(lookup catppuccin-frappe-gtk) / $(lookup catppuccin-icons))"
    echo "  gruvbox-material     ($(lookup gruvbox-material-gtk) / $(lookup gruvbox-material-icons))"
    echo "  gruvbox-plus         ($(lookup gruvbox-material-gtk) / $(lookup gruvbox-plus-icons))"
    echo
    echo "Currently active (from $GTK3_INI):"
    grep -E 'gtk-theme-name|gtk-icon-theme-name' "$GTK3_INI" 2>/dev/null || echo "  (not set yet)"
}

# ---------------------------------------------------------------------------
case "${1:-}" in
    install) cmd_install ;;
    use)     cmd_use "${2:-}" ;;
    list)    cmd_list ;;
    *)
        echo "Usage: $0 {install|use <preset>|list}"
        exit 1 ;;
esac
