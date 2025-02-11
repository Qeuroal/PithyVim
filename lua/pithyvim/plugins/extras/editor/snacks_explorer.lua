return {
  desc = "Snacks File Explorer",
  recommended = true,
  "folke/snacks.nvim",
  opts = { explorer = {} },
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
