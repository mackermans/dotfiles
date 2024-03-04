local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
    },
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local snippy = require("snippy")
      local cmp = require("cmp")

      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif snippy.can_expand_or_advance() then
            snippy.expand_or_advance()
          elseif has_words_before() then
            cmp.complete()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif snippy.can_jump(-1) then
            snippy.previous()
          else
            fallback()
          end
        end, { "i", "s" }),
      })
      opts.snippet = {
        expand = function(args)
          require("snippy").expand_snippet(args.body)
        end,
      }
    end,
  },
  -- snippets completion
  {
    "dcampos/cmp-snippy",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "dcampos/nvim-snippy",
    },
    setup = function()
      require("cmp").setup({
        snippet = {
          expand = function(args)
            require("snippy").expand_snippet(args.body)
          end,
        },
        sources = {
          { name = "snippy" },
        },
      })
    end,
  },
  -- command line completion
  {
    "hrsh7th/cmp-cmdline",
    opts = function()
      local cmp_mapping = require("cmp.config.mapping")
      local cmp_sources = require("cmp.config.sources")

      return {
        mapping = cmp_mapping.preset.cmdline(),
        sources = cmp_sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }, {
          { name = "buffer" },
        }),
      }
    end,
    config = function(_, opts)
      require("cmp").setup.cmdline(":", opts)
    end,
    dependencies = { "nvim-cmp" },
    event = { "CmdlineEnter" },
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = "copilot.lua",
    opts = {},
    config = function()
      local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
          return false
        end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
      end

      local copilot_cmp = require("copilot_cmp")
      copilot_cmp.setup({
        mapping = {
          ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if copilot_cmp.visible() and has_words_before() then
              copilot_cmp.select_next_item({ behavior = copilot_cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
        },
      })
      -- attach cmp source whenever copilot attaches
      -- fixes lazy-loading issues with the copilot cmp source
      require("lazyvim.util").lsp.on_attach(function(client)
        if client.name == "copilot" then
          copilot_cmp._on_insert_enter({})
        end
      end)
    end,
  },
}
