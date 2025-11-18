return {
  -- ansi render
  {
    '0xferrous/ansi.nvim',
    cmd = { "AnsiEnable" },
    config = function()
      require('ansi').setup({
        auto_enable = false,  -- Auto-enable for configured filetypes
        filetypes = { 'log', 'ansi' },  -- Filetypes to auto-enable
      })
    end
  },
}
