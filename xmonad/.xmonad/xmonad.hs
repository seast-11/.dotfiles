-- Base
import XMonad
import qualified XMonad.StackSet as W
import System.Exit (exitSuccess)

-- Utilities
import XMonad.Util.EZConfig
import XMonad.Util.Ungrab
import XMonad.Util.SpawnOnce

-- Data
import qualified Data.Map as M
import Data.Maybe (fromJust)

-- Actions
import XMonad.Actions.WithAll (sinkAll, killAll)
import XMonad.Actions.CopyWindow (kill1, killAllOtherCopies)

-- Layouts
import XMonad.Layout.ThreeColumns
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Magnifier
import XMonad.Layout.Renamed
import XMonad.Layout.ResizableTile
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Spacing
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.NoBorders
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.MultiToggle 
import XMonad.Layout.MultiToggle.Instances 
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Hooks
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.FadeInactive

-- Xmobar related modules
import XMonad.Hooks.DynamicLog
import XMonad.Util.Loggers

myTerminal :: String
myTerminal = "alacritty"

myModMask :: KeyMask
myModMask = mod4Mask       

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False 

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

myBorderWidth :: Dimension
myBorderWidth = 2          

myNormColor :: String
myNormColor   = "#d3869b"   -- gruvbox purple 

myFocusColor :: String
myFocusColor  = "#b8bb26"   -- gruvbox green

myManageHook :: ManageHook
myManageHook = composeAll
     -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
     -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
     -- I'm doing it this way because otherwise I would have to write out the full
     -- name of my workspaces and the names would be very long if using clickable workspaces.
     [ className =? "confirm"         --> doFloat
     , className =? "file_progress"   --> doFloat
     , className =? "dialog"          --> doFloat
     , className =? "download"        --> doFloat
     , className =? "error"           --> doFloat
     , className =? "Gimp"            --> doFloat
     , className =? "notification"    --> doFloat
     , className =? "pinentry-gtk-2"  --> doFloat
     , className =? "splash"          --> doFloat
     , className =? "toolbar"         --> doFloat
     , title =? "Oracle VM VirtualBox Manager"  --> doFloat
     --, title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 1 )
     --, className =? "brave-browser"   --> doShift ( myWorkspaces !! 1 )
     , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
     , isFullscreen -->  doFullFloat
     ] 

myStartup :: X ()
myStartup = do
        spawnOnce "nvidia-settings --assign CurrentMetaMode=\"nvidia-auto-select +0+0 { ForceFullCompositionPipeline = On }\" &"
        --spawnOnce "lxsession &"
        spawnOnce "nitrogen --restore &"
        spawnOnce "picom &" 
        spawnOnce "nm-applet &"
        --spawnOnce "volumeicon &"
        spawnOnce "pnmixer &"
        spawnOnce "trayer --edge top --align right --SetDockType true --SetPartialStrut true --expand true --width 5 --transparent true --tint 0x5f5f5f --height 28 &"
        setWMName "LG3d"

-- Makes setting the spacingRaw simpler to write. The spacingRaw
-- module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

myLayout =  smartBorders
            $ mkToggle (NOBORDERS ?? FULL ?? EOT)   
            $ tall ||| Mirror tall ||| magnify ||| floats ||| monocle -- ||| threeCol
  where
    threeCol    = renamed[Replace "ThreeCol"] $ magnifiercz' 1.3 $ ThreeColMid nmaster delta ratio
    magnify     = renamed [Replace "magnify"] $ magnifier $ limitWindows 12 $ mySpacing 8 $ ResizableTall nmaster delta ratio []
    monocle     = noBorders $ renamed[Replace "monocle"] $ limitWindows 20 Full
    floats      = renamed[Replace "floats"] $ limitWindows 20 simplestFloat
    tall        = renamed[Replace "Tall"] $ limitWindows 12 $ mySpacing 8 $ ResizableTall nmaster delta ratio []
    nmaster     = 1      -- Default number of windows in the master pane
    ratio       = 1/2    -- Default proportion of screen occupied by master pane
    delta       = 3/100  -- Percent of screen to increment by when resizing panes

xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]

myWorkspaces :: [String]
myWorkspaces = clickable . map xmobarEscape
               $ ["dev", "www", "mus", "vid", "gfx"]
  where
        clickable l = [ "<action=xdotool key super+" ++ show n ++ ">" ++ ws ++ "</action>" |
                      (i,ws) <- zip [1..5] l,
                      let n = i ]

myXmobarPP :: PP
myXmobarPP = def
      { ppSep             = blue " • "
      , ppTitleSanitize   = xmobarStrip
      , ppCurrent = purple . wrap (blue "[") (blue "]") 
      , ppHidden          = green . wrap " " ""
      , ppHiddenNoWindows = lowWhite . wrap " " ""
      , ppUrgent          = red . wrap (yellow "!") (yellow "!")
      , ppVisible         = purple 
      , ppTitle           = purple . shorten 50
      }
    where
      blue, lowWhite, purple, red, yellow, green :: String -> String
      purple   = xmobarColor "#d3869b" ""
      blue     = xmobarColor "#83a598" ""
      yellow   = xmobarColor "#f1fa8c" ""
      red      = xmobarColor "#fb4934" ""
      green    = xmobarColor "#8ec07c" ""
      lowWhite = xmobarColor "#ebdbb2" ""

main :: IO ()
main = xmonad
     . ewmh 
    =<< statusBar "xmobar ~/.config/xmobar/xmobarrc" myXmobarPP toggleStrutsKey myConfig
    where
      toggleStrutsKey :: XConfig Layout -> (KeyMask, KeySym)
      toggleStrutsKey XConfig{ modMask = m } = (m, xK_b)

myConfig = def
    {
      modMask               = myModMask
    , terminal              = myTerminal 
    , focusFollowsMouse     = myFocusFollowsMouse
    , clickJustFocuses      = myClickJustFocuses
    , layoutHook            = myLayout
    -- , handleEventHook       = handleEventHook def <+> fullscreenEventHook
    , startupHook           = myStartup
    , manageHook            = myManageHook
    , borderWidth           = myBorderWidth
    , normalBorderColor     = myNormColor
    , focusedBorderColor    = myFocusColor
    , workspaces            = myWorkspaces
    }
    `additionalKeysP`
      [
         -- Xmonad
          ("M-C-r", spawn "xmonad --recompile")      -- Recompiles xmonad
        , ("M-S-r", spawn "xmonad --restart")        -- Restarts xmonad
        , ("M-S-q", io exitSuccess)                  -- Quits xmonad
        , ("M-S-s", spawn "~/.local/bin/power_menu") -- Rofi shutdown prompt
        , ("M-S-l", spawn "i3lock-fancy")            -- Fancy lock screen

        -- Open my preferred terminal
        , ("M-t", spawn myTerminal)

        -- Windows
        , ("M-c", kill1)                             -- Kill the currently focused client
        , ("M-S-a", killAll)                         -- Kill all windows on current workspace

        -- Layouts
        , ("M-h", sendMessage Shrink)                       -- Shrink horiz window width
        , ("M-l", sendMessage Expand)                       -- Expand horiz window width
        , ("M-C-j", sendMessage MirrorShrink)               -- Shrink vert window width
        , ("M-C-k", sendMessage MirrorExpand)               -- Expand vert window width
        , ("M-m", sendMessage $ MT.Toggle FULL)             -- Monocle mode hotkey 

        -- Utilities
        , ("<Print>", unGrab *> spawn "flameshot gui")

        -- Applications       
        , ("M-f"  , spawn "firefox"                     )
        , ("M-y"  , spawn "firefox --private-window"                     )
        , ("M-p"  , spawn "rofi -show run")
        , ("M-e"  , spawn "pcmanfm")

        -- Floating windows
        , ("M-S-f", sendMessage (T.Toggle "floats"))     -- Toggles my 'floats' layout
        , ("M-<Delete>", withFocused $ windows . W.sink) -- Push floating window back to tile
        , ("M-S-<Delete>", sinkAll)                      -- Push ALL floating windows to tile

        -- Multimedia Keys
        , ("<XF86AudioMute>", spawn "amixer set Master toggle")
        , ("<XF86AudioLowerVolume>", spawn "amixer set Master 5%- unmute")
        , ("<XF86AudioRaiseVolume>", spawn "amixer set Master 5%+ unmute")
      ]
