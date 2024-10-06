local enabled_on_start = false

local function get_diagnostics_config(lsp_lines_enabled)
  if lsp_lines_enabled then
    return {
      virtual_lines = true,
      virtual_text = false,
    }
  end

  return {
    virtual_lines = false,
    virtual_text = true,
  }
end

-- Show lsp lines func
local open_diagnostics_preview = function()
  local float = vim.diagnostic.config().float

  if float then
    local config = type(float) == "table" and float or {}
    config.scope = "line"

    vim.diagnostic.open_float(config)
  end
end

return {
  -- "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
  "Maan2003/lsp_lines.nvim",
  event = "LspAttach",
  keys = {
    { "gl", open_diagnostics_preview, desc = "Open diagnostics preview" },
    {
      "<Leader>uD",
      function()
        local lsp_lines_enabled = not vim.diagnostic.config().virtual_lines
        local diagnostics_config = get_diagnostics_config(lsp_lines_enabled)
        vim.diagnostic.config(diagnostics_config)
      end,
      desc = "Toggle virtual diagnostic lines",
    },
  },
  opts = {},
  config = function()
    local diagnostics_config = get_diagnostics_config(enabled_on_start)
    vim.diagnostic.config(diagnostics_config)
    require("lsp_lines").setup()
  end,
}
