return {
  "sindrets/diffview.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>gd",
      function()
        if next(require("diffview.lib").views) == nil then
          vim.cmd("DiffviewOpen")
        else
          vim.cmd("DiffviewClose")
        end
      end,
    },
  },
  opts = {},
}
