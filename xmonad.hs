--IMPORTS

import XMonad
import Data.Monoid
import System.Exit
import XMonad.Actions.CycleWS --cycle through workspaces
import XMonad.Util.SpawnOnce --spawnOnce command
import XMonad.Util.Run --running protocols such as runInTerm or spawnPipe
import XMonad.Hooks.ManageDocks --manages dock-type programs (gnome-panel, xmobar etc.)
import XMonad.Hooks.ManageHelpers --manage screens
import Graphics.X11.ExtraTypes.XF86 --volume and brightness keys
import XMonad.Util.CustomKeys
import XMonad.Util.EZConfig
import System.IO

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "gnome-terminal"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = True

-- Width of the window border in pixels.
--
myBorderWidth   = 2

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#404B59"
myFocusedBorderColor = "#7F6D89"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm,               xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_d     ), spawn  "dmenu_run")

    --launch ranger
    , ((modm .|. controlMask, xK_r   ), runInTerm "--title ranger" "ranger")

    --launch atom
    , ((modm .|. controlMask, xK_a   ), spawn "atom")

    --launch firefox
    , ((modm .|. controlMask, xK_f   ), spawn "firefox")

    --launch nemo
    , ((modm .|. controlMask, xK_n   ), spawn "nemo")

    --Raise volume
    , ((0, xF86XK_AudioRaiseVolume   ), spawn "pactl set-sink-volume 0 +5%")

    --Lower volume
    , ((0, xF86XK_AudioLowerVolume   ), spawn "pactl set-sink-volume 0 -5%")

    --Mute Volume
    , ((0, xF86XK_AudioMute          ), spawn "pactl set-sink-mute 0 toggle")

    --Raise brightness
    , ((0, xF86XK_MonBrightnessUp    ), spawn "light -A 2")

    --Lower brightness
    , ((0, xF86XK_MonBrightnessDown  ), spawn "light -U 2")

    --Printscreen
    , ((0, xK_Print                  ), spawn "scrot -q 1 ~/Pictures/prints/%Y-%m-%d-%H:%M:%S.png")

    -- close focused window
    , ((modm .|. shiftMask, xK_q     ), kill)

    -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next windowr
    , ((modm,               xK_Right ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_Left  ), windows W.focusUp)

    -- Move focus to the master window
    , ((modm .|. shiftMask, xK_m     ), windows W.focusMaster)

    -- Swap the focused window and the master window
    --, ((modm  .|. shiftMask,   xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_Right    ), windows W.swapDown)

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_Left     ), windows W.swapUp)

    --moves to the next workspace
    , ((mod1Mask           , xK_Right   ),  nextWS)

    --moves to the previous workspace
    , ((mod1Mask           , xK_Left    ),    prevWS)

    --shifts to the next workspace
    , ((mod1Mask .|. shiftMask, xK_Right),  shiftToNext)

    --shifts to the previous workspace
    , ((mod1Mask .|. shiftMask, xK_Left ),    shiftToPrev)

    -- Shrink the master area
    , ((modm              , xK_Down     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm              , xK_Up       ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm .|. shiftMask, xK_space    ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma    ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period   ), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    ,((modm               , xK_t        ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_e        ), io (exitWith ExitSuccess))

    --launch ranger
    , ((modm .|. controlMask, xK_q      ), runInTerm "" "sudo systemctl start wpa_supplicant.service")

    -- Restart xmonad
    , ((modm              , xK_q        ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    --, ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    ]
    ++

    --
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
myLayout = avoidStruts (tiled ||| Full ||| Mirror tiled)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

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
myManageHook = composeOne [isFullscreen -?>  doFullFloat]

    --composeAll
    --[ className =? "MPlayer"        --> doFloat
    --, className =? "Gimp"           --> doFloat
    --, resource  =? "desktop_window" --> doIgnore
    --, resource  =? "kdesktop"       --> doIgnore]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
myLogHook = do
    spawnOnce "compton &"
    spawnOnce "feh --bg-center ~/Pictures/walls/snow_forest.jpg &"
    spawnOnce "redshift -O 3000"


------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = return ()

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc <- spawnPipe "xmobar -x 0 /home/yuji/.config/xmobar/xmobar.config"
    xmonad $ docks defaults



-- A structure containing your configuration settings, overriding
-- fields in the default config. Any you don't override, will
-- use the defaults defined in xmonad/XMonad/Config.hs
--
-- No need to modify this.
--
defaults = def {
      -- simple stuff
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch gnome-myTerminal",
    "mod-d            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-q      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-Right          Move focus to the next window",
    "mod-Left          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-Right  Swap the focused window with the next window",
    "mod-Shift-Left  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-Up  Shrink the master area",
    "mod-Down  Expand the master area",
    "",
    "-- floating layer support",
    "mod-Shift-Space  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-Shift-R        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
