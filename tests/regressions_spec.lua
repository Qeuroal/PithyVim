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

  it("derives effective indentation widths from tabstop", function()
    local previous = vim.api.nvim_get_current_buf()
    local buf = vim.api.nvim_create_buf(false, true)

    finally(function()
      vim.api.nvim_set_current_buf(buf)
      vim.bo[buf].expandtab = true
      vim.bo[buf].tabstop = 4
      vim.bo[buf].shiftwidth = 0
      vim.bo[buf].softtabstop = -1
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "x", "" })

      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd("normal! >>")
      assert.are.equal(vim.bo[buf].tabstop, vim.fn.shiftwidth())
      assert.are.equal(vim.bo[buf].tabstop, vim.fn.indent(1))

      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      vim.cmd([[execute "normal! i\<Tab>x\<Esc>"]])
      assert.are.equal(string.rep(" ", vim.bo[buf].tabstop) .. "x", vim.api.nvim_get_current_line())
    end, function()
      vim.api.nvim_set_current_buf(previous)
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
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

  it("customizes Snacks inline rendering for formula editing", function()
    local util_plugin = package.loaded["pithyvim.plugins.util"]
    local snacks = _G.Snacks
    local placement = package.loaded["snacks.image.placement"]
    local inline = package.loaded["snacks.image.inline"]
    local doc = package.loaded["snacks.image.doc"]
    local mode = vim.fn.mode
    local Placement = {
      _render = function(_, extmarks)
        return extmarks
      end,
    }
    local get_from, get_to
    local update_calls = 0
    local Inline = {
      get = function(_, from, to)
        get_from, get_to = from, to
        return "found"
      end,
      update = function()
        update_calls = update_calls + 1
      end,
    }
    local Doc = {
      _img = function(ctx)
        return ctx.result
      end,
    }
    package.loaded["snacks.image.placement"] = Placement
    package.loaded["snacks.image.inline"] = Inline
    package.loaded["snacks.image.doc"] = Doc
    package.loaded["pithyvim.plugins.util"] = nil

    finally(function()
      _G.Snacks = {
        setup = function() end,
        toggle = function()
          return { map = function() end }
        end,
        image = {
          config = { enabled = false, math = { enabled = false } },
        },
      }
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
      local opts = vim.deepcopy(snacks.opts)
      opts.image.math.enabled = true
      snacks.config(nil, opts)

      local hidden = { { conceal = "", conceal_lines = "" } }
      Placement._render({ hidden = true }, hidden)
      assert.is_nil(hidden[1].conceal_lines)

      local visible = { { conceal = "", conceal_lines = "" } }
      Placement._render({ hidden = false }, visible)
      assert.are.equal("", visible[1].conceal_lines)

      local renderer = { buf = vim.api.nvim_get_current_buf() }
      assert.are.equal("found", Inline.get(renderer, 7, 7))
      assert.are.equal(7, get_from)
      assert.are.equal(6, get_to)

      Doc._pithyvim_state.math = true
      vim.fn.mode = function()
        return "i"
      end
      Inline.update(renderer)
      assert.are.equal(0, update_calls)

      vim.fn.mode = function()
        return "n"
      end
      Inline.update(renderer)
      assert.are.equal(1, update_calls)
      Doc._pithyvim_state.math = false

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
      _G.Snacks = snacks
      package.loaded["snacks.image.placement"] = placement
      package.loaded["snacks.image.inline"] = inline
      package.loaded["snacks.image.doc"] = doc
      package.loaded["pithyvim.plugins.util"] = util_plugin
      vim.fn.mode = mode
    end)
  end)

  it("initializes and toggles Snacks image types independently", function()
    local util_plugin = package.loaded["pithyvim.plugins.util"]
    local snacks = _G.Snacks
    local placement = package.loaded["snacks.image.placement"]
    local inline = package.loaded["snacks.image.inline"]
    local doc = package.loaded["snacks.image.doc"]
    local placement_preload = package.preload["snacks.image.placement"]
    local inline_preload = package.preload["snacks.image.inline"]
    local doc_preload = package.preload["snacks.image.doc"]
    local exec_autocmds = vim.api.nvim_exec_autocmds
    local attached = vim.b.snacks_image_attached

    local setup_calls = 0
    local clean_calls = 0
    local hover_close_calls = 0
    local autocmd_calls = 0
    local config_calls = 0
    local configured_opts
    local toggles = {}
    local Placement = {
      _render = function(_, extmarks)
        return extmarks
      end,
      clean = function()
        clean_calls = clean_calls + 1
      end,
    }
    local Inline = {
      get = function() end,
      update = function() end,
    }
    local Doc = {
      _img = function(ctx)
        return ctx.result
      end,
      hover_close = function()
        hover_close_calls = hover_close_calls + 1
      end,
    }
    package.loaded["snacks.image.placement"] = nil
    package.loaded["snacks.image.inline"] = nil
    package.loaded["snacks.image.doc"] = nil
    package.loaded["pithyvim.plugins.util"] = nil
    package.preload["snacks.image.placement"] = function()
      return Placement
    end
    package.preload["snacks.image.inline"] = function()
      return Inline
    end
    package.preload["snacks.image.doc"] = function()
      return Doc
    end

    local spec
    for _, candidate in ipairs(require("pithyvim.plugins.util")) do
      if candidate[1] == "snacks.nvim" then
        spec = candidate
        break
      end
    end
    assert.is_not_nil(spec)
    assert.is_false(spec.opts.image.enabled)

    finally(function()
      _G.Snacks = {
        setup = function(opts)
          config_calls = config_calls + 1
          configured_opts = vim.deepcopy(opts)
        end,
        toggle = function(opts)
          return {
            map = function(_, key)
              toggles[key] = opts
            end,
          }
        end,
        image = {
          config = { enabled = false, math = { enabled = false } },
          doc = Doc,
          setup = function() setup_calls = setup_calls + 1 end,
          placement = Placement,
        },
      }
      vim.api.nvim_exec_autocmds = function() autocmd_calls = autocmd_calls + 1 end

      spec.init()
      local startup_opts = vim.deepcopy(spec.opts)
      assert.is_nil(Doc._pithyvim_state)
      spec.config(nil, startup_opts)
      assert.is_nil(package.loaded["snacks.image.placement"])
      assert.is_nil(package.loaded["snacks.image.inline"])
      assert.is_nil(package.loaded["snacks.image.doc"])

      local images = toggles["<leader>ti"]
      local math = toggles["<leader>tm"]
      assert.is_not_nil(images)
      assert.is_not_nil(math)
      assert.is_false(images.get())
      assert.is_false(math.get())

      images.set(true)
      assert.are.equal(Placement, package.loaded["snacks.image.placement"])
      assert.are.equal(Inline, package.loaded["snacks.image.inline"])
      assert.are.equal(Doc, package.loaded["snacks.image.doc"])
      assert.same({ images = true, math = false }, Doc._pithyvim_state)
      setup_calls = 0
      autocmd_calls = 0

      for _, case in ipairs({
        { images = true, math = true },
        { images = true, math = false },
        { images = false, math = true },
        { images = false, math = false },
      }) do
        local opts = vim.deepcopy(spec.opts)
        opts.image.enabled = case.images
        opts.image.math.enabled = case.math
        spec.config(nil, opts)

        assert.are.equal(case.images, images.get())
        assert.are.equal(case.math, math.get())
        assert.are.equal(case.images or case.math, Snacks.image.config.enabled)
        assert.are.equal(case.math, Snacks.image.config.math.enabled)
        assert.are.equal(case.images, opts.image.enabled)
        assert.are.equal(case.images or case.math, configured_opts.image.enabled)
        assert.are.equal(case.math, configured_opts.image.math.enabled)
      end
      assert.are.equal(5, config_calls)
      assert.is_false(images.get())
      assert.is_false(math.get())

      images.set(true)
      assert.is_true(images.get())
      assert.is_true(Snacks.image.config.enabled)
      assert.are.equal(1, setup_calls)
      assert.are.equal(1, autocmd_calls)

      images.set(false)
      assert.is_false(images.get())
      assert.is_false(Snacks.image.config.enabled)
      assert.are.equal(1, clean_calls)
      assert.are.equal(1, hover_close_calls)
      assert.are.equal(2, autocmd_calls)

      math.set(true)
      assert.is_true(math.get())
      assert.is_true(Snacks.image.config.math.enabled)
      assert.is_true(Snacks.image.config.enabled)
      assert.are.equal(2, setup_calls)
      assert.are.equal(3, autocmd_calls)

      images.set(true)
      images.set(false)
      assert.is_false(images.get())
      assert.is_true(math.get())
      assert.is_true(Snacks.image.config.enabled)

      math.set(false)
      assert.is_false(math.get())
      assert.is_false(Snacks.image.config.math.enabled)
      assert.are.equal(2, clean_calls)
      assert.is_false(Snacks.image.config.enabled)
      assert.are.equal(2, hover_close_calls)
      assert.are.equal(6, autocmd_calls)
    end, function()
      _G.Snacks = snacks
      package.loaded["snacks.image.placement"] = placement
      package.loaded["snacks.image.inline"] = inline
      package.loaded["snacks.image.doc"] = doc
      package.loaded["pithyvim.plugins.util"] = util_plugin
      package.preload["snacks.image.placement"] = placement_preload
      package.preload["snacks.image.inline"] = inline_preload
      package.preload["snacks.image.doc"] = doc_preload
      vim.api.nvim_exec_autocmds = exec_autocmds
      vim.b.snacks_image_attached = attached
    end)
  end)

  local function with_snacks_image_fixture(run)
    local saved = {
      snacks = _G.Snacks,
      util_plugin = package.loaded["pithyvim.plugins.util"],
      placement = package.loaded["snacks.image.placement"],
      inline = package.loaded["snacks.image.inline"],
      doc = package.loaded["snacks.image.doc"],
      placement_preload = package.preload["snacks.image.placement"],
      inline_preload = package.preload["snacks.image.inline"],
      doc_preload = package.preload["snacks.image.doc"],
      exec_autocmds = vim.api.nvim_exec_autocmds,
    }
    local loads = { placement = 0, inline = 0, doc = 0 }
    local toggles = {}
    local configured_opts
    local Placement = {
      _render = function(_, extmarks)
        return extmarks
      end,
      clean = function() end,
    }
    local Inline = {
      get = function() end,
      update = function() end,
    }
    local Doc = {
      _img = function(ctx)
        return ctx.result
      end,
      hover_close = function() end,
    }

    package.loaded["pithyvim.plugins.util"] = nil
    package.loaded["snacks.image.placement"] = nil
    package.loaded["snacks.image.inline"] = nil
    package.loaded["snacks.image.doc"] = nil
    package.preload["snacks.image.placement"] = function()
      loads.placement = loads.placement + 1
      return Placement
    end
    package.preload["snacks.image.inline"] = function()
      loads.inline = loads.inline + 1
      return Inline
    end
    package.preload["snacks.image.doc"] = function()
      loads.doc = loads.doc + 1
      return Doc
    end
    _G.Snacks = {
      setup = function(opts)
        configured_opts = vim.deepcopy(opts)
      end,
      toggle = function(opts)
        return {
          map = function(_, key)
            toggles[key] = opts
          end,
        }
      end,
      image = {
        config = { enabled = false, math = { enabled = false } },
        setup = function() end,
      },
    }
    vim.api.nvim_exec_autocmds = function() end

    finally(function()
      local spec
      for _, candidate in ipairs(require("pithyvim.plugins.util")) do
        if candidate[1] == "snacks.nvim" then
          spec = candidate
          break
        end
      end
      assert.is_not_nil(spec)
      spec.init()
      run({
        spec = spec,
        loads = loads,
        toggles = toggles,
        doc = Doc,
        configured_opts = function()
          return configured_opts
        end,
      })
    end, function()
      _G.Snacks = saved.snacks
      package.loaded["pithyvim.plugins.util"] = saved.util_plugin
      package.loaded["snacks.image.placement"] = saved.placement
      package.loaded["snacks.image.inline"] = saved.inline
      package.loaded["snacks.image.doc"] = saved.doc
      package.preload["snacks.image.placement"] = saved.placement_preload
      package.preload["snacks.image.inline"] = saved.inline_preload
      package.preload["snacks.image.doc"] = saved.doc_preload
      vim.api.nvim_exec_autocmds = saved.exec_autocmds
    end)
  end

  it("keeps Snacks image modules unloaded when both defaults are disabled", function()
    with_snacks_image_fixture(function(ctx)
      ctx.spec.config(nil, vim.deepcopy(ctx.spec.opts))
      assert.same({ placement = 0, inline = 0, doc = 0 }, ctx.loads)
      assert.is_nil(package.loaded["snacks.image.placement"])
      assert.is_nil(package.loaded["snacks.image.inline"])
      assert.is_nil(package.loaded["snacks.image.doc"])
      assert.is_false(ctx.toggles["<leader>ti"].get())
      assert.is_false(ctx.toggles["<leader>tm"].get())
      assert.is_false(ctx.configured_opts().image.enabled)
    end)
  end)

  it("loads Snacks image modules once on the first image toggle", function()
    with_snacks_image_fixture(function(ctx)
      ctx.spec.config(nil, vim.deepcopy(ctx.spec.opts))
      ctx.toggles["<leader>ti"].set(true)
      assert.same({ placement = 1, inline = 1, doc = 1 }, ctx.loads)
      assert.same({ images = true, math = false }, ctx.doc._pithyvim_state)
      ctx.toggles["<leader>ti"].set(false)
      ctx.toggles["<leader>ti"].set(true)
      assert.same({ placement = 1, inline = 1, doc = 1 }, ctx.loads)
    end)
  end)

  it("loads Snacks image modules once on the first math toggle", function()
    with_snacks_image_fixture(function(ctx)
      ctx.spec.config(nil, vim.deepcopy(ctx.spec.opts))
      ctx.toggles["<leader>tm"].set(true)
      assert.same({ placement = 1, inline = 1, doc = 1 }, ctx.loads)
      assert.same({ images = false, math = true }, ctx.doc._pithyvim_state)
      ctx.toggles["<leader>tm"].set(false)
      ctx.toggles["<leader>tm"].set(true)
      assert.same({ placement = 1, inline = 1, doc = 1 }, ctx.loads)
    end)
  end)

  it("loads Snacks image modules when images are enabled by default", function()
    with_snacks_image_fixture(function(ctx)
      local opts = vim.deepcopy(ctx.spec.opts)
      opts.image.enabled = true
      ctx.spec.config(nil, opts)
      assert.same({ placement = 1, inline = 1, doc = 1 }, ctx.loads)
      assert.same({ images = true, math = false }, ctx.doc._pithyvim_state)
      assert.is_true(ctx.configured_opts().image.enabled)
    end)
  end)

  it("loads Snacks image modules when math is enabled by default", function()
    with_snacks_image_fixture(function(ctx)
      local opts = vim.deepcopy(ctx.spec.opts)
      opts.image.math.enabled = true
      ctx.spec.config(nil, opts)
      assert.same({ placement = 1, inline = 1, doc = 1 }, ctx.loads)
      assert.same({ images = false, math = true }, ctx.doc._pithyvim_state)
      assert.is_false(opts.image.enabled)
      assert.is_true(ctx.configured_opts().image.enabled)
      assert.is_true(ctx.configured_opts().image.math.enabled)
    end)
  end)

  it("loads Snacks image modules once when images and math are enabled by default", function()
    with_snacks_image_fixture(function(ctx)
      local opts = vim.deepcopy(ctx.spec.opts)
      opts.image.enabled = true
      opts.image.math.enabled = true
      ctx.spec.config(nil, opts)
      assert.same({ placement = 1, inline = 1, doc = 1 }, ctx.loads)
      assert.same({ images = true, math = true }, ctx.doc._pithyvim_state)
      assert.is_true(ctx.configured_opts().image.enabled)
      assert.is_true(ctx.configured_opts().image.math.enabled)
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
