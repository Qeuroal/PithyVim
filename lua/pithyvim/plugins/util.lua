-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

--{{{> Qeuroal
local function toggle_snacks_images()
  local enabled = not Snacks.image.config.enabled
  Snacks.image.config.enabled = enabled
  if not enabled then
    Snacks.image.placement.clean()
  else
    Snacks.image.setup()
    -- Allow the current buffer to attach again after being disabled.
    vim.b.snacks_image_attached = nil
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
  end
end

local function toggle_snacks_math()
  local math = Snacks.image.config.math
  math.enabled = not math.enabled
  if Snacks.image.config.enabled then
    Snacks.image.placement.clean(0)
    vim.b.snacks_image_attached = nil
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
  end
end
--<}}}

return {

  -- Snacks utils
  {
    "snacks.nvim",
    --{{{> Qeuroal
    init = function()
      local Placement = require("snacks.image.placement")
      if rawget(Placement, "_pithyvim_multiline_source") then
        return
      end
      rawset(Placement, "_pithyvim_multiline_source", true)
      local render = Placement._render

      function Placement:_render(extmarks)
        if self.hidden then
          for _, extmark in ipairs(extmarks) do
            extmark.conceal_lines = nil
          end
        end
        return render(self, extmarks)
      end
    end,
    --<}}}
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      --{{{> Qeuroal
      image = {
        enabled = false,
        force = false,
        math = { enabled = false },
      },
      --<}}}
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
            hide_slash = { "<C-/>", "hide", desc = "Hide Terminal", mode = "t" },
            hide_underscore = { "<c-_>", "hide", desc = "which_key_ignore", mode = "t" },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
      --{{{> Qeuroal
      { "<leader>ti", toggle_snacks_images, desc = "Toggle Snacks Images" },
      { "<leader>tm", toggle_snacks_math, desc = "Toggle Snacks Math" },
      --<}}}
    },
  },

  -- Session management. This saves your session in the background,
  -- keeping track of open buffers, window arrangement, and more.
  -- You can restore sessions when returning through the dashboard.
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end,desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
}
