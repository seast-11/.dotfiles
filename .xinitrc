# To avoid screen tearing
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }" &

# Randomly pick a wallpaper from ~/Wallpapers
RANDOM_WALLPAPER=$(find /home/sean/Wallpapers -type f | shuf -n 1)

xwallpaper --zoom "$RANDOM_WALLPAPER"

# Set wallpaper and generate colors
wal -i "$RANDOM_WALLPAPER"

# Tiny wait to ensure wal finishes writing all files
sleep 0.2

# Apply colors to Xresources 
if [[ -f "$HOME/.cache/wal/colors.xresources" ]]; then
    xrdb -merge "$HOME/.cache/wal/colors.xresources"
fi

# Start picom for window effects
picom --animations &

# Start dwmblocks for status bar
dwmblocks &

# Start DWM and log errors
while true; do
    dwm 2> ~/.cache/.dwm.log
done

