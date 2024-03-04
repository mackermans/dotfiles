return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gY", ":GitBlameCopyCommitURL<cr>", desc = "Copy Git Commit URL", mode = { "n" } },
    { "<leader>gy", ":GitBlameCopyFileURL<cr>", desc = "Copy Git File URL", mode = { "n", "v" } },
  },
  config = function(_, opts)
    vim.g.gitblame_date_format = "%r"
    require("gitblame").setup(opts)
  end,
}
