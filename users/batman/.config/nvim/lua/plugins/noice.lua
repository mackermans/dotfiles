return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      hover = {
        -- Set not show a message if hover is not available
        -- ex: shift+k on Typescript code
        silent = true,
      },
    },
    messages = {
      view = "mini", -- default view for messages
      view_error = "mini", -- view for errors
      view_warn = "mini", -- view for warnings
    },
    notify = {
      view = "mini",
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  },
}
