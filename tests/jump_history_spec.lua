describe("jump history cleanup", function()
  it("clears every window and overwrites persisted jumps without merging", function()
    local script = vim.fn.tempname() .. ".lua"
    local directory = vim.fn.tempname()
    vim.fn.mkdir(directory, "p")
    local root = vim.uv.cwd()
    local source = [=[
vim.g.mapleader = " "
local toggle = {}; function toggle:map() return self end
Snacks = { toggle = setmetatable({}, { __index = function() return function() return toggle end end }) }
PithyVim = {
  safe_keymap_set = function(mode, lhs, rhs, opts)
    if lhs == "<leader>uj" then vim.keymap.set(mode, lhs, rhs, opts) end
  end,
  format = { snacks_toggle = function() return toggle end },
}
dofile(ROOT .. "/lua/pithyvim/config/keymaps.lua")
vim.o.shada = "!,'100,<50,s10,h"
vim.o.shadafile = DIRECTORY .. "/test.shada"
local file = DIRECTORY .. "/sample.txt"
vim.fn.writefile({ "one", "two", "three" }, file)
vim.cmd.edit(file)
vim.cmd("normal! G")
assert(#vim.fn.getjumplist()[1] > 0, "missing initial jumps")
vim.fn.setreg("a", "persisted register")
vim.cmd("wshada!")
vim.cmd("tab split")
vim.cmd("vsplit")
local windows = vim.api.nvim_list_wins()
assert(#vim.api.nvim_list_tabpages() == 2 and #windows == 3)
for _, win in ipairs(windows) do
  vim.api.nvim_win_call(win, function()
    vim.cmd("normal! gg")
    vim.cmd("normal! G")
    assert(#vim.fn.getjumplist()[1] > 0, "missing window jumps")
  end)
end
vim.api.nvim_set_current_win(windows[1])
vim.fn.setreg("a", "updated register")
local notifications = {}
vim.notify = function(message, level)
  notifications[#notifications + 1] = { message = message, level = level }
end
vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Space>uj", true, false, true), "xt", false)
assert(#notifications == 1, "missing success notification")
assert(notifications[1].message == "Cleared all jumplists and overwrote ShaDa")
assert(notifications[1].level == vim.log.levels.INFO)
local function assert_empty()
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    for index, _ in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      assert(#vim.fn.getjumplist(index, vim.api.nvim_tabpage_get_number(tab))[1] == 0,
        "jump history remains")
    end
  end
end
assert_empty()
vim.fn.setreg("a", "")
vim.cmd("rshada!")
assert_empty()
assert(vim.fn.getreg("a") == "updated register", "register was not saved")
vim.o.shadafile = DIRECTORY
local ok = pcall(vim.fn.maparg(" uj", "n", false, true).callback)
assert(not ok, "expected ShaDa write failure")
assert(#notifications == 1, "success notification shown after write failure")
vim.o.shadafile = "NONE"
vim.cmd("qa!")
]=]
    source = ("local ROOT = %q\nlocal DIRECTORY = %q\n"):format(root, directory) .. source
    vim.fn.writefile(vim.split(source, "\n", { plain = true }), script)
    local result = vim
      .system({ vim.v.progpath, "-n", "-i", "NONE", "--clean", "--headless", "-l", script }, { text = true })
      :wait()
    vim.fn.delete(script)
    vim.fn.delete(directory, "rf")
    assert.are.equal(0, result.code, result.stderr)
  end)
end)
