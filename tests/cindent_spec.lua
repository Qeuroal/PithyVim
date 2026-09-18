describe("C indentation", function()
  it("enables only C/C++ and restores the default when filetype changes", function()
    local script = vim.fn.tempname() .. ".lua"
    local root = vim.uv.cwd()
    vim.fn.writefile({
      "vim.cmd('filetype plugin on')",
      "vim.o.cindent = false",
      ("dofile(%q)"):format(root .. "/lua/pithyvim/config/autocmds.lua"),
      "for _, ft in ipairs({ 'markdown', 'c', 'markdown', 'cpp', 'markdown.mdx', 'lua' }) do",
      "  vim.bo.filetype = ft",
      "  assert(vim.bo.cindent == (ft == 'c' or ft == 'cpp'), ft)",
      "  assert(vim.go.cindent == false, 'global cindent changed')",
      "end",
      "vim.bo.filetype = 'markdown'",
      "vim.bo.autoindent = true",
      "vim.bo.shiftwidth = 3",
      "vim.api.nvim_buf_set_lines(0, 0, -1, false, { '## `<leader>tm` 无法预览 TeX 公式' })",
      "vim.api.nvim_win_set_cursor(0, { 1, 0 })",
      "vim.cmd('normal! oX')",
      "assert(vim.fn.indent(2) == 0, 'Markdown heading adds indentation')",
      "vim.cmd('qa!')",
    }, script)
    local result = vim.system({ vim.v.progpath, "--clean", "--headless", "-l", script }, { text = true }):wait()
    vim.fn.delete(script)
    assert.are.equal(0, result.code, result.stderr)
  end)
end)
