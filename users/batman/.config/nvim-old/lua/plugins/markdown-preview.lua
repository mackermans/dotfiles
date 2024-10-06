return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  ft = { "markdown" },
  keys = {
    { "<leader>cp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
  },
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
}
