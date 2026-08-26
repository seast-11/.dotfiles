# Export display env to systemd user session
systemctl --user import-environment DISPLAY XAUTHORITY

# Randomly pick a wallpaper from ~/Wallpapers
RANDOM_WALLPAPER=$(find ~/Wallpapers -type f | shuf -n 1)

xwallpaper --zoom "$RANDOM_WALLPAPER"

# Set wallpaper and generate colors
wal -i "$RANDOM_WALLPAPER"

# Tiny wait to ensure wal finishes writing all files
sleep 0.2

# Apply colors to Xresources 
if [[ -f "$HOME/.cache/wal/colors.xresources" ]]; then
    xrdb -merge "$HOME/.cache/wal/colors.xresources"
fi

# setup resolution
xrandr --output DP-1 --mode 5120x2160 --rate 120
xrandr --output DP-1 --set "Broadcast RGB" "Full"

# Start picom for window effects
picom --config ~/.config/picom/picom.conf &

# Start dwmblocks for status bar
dwmblocks &

# Start DWM and log errors
while true; do
    dwm 2> ~/.cache/.dwm.log
done

