return {
  {
    "dcampos/nvim-snippy",
    dependencies = {
      "honza/vim-snippets",
      "hrsh7th/nvim-cmp",
    },
    ft = "snippets",
    cmd = { "SnippyEdit", "SnippyReload" },
  },
}
