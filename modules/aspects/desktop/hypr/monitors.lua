hl.monitor({
  output = "desc:" .. mainMonitor,
  mode = "preferred",
  position = "0x0",
  scale = 1,
})
hl.monitor({
  output = "desc:" .. secondaryMonitor,
  mode = "preferred",
  position = "auto-center-up",
  scale = 1.25,
})
