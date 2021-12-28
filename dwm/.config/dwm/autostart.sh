#! /bin/bash 
nvidia-settings --assign CurrentMetaMode="nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }" &
picom &
nitrogen --restore &
dwmblocks &
