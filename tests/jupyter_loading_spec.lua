---@module "luassert"

describe("Jupyter filename loading", function()
  local function finally(run, cleanup)
    local ok, result = xpcall(run, debug.traceback)
    cleanup()
    if not ok then
      error(result)
    end
    return result
  end

  local function child_script(root, lazy_path, spec_path, scenario)
    local header = string.format(
      "local root, lazy_path, spec_path, scenario = %q, %q, %q, %q\n",
      root,
      lazy_path,
      spec_path,
      scenario
    )

    return header .. [=[
vim.o.loadplugins = true
vim.opt.rtp:prepend(lazy_path)

local spec = dofile(spec_path)[1]
-- Exercise the real spec and lazy.nvim loader without installing notebook dependencies.
spec.dir = vim.fs.joinpath(root, "plugin")
spec.name = "ipynb.nvim"
spec.dependencies = nil
spec.opts = nil

local reads = {}
spec.config = function()
  -- Match ipynb.nvim's grouped BufReadCmd contract to check first-event replay.
  vim.api.nvim_create_autocmd("BufReadCmd", {
    pattern = "*.ipynb",
    group = vim.api.nvim_create_augroup("NotebookRead", { clear = true }),
    callback = function(ev)
      reads[#reads + 1] = ev.file
      vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, { "notebook handled" })
      vim.bo[ev.buf].modified = false
    end,
  })
end

require("lazy").setup({ spec }, {
  defaults = { lazy = false },
  root = vim.fs.joinpath(root, "plugins"),
  lockfile = vim.fs.joinpath(root, "lock.json"),
  install = { missing = false },
  checker = { enabled = false },
  change_detection = { enabled = false },
  readme = { enabled = false },
  pkg = { enabled = false },
  local_spec = false,
})

local plugin = require("lazy.core.config").plugins["ipynb.nvim"]
assert(not plugin._.loaded, "Notebook plugin loaded at startup")

local function edit(name)
  local path = vim.fs.joinpath(root, name)
  vim.fn.writefile({ "{}" }, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  return path
end

for _, name in ipairs({ "plain.txt", "code.py", "data.json", "notebook.ipynb.txt" }) do
  edit(name)
  assert(not plugin._.loaded, "Notebook plugin loaded for " .. name)
end
assert(#reads == 0, "Reader handled a non-notebook")

if scenario ~= "ordinary" then
  local first = edit("first.ipynb")
  assert(plugin._.loaded, "Notebook filename did not load the plugin")
  assert(
    #reads == 1 and reads[1] == first,
    "First read must reach the reader exactly once: " .. vim.inspect(reads) .. " expected " .. first
  )
  assert(vim.api.nvim_get_current_line() == "notebook handled", "Raw JSON bypassed reader")

  if scenario == "subsequent" then
    local second = edit("second.ipynb")
    assert(#reads == 2 and reads[2] == second, "Second read must reach the reader exactly once")
    edit("after.txt")
    assert(#reads == 2, "Loaded reader intercepted a non-notebook")
  end
end

vim.cmd("qa!")
]=]
  end

  local function check_loading(scenario)
    local root = vim.fn.tempname()
    vim.fn.mkdir(vim.fs.joinpath(root, "plugin"), "p")
    root = assert(vim.uv.fs_realpath(root))
    local lazy_init = vim.api.nvim_get_runtime_file("lua/lazy/init.lua", false)[1]
    assert(lazy_init, "lazy.nvim must be available to run loading regressions")
    local lazy_path = vim.fn.fnamemodify(lazy_init, ":h:h:h")
    local spec_path = vim.fs.joinpath(vim.uv.cwd(), "lua", "pithyvim", "plugins", "extras", "lang", "jupyter.lua")
    local check_path = vim.fs.joinpath(root, "check.lua")
    vim.fn.writefile(vim.split(child_script(root, lazy_path, spec_path, scenario), "\n", { plain = true }), check_path)

    local result = finally(function()
      return vim.system({ vim.v.progpath, "--headless", "-u", "NONE", "-i", "NONE", "-n", "-l", check_path }, {
        text = true,
        env = {
          XDG_CONFIG_HOME = vim.fs.joinpath(root, "config"),
          XDG_DATA_HOME = vim.fs.joinpath(root, "data"),
          XDG_STATE_HOME = vim.fs.joinpath(root, "state"),
          XDG_CACHE_HOME = vim.fs.joinpath(root, "cache"),
          NVIM_LOG_FILE = vim.fs.joinpath(root, "nvim.log"),
        },
      }):wait(15000)
    end, function()
      vim.fn.delete(root, "rf")
    end)

    assert.are.equal(0, result.code, result.stdout .. result.stderr)
  end

  it("stays unloaded at startup and when editing non-notebook filenames", function()
    check_loading("ordinary")
  end)

  it("loads by suffix and handles the first notebook read exactly once", function()
    check_loading("first")
  end)

  it("handles subsequent notebooks without intercepting ordinary files", function()
    check_loading("subsequent")
  end)
end)
