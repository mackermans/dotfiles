return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
      {
        -- remove this fork when this PR has been merged:
        -- https://github.com/rouge8/neotest-rust/pull/57
        "gollth/neotest-rust",
        branch = "param",
      },
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "pnpm jest --no-coverage --",
          -- jestConfigFile = "custom.jest.config.ts",
          -- env = { CI = true },
          cwd = function(path)
            return vim.fn.getcwd()
          end,
        },
        ["neotest-rust"] = {
          parameterized_test_discovery = "treesitter",
        },
      },
    },
  },
}
