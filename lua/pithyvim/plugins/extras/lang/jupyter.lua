return {
  recommended = function()
    local buf = PithyVim.extras.buf
    local filename = vim.api.nvim_buf_get_name(buf)

    return vim.bo[buf].filetype == "ipynb" or filename:lower():match("%.ipynb$") ~= nil
  end,
  {
    "ajbucci/ipynb.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      "MeanderingProgrammer/render-markdown.nvim", -- optional, for markdown rendering
      "nvim-tree/nvim-web-devicons", -- optional, for language icons
      "folke/snacks.nvim", -- optional, for inline images
    },
    opts = {
      border_hints = {
        show_on_hover = false,
        show_on_edit = false,
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "ipynb" },
    opts = {
      overrides = {
        filetype = {
          ipynb = {
            anti_conceal = { enabled = false },
          },
        },
      },
    },
  },
}
