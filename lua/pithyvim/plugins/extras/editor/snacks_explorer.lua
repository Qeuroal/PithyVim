return {
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "folke/snacks.nvim",
    opts = { explorer = {} },
    keys = {
      {
        "<leader>fe",
        function()
          Snacks.explorer({ cwd = PithyVim.root() })
        end,
        desc = "Explorer Snacks (root dir)",
      },
      {
        "<leader>fE",
        function()
          Snacks.explorer()
        end,
        desc = "Explorer Snacks (cwd)",
      },
      { "<leader>E", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
      { "<leader>e", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
    },
  },
}
