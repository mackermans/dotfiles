return {
  "Wansmer/treesj",
  keys = { { "<leader>j", "<CMD>TSJToggle<CR>", desc = "Toggle Treesitter Join" } },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = { use_default_keymaps = false },
}
