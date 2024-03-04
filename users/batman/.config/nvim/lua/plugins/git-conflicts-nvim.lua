return {
  {
    "akinsho/git-conflict.nvim",
    config = function()
      require("git-conflict").setup({
        debug = false,
        default_mappings = false,
        default_commands = true, -- disable commands created by this plugin
        disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
        list_opener = "copen", -- command or function to open the conflicts list
        highlights = { -- They must have background color, otherwise the default color will be used
          incoming = "DiffAdd",
          current = "DiffText",
        },
      })
    end,
    keys = {
      { "<leader>gCo", ":GitConflictChooseOurs<Enter>", desc = "Choose Ours" },
      { "<leader>gCt", ":GitConflictChooseTheirs<Enter>", desc = "Choose Theirs" },
      { "<leader>gCb", ":GitConflictChooseBoth<Enter>", desc = "Choose Both" },
      { "<leader>gCn", ":GitConflictChooseNone<Enter>", desc = "Choose None" },
      { "<leader>gCq", ":GitConflictListQf<Enter>", desc = "Add to Quickfix" },
      { "]x", ":GitConflictNextConflict<Enter>", desc = "Next git conflict" },
      { "[x", ":GitConflictPrevConflict<Enter>", desc = "Previous git conflict" },
    },
    lazy = false,
    version = "*",
  },
}
