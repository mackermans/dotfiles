return {
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- Bash
        nls.builtins.formatting.shfmt,

        -- GitHub Actions
        nls.builtins.diagnostics.actionlint,

        -- JavaScript/TypeScript
        nls.builtins.formatting.prettier.with({
          condition = function(utils)
            return utils.root_has_file({ ".prettierrc", ".prettierrc.json", ".prettierrc.js", ".prettierrc.cjs" })
          end,
        }),

        -- Nix
        nls.builtins.code_actions.statix,
        nls.builtins.diagnostics.deadnix,
        nls.builtins.diagnostics.statix,
        nls.builtins.formatting.alejandra,
      })
    end,
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = {},
        -- automatically install missing sources configured above
        automatic_installation = true,
      })
    end,
  },
}
