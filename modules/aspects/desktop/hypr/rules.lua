hl.workspace_rule({ workspace = "1", default_name = "music", monitor = "desc:" .. MainMonitor, persistent = true })
hl.workspace_rule({
  workspace = "1",
  default_name = "code",
  monitor = "desc:" .. MainMonitor,
  persistent = true,
  default = true,
  on_created_empty = "uwsm app -- google-chrome-stable"
})
hl.workspace_rule({ workspace = "2", default_name = "gaming", monitor = "desc:" .. MainMonitor, persistent = true })
hl.workspace_rule({ workspace = "3", default_name = "music", monitor = "desc:" .. SecondaryMonitor, persistent = true, default = true })

hl.window_rule({
  name = "float-opacity",
  match = { float = true },
  opacity = 0.8,
})
hl.window_rule({
  name = "float-open-save-dialog",
  match = { title = "^(.*)(o|O|s|S)(pen|ave) (f|F|a|a)(ile|s)(.*)$" },
  float = true,
  center = true
})
hl.window_rule({
  name = "float-unzip-dialog",
  match = { title = "^(Select Extract)(.*)$" },
  float = true,
  center = true
})
hl.window_rule({
  name = "float-dialog-nemo-pavu-blue",
  match = { class = "^.*(xdg\\-desktop\\-portal|nemo|blueman\\-manager|pavucontrol).*$" },
  float = true,
  center = true,
  size = { "monitor_w*0.35", "monitor_h*0.45" }
})
hl.window_rule({
  name = "workspace-mpv-music",
  match = { class = "^mpv$" },
  workspace = "name:music silent"
})
hl.window_rule({
  name = "workspace-chat",
  match = { class = "^(.*)(vesktop|discord|Element|telegram)(.*)$" },
  workspace = "name:chat silent"
})
hl.window_rule({
  name = "workspace-steam-gaming",
  match = { class = "^(.*)steam(.*)$" },
  workspace = "name:gaming silent"
})
hl.window_rule({
  name = "viking-rise",
  match = { title = "^Viking Rise Steam$" },
  size = { 5160, 2080 },
  center = true,
  float = true,
})

hl.curve("rubber", { type = "spring", mass = 1, stiffness = 70, dampening = 10 })
hl.animation({ leaf = "workspaces", enabled = true, speed = 2, spring = "rubber", style = "slidefadevert", })
hl.animation({ leaf = "windows", enabled = true, speed = 2, spring = "rubber", })
hl.animation({ leaf = "fade", enabled = true, speed = 2, spring = "rubber", })

hl.layer_rule({ match = { namespace = "kitty\\-quick\\-access" }, blur = true })
hl.layer_rule({ match = { namespace = "dms:desktop\\-widget:.*" }, blur = true })
hl.layer_rule({ match = { namespace = "dms:(dash|notification\\-center\\-popout|app\\-launcher|spotlight)" }, blur = true })
