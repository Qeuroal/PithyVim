--{{{> Qeuroal
---@module "luassert"

local function read(path)
  local file = assert(io.open(path, "r"))
  local content = file:read("*a")
  file:close()
  return content
end

local function contains(path, values)
  local content = read(path)
  for _, value in ipairs(values) do
    assert.is_not_nil(content:find(value, 1, true), path .. " is missing: " .. value)
  end
end

describe("custom feature contracts", function()
  it("keeps custom editor defaults", function()
    contains("lua/pithyvim/config/options.lua", {
      "vim.g.autoformat = false",
      "opt.foldmarker = \"{{{>,<}}}\"",
      "opt.foldmethod = \"indent\"",
      "opt.foldenable = false",
      "opt.scrolloff = 1",
      "opt.shiftwidth = 4",
      "opt.tabstop = 4",
      "opt.softtabstop = 4",
      "opt.mouse = \"\"",
      "opt.wrap = true",
      "opt.linebreak = false",
      "opt.virtualedit = { \"block\", \"onemore\" }",
      "pcall(vim.diagnostic.enable, false)",
      "algorithm:patience",
      "indent-heuristic",
    })
  end)

  it("keeps text autocmds and case conversion commands", function()
    contains("lua/pithyvim/config/autocmds.lua", {
      "vim.opt_local.spell = false",
      "CamelToSnake",
      "SnakeToCamel",
    })
  end)

  it("keeps the custom colorscheme registry", function()
    local colors = require("pithyvim.config.colorscheme")
    assert.are.equal("catppuccin", colors.default)
    for _, name in ipairs({ "onedarkpro", "tokyonight", "everforest", "catppuccin" }) do
      assert.is_table(colors.schemes[name])
    end
    assert.are.equal("macchiato", colors.schemes.catppuccin.setup.flavour)
  end)

  it("keeps custom utility helpers", function()
    local util = require("pithyvim.util")
    assert.is_true(util.is_directory("lua"))
    assert.is_false(util.is_directory("lua/pithyvim/not-a-directory"))
    assert.is_string(util.join_paths("lua", "pithyvim"))
    assert.is_string(get_cache_dir())
  end)

  it("keeps global keymap contracts", function()
    contains("lua/pithyvim/config/keymaps.lua", {
      "<leader>ll",
      "<leader>le",
      "<leader>fy",
      "<leader>fY",
      "<leader>fC",
      "<leader>xw",
      "<leader>qw",
      "<leader>tz",
      "<leader>tc",
      "Snacks.toggle.scroll():map(\"<leader>uS\")",
    })
  end)

  it("keeps tmux and colorizer configuration", function()
    contains("lua/pithyvim/plugins/config/nvim_tmux_navigation.lua", {
      "disable_when_zoomed = true",
      "NvimTmuxNavigateLeft",
      "NvimTmuxNavigateLastActive",
      "NvimTmuxNavigateNext",
    })
    local opts = require("pithyvim.plugins.config.colorizer").opts()
    assert.is_true(opts.user_default_options.css)
    assert.is_true(opts.user_default_options.css_fn)
    assert.is_true(opts.user_default_options.always_update)
  end)

  it("keeps core UI behavior", function()
    contains("lua/pithyvim/plugins/ui.lua", {
      "sort_by = function",
      "i_ctrl_c",
      "n_ctrl_c",
      "scroll = { enabled = false }",
      "mbbill/undotree",
      "<leader>uu",
    })
    contains("lua/pithyvim/plugins/editor.lua", {
      "alexghergh/nvim-tmux-navigation",
      "NvChad/nvim-colorizer.lua",
      "<leader>j",
      "<leader>J",
      "auto_preview = false",
    })
  end)

  it("keeps colorscheme plugin behavior", function()
    contains("lua/pithyvim/plugins/colorscheme.lua", {
      "olimorris/onedarkpro.nvim",
      "neanias/everforest-nvim",
      "custom_highlights = function(colors)",
      "WinSeparator = { fg = colors.blue, bg = \"NONE\" }",
    })
  end)

  it("keeps project tooling contracts", function()
    contains("Makefile", { "l local:", "t test:", "gm gitmerge:" })
    contains("scripts/test", { "set -euo pipefail", "cd \"$root\"", "exec nvim -l tests/minit.lua" })
    contains("vim.toml", { "[selene]", "[vim]", "[describe]", "[it]" })
    contains("stylua.toml", {
      'line_endings = "Unix"',
      'quote_style = "AutoPreferDouble"',
      'call_parentheses = "None"',
    })
  end)

  it("keeps picker and explorer contracts", function()
    local contracts = {
      ["lua/pithyvim/plugins/extras/editor/fzf.lua"] = { "<leader>fF", "<leader>ff", "<leader>sD", "<leader>sd" },
      ["lua/pithyvim/plugins/extras/editor/telescope.lua"] = { "actions.move_selection_next", "actions.cycle_history_next", "<leader>sG", "<leader>sg" },
      ["lua/pithyvim/plugins/extras/editor/snacks_picker.lua"] = { "history_forward", "<C-r><C-r>", "hidden = true", "follow = false", "<leader>'" },
      ["lua/pithyvim/plugins/extras/editor/snacks_explorer.lua"] = { "diagnostics = false", "width = 36", "position = \"left\"" },
      ["lua/pithyvim/plugins/extras/editor/neo-tree.lua"] = { "width = 32", "fuzzy_finder_mappings", "file_open_requested" },
      ["lua/pithyvim/plugins/extras/editor/align.lua"] = { "align_to_char", "align_to_string", "gaw", "gaa" },
      ["lua/pithyvim/plugins/extras/coding/mini-align.lua"] = { "nvim-mini/mini.align", '"ga"', '"gA"' },
      ["lua/pithyvim/plugins/extras/editor/render.lua"] = { "qeuroal/ansiesc.nvim", "auto_enable = true", "'log'", "'ansi'" },
    }
    for path, values in pairs(contracts) do contains(path, values) end
  end)

  it("keeps completion and snippet contracts", function()
    contains("lua/pithyvim/plugins/extras/coding/blink.lua", { "['<C-j>']", "['<C-k>']", "['<C-y>']", "snippet_forward", "snippet_backward" })
    contains("lua/pithyvim/plugins/extras/coding/nvim-cmp.lua", { '["<C-j>"]', '["<C-k>"]', '["<C-n>"] = cmp.mapping.abort()', '["<C-l>"]' })
    contains("lua/pithyvim/plugins/extras/coding/luasnip.lua", { "snippets/from_vscode", "snippets/from_snipmate", "history = false", "exit_roots = true", "jumpable(-1)" })
  end)

  it("keeps AI safety and provider contracts", function()
    contains("lua/pithyvim/plugins/extras/ai/copilot.lua", { '["*"] = true', "should_attach", '"cookie"', '"%.env"', '"secret"', "vim.tbl_deep_extend" })
    contains("lua/pithyvim/plugins/extras/ai/sidekick.lua", { "completions limit reached", "require(\"sidekick.nes\").disable()", "if not notified" })
  end)

  it("keeps Markdown, Jupyter, Python, and TeX contracts", function()
    contains("lua/pithyvim/plugins/extras/lang/markdown.lua", { "tree-sitter", "0, 26, 1", "conceal_lines = nil", "force = false", "math = { enabled = true }", "latex = { enabled = false }", "min_width = 45" })
    contains("lua/pithyvim/plugins/extras/lang/jupyter.lua", { 'filetype == "ipynb"', '%.ipynb$', 'ft = { "ipynb" }', "anti_conceal = { enabled = false }" })
    contains("lua/pithyvim/plugins/extras/lang/python.lua", { 'vim.fn.executable("python")', 'vim.fn.executable("python3")' })
    contains("lua/pithyvim/plugins/extras/lang/tex.lua", { 'vim.fn.executable("latexmk")', 'vimtex_view_method = "skim"', "vimtex_complete_enabled = 0", "vimtex_imaps_enabled = 0", "vimtex_syntax_conceal" })
  end)

  it("keeps Tree-sitter, LSP, and repository contracts", function()
    contains("lua/pithyvim/util/treesitter.lua", { "function M.have_parser", "M._ts_cli_callbacks", 'p:is_installing()', 'install:success', 'install:failed' })
    contains("lua/pithyvim/plugins/treesitter.lua", { "PithyVim.treesitter.have_parser(lang)" })
    contains("lua/pithyvim/plugins/lsp/init.lua", { '"<leader>cL"', 'vim.cmd("lsp restart")' })
    contains("lua/pithyvim/plugins/init.lua", { '"Qeuroal/PithyVim"', 'branch = "dev"' })
    contains("lua/pithyvim/plugins/extras/vscode.lua", { '"Qeuroal/PithyVim"' })
  end)
end)
--<}}}
