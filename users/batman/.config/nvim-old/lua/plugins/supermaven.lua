return {
  "nvim-cmp",
  dependencies = {
    "supermaven-inc/supermaven-nvim",
    build = ":SupermavenUseFree", -- remove this line if you are using pro
    opts = {
      disable_keymaps = true,
      disable_inline_completion = true,
    },
  },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    table.insert(opts.sources, 1, {
      name = "supermaven",
      group_index = 1,
      priority = 100,
    })

    opts.formatting.format = function(entry, item)
      local icons = LazyVim.config.icons.kinds
      if icons[item.kind] then
        item.kind = icons[item.kind] .. item.kind
      end

      if item.kind == "Supermaven" then
        item.kind = " Supermaven"
      end

      local widths = {
        abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
        menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
      }

      for key, width in pairs(widths) do
        if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
          item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
        end
      end

      return item
    end
  end,
}
