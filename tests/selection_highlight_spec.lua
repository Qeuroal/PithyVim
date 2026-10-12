describe("selection highlighting", function()
  it("uses the current selection and matches literal text across selection types", function()
    local script = vim.fn.tempname() .. ".lua"
    local root = vim.uv.cwd()
    vim.fn.writefile({
      "vim.g.mapleader = ' '",
      "local toggle = {}; function toggle:map() return self end",
      "Snacks = { toggle = setmetatable({}, { __index = function() return function() return toggle end end }) }",
      "local function map(mode, lhs, rhs, opts)",
      "  if lhs == '<leader>h' or lhs == '<leader>H' then vim.keymap.set(mode, lhs, rhs, opts) end",
      "end",
      "PithyVim = { safe_keymap_set = map, format = { snacks_toggle = function() return toggle end } }",
      ("dofile(%q)"):format(root .. "/lua/pithyvim/config/keymaps.lua"),
      "local highlight = vim.fn.maparg(' h', 'x', false, true).callback",
      "local function check(lines, keys, expected, reject, exclusive)",
      "  vim.cmd('normal! ' .. string.char(27))",
      "  vim.fn.clearmatches()",
      "  vim.o.selection = exclusive and 'exclusive' or 'inclusive'",
      "  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)",
      "  vim.api.nvim_win_set_cursor(0, { 1, 0 })",
      "  vim.cmd('normal! ' .. keys)",
      "  highlight()",
      "  assert(vim.fn.mode() == 'n', 'selection remains active')",
      "  local matches = vim.fn.getmatches()",
      "  assert(#matches == 1, 'expected one highlight for ' .. keys)",
      "  local pattern = matches[1].pattern",
      "  assert(vim.fn.matchstr(expected, pattern) == expected, vim.inspect({ keys, expected, pattern }))",
      "  if reject then assert(vim.fn.match(reject, pattern) == -1, 'unexpected literal match') end",
      "end",
      "check({ 'a.b' }, 'v2l', 'a.b', 'axb')",
      "check({ 'old', '[x]\\tail' }, 'j0v$', '[x]\\tail', 'x')",
      "check({ 'abcdef' }, '3lv2h', 'bcd', 'abc')",
      "check({ '中文内容' }, 'vl', '中文', '中')",
      "check({ 'abcd' }, 'v2l', 'ab', 'ac', true)",
      "check({ 'abc', 'def' }, 'lVj', 'abc\\ndef')",
      "check({ 'abc', 'def' }, 'lvj', 'bc\\nde')",
      "check({ 'abcd', 'efgh' }, 'l' .. string.char(22) .. 'jl', 'bc\\nfg', 'bcd\\nef')",
      "vim.cmd('normal! ' .. string.char(27))",
      "vim.fn.clearmatches(); vim.api.nvim_buf_set_lines(0, 0, -1, false, { '' })",
      "vim.cmd('normal! gg0v'); highlight(); assert(#vim.fn.getmatches() == 0)",
      "assert(vim.fn.mode() == 'n', 'empty selection remains active')",
      "vim.fn.matchadd('Search', 'first'); vim.fn.matchadd('Search', 'second')",
      "vim.o.hlsearch = true; vim.fn.setreg('/', 'first'); vim.v.hlsearch = 1",
      "assert(#vim.fn.getmatches() == 2 and vim.v.hlsearch == 1)",
      "vim.fn.maparg(' H', 'n', false, true).callback()",
      "assert(#vim.fn.getmatches() == 0, 'matches remain after clearing')",
      "assert(vim.v.hlsearch == 0, 'search highlighting remains active')",
      "assert(vim.fn.getreg('/') == 'first', 'search pattern changed')",
      "vim.fn.maparg(' H', 'n', false, true).callback()",
      "vim.cmd('qa!')",
    }, script)
    local result = vim.system({ vim.v.progpath, "-n", "-i", "NONE", "--clean", "--headless", "-l", script }, { text = true }):wait()
    vim.fn.delete(script)
    assert.are.equal(0, result.code, result.stderr)
  end)
end)
