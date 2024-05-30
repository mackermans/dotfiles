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
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  },
}
