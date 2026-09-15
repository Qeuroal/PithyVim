return {
  recommended = function()
    return PithyVim.extras.wants({
      ft = "prisma",
    })
  end,
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "prisma" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        prismals = {},
      },
    },
  },
}
