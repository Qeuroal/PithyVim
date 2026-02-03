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
    lazy = true, -- lazy-loading will disable inverse search
    ft = { "tex", "plaintex", "bib", "sty" },
    --{{{> Qeuroal
    init = function ()
      vim.g.vimtex_quickfix_mode = 0
      vim.g.tex_conceal='abdmg'
      vim.g.tex_flavor='latex'
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync=1
      vim.g.vimtex_view_skim_activate=0
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 0,
        greek = 1,
        math_bounds = 0,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 1,
        styles = 1,
      }
      -- default: {'math_super_sub': 1, 'accents': 1, 'greek': 1, 'styles': 1, 'math_fracs': 1, 'math_symbols': 1, 'spacing': 1, 'ligatures': 1 , 'fancy': 1, 'sections': 0, 'math_delimiters': 1, 'math_bounds': 1, 'cites': 1}
    --<}}}
    end,
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
