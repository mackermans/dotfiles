return {
  "dmmulroy/tsc.nvim",
  config = function()
    require("tsc").setup({
      flags = {
        build = true,
      },
    })
  end,
}
