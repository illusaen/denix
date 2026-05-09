hl.bind("ALT + SHIFT + 4", hl.dsp.exec_cmd("grimblast copysave area"), { description = "Screenshot" })
hl.bind("ALT + SHIFT + T", hl.dsp.exec_cmd("kitten quick-access-terminal"), { description = "Terminal" })
hl.bind("CTRL + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"), { description = "Launcher" })
hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("dms ipc call notepad toggle"), { description = "Notepad" })
hl.bind("SUPER + CTRL + Space", hl.dsp.exec_cmd("dms ipc call powermenu toggle"), { description = "Power Menu" })
hl.bind("CTRL + ALT + Space", hl.dsp.exec_cmd("dms ipc call clipboard toggle"), { description = "Clipboard" })
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("dms ipc call keybinds open hyprland"), { description = "Keybinds" })

hl.bind("SUPER + Q", hl.dsp.window.close(), { repeating = false })
hl.bind("SUPER + CTRL + SHIFT + Q", hl.dsp.exec_cmd("pkill -9 winedevice.exe"),
  { description = "Kill Wine", repeating = false })
hl.bind("SUPER + G", hl.dsp.exec_cmd("google-chrome-stable"), { description = "Google Chrome" })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { description = "Move Window", mouse = true })
hl.bind("SUPER + SHIFT + P", hl.dsp.dpms("off"), { description = "Power Off Monitors" })

hl.bind("SUPER + C", hl.dsp.layout("fit active"), { description = "Expand Available Width" })
hl.bind("SUPER + Left", hl.dsp.layout("focus l"), { description = "Focus Left" })
hl.bind("SUPER + Right", hl.dsp.layout("focus r"), { description = "Focus Right" })
hl.bind("SUPER + SHIFT + Left", hl.dsp.layout("swapcol l"), { description = "Swap Column Left" })
hl.bind("SUPER + SHIFT + Right", hl.dsp.layout("swapcol r"), { description = "Swap Column Right" })
hl.bind("SUPER + Z", hl.dsp.layout("colresize +conf"), { description = "Resize Preset Column Width" })

hl.bind("SUPER + Up", hl.dsp.focus({ workspace = "m-1" }), { description = "Focus Previous Workspace" })
hl.bind("SUPER + Down", hl.dsp.focus({ workspace = "m+1" }), { description = "Focus Next Workspace" })
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.move({ workspace = "m-1" }),
  { description = "Move Window to Previous Workspace" })
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.move({ workspace = "m+1" }),
  { description = "Move Window to Next Workspace" })

hl.bind("SUPER + CTRL + Up", hl.dsp.focus({ monitor = "u" }), { description = "Focus Previous Monitor" })
hl.bind("SUPER + CTRL + Down", hl.dsp.focus({ monitor = "d" }), { description = "Focus Next Monitor" })
hl.bind("SUPER + CTRL + SHIFT + Up", hl.dsp.window.move({ monitor = "u" }),
  { description = "Move Window to Previous Workspace" })
hl.bind("SUPER + CTRL + SHIFT + Down", hl.dsp.window.move({ monitor = "d" }),
  { description = "Move Window to Next Workspace" })

hl.bind("SUPER + V", hl.dsp.window.float(), { description = "Toggle Floating" })

hl.bind("XF86AudioLowerVolume",
  hl.dsp.exec_cmd("dms ipc call audio decrement 5"),
  { description = "Lower Volume", repeating = true, locked = true }
)
hl.bind("XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("dms ipc call audio increment 5"),
  { description = "Raise Volume", repeating = true, locked = true }
)
hl.bind("XF86AudioMute",
  hl.dsp.exec_cmd("dms ipc call audio mute"),
  { description = "Mute", locked = true }
)
hl.bind("XF86AudioNext",
  hl.dsp.exec_cmd("playerctl next"),
  { description = "Next Track", locked = true }
)
hl.bind("XF86AudioPrev",
  hl.dsp.exec_cmd("playerctl previous"),
  { description = "Previous Track", locked = true }
)
hl.bind("XF86AudioPlay",
  hl.dsp.exec_cmd("playerctl play-pause"),
  { description = "Play/Pause", locked = true }
)
