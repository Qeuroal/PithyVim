PithyVim.on_very_lazy(function()
  vim.filetype.add({
    extension = { mdx = "markdown.mdx" },
  })
end)

return {
  recommended = function()
    return PithyVim.extras.wants({
      ft = { "markdown", "markdown.mdx" },
      root = "README.md",
    })
  end,
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!%-%- toc %-%->") then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
      formatters_by_ft = {
        ["markdown"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
        ["markdown.mdx"] = { "prettier", "markdownlint-cli2", "markdown-toc" },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "markdownlint-cli2", "markdown-toc" } },
  },
  --{{{> Qeuroal
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if vim.fn.executable("tree-sitter") ~= 1 then
        return
      end

      local output = vim.trim(vim.fn.system({ "tree-sitter", "--version" }))
      local version = vim.version.parse(output)
      if version and vim.version.ge(version, { 0, 26, 1 }) then
        opts.ensure_installed = opts.ensure_installed or {}
        if not vim.tbl_contains(opts.ensure_installed, "latex") then
          table.insert(opts.ensure_installed, "latex")
        end
      end
    end,
  },
  {
    "folke/snacks.nvim",
    opts = {
      image = {
        enabled = true,
        force = false,
        math = { enabled = true },
      },
    },
  },
  --<}}}
  {
    "nvimtools/none-ls.nvim",
    optional = true,
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.diagnostics.markdownlint_cli2,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
      },
      --{{{> Qeuroal
      linters = {
        ["markdownlint-cli2"] = {
          -- reference:
          --    https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc
          --    https://github.com/LazyVim/LazyVim/discussions/4094
          -- NOTE: ~ will not be parsed as HOME directory
          args = { "--config", vim.fn.stdpath("config") .. "/config/markdown/.markdownlint.jsonc", "--" },
        },
      },
      --<}}}
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = {},
      },
    },
  },

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<leader>cp",
        ft = "markdown",
        "<cmd>MarkdownPreviewToggle<cr>",
        desc = "Markdown Preview",
      },
    },
    config = function()
      vim.cmd([[do FileType]])
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      --{{{> Qeuroal
      latex = { enabled = false },
      --<}}}
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
        --{{{ Qeuroal
        min_width = 45,
        --}}}
      },
      heading = {
        sign = false,
        icons = {},
      },
      checkbox = {
        --{{{> Qeuroal
        enabled = true,
        render_modes = false,
        unchecked = {
          icon = '󰄱 ',
          highlight = 'RenderMarkdownUnchecked',
          scope_highlight = nil,
        },
        checked = {
          icon = '󰱒 ',
          highlight = 'RenderMarkdownChecked',
          scope_highlight = '@markup.strikethrough',
        },
        custom = {
          todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo', scope_highlight = nil },
          important = { raw = '[~]', rendered = '󰓎 ', highlight = 'DiagnosticWarn' },
        },
        --<}}}
      },
    },
    ft = { "markdown", "norg", "rmd", "org", "codecompanion" },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      Snacks.toggle({
        name = "Render Markdown",
        get = require("render-markdown").get,
        set = require("render-markdown").set,
      }):map("<leader>um")
    end,
  },
}
