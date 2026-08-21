--{{{> Qeuroal
---@module "luassert"

describe("regressions", function()
  local function finally(run, cleanup)
    local ok, err = xpcall(run, debug.traceback)
    cleanup()
    if not ok then
      error(err)
    end
  end

  local function bracket_calls(line, column, kind)
    local cmp = package.loaded.cmp
    local feedkeys = vim.api.nvim_feedkeys
    local virtualedit = vim.o.virtualedit
    local calls = 0
    package.loaded.cmp = { lsp = { CompletionItemKind = { Function = 3, Method = 2 } } }
    vim.api.nvim_feedkeys = function()
      calls = calls + 1
    end

    finally(function()
      vim.opt.virtualedit = "onemore"
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { line })
      vim.api.nvim_win_set_cursor(0, { 1, column })
      require("pithyvim.util.cmp").auto_brackets({
        get_completion_item = function()
          return { kind = kind }
        end,
      })
    end, function()
      vim.api.nvim_feedkeys = feedkeys
      vim.o.virtualedit = virtualedit
      package.loaded.cmp = cmp
    end)
    return calls
  end

  it("adds brackets safely at the end of a line", function()
    assert.are.equal(1, bracket_calls("hello", 5, 3))
  end)

  it("does not add brackets before an opening parenthesis", function()
    assert.are.equal(0, bracket_calls("hello(", 5, 3))
  end)

  it("does not add brackets before a closing parenthesis", function()
    assert.are.equal(0, bracket_calls("hello)", 5, 3))
  end)

  it("does not add brackets for non-callable completion items", function()
    assert.are.equal(0, bracket_calls("hello", 5, 1))
  end)

  it("detects parsers already available on the runtime path", function()
    local root = vim.fs.joinpath(vim.fn.stdpath("cache"), "parser-regression")
    local parser_dir = vim.fs.joinpath(root, "parser")
    vim.fn.mkdir(parser_dir, "p")
    local parser = vim.fs.joinpath(parser_dir, "pithyvim_test.so")
    local file = assert(io.open(parser, "w"))
    file:close()

    vim.opt.runtimepath:prepend(root)
    finally(function()
      local treesitter = require("pithyvim.util.treesitter")
      assert.is_true(treesitter.have_parser("pithyvim_test"))
      assert.is_false(treesitter.have_parser("pithyvim_missing"))
    end, function()
      vim.opt.runtimepath:remove(root)
    end)
  end)

  it("reveals all concealed lines when a Snacks image is hidden", function()
    local placement = package.loaded["snacks.image.placement"]
    local Placement = {
      _render = function(_, extmarks)
        return extmarks
      end,
    }
    package.loaded["snacks.image.placement"] = Placement

    finally(function()
      _G.PithyVim = _G.PithyVim or require("pithyvim.util")
      local snacks
      for _, spec in ipairs(require("pithyvim.plugins.extras.lang.markdown")) do
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
    end, function()
      package.loaded["snacks.image.placement"] = placement
    end)
  end)

  local function markdown_treesitter_opts(executable, result, installed)
    local executable_fn = vim.fn.executable
    local system = vim.system
    local opts = { ensure_installed = vim.deepcopy(installed or {}) }

    finally(function()
      vim.fn.executable = function()
        return executable and 1 or 0
      end
      vim.system = function()
        return { wait = function() return result end }
      end

      for _, spec in ipairs(require("pithyvim.plugins.extras.lang.markdown")) do
        if spec[1] == "nvim-treesitter/nvim-treesitter" then
          spec.opts(nil, opts)
          return
        end
      end
      error("Markdown Tree-sitter spec not found")
    end, function()
      vim.fn.executable = executable_fn
      vim.system = system
    end)
    return opts.ensure_installed
  end

  it("does not request the LaTeX parser without a Tree-sitter CLI", function()
    assert.same({}, markdown_treesitter_opts(false))
  end)

  it("does not request the LaTeX parser when the Tree-sitter CLI fails", function()
    assert.same({}, markdown_treesitter_opts(true, { code = 1, stdout = "" }))
  end)

  it("does not request the LaTeX parser from an old Tree-sitter CLI", function()
    assert.same({}, markdown_treesitter_opts(true, { code = 0, stdout = "tree-sitter 0.25.10" }))
  end)

  it("requests the LaTeX parser from a supported Tree-sitter CLI", function()
    assert.same({ "latex" }, markdown_treesitter_opts(true, { code = 0, stdout = "tree-sitter 0.26.1" }))
  end)

  it("does not request the LaTeX parser twice", function()
    assert.same({ "latex" }, markdown_treesitter_opts(true, { code = 0, stdout = "tree-sitter 0.26.1" }, { "latex" }))
  end)

  local function jupyter_recommended(name, filetype)
    local buf = vim.api.nvim_create_buf(false, true)
    local previous = PithyVim.extras.buf
    vim.api.nvim_buf_set_name(buf, name)
    vim.bo[buf].filetype = filetype
    PithyVim.extras.buf = buf

    local recommended
    finally(function()
      recommended = require("pithyvim.plugins.extras.lang.jupyter").recommended()
    end, function()
      PithyVim.extras.buf = previous
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
    return recommended
  end

  it("recommends Jupyter for ipynb filenames", function()
    assert.is_true(jupyter_recommended("/tmp/notebook.ipynb", ""))
    assert.is_true(jupyter_recommended("/tmp/NOTEBOOK.IPYNB", ""))
  end)

  it("recommends Jupyter for the ipynb filetype", function()
    assert.is_true(jupyter_recommended("/tmp/notebook", "ipynb"))
  end)

  it("does not recommend Jupyter for unrelated files", function()
    assert.is_false(jupyter_recommended("/tmp/notebook.py", "python"))
    assert.is_false(jupyter_recommended("/tmp/notes.md", "markdown"))
  end)
end)
--<}}}
