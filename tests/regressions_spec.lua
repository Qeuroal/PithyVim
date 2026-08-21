--{{{> Qeuroal
---@module "luassert"

describe("regressions", function()
  it("adds brackets safely at the end of a line", function()
    local cmp = package.loaded.cmp
    package.loaded.cmp = {
      lsp = {
        CompletionItemKind = {
          Function = 3,
          Method = 2,
        },
      },
    }

    local calls = 0
    local feedkeys = vim.api.nvim_feedkeys
    local virtualedit = vim.o.virtualedit
    vim.api.nvim_feedkeys = function()
      calls = calls + 1
    end

    vim.opt.virtualedit = "onemore"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })

    require("pithyvim.util.cmp").auto_brackets({
      get_completion_item = function()
        return { kind = 3 }
      end,
    })

    vim.api.nvim_feedkeys = feedkeys
    vim.o.virtualedit = virtualedit
    package.loaded.cmp = cmp
    assert.are.equal(1, calls)
  end)

  it("detects parsers already available on the runtime path", function()
    local root = vim.fs.joinpath(vim.fn.stdpath("cache"), "parser-regression")
    local parser_dir = vim.fs.joinpath(root, "parser")
    vim.fn.mkdir(parser_dir, "p")

    local parser = vim.fs.joinpath(parser_dir, "pithyvim_test.so")
    local file = assert(io.open(parser, "w"))
    file:close()

    vim.opt.runtimepath:prepend(root)
    local treesitter = require("pithyvim.util.treesitter")
    assert.is_true(treesitter.have_parser("pithyvim_test"))
    assert.is_false(treesitter.have_parser("pithyvim_missing"))
    vim.opt.runtimepath:remove(root)
  end)

  it("reveals all concealed lines when a Snacks image is hidden", function()
    local placement = package.loaded["snacks.image.placement"]
    local Placement = {
      _render = function(_, extmarks)
        return extmarks
      end,
    }
    package.loaded["snacks.image.placement"] = Placement

    _G.PithyVim = _G.PithyVim or require("pithyvim.util")
    local specs = require("pithyvim.plugins.extras.lang.markdown")
    local snacks
    for _, spec in ipairs(specs) do
      if spec[1] == "folke/snacks.nvim" then
        snacks = spec
        break
      end
    end
    assert.is_not_nil(snacks)
    snacks.init()

    local hidden = { { conceal = "", conceal_lines = "" } }
    Placement._render({ hidden = true }, hidden)
    assert.is_nil(hidden[1].conceal_lines)

    local visible = { { conceal = "", conceal_lines = "" } }
    Placement._render({ hidden = false }, visible)
    assert.are.equal("", visible[1].conceal_lines)
    package.loaded["snacks.image.placement"] = placement
  end)
end)
--<}}}
