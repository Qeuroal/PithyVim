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
    local doc = package.loaded["snacks.image.doc"]
    local Placement = {
      _render = function(_, extmarks)
        return extmarks
      end,
    }
    local Doc = {
      _img = function(ctx)
        return ctx.result
      end,
    }
    package.loaded["snacks.image.placement"] = Placement
    package.loaded["snacks.image.doc"] = Doc

    finally(function()
      _G.PithyVim = _G.PithyVim or require("pithyvim.util")
      local snacks
      for _, spec in ipairs(require("pithyvim.plugins.util")) do
        if spec[1] == "snacks.nvim" then
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

      local image = { type = "image" }
      local math = { type = "math" }
      assert.is_nil(Doc._img({ result = image }))
      assert.is_nil(Doc._img({ result = math }))
      Doc._pithyvim_state.images = true
      assert.are.equal(image, Doc._img({ result = image }))
      assert.is_nil(Doc._img({ result = math }))
      Doc._pithyvim_state.math = true
      assert.are.equal(math, Doc._img({ result = math }))
    end, function()
      package.loaded["snacks.image.placement"] = placement
      package.loaded["snacks.image.doc"] = doc
    end)
  end)

  it("keeps Snacks images disabled until explicitly toggled", function()
    local snacks = _G.Snacks
    local exec_autocmds = vim.api.nvim_exec_autocmds
    local attached = vim.b.snacks_image_attached
    local spec
    local mapping
    local math_mapping

    for _, candidate in ipairs(require("pithyvim.plugins.util")) do
      if candidate[1] == "snacks.nvim" then
        spec = candidate
        break
      end
    end
    assert.is_not_nil(spec)
    assert.is_false(spec.opts.image.enabled)
    for _, key in ipairs(spec.keys) do
      if key[1] == "<leader>ti" then
        mapping = key[2]
      elseif key[1] == "<leader>tm" then
        math_mapping = key[2]
      end
    end
    assert.is_not_nil(mapping)
    assert.is_not_nil(math_mapping)

    local setup_calls = 0
    local clean_calls = 0
    local hover_close_calls = 0
    local autocmd_calls = 0
    finally(function()
      _G.Snacks = {
        image = {
          config = { enabled = false, math = { enabled = false } },
          doc = {
            _pithyvim_state = { images = false, math = false },
            hover_close = function() hover_close_calls = hover_close_calls + 1 end,
          },
          setup = function() setup_calls = setup_calls + 1 end,
          placement = { clean = function() clean_calls = clean_calls + 1 end },
        },
      }
      vim.api.nvim_exec_autocmds = function() autocmd_calls = autocmd_calls + 1 end

      mapping()
      assert.is_true(Snacks.image.config.enabled)
      assert.are.equal(1, setup_calls)
      assert.are.equal(1, autocmd_calls)

      mapping()
      assert.is_false(Snacks.image.doc._pithyvim_state.images)
      assert.is_false(Snacks.image.config.enabled)
      assert.are.equal(1, clean_calls)
      assert.are.equal(1, hover_close_calls)
      assert.are.equal(2, autocmd_calls)

      math_mapping()
      assert.is_true(Snacks.image.doc._pithyvim_state.math)
      assert.is_true(Snacks.image.config.math.enabled)
      assert.is_true(Snacks.image.config.enabled)
      assert.are.equal(2, setup_calls)
      assert.are.equal(3, autocmd_calls)

      math_mapping()
      assert.is_false(Snacks.image.doc._pithyvim_state.math)
      assert.is_false(Snacks.image.config.math.enabled)
      assert.are.equal(2, clean_calls)
      assert.is_false(Snacks.image.config.enabled)
      assert.are.equal(2, hover_close_calls)
      assert.are.equal(4, autocmd_calls)
    end, function()
      _G.Snacks = snacks
      vim.api.nvim_exec_autocmds = exec_autocmds
      vim.b.snacks_image_attached = attached
    end)
  end)

  local function global_treesitter_opts(executable, result, installed)
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

      for _, spec in ipairs(require("pithyvim.plugins.treesitter")) do
        if spec[1] == "nvim-treesitter/nvim-treesitter" and type(spec.opts) == "function" then
          spec.opts(nil, opts)
          return
        end
      end
      error("Global Tree-sitter extension spec not found")
    end, function()
      vim.fn.executable = executable_fn
      vim.system = system
    end)
    return opts.ensure_installed
  end

  it("does not request the LaTeX parser without a Tree-sitter CLI", function()
    assert.same({}, global_treesitter_opts(false))
  end)

  it("does not request the LaTeX parser when the Tree-sitter CLI fails", function()
    assert.same({}, global_treesitter_opts(true, { code = 1, stdout = "" }))
  end)

  it("does not request the LaTeX parser from an old Tree-sitter CLI", function()
    assert.same({}, global_treesitter_opts(true, { code = 0, stdout = "tree-sitter 0.25.10" }))
  end)

  it("requests the LaTeX parser from a supported Tree-sitter CLI", function()
    assert.same({ "latex" }, global_treesitter_opts(true, { code = 0, stdout = "tree-sitter 0.26.1" }))
  end)

  it("does not request the LaTeX parser twice", function()
    assert.same({ "latex" }, global_treesitter_opts(true, { code = 0, stdout = "tree-sitter 0.26.1" }, { "latex" }))
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
