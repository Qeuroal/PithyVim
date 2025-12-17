return {
  -- disable builtin snippet support
  { "garymjr/nvim-snippets", optional = true, enabled = false },

  -- add luasnip
  {
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = (not PithyVim.is_win())
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build'; make install_jsregexp"
      or nil,
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
          --{{{> Qeuroal, PithyVim 自定义片段的默认路径
          -- WARNING: 如果要使用自定义片段, 必须打开 luasnip 插件
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets/from_vscode" } })
          require("luasnip.loaders.from_snipmate").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets/from_snipmate" } })
          -- Load user custom default snippets
          require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
          -- require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
          --<}}}
        end,
      },
    },
    --{{{> Qeuroal: snippet 结束后, 不再被允许后跳
    opts = {
      history = false, -- true: 允许后跳; false 反之
      delete_check_events = "TextChanged",
      exit_roots = true, -- true: 遇到 $0, 即不允许后跳; false 反之
    },
    --<}}}
  },

  -- add snippet_forward action
  {
    "L3MON4D3/LuaSnip",
    opts = function()
      PithyVim.cmp.actions.snippet_forward = function()
        if require("luasnip").jumpable(1) then
          vim.schedule(function()
            require("luasnip").jump(1)
          end)
          return true
        end
      end
      PithyVim.cmp.actions.snippet_stop = function()
        if require("luasnip").expand_or_jumpable() then -- or just jumpable(1) is fine?
          require("luasnip").unlink_current()
          return true
        end
      end
    end,
  },

  -- nvim-cmp integration
  {
    "hrsh7th/nvim-cmp",
    optional = true,
    dependencies = { "saadparwaiz1/cmp_luasnip" },
    opts = function(_, opts)
      opts.snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      }
      table.insert(opts.sources, { name = "luasnip" })
    end,
    -- stylua: ignore
    keys = {
      { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
      --{{{> Qeuroal: backward jump issue
      -- { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
      { "<s-tab>",
        function()
          local luasnip = require("luasnip")
          if luasnip.in_snippet() and luasnip.jumpable(-1) then
            luasnip.jump(-1)
          end
        end,
        mode = { "i", "s" },
      },
      --<}}}
    },
  },

  -- blink.cmp integration
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      snippets = {
        preset = "luasnip",
      },
    },
  },
}
