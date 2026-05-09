hl.workspace_rule({ workspace = "name:chat", monitor = "desc:" .. mainMonitor, persistent = true })
hl.workspace_rule({
  workspace = "name:code",
  monitor = "desc:" .. mainMonitor,
  persistent = true,
  default = true,
  on_created_empty = "uwsm app -- google-chrome-stable"
})
hl.workspace_rule({ workspace = "name:gaming", monitor = "desc:" .. mainMonitor, persistent = true })
hl.workspace_rule({ workspace = "name:music", monitor = "desc:" .. secondaryMonitor, persistent = true, default = true })

hl.window_rule({
  match = { title = "^(.*)(o|O|s|S)(pen|ave) (f|F|a|a)(ile|s)(.*)$" },
  float = true,
  center = true
})
hl.window_rule({
  match = { title = "^(Select Extract)(.*)$" },
  float = true,
  center = true
})
hl.window_rule({
  match = { class = "^nemo$" },
  float = true,
  center = true,
  size = { "monitor_w * 0.35", "monitor_h * 0.3" }
})
hl.window_rule({
  match = { class = "^xdg-desktop-portal-(.+)$" },
  float = true,
  center = true,
  size = { "monitor_w * 0.35", "monitor_h * 0.3" }
})
hl.window_rule({
  match = { class = "^org.pulseaudio.pavucontrol$" },
  float = true,
  center = true,
  size = { "monitor_w * 0.35", "monitor_h * 0.3" }
})
hl.window_rule({
  match = { class = "^(.*)(blueman-manager)(.*)$" },
  float = true,
  center = true,
  size = { "monitor_w * 0.35", "monitor_h * 0.3" }
})
hl.window_rule({
  match = { class = "^(.*)steam(.*)$" },
  workspace = "name:gaming silent"
})
hl.window_rule({
  match = { class = "^(.*)(vesktop|discord|Element|telegram)(.*)$" },
  workspace = "name:chat silent"
})
