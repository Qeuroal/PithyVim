return {
  -- ansi render
  {
    'qeuroal/ansiesc.nvim',
    cmd = { "AnsiEnable" },
    config = function()
      require('ansi').setup({
        auto_enable = true,  -- Auto-enable for configured filetypes
        filetypes = { 'log', 'ansi' },  -- Filetypes to auto-enable
        theme = "catppuccin",
      })
    end
  },
}
