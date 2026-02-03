return {
  recommended = function()
    return PithyVim.extras.wants({
      ft = { "tex", "plaintex", "bib" },
      root = { ".latexmkrc", ".texlabroot", "texlabroot", "Tectonic.toml" },
    })
  end,

  -- Add BibTeX/LaTeX to treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.highlight = opts.highlight or {}
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "bibtex", "latex" })
      end
      if type(opts.highlight.disable) == "table" then
        vim.list_extend(opts.highlight.disable, { "latex" })
      else
        opts.highlight.disable = { "latex" }
      end
    end,
  },

  {
    "lervag/vimtex",
    lazy = false, -- lazy-loading will disable inverse search
    --{{{> Qeuroal
    -- ft = { "tex", "plaintex", "bib", "sty" },
    init = function ()
      vim.g.vimtex_quickfix_mode = 0 -- 编译出错时自动打开 quickfix, 0, 从不; 1, 出错时; 2, 总是
      vim.g.tex_conceal = 'abdmg'
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1
      vim.g.vimtex_view_skim_activate = 0
      vim.g.vimtex_view_automatic = 0
      vim.g.vimtex_complete_enabled = 0 -- 关闭内建补全
      vim.g.vimtex_imaps_enabled = 0 -- 禁用 VimTeX 的 insert-mode mappings, 防止与 UltiSnips / LuaSnip 冲突
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 0, -- default 1
        greek = 1,
        math_bounds = 0, -- default 1
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 1, -- default 0
        styles = 1,
      }
      vim.g.vimtex_quickfix_ignore_filters = {
        -- "Command terminated with space",
        -- "LaTeX Font Warning: Font shape",
        -- "Package caption Warning: The option",
        -- [[Underfull \\hbox (badness [0-9]*) in]],
        -- "Package enumitem Warning: Negative labelwidth",
        -- [[Overfull \\hbox ([0-9]*.[0-9]*pt too wide) in]],
        -- [[Package caption Warning: Unused \\captionsetup]],
        -- "Package typearea Warning: Bad type area settings!",
        -- [[Package fancyhdr Warning: \\headheight is too small]],
        -- [[Underfull \\hbox (badness [0-9]*) in paragraph at lines]],
        -- "Package hyperref Warning: Token not allowed in a PDF string",
        -- [[Overfull \\hbox ([0-9]*.[0-9]*pt too wide) in paragraph at lines]],

        -- 'Package hyperref Warning: Option `pagebackref\'',
        -- 'Package natbib Warning: Citation',
        -- 'There were undefined citations',
      }
    end,
    --<}}}
    config = function()
      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
      vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
    end,
    keys = {
      { "<localLeader>l", "", desc = "+vimtex", ft = "tex" },
    },
  },

  -- Correctly setup lspconfig for LaTeX 🚀
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = {
      servers = {
        texlab = {
          keys = {
            { "<Leader>K", "<plug>(vimtex-doc-package)", desc = "Vimtex Docs", silent = true },
          },
        },
      },
    },
  },
}
