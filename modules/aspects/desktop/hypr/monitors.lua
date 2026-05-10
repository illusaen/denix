hl.monitor({
  output = "desc:" .. MainMonitor,
  mode = "preferred",
  position = "0x0",
})
hl.monitor({
  output = "desc:" .. SecondaryMonitor,
  mode = "preferred",
  position = "auto-center-up",
  scale = 1.25,
})
