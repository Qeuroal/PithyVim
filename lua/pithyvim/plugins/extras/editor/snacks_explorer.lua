return {
  desc = "Snacks File Explorer",
  recommended = true,
  "folke/snacks.nvim",
  --{{{> Qeuroal
  opts = {
    explorer = {},
    picker = {
      sources = {
        explorer = {
          -- your explorer picker configuration comes here
          -- or leave it empty to use the default settings

          -- 关闭explorer诊断提示
          diagnostics = false,
        }
      }
    }
  },
  --<}}}
  keys = {
    {
      "<leader>fE",
      function()
        Snacks.explorer({ cwd = PithyVim.root() })
      end,
      desc = "Explorer Snacks (root dir)",
    },
    {
      "<leader>fe",
      function()
        Snacks.explorer()
      end,
      desc = "Explorer Snacks (cwd)",
    },
    { "<leader>E", "<leader>fE", desc = "Explorer Snacks (root dir)", remap = true },
    { "<leader>e", "<leader>fe", desc = "Explorer Snacks (cwd)", remap = true },
  },
}
