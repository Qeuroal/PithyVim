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
          layout = {
            -- preview = "main",
            layout = {
              backdrop = false,
              width = 36,
              min_width = 36,
              -- height = 0,
              position = "left",
              border = "right",
              box = "horizontal",
              {
                box = "vertical",
                {
                  win = "input",
                  height = 1,
                  -- width = 0.5,
                  border = "rounded",
                  title = "{title} {live} {flags}",
                  title_pos = "center",
                },
                {
                  win = "list",
                  border = "none",
                  -- width = 0.5,
                },
                {
                  win = "preview",
                  title = "{preview}",
                  -- width = 0.5,
                  height = 0.45,
                  max_width = 36,
                  border = "top",
                },
              },
            },
          },
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
