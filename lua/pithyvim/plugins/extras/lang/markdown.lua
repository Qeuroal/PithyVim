PithyVim.on_very_lazy(function()
  vim.filetype.add({
    extension = { mdx = "markdown.mdx" },
  })
end)

--{{{> Qeuroal
local function table_column_count()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 2
  if row < 0 then return 0 end

  local line = vim.trim(vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1])
  local count, first, last = 0, nil, nil
  for escapes, position in line:gmatch("(\\*)()|") do
    if #escapes % 2 == 0 then
      count = count + 1
      first = first or position
      last = position
    end
  end

  if count == 0 then return 0 end
  return count + 1 - (first == 1 and 1 or 0) - (last == #line and 1 or 0)
end

local function has_table_row()
  return table_column_count() > 0
end
--<}}}

return {
  recommended = function()
    return PithyVim.extras.wants({
      ft = { "markdown", "markdown.mdx" },
      root = "README.md",
    })
  end,
  --{{{> Qeuroal
  {
    "L3MON4D3/LuaSnip",
    optional = true,
    opts = function()
      local ls = require("luasnip")
      local conditions = { condition = has_table_row, show_condition = has_table_row }

      local row = ls.s({ trig = "trow", desc = "Insert a data row based on the row above" }, ls.d(1, function()
        local columns = table_column_count()
        local nodes = { ls.t("| ") }
        for col = 1, columns do
          nodes[#nodes + 1] = ls.i(col)
          nodes[#nodes + 1] = ls.t(col == columns and " |" or " | ")
        end
        return ls.sn(nil, nodes)
      end), conditions)

      local separator = ls.s({ trig = "tsep", desc = "Insert a separator based on the row above" }, ls.f(function()
        return "|" .. string.rep(" --- |", table_column_count())
      end), conditions)

      ls.add_snippets("markdown", { row, separator }, { key = "markdown-table-rows" })
    end,
  },
  --<}}}
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
