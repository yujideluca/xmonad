            {--  IMPORTS  --}
import Data.Monoid
import Graphics.X11.ExtraTypes.XF86 --volume and brightness keys
import System.Exit
import System.IO
import XMonad
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
            {--  ACTIONS  --}
import XMonad.Actions.CycleWS --cycle through workspaces
            {--   HOOKS   --}
--import XMonad.Hooks.ManageDocks --manages dock-type programs (gnome-panel, xmobar etc.)
--import XMonad.Hooks.ManageHelpers --manage screens
--import XMonad.Hooks.DynamicLog --calls the internal states updates for status bars
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
            {--  LAYOUT   --}            
import XMonad.Layout.Gaps
import XMonad.Layout.Spacing
import XMonad.Layout.LayoutModifier
import XMonad.Layout.ThreeColumns
            {--   UTILS   --}
import XMonad.Util.CustomKeys
import XMonad.Util.EZConfig
import XMonad.Util.Run --running protocols such as runInTerm or spawnPipe
import XMonad.Util.SpawnOnce --spawnOnce command
import XMonad.Util.NamedScratchpad ------

{--VARIABLES--}
-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal           = "gnome-terminal"
-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse  = False
-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses   = True
-- Width of the window border in pixels.
--
myBorderWidth        = 2
-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
myModMask            = mod4Mask
--
-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
xmobarEscape :: String -> String
xmobarEscape = concatMap doubleLts
  where
        doubleLts '<' = "<<"
        doubleLts x   = [x]
myWorkspaces         = map xmobarEscape
    $ ["1","2","3","4","5","6","7","8","9"]
-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#404B59"
myFocusedBorderColor = "#7F6D89"

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

            {--PROGRAM COMMANDS--}
    
    [ 
    --launch rofi
    ((modm,                       xK_d), spawn "rofi -show run")

    
    --keyboard language asjustment for programming vs typing
     
    , ((modm .|. controlMask ,    xK_p), spawn "setxkbmap -model abnt2 -layout br -variant abnt2")
    , ((modm .|. controlMask ,    xK_u), spawn "setxkbmap us")


    --launch firefox
    , ((modm .|. controlMask,    xK_f), spawn "firefox")

    --launch nemo
    , ((modm .|. controlMask,    xK_n), spawn "nemo")

    --restart connection
    , ((modm .|. controlMask,    xK_q), runInTerm "" "sudo systemctl start wpa_supplicant.service")

    --launch ranger
    , ((modm .|. controlMask,    xK_r), runInTerm "--title ranger" "ranger")

    -- launch a terminal
    , ((modm,               xK_Return), spawn $ XMonad.terminal conf)

            {--SPECIAL KEYS COMMANDS--}
    --Raise volume
    , ((0,    xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +5% && amixer set Master unmute")

    --Lower volume
    , ((0,    xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -5% && amixer set Master unmute")

    --Mute Volume
    , ((0,           xF86XK_AudioMute), spawn "amixer set Master toggle")

    --Printscreen
    , ((0,                   xK_Print), spawn "scrot -q 1 ~/Pictures/prints/%Y-%m-%d-%H:%M:%S.png")

    --Raise brightness
    , ((0,     xF86XK_MonBrightnessUp), spawn "light -A 2")

    --Lower brightness
    , ((0,   xF86XK_MonBrightnessDown), spawn "light -U 2")

            {--WINDOW COMMANDS--}
    -- Move focus to the master window
    , ((modm .|. shiftMask,      xK_m), windows W.focusMaster)

    -- Resize viewed windows to the correct size
    --, ((modm,                    xK_n), refresh)

    -- close focused window
    , ((modm .|. shiftMask,      xK_q), kill)

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    ,((modm,                     xK_t), sendMessage ToggleStruts)

    -- Move focus to the next window
    , ((modm,                  xK_Tab), windows W.focusDown)

    -- Move focus to the next windowr
    , ((modm,                xK_Right), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,                    xK_Left), windows W.focusUp)

    -- Swap the focused window and the master window
    , ((modm  .|. shiftMask,   xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask,     xK_Right), windows W.swapDown)

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask,      xK_Left), windows W.swapUp)

    -- Shrink the master area (window space)
    , ((modm,                    xK_Down), sendMessage Shrink)

    -- Expand the master area (window space)
    , ((modm,                      xK_Up), sendMessage Expand)

     -- Move focus to the next windowr
     , ((modm,                      xK_l), windows W.focusDown)

     -- Move focus to the previous window
     , ((modm,                      xK_h), windows W.focusUp)

     -- Swap the focused window with the next window
     , ((modm .|. shiftMask,        xK_l), windows W.swapDown)

     -- Swap the focused window with the previous window
     , ((modm .|. shiftMask,        xK_h), windows W.swapUp)

     -- Shrink the master area (window space)
     , ((modm,                      xK_j), sendMessage Shrink)

     -- Expand the master area (window space)
     , ((modm,                      xK_k), sendMessage Expand)
    
            {--WORKSPCE COMMANDS--}

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask,  xK_space), setLayout $ XMonad.layoutHook conf)

    --moves to the next workspace
    , ((mod1Mask,               xK_Right), nextWS)

    --moves to the previous workspace
    , ((mod1Mask,                xK_Left), prevWS)

    --shifts to the next workspace
    , ((mod1Mask .|. shiftMask, xK_Right), shiftToNext)

    --shifts to the previous workspace
    , ((mod1Mask .|. shiftMask,  xK_Left), shiftToPrev)

    --moves to the next workspace
    , ((mod1Mask,               xK_l), nextWS)

    --moves to the previous workspace
    , ((mod1Mask,                xK_h), prevWS)

    --shifts to the next workspace
    , ((mod1Mask .|. shiftMask, xK_l), shiftToNext)

    --shifts to the previous workspace
    , ((mod1Mask .|. shiftMask,  xK_h), shiftToPrev)
    
            {--LAYOUT COMMANDS--}

    -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    -- Push window back into tiling
    , ((modm .|. shiftMask,     xK_space), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm,                   xK_comma), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm,                  xK_period), sendMessage (IncMasterN (-1)))


    -- Quit xmonad
    , ((modm .|. shiftMask,         xK_e), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm,                       xK_q), spawn "xmonad --recompile & xmonad --restart")

    ]
    ++
    -- modm + workspace number commands
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-Shift-r') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts(lapLayout||| Full ||| ultraLayout) 
  where

    lapSpacing = spacingRaw True             -- Only for >1 window
                            -- The bottom edge seems to look narrower than it is
                            --(Border top bottom right left)
                            (Border 7 7 7 7) -- Size of screen edge gaps
                            True             -- Enable screen edge gaps
                            (Border 3 3 3 3) -- Size of window gaps
                            True             -- Enable window gaps

    ultraSpacing = spacingRaw True             -- Only for >1 window
                            -- The bottom edge seems to look narrower than it is
                            --(Border top bottom right left)
                            (Border 14 14 14 14) -- Size of screen edge gaps
                            True             -- Enable screen edge gaps
                            (Border 5 5 5 5) -- Size of window gaps
                            True             -- Enable window gaps

    -- default tiling algorithm partitions the screen into two panes
    lapLayout   = lapSpacing $ Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100


    --three columns layout
    ultraLayout = ultraSpacing $ ThreeCol (1) (3/100) (1/3)

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore
    , isFullscreen                  --> doFullFloat]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = ewmhDesktopsEventHook

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--

------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook :: X ()
myStartupHook = do
    spawnOnce "compton &"
    spawnOnce "feh --bg-fill ~/Pictures/walls/wallpaper.jpg &"
    spawnOnce "xrandr --output eDP-1 --brightness 0.7 & redshift -O 3000"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc <- spawnPipe "xmobar -x 0 /home/yuji/.config/xmobar/xmobar.config"
    xmonad $ docks $ ewmh def
        {
          -- simple stuff
            terminal             = myTerminal
            , focusFollowsMouse  = myFocusFollowsMouse
            , clickJustFocuses   = myClickJustFocuses
            , borderWidth        = myBorderWidth
            , modMask            = myModMask
            , workspaces         = myWorkspaces
            , normalBorderColor  = myNormalBorderColor
            , focusedBorderColor = myFocusedBorderColor

          --  key bindings
            , keys               = myKeys
            , mouseBindings      = myMouseBindings

          --  hooks, layouts
            , layoutHook         = myLayout

            , manageHook         = myManageHook <+> manageDocks
            , handleEventHook    = handleEventHook def <+> fullscreenEventHook
            , logHook = dynamicLogWithPP xmobarPP
                       { ppOutput          = \x -> hPutStrLn xmproc x
                       , ppCurrent         = xmobarColor "#AC9EC4" "" . wrap "[" "]" -- Current workspace in xmobar
                       , ppVisible         = xmobarColor "#AC9EC4" ""                -- Visible but not current workspace
                       , ppHidden          = xmobarColor "#AC9EC4" "" . wrap "'" ""  -- Hidden workspaces in xmobar
                       , ppHiddenNoWindows = xmobarColor "#AC9EC4" ""                -- Hidden workspaces (no windows)
                       , ppSep             =             "<fc=#AC9EC4> | </fc>"      -- Separators in xmobar
                       , ppUrgent          = xmobarColor "#BF99B9" "" . wrap "!" "!" -- Urgent workspace
                       , ppOrder           = \(ws:_:t:_) -> [ws]
                       }
            , startupHook        = myStartupHook
        }
