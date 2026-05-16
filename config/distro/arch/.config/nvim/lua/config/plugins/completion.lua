require("blink.cmp").setup({
  keymap = {
    preset = "super-tab",
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    menu = {
      auto_show = true,
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  snippets = {
    preset = "default",
  },
  fuzzy = {
    implementation = "lua",
  },
})
