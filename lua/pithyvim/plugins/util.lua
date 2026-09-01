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
local function refresh_snacks_images()
  if vim.b.snacks_image_attached then
    vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = 0 })
    vim.api.nvim_exec_autocmds("CursorMoved", { buffer = 0 })
  else
    vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
  end
end

local function set_snacks_image_type(kind, enabled)
  local state = Snacks.image.doc._pithyvim_state
  state[kind] = enabled
  Snacks.image.config.math.enabled = state.math
  Snacks.image.config.enabled = state.images or state.math
  if Snacks.image.config.enabled then
    Snacks.image.setup()
    refresh_snacks_images()
  else
    Snacks.image.placement.clean()
    Snacks.image.doc.hover_close()
    refresh_snacks_images()
  end
end
--<}}}

return {

  -- Snacks utils
  {
    "snacks.nvim",
    --{{{> Qeuroal: 控制 Snacks 图片与公式渲染；修正上一行误隐藏公式并暂停 Insert 模式重复渲染
    init = function()
      local Placement = require("snacks.image.placement")
      if not rawget(Placement, "_pithyvim_multiline_source") then
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
      end

      local Doc = require("snacks.image.doc")
      Doc._pithyvim_state = Doc._pithyvim_state or { images = false, math = false }

      if not rawget(Doc, "_pithyvim_filter_types") then
        rawset(Doc, "_pithyvim_filter_types", true)
        local image = Doc._img

        function Doc._img(ctx)
          local result = image(ctx)
          if result then
            local enabled
            if result.type == "math" then
              enabled = Doc._pithyvim_state.math
            else
              enabled = Doc._pithyvim_state.images
            end
            return enabled and result or nil
          end
        end
      end

      Snacks.toggle({
        name = "Snacks Images",
        get = function()
          return Doc._pithyvim_state.images
        end,
        set = function(state)
          set_snacks_image_type("images", state)
        end,
      }):map("<leader>ti")
      Snacks.toggle({
        name = "Snacks Math",
        get = function()
          return Doc._pithyvim_state.math
        end,
        set = function(state)
          set_snacks_image_type("math", state)
        end,
      }):map("<leader>tm")

      local Inline = require("snacks.image.inline")
      -- Snacks 当前把 1-based 的 `to` 直接作为 extmark 的 0-based 结束行, 导致查询额外包含下一行.
      -- 保存原方法并在运行时覆写 `Inline:get()`, 将结束行减一后再调用原实现.
      -- TODO: 更新 Snacks 后检查 `snacks/image/inline.lua`; 若上游已使用 `to - 1`, 删除此覆写.
      if not rawget(Inline, "_pithyvim_exact_line_ranges") then
        rawset(Inline, "_pithyvim_exact_line_ranges", true)
        local get = Inline.get

        function Inline:get(from, to)
          return get(self, from, to - 1)
        end
      end

      if not rawget(Inline, "_pithyvim_normal_mode_updates") then
        rawset(Inline, "_pithyvim_normal_mode_updates", true)
        local update = Inline.update

        function Inline:update()
          if Doc._pithyvim_state.math and vim.fn.mode():sub(1, 1):lower() == "i" then
            return
          end
          return update(self)
        end
      end

      vim.api.nvim_create_autocmd("InsertLeave", {
        group = vim.api.nvim_create_augroup("pithyvim_snacks_image_insert", { clear = true }),
        callback = function()
          if Doc._pithyvim_state.math then
            refresh_snacks_images()
          end
        end,
      })
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
