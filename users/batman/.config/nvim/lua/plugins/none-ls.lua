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

        -- Golang
        nls.builtins.code_actions.gomodifytags,
        nls.builtins.code_actions.impl,
        nls.builtins.formatting.goimports,
        nls.builtins.formatting.gofumpt,

        -- JavaScript/TypeScript
        nls.builtins.formatting.biome.with({
          condition = function(utils)
            return utils.root_has_file({ "biome.json" })
          end,
        }),
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
}
