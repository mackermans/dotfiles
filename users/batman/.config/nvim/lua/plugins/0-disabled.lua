return {
  -- dashboard
  { "nvimdev/dashboard-nvim", enabled = false },

  -- file explorer
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },

  -- code snippets
  {
    "L3MON4D3/LuaSnip",
    enabled = false,
    keys = function()
      return {}
    end,
  },
  { "rafamadriz/friendly-snippets", enabled = false },
}
