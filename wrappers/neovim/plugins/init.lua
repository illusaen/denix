local cfgdir = nixInfo(nil, "settings", "config_directory")
local function plugin(file)
  return dofile(cfgdir .. "/plugins/" .. file .. ".lua")
end

return {
  plugin("blink.cmp"),
  plugin("cmp-cmdline"),
  plugin("colorful-menu.nvim"),
  plugin("conform.nvim"),
  plugin("fidget.nvim"),
  plugin("gitsigns.nvim"),
  plugin("lazydev.nvim"),
  plugin("lua-ls"),
  plugin("lualine.nvim"),
  plugin("mason.nvim"),
  plugin("nixd"),
  plugin("nvim-lint"),
  plugin("nvim-lspconfig"),
  plugin("nvim-surround"),
  plugin("nvim-treesitter-textobjects"),
  plugin("nvim-treesitter"),
  plugin("onedarkpro.nvim"),
  plugin("snacks.nvim"),
  plugin("trigger_colorscheme"),
  plugin("vim-startuptime"),
  plugin("which-key.nvim"),
}
